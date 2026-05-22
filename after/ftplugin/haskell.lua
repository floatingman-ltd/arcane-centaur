-- ~/.config/nvim/after/ftplugin/haskell.lua
local ht = require('haskell-tools')
local bufnr = vim.api.nvim_get_current_buf()
local opts = { noremap = true, silent = true, buffer = bufnr, }
-- haskell-language-server relies heavily on codeLenses,
-- so auto-refresh (see advanced configuration) is enabled by default
vim.keymap.set('n', '<space>cl', vim.lsp.codelens.run,          vim.tbl_extend("force", opts, { desc = "Haskell: run code lens" }))
vim.keymap.set('n', '<space>hs', ht.hoogle.hoogle_signature,   vim.tbl_extend("force", opts, { desc = "Haskell: Hoogle search signature" }))
vim.keymap.set('n', '<space>ea', ht.lsp.buf_eval_all,          vim.tbl_extend("force", opts, { desc = "Haskell: evaluate all snippets" }))
vim.keymap.set('n', '<leader>rr', ht.repl.toggle,              vim.tbl_extend("force", opts, { desc = "Haskell: toggle GHCi repl (package)" }))
vim.keymap.set('n', '<leader>rf', function()
  ht.repl.toggle(vim.api.nvim_buf_get_name(0))
end, vim.tbl_extend("force", opts, { desc = "Haskell: toggle GHCi repl (buffer)" }))
vim.keymap.set('n', '<leader>rq', ht.repl.quit, vim.tbl_extend("force", opts, { desc = "Haskell: quit GHCi repl" }))
