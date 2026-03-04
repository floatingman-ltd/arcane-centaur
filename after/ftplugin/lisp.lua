-- ~/.config/nvim/after/ftplugin/lisp.lua
-- Lisp-specific settings for optimized editing
local o = vim.opt_local

-- Lisp indentation
o.lisp = true
o.lispwords:append("defmethod,defgeneric,defclass,define,letrec")

-- Disable spell checking in code (comments are still checked)
o.spell = false

-- Set local leader for Conjure mappings
vim.b.maplocalleader = ","
