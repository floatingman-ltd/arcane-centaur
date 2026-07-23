vim.b.maplocalleader = ","
vim.keymap.set("n", "<localleader>p", "<cmd>PumlPreview<cr>", { buffer = true, desc = "Preview PlantUML diagram" })
vim.keymap.set(
  "n",
  "<leader>pa",
  "<cmd>PumlPreviewAscii<cr>",
  { buffer = true, desc = "Preview PlantUML diagram as ASCII" }
)
