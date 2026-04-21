require('options') -- loads options.lua
require('loader')  -- loads the loader/init.lua (lazy)
require('keymaps') -- loads keymaps.lua

require('config.copilot_cli').setup()
require('config.openspec').setup()
