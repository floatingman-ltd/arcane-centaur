-- Pandoc Lua filter: render plantuml fenced code blocks via the local PlantUML
-- Docker server (http://localhost:8080) as SVG
--
-- Requirements (available in pandoc/extra):
--   python3       — PlantUML deflate + base64 encoding
--   curl          — fetch rendered SVG from the PlantUML server
--   rsvg-convert  — convert SVG to PNG for LaTeX / PDF output
--
-- The container must be started with --network=host so that
-- localhost:8080 resolves to the host's PlantUML server.
--
-- For HTML output the SVG is embedded inline; for all other outputs
-- (including PDF) the SVG is converted to PNG via rsvg-convert.

local encode_script = [[
import sys, zlib, base64
data = sys.stdin.buffer.read()
compressed = zlib.compress(data)[2:-4]
b64 = base64.b64encode(compressed).decode()
alpha = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_'
std  = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
print(''.join(alpha[std.index(c)] if c in std else c for c in b64), end='')
]]

local img_counter = 0

function CodeBlock(el)
  if el.classes[1] ~= "plantuml" then return el end

  img_counter = img_counter + 1

  local encoded = pandoc.pipe("python3", { "-c", encode_script }, el.text)
  encoded = encoded:gsub("%s+", "")

  local svg_url  = "http://localhost:8080/svg/" .. encoded
  local svg_file = "/tmp/puml_diagram_" .. img_counter .. ".svg"

  -- Fetch SVG from the PlantUML server
  local ok, err = pcall(function()
    pandoc.pipe("curl", { "-fsSL", "-o", svg_file, svg_url }, "")
  end)

  if not ok then
    io.stderr:write("plantuml-filter: failed to fetch diagram " .. img_counter
      .. " (is the PlantUML server running on localhost:8080?): " .. tostring(err) .. "\n")
    return el
  end

  -- For HTML output embed the SVG directly; for all other formats (PDF/LaTeX)
  -- convert to PNG so the renderer doesn't need native SVG support.
  local fmt = FORMAT or ""
  if fmt == "html" or fmt == "html5" or fmt == "html4" then
    local svg_data = io.open(svg_file, "r")
    if svg_data then
      local content = svg_data:read("*a")
      svg_data:close()
      return pandoc.RawBlock("html", content)
    end
  end

  -- Raster fallback: convert SVG → PNG using rsvg-convert (bundled in pandoc/extra)
  local png_file = "/tmp/puml_diagram_" .. img_counter .. ".png"
  local conv_ok, conv_err = pcall(function()
    pandoc.pipe("rsvg-convert", { "-o", png_file, svg_file }, "")
  end)

  if not conv_ok then
    io.stderr:write("plantuml-filter: rsvg-convert failed for diagram " .. img_counter
      .. ": " .. tostring(conv_err) .. "\n")
    -- rsvg-convert is not available: fall back to the SVG path so the caller
    -- sees a clear error rather than a silent failure; PDF/LaTeX output will
    -- not render this image, but the document will still build.
    return pandoc.Para({ pandoc.Image({ pandoc.Str("diagram") }, svg_file) })
  end

  return pandoc.Para({ pandoc.Image({ pandoc.Str("diagram") }, png_file) })
end
