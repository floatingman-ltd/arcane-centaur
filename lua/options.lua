-- alias'
local global = vim.g
local o = vim.opt

-- Hint: use `:h <option>` to figure out the meaning if needed
o.clipboard = 'unnamedplus'   -- use system clipboard 
o.completeopt = {'menu', 'menuone', 'noselect'}
o.mouse = 'a'                 -- allow the mouse to be used in Nvim

-- Tab
o.tabstop = 2                 -- number of visual spaces per TAB
o.softtabstop = 2             -- number of spacesin tab when editing
o.shiftwidth = 2              -- insert 4 spaces on a tab
o.expandtab = true            -- tabs are spaces, mainly because of python
o.smartindent = true          -- syntax based indents
o.autoindent = true

-- UI config
o.number = true               -- show absolute number
o.relativenumber = true       -- add numbers to each line on the left side
o.cursorline = true           -- highlight cursor line underneath the cursor horizontally
o.splitbelow = true           -- open new vertical split bottom
o.splitright = true           -- open new horizontal splits right
o.termguicolors = true         -- enable 24-bit RGB color in the TUI
o.showmode = false            -- we are experienced, wo don't need the "-- INSERT --" mode hint

-- Searching
o.incsearch = true            -- search as characters are entered
o.hlsearch = false            -- do not highlight matches
o.ignorecase = true           -- ignore case in searches by default
o.smartcase = true            -- but make it case sensitive if an uppercase is entered

o.scrolloff = 8               -- an 8 line vertical margin
o.signcolumn = "yes"          -- disable the ugly column
o.colorcolumn = ""

-- Folding (nvim-ufo)
o.foldlevel      = 99         -- open all folds by default
o.foldlevelstart = 99         -- files always open fully expanded
o.foldenable     = true       -- enable folding
o.foldcolumn     = "1"        -- thin gutter indicator

-- Spelling
o.spell = true
o.spelllang = "en_ca"

-- Nerd Font support — auto-detected from the terminal emulator.
-- Override to true/false here if the detection is wrong for your setup.
local term = require("config.terminal")
global.have_nerd_font = term.has_nerd_font

-- Clipboard provider — chosen by environment.
--
-- Priority:
--   1. WSL  → win32yank.exe  (fastest, bidirectional)
--   2. Console / SSH / TTY → OSC 52 escape sequence
--      Works transparently through SSH tunnels and RDP without any
--      external tool.  Requires Neovim ≥ 0.10 and a terminal that
--      honours OSC 52 (Windows Terminal, Alacritty, kitty, WezTerm,
--      iTerm2, Ghostty).  Paste support varies by terminal — if paste
--      fails, use the terminal's own paste shortcut (Shift+Insert /
--      Ctrl+Shift+V) instead.
--   3. GUI Linux (X11 / Wayland) → auto-detected by Neovim from
--      wl-clipboard, xclip, or xsel on $PATH.
if term.is_wsl and vim.fn.executable("win32yank.exe") == 1 then
  global.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = true,
  }
elseif term.is_console then
  local osc52 = require("vim.ui.clipboard.osc52")
  global.clipboard = {
    name  = "OSC 52",
    copy  = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
  }
end

-- leader key
global.mapleader = " "
global.maplocalleader = ","

-- copilot
global.copilot_no_tab_map = true
-- global.copilot_auto_trigger = true

-- fsharp
-- global['fsharp#fsautocomplete_command'] = {'dotnet','fsautocomplete','--background-service-enabled'}
-- global['deoplete#enable_at_startup'] = 1

-- pythoin provider
-- global.python3_host_prog = "/usr/bin/python3"
