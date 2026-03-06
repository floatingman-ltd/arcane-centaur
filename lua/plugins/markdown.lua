vim.g.mkdp_preview_options = {
  plantuml_server = "http://localhost:8080",
}

return {
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    build = "cd app && npm install",
  },
}
