-- lua/config/confluence.lua
--
-- Publish the current markdown buffer to its Confluence page via the
-- Confluence REST API.
--
-- Requires:
--   CONFLUENCE_EMAIL       env var  — your Atlassian account email
--   CONFLUENCE_API_TOKEN   env var  — your Atlassian API token
--   pandoc                          — markdown → HTML conversion
--   python3                         — runs the publish script
--
-- The publish script is located at scripts/confluence_publish.py in the
-- git repository root of the currently open file. The Confluence page is
-- resolved from docs/confluence-page-map.md in the same repository.
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

--- Locate the confluence_publish.py script.
-- Checks CONFLUENCE_PUBLISH_SCRIPT env var first, then falls back to
-- scripts/confluence_publish.py in the repository root.
local function find_publish_script(git_root)
  local env_path = os.getenv("CONFLUENCE_PUBLISH_SCRIPT")
  if env_path and env_path ~= "" then
    if vim.fn.filereadable(env_path) == 1 then
      return env_path
    end
    vim.notify(
      "Confluence: CONFLUENCE_PUBLISH_SCRIPT is set but file not readable:\n" .. env_path,
      vim.log.levels.ERROR
    )
    return nil
  end
  local path = git_root .. "/scripts/confluence_publish.py"
  if vim.fn.filereadable(path) == 1 then
    return path
  end
  return nil
end

--- Publish the current buffer to its Confluence page.
function M.publish()
  local file = vim.fn.expand("%:p")

  if file == "" then
    vim.notify("Confluence: buffer has no file", vim.log.levels.WARN)
    return
  end

  if not file:match("%.md$") then
    vim.notify("Confluence: not a markdown file", vim.log.levels.WARN)
    return
  end

  -- Verify environment variables are present before launching the job.
  -- The script performs the same check; this gives a faster, clearer message.
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

  local dir      = vim.fn.expand("%:p:h")
  local git_root = find_git_root(dir)
  if not git_root then
    vim.notify("Confluence: file is not inside a git repository", vim.log.levels.ERROR)
    return
  end

  local script = find_publish_script(git_root)
  if not script then
    vim.notify(
      "Confluence: publish script not found.\n"
        .. "Set CONFLUENCE_PUBLISH_SCRIPT to the full path of confluence_publish.py,\n"
        .. "or place the script at: " .. git_root .. "/scripts/confluence_publish.py",
      vim.log.levels.ERROR
    )
    return
  end

  local filename = vim.fn.expand("%:t")
  vim.notify("Confluence: publishing " .. filename .. "…", vim.log.levels.INFO)

  local cmd = "python3 "
    .. vim.fn.shellescape(script)
    .. " "
    .. vim.fn.shellescape(file)

  local output_lines = {}

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,

    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        local l = line:match("^%s*(.-)%s*$")
        if l ~= "" then
          table.insert(output_lines, l)
          vim.notify("Confluence: " .. l, vim.log.levels.INFO)
        end
      end
    end,

    on_stderr = function(_, data)
      for _, line in ipairs(data) do
        local l = line:match("^%s*(.-)%s*$")
        if l ~= "" then
          vim.notify("Confluence: " .. l, vim.log.levels.ERROR)
        end
      end
    end,

    on_exit = function(_, code)
      if code == 0 then
        vim.notify("Confluence: " .. filename .. " published successfully.", vim.log.levels.INFO)
      else
        vim.notify(
          "Confluence: publish failed (exit " .. code .. "). Check the messages above.",
          vim.log.levels.ERROR
        )
      end
    end,
  })
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
