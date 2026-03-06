vim.b.localleader = ","
vim.keymap.set("n", "<localleader>p", "<cmd>MarkdownPreviewToggle<cr>", { buffer = true, desc = "Toggle markdown preview" })
