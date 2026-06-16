-- lua/config/research.lua
--
-- Free-form research popup: ask a question, get a prose answer in a float.
--
-- Commands registered by M.setup():
--   :ResearchLocal   Grounded in this config's live keymaps + cheatsheets.
--                    The model is instructed to answer only from that context.
--   :ResearchAsk     Bare question — general-knowledge, no local context.
--
-- Keymaps (set in lua/keymaps.lua):
--   <leader>?l  — ResearchLocal
--   <leader>?a  — ResearchAsk
--
-- Uses Claude Code's built-in authentication (no ANTHROPIC_API_KEY required).

local M = {}

local function read_file(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  return content
end

local function assemble_local_context()
  local modes = { "n" }
  local keymap_lines = { "## Live Keymaps" }
  for _, mode in ipairs(modes) do
    for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
      if m.desc and m.desc ~= "" then
        keymap_lines[#keymap_lines + 1] = string.format("[%s] %s — %s", mode, m.lhs, m.desc)
      end
    end
  end

  local config_dir = vim.fn.stdpath("config")
  local sheets_dir = config_dir .. "/cheatsheets"
  local core = read_file(sheets_dir .. "/core.md") or ""

  local ft_sheets = {
    lisp = "lisp.md", clojure = "lisp.md", scheme = "lisp.md", fennel = "lisp.md",
    janet = "janet.md", fsharp = "fsharp.md", cs = "fsharp.md",
    haskell = "haskell.md", markdown = "markdown.md",
  }
  local ft_sheet = ft_sheets[vim.bo.filetype]
  local sheet = core
  if ft_sheet then
    local lang = read_file(sheets_dir .. "/" .. ft_sheet)
    if lang then
      sheet = sheet .. "\n\n---\n\n" .. lang
    end
  end

  return table.concat(keymap_lines, "\n") .. "\n\n## Cheatsheet\n\n" .. sheet
end

local function run(title, prompt)
  vim.notify("Research: running…", vim.log.levels.INFO)
  -- Use `env -u` to unset ANTHROPIC_API_KEY so claude uses its OAuth session
  -- auth rather than a potentially stale/placeholder key from the environment.
  vim.system({ "env", "-u", "ANTHROPIC_API_KEY", "claude", "-p", prompt }, {}, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local detail = (result.stderr ~= "" and result.stderr)
          or (result.stdout ~= "" and result.stdout)
          or "(no output)"
        vim.notify(
          "research: claude CLI failed (exit " .. result.code .. "):\n" .. detail,
          vim.log.levels.ERROR
        )
        return
      end
      local lines = vim.split(result.stdout or "", "\n", { plain = true })
      while #lines > 0 and lines[#lines] == "" do
        table.remove(lines)
      end
      require("config.util").open_float(title, lines)
    end)
  end)
end

local function ask(title, make_prompt)
  if vim.fn.executable("claude") ~= 1 then
    vim.notify(
      "research: `claude` CLI not found on $PATH.\nInstall Claude Code: https://claude.com/claude-code",
      vim.log.levels.ERROR
    )
    return
  end
  vim.ui.input({ prompt = "Research: " }, function(question)
    if not question or question == "" then return end
    run(title, make_prompt(question))
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("ResearchLocal", function()
    ask("Research (local)", function(question)
      local context = assemble_local_context()
      return "You are an assistant for a specific Neovim configuration. "
        .. "Answer using ONLY the provided configuration context below. "
        .. "If the answer is not present in the context, say so explicitly — "
        .. "do not guess or provide generic Neovim advice.\n\n"
        .. "=== Configuration Context ===\n"
        .. context
        .. "\n\n=== Question ===\n"
        .. question
    end)
  end, { desc = "Research question grounded in this Neovim configuration" })

  vim.api.nvim_create_user_command("ResearchAsk", function()
    ask("Research", function(question) return question end)
  end, { desc = "Ask a general-knowledge research question" })
end

return M
