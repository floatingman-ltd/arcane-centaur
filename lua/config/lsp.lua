-- Global LSP keybindings — applied whenever any LSP client attaches to a buffer.
-- Uses LspAttach so the maps are set for every server, including haskell-tools.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("arcane_lsp_keymaps", { clear = true }),
  callback = function(ev)
    local opts = { noremap = true, silent = true, buffer = ev.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K",  vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>e",  vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  end,
})

-- F# LSP (requires: dotnet tool install -g fsautocomplete)
vim.lsp.enable("fsautocomplete")

-- Markdown LSP (requires: marksman on $PATH)
vim.lsp.enable("marksman")
