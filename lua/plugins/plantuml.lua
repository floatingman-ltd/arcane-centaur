local encode_cmd = "python3 -c \""
  .. "import sys, zlib, base64; "
  .. "data = sys.stdin.buffer.read(); "
  .. "compressed = zlib.compress(data)[2:-4]; "
  .. "b64 = base64.b64encode(compressed).decode(); "
  .. "alpha = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_'; "
  .. "std  = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'; "
  .. "print(''.join(alpha[std.index(c)] if c in std else c for c in b64), end='')\""

--- Encode the current buffer and return the PlantUML URL for the given format,
--- or nil on failure.
local function puml_encode(format)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")

  -- PlantUML encoding: deflate then re-encode with PlantUML's custom base64 alphabet
  local encoded = vim.fn.system(encode_cmd, content)

  if vim.v.shell_error ~= 0 then
    vim.notify("PumlPreview: encoding failed — is python3 available?", vim.log.levels.ERROR)
    return nil
  end

  return "http://localhost:8080/" .. format .. "/" .. vim.trim(encoded)
end

--- Open the current buffer rendered as SVG in the default browser.
local function puml_preview()
  local url = puml_encode("svg")
  if url then
    vim.fn.jobstart({ "xdg-open", url }, { detach = true })
  end
end

--- Save the current buffer as an SVG file alongside the source file.
local function puml_export_svg()
  local url = puml_encode("svg")
  if not url then return end

  local src = vim.fn.expand("%:p")
  local out = (src ~= "" and vim.fn.fnamemodify(src, ":r") or "/tmp/diagram") .. ".svg"

  vim.fn.jobstart({ "curl", "-fsSL", "-o", out, url }, {
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("PumlExportSvg: saved → " .. out, vim.log.levels.INFO)
      else
        vim.notify("PumlExportSvg: download failed (is the PlantUML server running on localhost:8080?)", vim.log.levels.ERROR)
      end
    end,
  })
end

return {
  {
    "aklt/plantuml-syntax",
    ft = { "plantuml" },
    config = function()
      vim.api.nvim_create_user_command("PumlPreview", puml_preview, { desc = "Preview PlantUML as SVG in browser via Docker server" })
      vim.api.nvim_create_user_command("PumlExportSvg", puml_export_svg, { desc = "Export PlantUML buffer to SVG file via Docker server" })
    end,
  },
}
