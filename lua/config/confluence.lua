-- lua/config/confluence.lua
--
-- Publish the current markdown buffer to its Confluence page via the
-- Confluence REST API.
--
-- Pure Lua implementation — no Python required.
--
-- Requires:
--   CONFLUENCE_EMAIL       env var  — your Atlassian account email
--   CONFLUENCE_API_TOKEN   env var  — your Atlassian API token
--   pandoc                          — markdown → HTML fragment conversion
--   curl                            — REST API calls
--
-- The Confluence page is resolved from docs/confluence-page-map.md in the
-- git repository root of the currently open file.
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

--- Extract the base URL and numeric page ID from a Confluence page URL.
-- e.g. https://acme.atlassian.net/wiki/spaces/TEAM/pages/123456/Title
-- returns "https://acme.atlassian.net", "123456"
local function parse_confluence_url(url)
  local base    = url:match("(https?://[^/]+)")
  local page_id = url:match("/pages/(%d+)")
  return base, page_id
end

--- Publish the current buffer to its Confluence page.
--
-- Async pipeline (each step uses vim.system with a callback):
--   1. pandoc  — convert markdown to an HTML fragment
--   2. curl GET — fetch the current page version and title
--   3. curl PUT — update the page with the new HTML body
function M.publish()
  -- Gather vim API values on the main thread before entering async callbacks.
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

  -- Path relative to git root (e.g. "docs/lld/x.md").
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

  -- Step 1: convert markdown → HTML fragment via pandoc.
  -- Omitting --standalone produces only the body content (no <html>/<head>
  -- wrapper), which is what the Confluence storage-format body field expects.
  vim.system(
    { "pandoc", "--from", "markdown", "--to", "html5", file },
    { text = true },
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

      -- Step 2: fetch the current page version and title.
      local get_url = base_url
        .. "/wiki/rest/api/content/"
        .. page_id
        .. "?expand=version,title"

      vim.system(
        { "curl", "-s", "-f", "-u", email .. ":" .. token,
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

          local ok, data = pcall(vim.json.decode, get_obj.stdout)
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

          -- Step 3: write the JSON payload and PUT the updated page.
          local payload = vim.json.encode({
            id      = page_id,
            type    = "page",
            title   = title,
            version = { number = version + 1 },
            body    = {
              storage = {
                value          = html,
                representation = "storage",
              },
            },
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

          vim.system(
            { "curl", "-s", "-f", "-X", "PUT",
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

              local ok2, resp = pcall(vim.json.decode, put_obj.stdout)
              local page_url  = put_url
              if ok2 and resp._links and resp._links.base and resp._links.webui then
                page_url = resp._links.base .. resp._links.webui
              end

              vim.schedule(function()
                vim.notify(
                  "Confluence: " .. filename .. " published successfully.\n" .. page_url,
                  vim.log.levels.INFO
                )
              end)
            end
          )
        end
      )
    end
  )
end

--- Register the MdToConfluence user command. Safe to call multiple times.
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
end

return M
