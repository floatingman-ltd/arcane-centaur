local lspconfig = require("lspconfig")

-- Common on_attach function with LSP keybindings
local on_attach = function(_, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
end

-- Common Lisp LSP
lspconfig.cl_lsp.setup{ on_attach = on_attach }

-- F# LSP (requires: dotnet tool install -g fsautocomplete)
lspconfig.fsautocomplete.setup{ on_attach = on_attach }

-- Markdown LSP (requires: marksman on $PATH)
lspconfig.marksman.setup{ on_attach = on_attach }

-- C# LSP (roslyn.nvim manages the server; we attach shared keymaps here)
-- Requires the Roslyn server binary on $PATH — see docs/guides/dotnet.md.
vim.lsp.config("roslyn", { on_attach = on_attach })
