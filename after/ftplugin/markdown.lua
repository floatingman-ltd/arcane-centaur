vim.b.maplocalleader = ","
vim.keymap.set("n", "<localleader>p", "<cmd>MarkdownPreviewToggle<cr>", { buffer = true, desc = "Toggle markdown preview" })

-- Markserv server preview (requires Docker; see docs/guides/markdown.md)
require("config.mdpreview").setup()
vim.keymap.set("n", "<localleader>sp", "<cmd>MdServerPreview<cr>", { buffer = true, desc = "Open in markserv Docker preview server (cross-page links)" })

-- MARP presentation commands (requires Docker; see docs/presentations.md)
require("config.marp").setup()
vim.keymap.set("n", "<localleader>mp", "<cmd>MarpPreview<cr>", { buffer = true, desc = "MARP: open in preview server" })
vim.keymap.set("n", "<localleader>mx", "<cmd>MarpToPptx<cr>", { buffer = true, desc = "MARP: export to PPTX" })
vim.keymap.set("n", "<localleader>mh", "<cmd>MarpToHtml<cr>", { buffer = true, desc = "MARP: export to HTML" })
vim.keymap.set("n", "<localleader>md", "<cmd>MarpToPdf<cr>", { buffer = true, desc = "MARP: export to PDF" })

-- Markdown → PDF with PlantUML diagrams (requires Docker; see docs/guides/diagrams.md)
require("config.mdpdf").setup()
vim.keymap.set("n", "<localleader>dp", "<cmd>MdToPdf<cr>", { buffer = true, desc = "Export markdown to PDF with PlantUML diagrams" })

-- Confluence publish (requires CONFLUENCE_EMAIL + CONFLUENCE_API_TOKEN env vars; see docs/guides/confluence.md)
require("config.confluence").setup()
vim.keymap.set("n", "<localleader>cc", "<cmd>MdToConfluence<cr>",       { buffer = true, desc = "Confluence: publish to Confluence" })
vim.keymap.set("n", "<localleader>cp", "<cmd>MdFromConfluence<cr>",     { buffer = true, desc = "Confluence: pull from Confluence" })
vim.keymap.set("n", "<localleader>cv", "<cmd>MdConfluenceComments<cr>", { buffer = true, desc = "Confluence: fetch comments to .comments.md" })
