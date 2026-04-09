-- lua/config/confluence.lua
--
-- Publish, pull, and comment-fetch for Confluence pages linked to local
-- markdown files via docs/confluence-page-map.md.
--
-- Commands registered by M.setup():
--   :MdToConfluence        Publish current buffer → Confluence.
--                          Aborts with a confirmation dialog if the page has
--                          been edited on Confluence since the last publish.
--   :MdFromConfluence      Pull the current Confluence page back to the local
--                          markdown file (overwrites; creates a .bak backup).
--   :MdConfluenceComments  Fetch all page comments and write them to
--                          <file>.comments.md alongside the markdown file.
--
-- All three commands are implemented in pure Lua — no shell scripts or Python
-- required.  External dependencies:
--   CONFLUENCE_EMAIL       env var  — your Atlassian account email
--   CONFLUENCE_API_TOKEN   env var  — your Atlassian API token
--   pandoc                          — markdown ↔ HTML conversion (publish + pull)
--   curl                            — REST API calls
--
-- Conflict detection:
--   The last-published Confluence version is stored in
--   docs/.confluence-state.json (relative to the git root).  On publish, if
--   the live Confluence version exceeds the stored value, someone has edited
--   the page directly and a confirmation dialog is shown.  Commit
--   .confluence-state.json so the whole team benefits.
--
-- See docs/guides/confluence.md for full setup instructions.

local M = {}

--- Find the git repository root from the given path.
local function find_git_root(dir)
  local result = vim.fn.systemlist(
    "git -C " .. vim.fn.shellescape(dir) .. " rev-parse --show-toplevel 2>/dev/null"
  )
  if vim.v.shell_error ~= 0 or #result == 0 then
    return nil
  end
  return result[1]
end

--- Parse docs/confluence-page-map.md to find the Confluence page entry for a file.
--
-- The page map is a markdown table where each data row has the form:
--   | `path/to/file.md` | Page Title | https://…atlassian.net/wiki/…/pages/ID/… | notes |
-- Paths in the map are relative to docs/ (the leading "docs/" prefix is
-- stripped before comparison).
--
-- @param page_map_path  absolute path to confluence-page-map.md
-- @param rel_path       path of the file relative to the git root (e.g. "docs/lld/x.md")
-- @return {title, url}  or nil, error_message
local function find_page_entry(page_map_path, rel_path)
  local f = io.open(page_map_path, "r")
  if not f then
    return nil, "cannot open page map: " .. page_map_path
  end

  for line in f:lines() do
    local mapped_path = line:match("|%s*`([^`]*)`%s*|")
    if mapped_path then
      -- Support entries with or without the leading "docs/" prefix.
      local norm_mapped = mapped_path:gsub("^docs/", "")
      local norm_file   = rel_path:gsub("^docs/", "")
      if norm_mapped == norm_file then
        -- Split the pipe-delimited row into trimmed columns.
        -- Because the row starts with "|", the first non-empty token is the
        -- path cell (cols[1]), followed by title (cols[2]) and URL (cols[3]).
        -- The extra "|" appended to `line` ensures gmatch captures the very
        -- last cell even when the row does not end with a trailing "|".
        local cols = {}
        for col in (line .. "|"):gmatch("[^|]+") do
          table.insert(cols, col:match("^%s*(.-)%s*$"))
        end
        local url = (cols[3] or ""):match("(https?://[^%s]+)")
        f:close()
        return { title = cols[2], url = url }
      end
    end
  end

  f:close()
  return nil, "'" .. rel_path .. "' not found in confluence-page-map.md"
end

--- Find the pandoc Lua filter.
-- Search order:
--   1. CONFLUENCE_FILTER_LUA env var
--   2. scripts/ inside the nvim config directory (~/.config/nvim/scripts/)
--   3. scripts/ in the project git root (project-local override)
local function find_filter(git_root)
  local env_filter = os.getenv("CONFLUENCE_FILTER_LUA")
  if env_filter and env_filter ~= "" and vim.fn.filereadable(env_filter) == 1 then
    return env_filter
  end
  local nvim_filter = vim.fn.stdpath("config") .. "/scripts/confluence_filter.lua"
  if vim.fn.filereadable(nvim_filter) == 1 then
    return nvim_filter
  end
  local default = git_root .. "/scripts/confluence_filter.lua"
  if vim.fn.filereadable(default) == 1 then
    return default
  end
  return nil
end

-- ── Confluence storage-format preprocessing (used by M.pull) ─────────────────
-- These functions port the logic of confluence_preproc.lua into Neovim so that
-- the pull pipeline is pure Lua with no external script dependencies.

local function html_escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

local function trim(s)
  return s:match("^%s*(.-)%s*$")
end

-- Decode a base64 string using the system `base64` command.
-- Uses io.popen (blocking, safe to call from a vim.system callback thread).
local function b64_decode_sync(b64)
  local tmp = os.tmpname()
  local f   = io.open(tmp, "w")
  if not f then return nil end
  f:write(b64)
  f:close()
  local handle = io.popen("base64 -d < " .. tmp .. " 2>/dev/null")
  local result = handle and handle:read("*a") or ""
  if handle then handle:close() end
  os.remove(tmp)
  return result ~= "" and result or nil
end

--- Pre-process Confluence storage-format HTML into plain HTML for pandoc.
-- Handles ac:structured-macro elements (code, panels, expand), CDATA sections,
-- ac:/ri: namespace tags, and PlantUML source comment recovery.
-- @param text  string — raw Confluence storage-format HTML
-- @return string — cleaned HTML ready for pandoc --from=html
local function preprocess_storage(text)
  -- PlantUML round-trip: recover source from the HTML comment stashed on publish.
  text = text:gsub(
    "<!%-%- plantuml_src_b64: ([A-Za-z0-9+/=]+) %-%->[%s]*<p><img[^>]-/></p>",
    function(b64)
      local src = b64_decode_sync(b64)
      if not src then return "" end
      return '<pre><code class="language-plantuml">' .. html_escape(src) .. "</code></pre>"
    end)

  -- Code macros — must run before the global CDATA sweep.
  text = text:gsub(
    '<ac:structured%-macro[^>]*ac:name="code"[^>]*>[%s%S]-</ac:structured%-macro>',
    function(block)
      local lang = block:match('ac:name="language"[^>]*>([^<]*)</ac:parameter>') or ""
      local body = block:match("<!%[CDATA%[([%s%S]-)%]%]>")
                or block:match("<ac:plain%-text%-body>([%s%S]-)</ac:plain%-text%-body>")
                or ""
      return '<pre><code class="language-' .. trim(lang) .. '">'
          .. html_escape(trim(body)) .. "</code></pre>"
    end)

  -- Panel macros (info / note / warning / tip).
  for _, t in ipairs({ "info", "warning", "note", "tip" }) do
    text = text:gsub(
      '<ac:structured%-macro[^>]*ac:name="' .. t .. '"[^>]*>[%s%S]-</ac:structured%-macro>',
      function(block)
        local body = block:match("<ac:rich%-text%-body>([%s%S]-)</ac:rich%-text%-body>") or ""
        return "<blockquote><p><strong>" .. t:upper() .. ":</strong></p>\n"
            .. trim(body) .. "\n</blockquote>"
      end)
  end

  -- Expand / collapsible — keep the rich-text body.
  text = text:gsub(
    '<ac:structured%-macro[^>]*ac:name="expand"[^>]*>[%s%S]-</ac:structured%-macro>',
    function(block)
      return block:match("<ac:rich%-text%-body>([%s%S]-)</ac:rich%-text%-body>") or ""
    end)

  -- Drop remaining structured macros (TOC, status, Jira, etc.).
  text = text:gsub('<ac:structured%-macro[^>]*>[%s%S]-</ac:structured%-macro>', "")

  -- Remaining CDATA sections → HTML-escaped text.
  text = text:gsub("<!%[CDATA%[([%s%S]-)%]%]>", function(c) return html_escape(c) end)

  -- Strip ac: and ri: namespace tags (keep any inner text content).
  text = text:gsub("<ac:[^>]-/>", "")
  text = text:gsub("</?ac:[^>]->", "")
  text = text:gsub("<ri:[^>]-/>", "")
  text = text:gsub("</?ri:[^>]->", "")

  return text
end

--- Convert lightweight HTML (Confluence comment body) to plain markdown.
local function html_to_md(text)
  text = text:gsub("<br%s*/?>", "\n")
  text = text:gsub("</?p[^>]*>", "\n")
  text = text:gsub("<strong[^>]*>([%s%S]-)</strong>",
    function(c) return "**" .. c .. "**" end)
  text = text:gsub("<em[^>]*>([%s%S]-)</em>",
    function(c) return "*" .. c .. "*" end)
  text = text:gsub("<code[^>]*>([%s%S]-)</code>",
    function(c) return "`" .. c .. "`" end)
  text = text:gsub('<a[^>]*href="([^"]*)"[^>]*>([%s%S]-)</a>',
    function(href, content) return "[" .. content .. "](" .. href .. ")" end)
  text = text:gsub("<[^>]+>", "")
  text = text:gsub("&amp;",  "&")
  text = text:gsub("&lt;",   "<")
  text = text:gsub("&gt;",   ">")
  text = text:gsub("&quot;", '"')
  text = text:gsub("&#39;",  "'")
  text = text:gsub("&nbsp;", " ")
  text = text:gsub("\n\n\n+", "\n\n")
  return trim(text)
end

-- e.g. https://acme.atlassian.net/wiki/spaces/TEAM/pages/123456/Title
-- returns "https://acme.atlassian.net", "123456"
local function parse_confluence_url(url)
  local base    = url:match("(https?://[^/]+)")
  local page_id = url:match("/pages/(%d+)")
  return base, page_id
end

-- ── State file helpers (conflict detection) ───────────────────────────────────

local function state_path(git_root)
  return git_root .. "/docs/.confluence-state.json"
end

--- Read the last-published Confluence version number for rel_path from the
--- state file.  Returns nil if the file doesn't exist or has no entry.
local function state_read(git_root, rel_path)
  local f = io.open(state_path(git_root), "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  if not ok or type(data) ~= "table" then return nil end
  local entry = data[rel_path]
  if type(entry) ~= "table" then return nil end
  return entry.version
end

--- Write the published version number for rel_path into the state file.
--- Called on the main thread inside a vim.schedule block.
local function state_write(git_root, rel_path, version)
  local path = state_path(git_root)
  local existing = {}
  local f = io.open(path, "r")
  if f then
    local content = f:read("*a")
    f:close()
    local ok, data = pcall(vim.json.decode, content)
    if ok and type(data) == "table" then existing = data end
  end
  existing[rel_path] = { version = version, at = os.date("!%Y-%m-%dT%H:%M:%SZ") }
  f = io.open(path, "w")
  if f then
    f:write(vim.json.encode(existing))
    f:close()
  end
end

--- Publish the current buffer to its Confluence page.
--
-- Async pipeline:
--   1. curl GET  — fetch current page version and title
--   2. Conflict check — compare against docs/.confluence-state.json
--      (prompts for confirmation if someone edited on Confluence directly)
--   3. pandoc    — convert markdown to an HTML fragment
--   4. curl PUT  — update the page with the new HTML body
--   5. state_write — record the new version in .confluence-state.json
function M.publish()
  local file     = vim.fn.expand("%:p")
  local dir      = vim.fn.expand("%:p:h")
  local filename = vim.fn.expand("%:t")
  local tmpfile  = vim.fn.tempname()

  if file == "" then
    vim.notify("Confluence: buffer has no file", vim.log.levels.WARN)
    return
  end

  if not file:match("%.md$") then
    vim.notify("Confluence: not a markdown file", vim.log.levels.WARN)
    return
  end

  local email = os.getenv("CONFLUENCE_EMAIL")
  local token = os.getenv("CONFLUENCE_API_TOKEN")
  if not email or email == "" or not token or token == "" then
    vim.notify(
      "Confluence: CONFLUENCE_EMAIL and CONFLUENCE_API_TOKEN must be set.\n"
        .. "See docs/guides/confluence.md for setup instructions.",
      vim.log.levels.ERROR
    )
    return
  end

  local git_root = find_git_root(dir)
  if not git_root then
    vim.notify("Confluence: file is not inside a git repository", vim.log.levels.ERROR)
    return
  end

  local rel_path = file:sub(#git_root + 2)

  local page_map_path = git_root .. "/docs/confluence-page-map.md"
  local entry, map_err = find_page_entry(page_map_path, rel_path)
  if not entry then
    vim.notify("Confluence: " .. (map_err or "file not in page map"), vim.log.levels.ERROR)
    return
  end

  if not entry.url then
    vim.notify(
      "Confluence: no Confluence URL found in page map for this file",
      vim.log.levels.ERROR
    )
    return
  end

  local base_url, page_id = parse_confluence_url(entry.url)
  if not base_url or not page_id then
    vim.notify("Confluence: cannot parse Confluence URL: " .. entry.url, vim.log.levels.ERROR)
    return
  end

  vim.notify("Confluence: publishing " .. filename .. "…", vim.log.levels.INFO)

  local get_url = base_url .. "/wiki/rest/api/content/" .. page_id .. "?expand=version,title"

  -- Step 1: fetch the current page version and title.
  vim.system(
    { "curl", "-s", "-w", "\n%{http_code}", "-u", email .. ":" .. token,
      "-H", "Accept: application/json", get_url },
    { text = true },
    function(get_obj)
      if get_obj.code ~= 0 then
        vim.schedule(function()
          vim.notify(
            "Confluence: GET " .. get_url .. " failed (exit " .. get_obj.code .. "): "
              .. (get_obj.stderr or ""),
            vim.log.levels.ERROR
          )
        end)
        return
      end

      local raw = get_obj.stdout or ""
      local body, http_code_str = raw:match("^(.*)\n(%d%d%d)$")
      local http_code = tonumber(http_code_str) or 0
      if http_code < 200 or http_code >= 300 then
        vim.schedule(function()
          vim.notify(
            "Confluence: GET " .. get_url .. " returned HTTP " .. http_code .. ":\n"
              .. (body or raw),
            vim.log.levels.ERROR
          )
        end)
        return
      end

      local ok, data = pcall(vim.json.decode, body or raw)
      if not ok or not (data.version and data.version.number) then
        vim.schedule(function()
          vim.notify(
            "Confluence: unexpected API response: " .. (get_obj.stdout or ""),
            vim.log.levels.ERROR
          )
        end)
        return
      end

      local version = data.version.number
      local title   = data.title or entry.title or filename

      -- Inner function: run pandoc then PUT.
      local function do_publish()
        local filter     = find_filter(git_root)
        local pandoc_cmd = { "pandoc", "--from", "markdown", "--to", "html5", "--wrap=none" }
        if filter then
          table.insert(pandoc_cmd, "--lua-filter")
          table.insert(pandoc_cmd, filter)
        end
        table.insert(pandoc_cmd, file)

        local pandoc_env = nil
        if filter then
          pandoc_env = {
            CONFLUENCE_PAGE_MAP   = page_map_path,
            CONFLUENCE_SELF_URL   = entry.url,
            CONFLUENCE_DOCS_DIR   = git_root .. "/docs",
            CONFLUENCE_FILE_PATH  = file,
            PLANTUML_SERVER       = os.getenv("PLANTUML_SERVER") or "http://localhost:8080",
          }
        end

        -- Step 3: pandoc conversion.
        vim.system(
          pandoc_cmd,
          { text = true, env = pandoc_env },
          function(pandoc_obj)
            if pandoc_obj.code ~= 0 then
              vim.schedule(function()
                vim.notify(
                  "Confluence: pandoc failed (exit " .. pandoc_obj.code .. "): "
                    .. (pandoc_obj.stderr or ""),
                  vim.log.levels.ERROR
                )
              end)
              return
            end

            local html = pandoc_obj.stdout

            local payload = vim.json.encode({
              id      = page_id,
              type    = "page",
              title   = title,
              version = { number = version + 1 },
              body    = { storage = { value = html, representation = "storage" } },
            })

            local pf = io.open(tmpfile, "w")
            if not pf then
              vim.schedule(function()
                vim.notify("Confluence: cannot write temp file " .. tmpfile, vim.log.levels.ERROR)
              end)
              return
            end
            pf:write(payload)
            pf:close()

            local put_url = base_url .. "/wiki/rest/api/content/" .. page_id

            -- Step 4: PUT the updated page.
            vim.system(
              { "curl", "-s", "-w", "\n%{http_code}", "-X", "PUT",
                "-u", email .. ":" .. token,
                "-H", "Content-Type: application/json",
                "-d", "@" .. tmpfile,
                put_url },
              { text = true },
              function(put_obj)
                os.remove(tmpfile)

                if put_obj.code ~= 0 then
                  vim.schedule(function()
                    vim.notify(
                      "Confluence: PUT " .. put_url .. " failed (exit " .. put_obj.code .. "): "
                        .. (put_obj.stderr or ""),
                      vim.log.levels.ERROR
                    )
                  end)
                  return
                end

                local raw2 = put_obj.stdout or ""
                local body2, http_code_str2 = raw2:match("^(.*)\n(%d%d%d)$")
                local http_code2 = tonumber(http_code_str2) or 0
                if http_code2 < 200 or http_code2 >= 300 then
                  vim.schedule(function()
                    vim.notify(
                      "Confluence: PUT " .. put_url .. " returned HTTP " .. http_code2 .. ":\n"
                        .. (body2 or raw2),
                      vim.log.levels.ERROR
                    )
                  end)
                  return
                end

                local ok2, resp = pcall(vim.json.decode, body2 or raw2)
                local page_url  = put_url
                if ok2 and resp._links and resp._links.base and resp._links.webui then
                  page_url = resp._links.base .. resp._links.webui
                end

                -- Step 5: record the new version.
                vim.schedule(function()
                  state_write(git_root, rel_path, version + 1)
                  vim.notify(
                    "Confluence: " .. filename .. " published successfully.\n" .. page_url,
                    vim.log.levels.INFO
                  )
                end)
              end
            )
          end
        )
      end -- do_publish

      -- Step 2: conflict check — was the page edited on Confluence after our last publish?
      local last_version = state_read(git_root, rel_path)
      if last_version and version > last_version then
        vim.schedule(function()
          vim.ui.select(
            { "Overwrite (publish anyway)", "Cancel — I'll pull first" },
            {
              prompt = string.format(
                "Confluence conflict: page is at v%d but last publish recorded v%d.\n"
                  .. "Someone may have edited the page directly on Confluence.",
                version, last_version
              ),
            },
            function(choice)
              if choice == "Overwrite (publish anyway)" then
                do_publish()
              else
                vim.notify(
                  "Confluence: publish cancelled. Use :MdFromConfluence to pull changes first.",
                  vim.log.levels.WARN
                )
              end
            end
          )
        end)
      else
        do_publish()
      end
    end
  )
end

--- Pull the current Confluence page back to the local markdown file.
--
-- Pure-Lua async pipeline:
--   1. curl GET  — fetch page version and storage-format body
--   2. preprocess_storage() — convert Confluence macros to plain HTML (Lua)
--   3. pandoc     — convert HTML → CommonMark (via stdin)
--   4. write file — backup existing → overwrite → reload buffer
--   5. state_write — record the pulled version in .confluence-state.json
function M.pull()
  local file     = vim.fn.expand("%:p")
  local dir      = vim.fn.expand("%:p:h")
  local filename = vim.fn.expand("%:t")

  if file == "" or not file:match("%.md$") then
    vim.notify("Confluence: not a markdown file", vim.log.levels.WARN)
    return
  end

  local email = os.getenv("CONFLUENCE_EMAIL")
  local token = os.getenv("CONFLUENCE_API_TOKEN")
  if not email or email == "" or not token or token == "" then
    vim.notify(
      "Confluence: CONFLUENCE_EMAIL and CONFLUENCE_API_TOKEN must be set.\n"
        .. "See docs/guides/confluence.md for setup instructions.",
      vim.log.levels.ERROR
    )
    return
  end

  local git_root = find_git_root(dir)
  if not git_root then
    vim.notify("Confluence: file is not inside a git repository", vim.log.levels.ERROR)
    return
  end

  local rel_path      = file:sub(#git_root + 2)
  local page_map_path = git_root .. "/docs/confluence-page-map.md"
  local entry, map_err = find_page_entry(page_map_path, rel_path)
  if not entry then
    vim.notify("Confluence: " .. (map_err or "file not in page map"), vim.log.levels.ERROR)
    return
  end
  if not entry.url then
    vim.notify("Confluence: no Confluence URL found in page map for this file", vim.log.levels.ERROR)
    return
  end

  local base_url, page_id = parse_confluence_url(entry.url)
  if not base_url or not page_id then
    vim.notify("Confluence: cannot parse Confluence URL: " .. entry.url, vim.log.levels.ERROR)
    return
  end

  vim.notify("Confluence: pulling " .. filename .. "…", vim.log.levels.INFO)

  local get_url = base_url
    .. "/wiki/rest/api/content/" .. page_id
    .. "?expand=version,body.storage"

  -- Step 1: fetch current version and storage body.
  vim.system(
    { "curl", "-s", "-w", "\n%{http_code}", "-u", email .. ":" .. token,
      "-H", "Accept: application/json", get_url },
    { text = true },
    function(get_obj)
      if get_obj.code ~= 0 then
        vim.schedule(function()
          vim.notify(
            "Confluence: GET " .. get_url .. " failed (exit " .. get_obj.code .. "): "
              .. (get_obj.stderr or ""),
            vim.log.levels.ERROR
          )
        end)
        return
      end

      local raw = get_obj.stdout or ""
      local body_str, http_code_str = raw:match("^(.*)\n(%d%d%d)$")
      local http_code = tonumber(http_code_str) or 0
      if http_code < 200 or http_code >= 300 then
        vim.schedule(function()
          vim.notify(
            "Confluence: GET " .. get_url .. " returned HTTP " .. http_code .. ":\n"
              .. (body_str or raw),
            vim.log.levels.ERROR
          )
        end)
        return
      end

      local ok, data = pcall(vim.json.decode, body_str or raw)
      if not ok or not (data.version and data.body and data.body.storage) then
        vim.schedule(function()
          vim.notify(
            "Confluence: unexpected GET response for " .. filename,
            vim.log.levels.ERROR
          )
        end)
        return
      end

      local version      = data.version.number
      local storage_html = data.body.storage.value or ""

      -- Step 2: pre-process Confluence storage format → plain HTML (synchronous Lua).
      local clean_html = preprocess_storage(storage_html)

      -- Step 3: pandoc converts plain HTML → CommonMark (stdin → stdout).
      vim.system(
        { "pandoc", "--from=html", "--to=commonmark", "--wrap=none" },
        { text = true, stdin = clean_html },
        function(pandoc_obj)
          if pandoc_obj.code ~= 0 then
            vim.schedule(function()
              vim.notify(
                "Confluence: pandoc failed (exit " .. pandoc_obj.code .. "): "
                  .. (pandoc_obj.stderr or ""),
                vim.log.levels.ERROR
              )
            end)
            return
          end

          local md_content = pandoc_obj.stdout or ""

          -- Step 4: backup, write, reload — on the main thread.
          vim.schedule(function()
            -- Backup existing file.
            local bak   = file .. ".bak"
            local src_f = io.open(file, "r")
            if src_f then
              local old = src_f:read("*a")
              src_f:close()
              local dst_f = io.open(bak, "w")
              if dst_f then
                dst_f:write(old)
                dst_f:close()
              end
            end

            -- Write new content.
            local out = io.open(file, "w")
            if not out then
              vim.notify("Confluence: cannot write to " .. file, vim.log.levels.ERROR)
              return
            end
            out:write(md_content)
            out:close()

            -- Step 5: record pulled version and reload.
            state_write(git_root, rel_path, version)
            vim.cmd("e!")
            vim.notify(
              "Confluence: " .. filename .. " updated from Confluence (v" .. version .. ").\n"
                .. "Original backed up as " .. filename .. ".bak",
              vim.log.levels.INFO
            )
          end)
        end
      )
    end
  )
end

--- Fetch all comments for the current page and write them to <file>.comments.md.
--
-- Pure-Lua async pipeline:
--   1. curl GET — fetch all comments (body.view, version, history)
--   2. html_to_md() — strip HTML from comment bodies (Lua)
--   3. write <file>.comments.md
function M.fetch_comments()
  local file     = vim.fn.expand("%:p")
  local dir      = vim.fn.expand("%:p:h")
  local filename = vim.fn.expand("%:t")

  if file == "" or not file:match("%.md$") then
    vim.notify("Confluence: not a markdown file", vim.log.levels.WARN)
    return
  end

  local email = os.getenv("CONFLUENCE_EMAIL")
  local token = os.getenv("CONFLUENCE_API_TOKEN")
  if not email or email == "" or not token or token == "" then
    vim.notify(
      "Confluence: CONFLUENCE_EMAIL and CONFLUENCE_API_TOKEN must be set.\n"
        .. "See docs/guides/confluence.md for setup instructions.",
      vim.log.levels.ERROR
    )
    return
  end

  local git_root = find_git_root(dir)
  if not git_root then
    vim.notify("Confluence: file is not inside a git repository", vim.log.levels.ERROR)
    return
  end

  local rel_path      = file:sub(#git_root + 2)
  local page_map_path = git_root .. "/docs/confluence-page-map.md"
  local entry, map_err = find_page_entry(page_map_path, rel_path)
  if not entry then
    vim.notify("Confluence: " .. (map_err or "file not in page map"), vim.log.levels.ERROR)
    return
  end
  if not entry.url then
    vim.notify("Confluence: no Confluence URL found in page map for this file", vim.log.levels.ERROR)
    return
  end

  local base_url, page_id = parse_confluence_url(entry.url)
  if not base_url or not page_id then
    vim.notify("Confluence: cannot parse Confluence URL: " .. entry.url, vim.log.levels.ERROR)
    return
  end

  vim.notify("Confluence: fetching comments for " .. filename .. "…", vim.log.levels.INFO)

  local comments_url = base_url
    .. "/wiki/rest/api/content/" .. page_id
    .. "/child/comment?expand=body.view,version,history&limit=100&depth=all"

  -- Step 1: fetch comments.
  vim.system(
    { "curl", "-s", "-w", "\n%{http_code}", "-u", email .. ":" .. token,
      "-H", "Accept: application/json", comments_url },
    { text = true },
    function(get_obj)
      if get_obj.code ~= 0 then
        vim.schedule(function()
          vim.notify(
            "Confluence: GET comments failed (exit " .. get_obj.code .. "): "
              .. (get_obj.stderr or ""),
            vim.log.levels.ERROR
          )
        end)
        return
      end

      local raw = get_obj.stdout or ""
      local body_str, http_code_str = raw:match("^(.*)\n(%d%d%d)$")
      local http_code = tonumber(http_code_str) or 0
      if http_code < 200 or http_code >= 300 then
        vim.schedule(function()
          vim.notify(
            "Confluence: GET comments returned HTTP " .. http_code,
            vim.log.levels.ERROR
          )
        end)
        return
      end

      local ok, data = pcall(vim.json.decode, body_str or raw)
      if not ok or type(data.results) ~= "table" then
        vim.schedule(function()
          vim.notify("Confluence: unexpected comments response", vim.log.levels.ERROR)
        end)
        return
      end

      local count = #data.results
      if count == 0 then
        vim.schedule(function()
          vim.notify("Confluence: no comments found for " .. filename, vim.log.levels.INFO)
        end)
        return
      end

      -- Step 2: format comments as markdown.
      local title        = entry.title or filename
      local comments_file = file:gsub("%.md$", ".comments.md")
      local cf_name       = vim.fn.fnamemodify(comments_file, ":t")
      local now           = os.date("!%Y-%m-%d %H:%M UTC")

      local lines = {
        "# Confluence Comments: " .. title,
        "",
        "> Auto-generated by :MdConfluenceComments — do not edit manually.",
        "> Source: " .. entry.url,
        "> Fetched: " .. now,
        "",
      }

      for _, comment in ipairs(data.results) do
        local author = (comment.version and comment.version.by
                         and comment.version.by.displayName) or "Unknown"
        local when   = (comment.version and comment.version.when) or ""
        local date   = when:match("^(%d%d%d%d%-%d%d%-%d%d)") or when
        local body_v = comment.body and comment.body.view
                       and comment.body.view.value or ""
        local md_body = html_to_md(body_v)

        table.insert(lines, "---")
        table.insert(lines, "")
        table.insert(lines, "**" .. author .. "** · " .. date)
        table.insert(lines, "")
        table.insert(lines, md_body)
        table.insert(lines, "")
      end

      -- Step 3: write the comments file on the main thread.
      vim.schedule(function()
        local out = io.open(comments_file, "w")
        if not out then
          vim.notify("Confluence: cannot write " .. cf_name, vim.log.levels.ERROR)
          return
        end
        out:write(table.concat(lines, "\n"))
        out:close()
        vim.notify(
          "Confluence: " .. count .. " comment(s) saved to " .. cf_name,
          vim.log.levels.INFO
        )
      end)
    end
  )
end

--- Register user commands. Safe to call multiple times.
function M.setup()
  if M._loaded then
    return
  end
  M._loaded = true

  vim.api.nvim_create_user_command(
    "MdToConfluence",
    M.publish,
    { desc = "Publish current markdown file to its Confluence page" }
  )
  vim.api.nvim_create_user_command(
    "MdFromConfluence",
    M.pull,
    { desc = "Pull current Confluence page back to local markdown (creates .bak backup)" }
  )
  vim.api.nvim_create_user_command(
    "MdConfluenceComments",
    M.fetch_comments,
    { desc = "Fetch Confluence page comments to a sidecar .comments.md file" }
  )
end

return M
