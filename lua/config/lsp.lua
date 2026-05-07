-- LSP configuration using the Neovim 0.11+ native API.
-- vim.lsp.config sets per-server options; vim.lsp.enable auto-starts the server
-- for matching filetypes using default cmd/root/filetypes from nvim-lspconfig's
-- bundled lsp/<server>.lua files (no require('lspconfig') needed).

local on_attach = function(_, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts)
end

-- F# LSP (requires: dotnet tool install -g fsautocomplete)
vim.lsp.config("fsautocomplete", { on_attach = on_attach })
vim.lsp.enable("fsautocomplete")

-- Markdown LSP (requires: marksman on $PATH)
vim.lsp.config("marksman", { on_attach = on_attach })
vim.lsp.enable("marksman")

-- C# LSP (roslyn.nvim manages the server; we attach shared keymaps here)
-- Requires the Roslyn server binary on $PATH — see docs/guides/dotnet.md.
vim.lsp.config("roslyn", { on_attach = on_attach })
