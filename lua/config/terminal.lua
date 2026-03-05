-- Terminal detection and capability flags.
--
-- Require this module early (before plugins load) to let the rest of the
-- config adapt to the running terminal emulator.
--
--   local term = require("config.terminal")
--   if term.has_nerd_font then ...
--   if term.has_undercurl  then ...

local M = {}

--- Detect the terminal emulator from environment variables.
--- Returns a short, lowercase identifier string.
local function detect()
  -- WezTerm always sets TERM_PROGRAM
  if vim.env.TERM_PROGRAM == "WezTerm" then
    return "wezterm"
  end

  -- Alacritty sets TERM_PROGRAM on macOS; on Linux it often sets TERM only
  if vim.env.TERM_PROGRAM == "Alacritty"
    or (vim.env.TERM or ""):find("alacritty") then
    return "alacritty"
  end

  -- VTE-based terminals (GNOME Terminal, Tilix, Terminator, …)
  if vim.env.VTE_VERSION ~= nil then
    return "vte"
  end

  -- macOS Terminal.app
  if vim.env.TERM_PROGRAM == "Apple_Terminal" then
    return "apple"
  end

  -- tmux — check the *inner* terminal later if needed
  if vim.env.TMUX ~= nil then
    return "tmux"
  end

  return "unknown"
end

--- Terminal identifier (e.g. "wezterm", "alacritty", "vte", "unknown").
M.name = detect()

--- True when the terminal is known to ship with / fully support Nerd Font
--- glyphs out of the box (i.e. the user only needs to install the font and
--- select it in the terminal settings).
local nerd_font_terminals = {
  wezterm   = true,
  alacritty = true,
}

--- True when the terminal supports the undercurl SGR escape (curly
--- underlines used by spell-check and diagnostics).
local undercurl_terminals = {
  wezterm   = true,
  alacritty = true,
}

M.has_nerd_font = nerd_font_terminals[M.name] or false
M.has_undercurl = undercurl_terminals[M.name] or false
M.is_vte        = M.name == "vte"

return M
