-- claudecode.nvim: persistent Claude Code session via WebSocket MCP protocol.
-- Uses the native terminal provider (no snacks dependency), coexisting with
-- the one-shot claude_cli commands (<leader>gcs / <leader>gce).
-- Maps nest under the existing <leader>gc "Claude" which-key group.
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
    keys = {
      { "<leader>gcc", "<cmd>ClaudeCode<cr>",        desc = "Claude: toggle session" },
      { "<leader>gcf", "<cmd>ClaudeCodeFocus<cr>",   desc = "Claude: focus session" },
      { "<leader>gcb", "<cmd>ClaudeCodeAdd %<cr>",   desc = "Claude: add buffer to context" },
      { "<leader>gcv", "<cmd>ClaudeCodeSend<cr>",    mode = "v", desc = "Claude: send selection" },
      { "<leader>gca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: accept diff" },
      { "<leader>gcr", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Claude: reject diff" },
    },
  },
}
