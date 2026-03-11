-- Pandoc Lua filter: render plantuml fenced code blocks via the local PlantUML
-- Docker server (http://localhost:8080) as SVG.
--
-- Requirements (available in pandoc/extra):
--   curl          — fetch rendered SVG from the PlantUML server
--   rsvg-convert  — convert SVG to PNG for LaTeX / PDF output
--
-- No Python or other external encoding tool is required; the PlantUML server's
-- native ~1 hex encoding is computed in pure Lua.
--
-- The container must be started with --network=host so that
-- localhost:8080 resolves to the host's PlantUML server.
--
-- For HTML output the SVG is embedded inline; for all other outputs
-- (including PDF) the SVG is converted to PNG via rsvg-convert.

--- Encode a PlantUML string using the server's ~1 hex encoding format.
--- The ~1 prefix signals hex encoding to the PlantUML server.
local function hex_encode(text)
  return "~1" .. text:gsub(".", function(c)
    return string.format("%02x", string.byte(c))
  end)
end

local img_counter = 0

function CodeBlock(el)
  if el.classes[1] ~= "plantuml" then return el end

  img_counter = img_counter + 1

  local svg_url  = "http://localhost:8080/svg/" .. hex_encode(el.text)
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
    io.stderr:write(string.format("plantuml-filter: rsvg-convert failed for diagram %d: %s\n",
      img_counter, tostring(conv_err)))
    -- rsvg-convert is not available: fall back to the SVG path so the caller
    -- sees a clear error rather than a silent failure; PDF/LaTeX output will
    -- not render this image, but the document will still build.
    return pandoc.Para({ pandoc.Image({ pandoc.Str("diagram") }, svg_file) })
  end

  return pandoc.Para({ pandoc.Image({ pandoc.Str("diagram") }, png_file) })
end
