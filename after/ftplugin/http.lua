local kulala = require("kulala")
vim.b.maplocalleader = ","
vim.keymap.set("n", "<localleader>r", function() kulala.run() end,              { buffer = true, desc = "REST: run request under cursor" })
vim.keymap.set("n", "<localleader>l", function() kulala.replay() end,           { buffer = true, desc = "REST: run last request" })
vim.keymap.set("n", "<localleader>o", function() kulala.open() end,             { buffer = true, desc = "REST: open result pane" })
vim.keymap.set("n", "<localleader>e", function() kulala.set_selected_env() end, { buffer = true, desc = "REST: select environment" })
