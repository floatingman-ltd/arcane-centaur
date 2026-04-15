-- lua/config/jira.lua
--
-- Create Jira issues and stories from Neovim via the Jira Cloud REST API v3.
--
-- Commands registered by M.setup():
--   :JiraCreateIssue   Prompt for summary + description, create a Task in the
--                      Jira project mapped to the current file.
--   :JiraCreateStory   Same flow, but creates a Story issue type.
--
-- Keymaps (registered in after/ftplugin/markdown.lua):
--   ,ji  Normal  — :JiraCreateIssue
--   ,js  Normal  — :JiraCreateStory
--   ,ji  Visual  — :JiraCreateIssue  (selection used as description)
--   ,js  Visual  — :JiraCreateStory  (selection used as description)
--
-- Requires:
--   JIRA_EMAIL         env var — your Atlassian account email
--   JIRA_API_TOKEN     env var — your Atlassian API token
--   JIRA_BASE_URL      env var — e.g. https://yourcompany.atlassian.net
--   curl                       — REST API calls
--
-- Project map:
--   docs/jira-project-map.md at the git root maps directory/file path prefixes
--   (relative to the git root) to Jira project keys.  The longest matching
--   prefix wins.  See docs/guides/jira.md for the table format.
--
-- See docs/guides/jira.md for full setup instructions.

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

--- Parse docs/jira-project-map.md and resolve the Jira project key for a file.
--
-- The map is a markdown table where each data row has the form:
--   | path/prefix | PROJECT_KEY | optional notes |
-- Paths are relative to the git root.  The longest matching prefix wins.
--
-- @param map_path   absolute path to jira-project-map.md
-- @param rel_path   file path relative to the git root (e.g. "docs/design/foo.md")
-- @return project_key string or nil, error_message string
local function find_project_key(map_path, rel_path)
  local f = io.open(map_path, "r")
  if not f then
    return nil, "cannot open project map: " .. map_path
  end

  local best_key    = nil
  local best_prefix = ""

  for line in f:lines() do
    -- Match pipe-delimited table rows (skip header/separator rows).
    local path_col = line:match("^%s*|%s*([^|%-][^|]-)%s*|")
    if path_col then
      -- Strip backtick fencing if present.
      local prefix = path_col:match("^`(.*)`$") or path_col
      prefix = prefix:match("^%s*(.-)%s*$")  -- trim whitespace

      if prefix ~= "" and prefix ~= "Path Prefix" then
        -- Normalise trailing slash for directory prefixes.
        local norm_prefix = prefix:gsub("/$", "")
        local norm_rel    = rel_path:gsub("/$", "")

        local matches = (norm_rel == norm_prefix)
          or (norm_rel:sub(1, #norm_prefix + 1) == norm_prefix .. "/")

        if matches and #norm_prefix > #best_prefix then
          -- Extract the second column as the project key.
          local cols = {}
          for col in (line .. "|"):gmatch("[^|]+") do
            table.insert(cols, col:match("^%s*(.-)%s*$"))
          end
          local key = cols[2]
          if key and key ~= "" then
            best_key    = key
            best_prefix = norm_prefix
          end
        end
      end
    end
  end

  f:close()

  if best_key then
    return best_key, nil
  end
  return nil, "'" .. rel_path .. "' not found in jira-project-map.md"
end

--- Get the visual selection as a string (called from normal mode after a visual op).
-- Returns nil if no prior selection is available.
local function get_visual_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos   = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line   = end_pos[2]
  if start_line == 0 and end_line == 0 then
    return nil
  end
  local lines = vim.fn.getline(start_line, end_line)
  if type(lines) ~= "table" or #lines == 0 then
    return nil
  end
  return table.concat(lines, "\n")
end

--- Build an Atlassian Document Format (ADF) paragraph node for a plain-text body.
-- Jira Cloud REST API v3 requires ADF for description fields.
local function adf_doc(text)
  local content = {}
  for _, para in ipairs(vim.split(text, "\n\n", { plain = true })) do
    local trimmed = para:match("^%s*(.-)%s*$")
    if trimmed ~= "" then
      table.insert(content, {
        type    = "paragraph",
        content = {
          { type = "text", text = trimmed },
        },
      })
    end
  end
  if #content == 0 then
    content = { { type = "paragraph", content = { { type = "text", text = text } } } }
  end
  return { version = 1, type = "doc", content = content }
end

--- Core function: prompt for summary (+optional description), then POST to Jira.
--
-- @param issue_type  string — "Task" or "Story"
-- @param pre_desc    string|nil — pre-populated description (from visual selection)
function M.create_issue(issue_type, pre_desc)
  local file = vim.fn.expand("%:p")
  local dir  = vim.fn.expand("%:p:h")

  if file == "" then
    vim.notify("Jira: buffer has no file", vim.log.levels.WARN)
    return
  end

  local email     = os.getenv("JIRA_EMAIL")
  local token     = os.getenv("JIRA_API_TOKEN")
  local base_url  = os.getenv("JIRA_BASE_URL")

  if not email or email == "" or not token or token == "" then
    vim.notify(
      "Jira: JIRA_EMAIL and JIRA_API_TOKEN must be set.\n"
        .. "See docs/guides/jira.md for setup instructions.",
      vim.log.levels.ERROR
    )
    return
  end

  if not base_url or base_url == "" then
    vim.notify(
      "Jira: JIRA_BASE_URL must be set (e.g. https://yourcompany.atlassian.net).\n"
        .. "See docs/guides/jira.md for setup instructions.",
      vim.log.levels.ERROR
    )
    return
  end

  -- Normalise base URL (strip trailing slash).
  base_url = base_url:gsub("/$", "")

  local git_root = find_git_root(dir)
  if not git_root then
    vim.notify("Jira: file is not inside a git repository", vim.log.levels.ERROR)
    return
  end

  local rel_path    = file:sub(#git_root + 2)
  local map_path    = git_root .. "/docs/jira-project-map.md"
  local project_key, map_err = find_project_key(map_path, rel_path)

  if not project_key then
    vim.notify("Jira: " .. (map_err or "file not in project map"), vim.log.levels.ERROR)
    return
  end

  -- Prompt for summary, then optionally for description.
  vim.ui.input({ prompt = "Jira " .. issue_type .. " summary: " }, function(summary)
    if not summary or summary:match("^%s*$") then
      vim.notify("Jira: creation cancelled (no summary provided)", vim.log.levels.WARN)
      return
    end

    local function do_create(description)
      local api_url = base_url .. "/rest/api/3/issue"

      local body = {
        fields = {
          project     = { key = project_key },
          summary     = summary,
          issuetype   = { name = issue_type },
        },
      }

      if description and description ~= "" then
        body.fields.description = adf_doc(description)
      end

      local json_body = vim.json.encode(body)

      vim.system(
        {
          "curl", "-s", "-w", "\n%{http_code}",
          "-u", email .. ":" .. token,
          "-H", "Content-Type: application/json",
          "-H", "Accept: application/json",
          "-X", "POST",
          "-d", json_body,
          api_url,
        },
        { text = true },
        function(obj)
          vim.schedule(function()
            if obj.code ~= 0 then
              vim.notify(
                "Jira: curl failed (exit " .. obj.code .. "): " .. (obj.stderr or ""),
                vim.log.levels.ERROR
              )
              return
            end

            local raw = obj.stdout or ""
            local resp_body, http_code_str = raw:match("^(.*)\n(%d%d%d)$")
            local http_code = tonumber(http_code_str) or 0

            if http_code < 200 or http_code >= 300 then
              vim.notify(
                "Jira: API returned HTTP " .. http_code .. ":\n" .. (resp_body or raw),
                vim.log.levels.ERROR
              )
              return
            end

            local ok, data = pcall(vim.json.decode, resp_body or raw)
            if not ok or not data.key then
              vim.notify(
                "Jira: unexpected API response: " .. (resp_body or raw),
                vim.log.levels.ERROR
              )
              return
            end

            local issue_url = base_url .. "/browse/" .. data.key
            vim.notify(
              "Jira: created " .. data.key .. " (" .. issue_type .. ")\n" .. issue_url,
              vim.log.levels.INFO
            )
          end)
        end
      )
    end

    if pre_desc and pre_desc ~= "" then
      do_create(pre_desc)
    else
      vim.ui.input({ prompt = "Description (optional): " }, function(desc)
        do_create(desc or "")
      end)
    end
  end)
end

--- Register :JiraCreateIssue and :JiraCreateStory user commands.
function M.setup()
  if vim.g._jira_setup_done then
    return
  end
  vim.g._jira_setup_done = true

  vim.api.nvim_create_user_command("JiraCreateIssue", function()
    M.create_issue("Task", nil)
  end, { desc = "Create a Jira Task issue from the current file" })

  vim.api.nvim_create_user_command("JiraCreateStory", function()
    M.create_issue("Story", nil)
  end, { desc = "Create a Jira Story issue from the current file" })

  vim.api.nvim_create_user_command("JiraCreateIssueFromSelection", function()
    M.create_issue("Task", get_visual_selection())
  end, { desc = "Create a Jira Task issue using the visual selection as description" })

  vim.api.nvim_create_user_command("JiraCreateStoryFromSelection", function()
    M.create_issue("Story", get_visual_selection())
  end, { desc = "Create a Jira Story using the visual selection as description" })
end

return M
