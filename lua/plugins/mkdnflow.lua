-- mkdnflow.nvim — navigate between inter-linked Markdown files in a project.
-- <CR>        follow link under cursor (opens target file in current window)
-- <BS>        go back to the previous file
-- <Tab>       jump to the next link in the buffer
-- <S-Tab>     jump to the previous link in the buffer
-- See docs/cheatsheets/markdown.md for the full reference.

return {
  {
    "jakewvincent/mkdnflow.nvim",
    ft = { "markdown" },
    opts = {},
  },
}
