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

-- easy-dotnet test/run/build
local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true, desc = desc })
end
map("<localleader>tt", function() require("easy-dotnet").test() end,  "dotnet: test project")
map("<localleader>tr", function() require("easy-dotnet").run() end,   "dotnet: run project")
map("<localleader>tb", function() require("easy-dotnet").build() end, "dotnet: build project")
