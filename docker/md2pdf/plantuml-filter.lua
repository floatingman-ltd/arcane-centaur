-- Pandoc Lua filter: render plantuml fenced code blocks via the local PlantUML
-- Docker server (http://localhost:8080).
--
-- Requirements (available in pandoc/extra):
--   python3  — PlantUML deflate + base64 encoding
--   wget     — fetch rendered PNG from the PlantUML server
--
-- The container must be started with --network=host so that
-- localhost:8080 resolves to the host's PlantUML server.

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

  local tmpfile = "/tmp/puml_diagram_" .. img_counter .. ".png"
  local url     = "http://localhost:8080/png/" .. encoded

  local ok, err = pcall(function()
    pandoc.pipe("wget", { "-q", "-O", tmpfile, url }, "")
  end)

  if not ok then
    io.stderr:write("plantuml-filter: failed to fetch diagram " .. img_counter
      .. " (is the PlantUML server running on localhost:8080?): " .. tostring(err) .. "\n")
    return el
  end

  return pandoc.Para({ pandoc.Image({ pandoc.Str("diagram") }, tmpfile) })
end
