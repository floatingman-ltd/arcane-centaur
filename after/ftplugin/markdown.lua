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

-- Confluence publish/pull/comments (requires CONFLUENCE_EMAIL + CONFLUENCE_API_TOKEN env vars; see docs/guides/confluence.md)
require("config.confluence").setup()
vim.keymap.set("n", "<localleader>cc", "<cmd>MdToConfluence<cr>",       { buffer = true, desc = "Confluence: publish current file" })
vim.keymap.set("n", "<localleader>cf", "<cmd>MdFromConfluence<cr>",     { buffer = true, desc = "Confluence: pull page to local file" })
vim.keymap.set("n", "<localleader>ck", "<cmd>MdConfluenceComments<cr>", { buffer = true, desc = "Confluence: fetch comments to sidecar file" })

-- Jira issue/story creation (requires JIRA_EMAIL + JIRA_API_TOKEN + JIRA_BASE_URL env vars; see docs/guides/jira.md)
require("config.jira").setup()
vim.keymap.set("n", "<localleader>ji", "<cmd>JiraCreateIssue<cr>",                { buffer = true, desc = "Jira: create Task issue from current file" })
vim.keymap.set("n", "<localleader>js", "<cmd>JiraCreateStory<cr>",                { buffer = true, desc = "Jira: create Story from current file" })
vim.keymap.set("v", "<localleader>ji", "<cmd>JiraCreateIssueFromSelection<cr>",   { buffer = true, desc = "Jira: create Task issue with selection as description" })
vim.keymap.set("v", "<localleader>js", "<cmd>JiraCreateStoryFromSelection<cr>",   { buffer = true, desc = "Jira: create Story with selection as description" })
