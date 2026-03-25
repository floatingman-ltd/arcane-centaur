vim.b.maplocalleader = ","
vim.keymap.set("n", "<localleader>r", function() require("kulala").run() end,              { buffer = true, desc = "REST: run request under cursor" })
vim.keymap.set("n", "<localleader>l", function() require("kulala").replay() end,           { buffer = true, desc = "REST: run last request" })
vim.keymap.set("n", "<localleader>o", function() require("kulala").open() end,             { buffer = true, desc = "REST: open result pane" })
vim.keymap.set("n", "<localleader>e", function() require("kulala").set_selected_env() end, { buffer = true, desc = "REST: select environment" })
