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
-- Requires:
--   CONFLUENCE_EMAIL       env var  — your Atlassian account email
--   CONFLUENCE_API_TOKEN   env var  — your Atlassian API token
--   pandoc                          — markdown → HTML fragment conversion
--   curl                            — REST API calls
--
-- Script resolution (first match wins):
--   confluence_publish.sh and confluence_filter.lua are resolved from:
--     1. CONFLUENCE_PUBLISH_SCRIPT / CONFLUENCE_FILTER_LUA env vars
--     2. ~/.config/nvim/scripts/   (standard location — no project setup needed)
--     3. <git-root>/scripts/       (project-local override)
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
--   3. Beside CONFLUENCE_PUBLISH_SCRIPT if set
--   4. scripts/ in the project git root (project-local override)
local function find_filter(git_root)
  local env_filter = os.getenv("CONFLUENCE_FILTER_LUA")
  if env_filter and env_filter ~= "" and vim.fn.filereadable(env_filter) == 1 then
    return env_filter
  end
  local nvim_filter = vim.fn.stdpath("config") .. "/scripts/confluence_filter.lua"
  if vim.fn.filereadable(nvim_filter) == 1 then
    return nvim_filter
  end
  local script = os.getenv("CONFLUENCE_PUBLISH_SCRIPT") or ""
  if script ~= "" then
    local sibling = script:gsub("[^/]+$", "confluence_filter.lua")
    if vim.fn.filereadable(sibling) == 1 then
      return sibling
    end
  end
  local default = git_root .. "/scripts/confluence_filter.lua"
  if vim.fn.filereadable(default) == 1 then
    return default
  end
  return nil
end

--- Find confluence_publish.sh (used by pull and comments modes).
-- Search order:
--   1. CONFLUENCE_PUBLISH_SCRIPT env var
--   2. scripts/ inside the nvim config directory (~/.config/nvim/scripts/)
--   3. scripts/ in the project git root (project-local override)
local function find_publish_script(git_root)
  local env_script = os.getenv("CONFLUENCE_PUBLISH_SCRIPT") or ""
  if env_script ~= "" and vim.fn.filereadable(env_script) == 1 then
    return env_script
  end
  local nvim_script = vim.fn.stdpath("config") .. "/scripts/confluence_publish.sh"
  if vim.fn.filereadable(nvim_script) == 1 then
    return nvim_script
  end
  local default = git_root .. "/scripts/confluence_publish.sh"
  if vim.fn.filereadable(default) == 1 then
    return default
  end
  return nil
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
-- Delegates to confluence_publish.sh --pull, which:
--   • fetches the Confluence storage-format body
--   • pre-processes it with confluence_preproc.py
--   • converts to CommonMark via pandoc
--   • backs up the existing file to <file>.bak before overwriting
--   • records the pulled version in .confluence-state.json
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

  local script = find_publish_script(git_root)
  if not script then
    vim.notify(
      "Confluence: confluence_publish.sh not found.\n"
        .. "Set CONFLUENCE_PUBLISH_SCRIPT or ensure scripts/confluence_publish.sh exists.",
      vim.log.levels.ERROR
    )
    return
  end

  vim.notify("Confluence: pulling " .. filename .. "…", vim.log.levels.INFO)

  vim.system(
    { script, "--pull", file },
    {
      text = true,
      env  = {
        CONFLUENCE_EMAIL     = email,
        CONFLUENCE_API_TOKEN = token,
        PLANTUML_SERVER      = os.getenv("PLANTUML_SERVER") or "http://localhost:8080",
      },
    },
    function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify(
            "Confluence: pull failed:\n" .. (result.stderr or result.stdout or "unknown error"),
            vim.log.levels.ERROR
          )
          return
        end
        vim.cmd("e!")
        vim.notify(
          "Confluence: " .. filename .. " updated from Confluence.\n"
            .. "Original backed up as " .. filename .. ".bak",
          vim.log.levels.INFO
        )
      end)
    end
  )
end

--- Fetch all comments for the current page and write them to <file>.comments.md.
--
-- Delegates to confluence_publish.sh --comments.
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

  local script = find_publish_script(git_root)
  if not script then
    vim.notify(
      "Confluence: confluence_publish.sh not found.\n"
        .. "Set CONFLUENCE_PUBLISH_SCRIPT or ensure scripts/confluence_publish.sh exists.",
      vim.log.levels.ERROR
    )
    return
  end

  vim.notify("Confluence: fetching comments for " .. filename .. "…", vim.log.levels.INFO)

  vim.system(
    { script, "--comments", file },
    {
      text = true,
      env  = {
        CONFLUENCE_EMAIL     = email,
        CONFLUENCE_API_TOKEN = token,
      },
    },
    function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify(
            "Confluence: comment fetch failed:\n" .. (result.stderr or result.stdout or ""),
            vim.log.levels.ERROR
          )
          return
        end
        local comments_file = filename:gsub("%.md$", ".comments.md")
        vim.notify(
          "Confluence: comments saved to " .. comments_file,
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
