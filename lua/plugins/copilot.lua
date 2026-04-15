return {
  {
    "github/copilot.vim",
    config = function()
      -- Inline-completion model. Uncomment one line to activate it.
      -- vim.g.copilot_model = "gpt-4o"
      -- vim.g.copilot_model = "gpt-4.1"
      vim.g.copilot_model = "claude-sonnet-4-5"
      -- vim.g.copilot_model = "claude-opus-4-5"

      -- Serena MCP server — symbol-aware code intelligence for Copilot.
      -- Prefer a globally installed binary; fall back to npx on-demand.
      local serena_cmd
      if vim.fn.executable("serena") == 1 then
        serena_cmd = { "serena" }
      else
        serena_cmd = { "npx", "-y", "@oramasearch/serena" }
      end

      vim.g.copilot_mcp_servers = {
        serena = {
          type    = "stdio",
          command = serena_cmd[1],
          args    = vim.list_slice(serena_cmd, 2),
          cwd     = vim.fn.getcwd(),
        },
      }
    end,
  },
}
