-- ~/.config/nvim/after/ftplugin/terraform.lua
local o = vim.opt_local

-- HCL's conventional indent is 2 spaces, and `terraform fmt` enforces it --
-- anything else here would be undone on the next write.
o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true

-- Disable spell checking in code
o.spell = false

-- Set local leader for iron.nvim REPL mappings (mirrors Conjure's <localleader> convention)
vim.b.maplocalleader = ","

-- `terraform console` REPL. iron.nvim's own <localleader>s* maps (send line,
-- send selection, interrupt, quit) are registered globally in
-- lua/plugins/iron.lua; this adds the open/restart pair, which iron does not
-- bind for itself.
--
-- The console evaluates against real state rather than a scratch environment.
-- In an uninitialised directory it starts but answers little -- run
-- `terraform init` first for anything referring to providers or resources.
local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true, desc = desc })
end
map("<localleader>ss", function()
  require("iron.core").repl_for("terraform")
end, "terraform: open console REPL")
map("<localleader>sr", function()
  require("iron.core").repl_restart()
end, "terraform: restart console REPL")
