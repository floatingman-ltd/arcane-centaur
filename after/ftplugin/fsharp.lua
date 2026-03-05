-- ~/.config/nvim/after/ftplugin/fsharp.lua
local o = vim.opt_local

-- F# standard indentation: 4 spaces
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true

-- Disable spell checking in code
o.spell = false

-- Set local leader for iron.nvim REPL mappings (mirrors Conjure's <localleader> convention)
vim.b.maplocalleader = ","
