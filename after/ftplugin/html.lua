vim.b.localleader = ","
vim.keymap.set("n", "<localleader>p", "<cmd>Bracey<cr>", { buffer = true, desc = "Start HTML live preview" })
vim.keymap.set("n", "<localleader>x", "<cmd>BraceyStop<cr>", { buffer = true, desc = "Stop HTML live preview" })
vim.keymap.set("n", "<localleader>r", "<cmd>BraceyReload<cr>", { buffer = true, desc = "Reload HTML live preview" })
