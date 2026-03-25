vim.b.maplocalleader = ","
vim.keymap.set("n", "<localleader>r", "<cmd>Rest run<cr>",         { buffer = true, desc = "REST: run request under cursor" })
vim.keymap.set("n", "<localleader>l", "<cmd>Rest last<cr>",        { buffer = true, desc = "REST: run last request" })
vim.keymap.set("n", "<localleader>o", "<cmd>Rest open<cr>",        { buffer = true, desc = "REST: open result pane" })
vim.keymap.set("n", "<localleader>e", "<cmd>Rest env select<cr>",  { buffer = true, desc = "REST: select environment file" })
