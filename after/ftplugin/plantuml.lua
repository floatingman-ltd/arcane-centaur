vim.b.localleader = ","
vim.keymap.set("n", "<localleader>p", "<cmd>PumlPreview<cr>", { buffer = true, desc = "Preview PlantUML diagram" })
