-- ~/.config/nvim/after/ftplugin/scheme.lua
-- Scheme-specific settings for optimized editing
local o = vim.opt_local

-- Lisp-style indentation
o.lisp = true

-- Disable spell checking in code
o.spell = false

-- Set local leader for Conjure mappings
vim.b.maplocalleader = ","
