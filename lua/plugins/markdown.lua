vim.g.mkdp_preview_options = {
  plantuml_server = "http://localhost:8080",
}

-- WSL2: xdg-open and wslview are unavailable; use the Windows explorer shim.
vim.g.mkdp_browser = "explorer.exe"

return {
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    build = "cd app && npm install",
  },
}
