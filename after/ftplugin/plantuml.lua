vim.b.maplocalleader = ","
vim.keymap.set("n", "<localleader>p", "<cmd>PumlPreview<cr>", { buffer = true, desc = "Preview PlantUML diagram as SVG in browser" })
vim.keymap.set("n", "<localleader>s", "<cmd>PumlExportSvg<cr>", { buffer = true, desc = "Export PlantUML diagram to SVG file" })
