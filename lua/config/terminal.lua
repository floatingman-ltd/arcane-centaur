-- Terminal detection and capability flags.
--
-- Require this module early (before plugins load) to let the rest of the
-- config adapt to the running terminal emulator.
--
--   local term = require("config.terminal")
--   if term.has_nerd_font then ...
--   if term.has_undercurl  then ...

local M = {}

--- True when running inside Windows Subsystem for Linux.
local is_wsl = vim.env.WSL_DISTRO_NAME ~= nil

--- Detect the terminal emulator from environment variables.
--- Returns a short, lowercase identifier string.
local function detect()
  -- Alacritty sets TERM_PROGRAM on macOS; on Linux it often sets TERM only
  if vim.env.TERM_PROGRAM == "Alacritty" or (vim.env.TERM or ""):find("alacritty") then
    return "alacritty"
  end

  -- Windows Terminal on WSL — WT_SESSION is always set
  if vim.env.WT_SESSION ~= nil then
    return "wt"
  end

  -- VTE-based terminals (GNOME Terminal, Tilix, Terminator, …)
  if vim.env.VTE_VERSION ~= nil then
    return "vte"
  end

  -- macOS Terminal.app
  if vim.env.TERM_PROGRAM == "Apple_Terminal" then
    return "apple"
  end

  -- Linux TTY console ($TERM=linux, no graphical display)
  if vim.env.TERM == "linux" and (vim.env.DISPLAY or "") == "" and (vim.env.WAYLAND_DISPLAY or "") == "" then
    return "tty"
  end

  -- tmux — check the *inner* terminal later if needed
  if vim.env.TMUX ~= nil then
    return "tmux"
  end

  return "unknown"
end

--- Detect whether this session reaches the user across a network.
---
--- `sshd` sets both variables for interactive sessions. Neither is set for a
--- non-interactive command, which is intended -- remote-specific behaviour is
--- not wanted there.
---
--- The tmux fallback exists because a process's environment is fixed when it
--- starts and tmux cannot update panes that already exist. A tmux session
--- started *before* the SSH connection -- or started locally and later attached
--- to over SSH -- therefore hosts a Neovim whose $SSH_CONNECTION is stale or
--- absent, and which would otherwise read as local while being remote. The tmux
--- server does know: SSH_CONNECTION is in its default `update-environment`, so
--- it is refreshed from each attaching client. Only the *presence* of a value
--- is tested, never its content, so a value left over from an earlier
--- connection is harmless.
---
--- Independent of `M.is_console`. That flag asks whether a display is
--- available; this one asks whether the session crosses a network. All four
--- combinations occur -- a WSLg session is local with a display, a headless
--- server over SSH is remote without one.
local function detect_remote()
  if vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil then
    return true
  end

  if vim.env.TMUX ~= nil and vim.fn.executable("tmux") == 1 then
    local out = vim.fn.system({ "tmux", "show-environment", "SSH_CONNECTION" })
    -- tmux prefixes the name with "-" when it knows the variable to be unset,
    -- which is what distinguishes that from a query that failed.
    return vim.v.shell_error == 0 and out:sub(1, 1) ~= "-"
  end

  return false
end

--- Terminal identifier (e.g. "alacritty", "vte", "tty", "unknown").
M.name = detect()

--- True when the terminal is known to ship with / fully support Nerd Font
--- glyphs out of the box (i.e. the user only needs to install the font and
--- select it in the terminal settings).
local nerd_font_terminals = {
  alacritty = true,
  wt = true,
}

--- True when the terminal supports the undercurl SGR escape (curly
--- underlines used by spell-check and diagnostics).
local undercurl_terminals = {
  alacritty = true,
  wt = true,
}

M.has_nerd_font = nerd_font_terminals[M.name] or false
M.has_undercurl = undercurl_terminals[M.name] or false
M.is_vte = M.name == "vte"
M.is_wsl = is_wsl

--- True when the session reaches the user across a network (SSH, or a tmux
--- session attached to over SSH). Independent of `M.is_console` -- see
--- `detect_remote` above.
M.is_remote = detect_remote()

--- True when no graphical display is available (physical TTY, SSH without X
--- forwarding, headless server). Derived solely from the absence of both
--- $DISPLAY and $WAYLAND_DISPLAY — no manual override flag is used.
M.is_console = (vim.env.DISPLAY or "") == "" and (vim.env.WAYLAND_DISPLAY or "") == ""

--- True when the terminal can render 24-bit ("true") color. A real Linux TTY
--- (TERM=linux) and many bare SSH terminals cannot; truecolor-first themes such
--- as TokyoNight render poorly there (invisible Visual, odd cursor). When false,
--- the config falls back to Neovim's default colorscheme. Detected from
--- $COLORTERM, known-truecolor terminals, and VTE.
M.has_truecolor = ((vim.env.COLORTERM or "") == "truecolor" or (vim.env.COLORTERM or "") == "24bit")
  or nerd_font_terminals[M.name] == true
  or M.is_vte

return M
