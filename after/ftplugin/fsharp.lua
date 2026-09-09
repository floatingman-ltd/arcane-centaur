-- ~/.config/nvim/after/ftplugin/fsharp.lua
local o = vim.opt_local

-- F# standard indentation: 4 spaces
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true

-- Disable spell checking in code
o.spell = false

-- Comment support. Neovim ships no ftplugin for F# at all, so `commentstring`
-- was empty and `gcc` failed outright with "comment string is empty" -- native
-- commenting has never worked in an F# buffer here. Surfaced while validating
-- add-fsharp-indent (FI.7).
--
-- `// %s` rather than Ionide-vim's `(*%s*)`: line comments are what idiomatic
-- F# uses, and a block comment wrapped around every line is worse output from
-- `gcc` than a `//` prefix.
o.commentstring = "// %s"

-- `comments` drives comment continuation and formatting, which is separate from
-- what `gcc` inserts. `:///` must precede `://` so an XML doc comment is
-- recognised before the plain line comment; `s1:(*,mb:*,ex:*)` handles `(* *)`
-- blocks, which F# has and the default list does not.
o.comments = "s1:(*,mb:*,ex:*),:///,://"

-- Set local leader for iron.nvim REPL mappings (mirrors Conjure's <localleader> convention)
vim.b.maplocalleader = ","

-- easy-dotnet test/run/build
local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true, desc = desc })
end
map("<localleader>tt", function()
  require("easy-dotnet").test()
end, "dotnet: test project")
map("<localleader>tr", function()
  require("easy-dotnet").run()
end, "dotnet: run project")
map("<localleader>tb", function()
  require("easy-dotnet").build()
end, "dotnet: build project")
