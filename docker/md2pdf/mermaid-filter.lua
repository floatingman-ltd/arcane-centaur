-- Pandoc Lua filter: render mermaid fenced code blocks via the Kroki public
-- API (https://kroki.io).  No local server or Node.js installation is needed.
--
-- Requirements (available in pandoc/extra):
--   python3  — base64url encoding of the diagram source
--   wget     — fetch rendered PNG from the Kroki API
--
-- The container must be started with --network=host (already the case for
-- MdToPdf) so that general internet access is available.
--
-- To self-host Kroki instead of using the public endpoint, change
-- KROKI_BASE_URL below to point at your own instance.

local KROKI_BASE_URL = "https://kroki.io"

local encode_script = [[
import sys, base64
data = sys.stdin.buffer.read()
print(base64.urlsafe_b64encode(data).decode().rstrip('='), end='')
]]

local img_counter = 0

function CodeBlock(el)
  if el.classes[1] ~= "mermaid" then return el end

  img_counter = img_counter + 1

  local encoded = pandoc.pipe("python3", { "-c", encode_script }, el.text)
  encoded = encoded:gsub("%s+", "")

  local tmpfile = "/tmp/mermaid_diagram_" .. img_counter .. ".png"
  local url     = KROKI_BASE_URL .. "/mermaid/png/" .. encoded

  local ok, err = pcall(function()
    pandoc.pipe("wget", { "-q", "-O", tmpfile, url }, "")
  end)

  if not ok then
    io.stderr:write("mermaid-filter: failed to fetch diagram " .. img_counter
      .. " (is the Kroki API reachable at " .. KROKI_BASE_URL .. "?): "
      .. tostring(err) .. "\n")
    return el
  end

  return pandoc.Para({ pandoc.Image({ pandoc.Str("diagram") }, tmpfile) })
end
