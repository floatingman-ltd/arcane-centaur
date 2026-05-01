local util = require("config.util")
local term = require("config.terminal")

--- Encode the current buffer's content using the PlantUML encoding scheme
--- (deflate + custom base64 alphabet). Returns the encoded string on success,
--- or nil if the Python command fails.
local function encode_puml()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")

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
    return nil
  end
  return vim.trim(encoded)
end

local function puml_preview()
  local encoded = encode_puml()
  if not encoded then
    vim.notify("PumlPreview: encoding failed — is python3 available?", vim.log.levels.ERROR)
    return
  end
  local url = "http://localhost:8080/png/" .. encoded
  util.open_url(url)
end

--- Fetch ASCII art from the PlantUML server's /txt/ endpoint and display the
--- result in a centered floating window matching the glow.nvim popup geometry.
local function puml_preview_ascii()
  local encoded = encode_puml()
  if not encoded then
    vim.notify("PumlPreviewAscii: encoding failed — is python3 available?", vim.log.levels.ERROR)
    return
  end

  local url = "http://localhost:8080/txt/" .. encoded
  local output = vim.fn.system("curl -s " .. vim.fn.shellescape(url))

  -- Mirror glow.nvim sizing: 70% of editor dimensions, capped at 120×80.
  local editor_w = vim.o.columns
  local editor_h = vim.o.lines
  local win_w = math.min(math.ceil(editor_w * 0.7), 120)
  local win_h = math.min(math.ceil(editor_h * 0.7), 80)
  local row = math.ceil((editor_h - win_h) / 2 - 1)
  local col = math.ceil((editor_w - win_w) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, "\n", { plain = true }))

  local win = vim.api.nvim_open_win(buf, true, {
    style    = "minimal",
    relative = "editor",
    border   = "rounded",
    width    = win_w,
    height   = win_h,
    row      = row,
    col      = col,
  })

  local close = function() vim.api.nvim_win_close(win, true) end
  vim.keymap.set("n", "q",     close, { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, silent = true })
end

return {
  {
    "aklt/plantuml-syntax",
    ft = { "plantuml" },
    config = function()
      -- PumlPreviewAscii is always available (useful in GUI too).
      vim.api.nvim_create_user_command(
        "PumlPreviewAscii",
        puml_preview_ascii,
        { desc = "Preview PlantUML as Unicode art via Docker server" }
      )
      -- PumlPreview routes to ASCII in console mode, PNG otherwise.
      if term.is_console then
        vim.api.nvim_create_user_command(
          "PumlPreview",
          puml_preview_ascii,
          { desc = "Preview PlantUML diagram (ASCII in console mode)" }
        )
      else
        vim.api.nvim_create_user_command(
          "PumlPreview",
          puml_preview,
          { desc = "Preview PlantUML diagram via Docker server" }
        )
      end
    end,
  },
}
