local util = require("config.util")

local function puml_preview()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")

  -- PlantUML encoding: deflate then encode with plantuml's custom base64 alphabet
  local encoded = vim.fn.system(
    "python3 -c \""
      .. "import sys, zlib, base64; "
      .. "data = sys.stdin.buffer.read(); "
      .. "compressed = zlib.compress(data)[2:-4]; "
      .. "b64 = base64.b64encode(compressed).decode(); "
      .. "alpha = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_'; "
      .. "std  = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'; "
      .. "print(''.join(alpha[std.index(c)] if c in std else c for c in b64), end='')\"",
    content
  )

  if vim.v.shell_error ~= 0 then
    vim.notify("PumlPreview: encoding failed — is python3 available?", vim.log.levels.ERROR)
    return
  end

  local url = "http://localhost:8080/png/" .. vim.trim(encoded)
  util.open_url(url)
end

return {
  {
    "aklt/plantuml-syntax",
    ft = { "plantuml" },
    config = function()
      vim.api.nvim_create_user_command("PumlPreview", puml_preview, { desc = "Preview PlantUML via Docker server" })
    end,
  },
}
