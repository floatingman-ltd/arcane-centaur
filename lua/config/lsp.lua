-- LSP configuration using the Neovim 0.11+ native API.
-- vim.lsp.config sets per-server options; vim.lsp.enable auto-starts the server
-- for matching filetypes using default cmd/root/filetypes from nvim-lspconfig's
-- bundled lsp/<server>.lua files (no require('lspconfig') needed).

-- Shared capabilities: blink.cmp completion capabilities + fold range support for nvim-ufo.
-- pcall guard covers the case where blink hasn't loaded yet at config time.
local capabilities
local ok, blink = pcall(require, "blink.cmp")
if ok then
  capabilities = blink.get_lsp_capabilities({
    textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } },
  })
else
  capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
end

local on_attach = function(_, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd",        vim.lsp.buf.definition,                          vim.tbl_extend("force", opts, { desc = "LSP: go to definition" }))
  vim.keymap.set("n", "K",         vim.lsp.buf.hover,                               vim.tbl_extend("force", opts, { desc = "LSP: hover docs" }))
  vim.keymap.set("n", "gr",        vim.lsp.buf.references,                          vim.tbl_extend("force", opts, { desc = "LSP: references" }))
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,                             vim.tbl_extend("force", opts, { desc = "LSP: rename symbol" }))
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,                        vim.tbl_extend("force", opts, { desc = "LSP: code action" }))
  vim.keymap.set("n", "<leader>e",  vim.diagnostic.open_float,                      vim.tbl_extend("force", opts, { desc = "LSP: show diagnostics" }))
  vim.keymap.set("n", "[d",         function() vim.diagnostic.jump({ count = -1 }) end, vim.tbl_extend("force", opts, { desc = "LSP: previous diagnostic" }))
  vim.keymap.set("n", "]d",         function() vim.diagnostic.jump({ count = 1 })  end, vim.tbl_extend("force", opts, { desc = "LSP: next diagnostic" }))
end

-- F# LSP (requires: dotnet tool install -g fsautocomplete)
vim.lsp.config("fsautocomplete", { on_attach = on_attach, capabilities = capabilities })
vim.lsp.enable("fsautocomplete")

-- Markdown LSP (requires: marksman on $PATH)
vim.lsp.config("marksman", { on_attach = on_attach, capabilities = capabilities })
vim.lsp.enable("marksman")

-- Janet LSP (requires: jpm install janet-lsp)
vim.lsp.config("janet_lsp", { on_attach = on_attach, capabilities = capabilities })
vim.lsp.enable("janet_lsp")

-- C# LSP (roslyn.nvim manages the server; we attach shared keymaps here)
-- Requires the Roslyn server binary on $PATH — see docs/guides/dotnet.md.
--
-- cmd override: roslyn.nvim's default cmd is `{ <server>, "--stdio" }`, which targets a
-- `roslyn-language-server` wrapper. Against the raw Microsoft.CodeAnalysis.LanguageServer we
-- install, that omits the server's REQUIRED `--logLevel` / `--extensionLogDirectory` args, so it
-- exits 1 ("Option '--logLevel' is required."). Supply the full invocation here (the server does
-- support `--stdio`). roslyn.nvim never sets cmd itself, so this override holds.
local roslyn_log_dir = vim.fs.joinpath(vim.fn.stdpath("log"), "roslyn")
vim.fn.mkdir(roslyn_log_dir, "p")
vim.lsp.config("roslyn", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {
    "Microsoft.CodeAnalysis.LanguageServer",
    "--stdio",
    "--logLevel", "Information",
    "--extensionLogDirectory", roslyn_log_dir,
  },
})

-- Lua LSP (requires: lua-language-server on $PATH)
vim.lsp.config("lua_ls", { on_attach = on_attach, capabilities = capabilities })
vim.lsp.enable("lua_ls")
