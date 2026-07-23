-- claudecode.nvim: persistent Claude Code session via WebSocket MCP protocol.
-- Uses the native terminal provider (no snacks dependency), coexisting with
-- the one-shot claude_cli commands (<leader>gcs / <leader>gce).
-- Maps nest under the existing <leader>gc "Claude" which-key group.
--
-- Keymaps are registered EAGERLY in `init` (not via lazy's `keys` field). The
-- plugin still lazy-loads on `cmd` — the `<cmd>ClaudeCode…<cr>` right-hand sides
-- trigger that load on first use. Eager registration is deliberate: a lazy `keys`
-- map is only created when the plugin loads, which is *after* which-key builds its
-- trigger tree, so the visual-mode `<leader>gcv` lost a race to Neovim's native
-- `gc` (comment) operator on fast input — the `<Space>gc` prefix wasn't held and
-- the buffered `gc` fired the comment. Registering at startup makes the prefix
-- known before which-key initialises, matching how `claude_cli` binds gcs/gce.
return {
  {
    "coder/claudecode.nvim",
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeAdd",
      "ClaudeCodeSend",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
      "ClaudeCodeCloseAllDiffs",
      "ClaudeCodeStatus",
      "ClaudeCodeStart",
      "ClaudeCodeStop",
    },
    opts = {
      terminal = {
        provider = "native",
      },
    },
    init = function()
      local map = vim.keymap.set
      map("n", "<leader>gcc", "<cmd>ClaudeCode<cr>", { desc = "Claude: toggle session" })
      map("n", "<leader>gcf", "<cmd>ClaudeCodeFocus<cr>", { desc = "Claude: focus session" })
      map("n", "<leader>gcb", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Claude: add buffer to context" })
      map("v", "<leader>gcv", "<cmd>ClaudeCodeSend<cr>", { desc = "Claude: send selection" })
      map("n", "<leader>gca", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Claude: accept diff" })
      map("n", "<leader>gcr", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Claude: reject diff" })
    end,
  },
}
