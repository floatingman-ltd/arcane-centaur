vim.b.localleader = ","
vim.keymap.set("n", "<localleader>p", "<cmd>MarkdownPreviewToggle<cr>", { buffer = true, desc = "Toggle markdown preview" })

-- MARP presentation commands (requires Docker; see docs/presentations.md)
require("config.marp").setup()
vim.keymap.set("n", "<localleader>mp", "<cmd>MarpPreview<cr>", { buffer = true, desc = "MARP: open in preview server" })
vim.keymap.set("n", "<localleader>mx", "<cmd>MarpToPptx<cr>", { buffer = true, desc = "MARP: export to PPTX" })
vim.keymap.set("n", "<localleader>mh", "<cmd>MarpToHtml<cr>", { buffer = true, desc = "MARP: export to HTML" })
vim.keymap.set("n", "<localleader>md", "<cmd>MarpToPdf<cr>", { buffer = true, desc = "MARP: export to PDF" })
