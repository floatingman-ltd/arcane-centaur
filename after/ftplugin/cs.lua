-- ~/.config/nvim/after/ftplugin/cs.lua
local o = vim.opt_local

-- C# standard indentation: 4 spaces
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true

-- Disable spell checking in code
o.spell = false

-- Set local leader for iron.nvim REPL mappings
vim.b.maplocalleader = ","
