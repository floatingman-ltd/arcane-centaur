--- Encode a PlantUML string using the server's hex encoding format.
--- The ~1 prefix signals hex encoding to the PlantUML server; no external
--- tools are required.
local function hex_encode(text)
  return "~1" .. text:gsub(".", function(c)
    return string.format("%02x", string.byte(c))
  end)
end

--- Encode the current buffer and return the PlantUML URL for the given format.
local function puml_encode(format)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")
  return "http://localhost:8080/" .. format .. "/" .. hex_encode(content)
end

--- Open the current buffer rendered as SVG in the default browser.
local function puml_preview()
  vim.fn.jobstart({ "xdg-open", puml_encode("svg") }, { detach = true })
end

--- Save the current buffer as an SVG file alongside the source file.
local function puml_export_svg()
  local url = puml_encode("svg")
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
