-- Minimal localhost static-file server built on Neovim's built-in libuv
-- (`vim.uv`) — no external runtime (python/node) required.
--
-- Used to serve generated preview HTML over `http://` so sandboxed browsers
-- (e.g. snap-packaged Firefox on Ubuntu, which cannot open `file://` URLs under
-- hidden dirs like ~/.cache) can load it. The server lives for the Neovim
-- session and is reused across previews.
--
--   local srv = require("config.http_preview")
--   srv.ensure(dir, 8092)            -- serve `dir` on 127.0.0.1:8092
--   -- open http://127.0.0.1:8092/<file>

local uv = vim.uv or vim.loop

local M = { _server = nil, _root = nil, _port = nil }

local MIME = {
  html = "text/html; charset=utf-8",
  htm  = "text/html; charset=utf-8",
  css  = "text/css",
  js   = "application/javascript",
  json = "application/json",
  svg  = "image/svg+xml",
  png  = "image/png",
  jpg  = "image/jpeg",
  jpeg = "image/jpeg",
  gif  = "image/gif",
}

local function mime_for(path)
  local ext = path:match("%.([%w]+)$")
  return (ext and MIME[ext:lower()]) or "application/octet-stream"
end

local function respond(client, status, ctype, body)
  local header = ("HTTP/1.1 %s\r\nContent-Type: %s\r\nContent-Length: %d\r\nConnection: close\r\n\r\n")
    :format(status, ctype, #body)
  client:write(header .. body, function()
    client:shutdown(function()
      if not client:is_closing() then client:close() end
    end)
  end)
end

local function serve_request(client, root)
  client:read_start(function(err, chunk)
    if err or not chunk then
      if not client:is_closing() then client:close() end
      return
    end
    client:read_stop()
    -- Parse the request line: "GET /path?query HTTP/1.1"
    local path = chunk:match("^%u+%s+([^%s%?]+)")
    if not path then
      return respond(client, "400 Bad Request", "text/plain", "bad request")
    end
    path = path:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
    if path == "/" then path = "/index.html" end
    if path:find("%.%.") then
      return respond(client, "403 Forbidden", "text/plain", "forbidden")
    end
    local fd = io.open(root .. path, "rb")
    if not fd then
      return respond(client, "404 Not Found", "text/plain", "not found: " .. path)
    end
    local body = fd:read("*a")
    fd:close()
    respond(client, "200 OK", mime_for(path), body or "")
  end)
end

--- Ensure a static server is serving `root` on 127.0.0.1:`port`.
--- Reuses a server already bound to the same root/port. Returns true on success.
function M.ensure(root, port)
  if M._server and M._root == root and M._port == port then
    return true
  end
  if M._server then
    pcall(function() M._server:close() end)
    M._server = nil
  end
  local server = uv.new_tcp()
  local ok = pcall(function() server:bind("127.0.0.1", port) end)
  if not ok then
    pcall(function() server:close() end)
    -- Port already bound (e.g. another Neovim instance already serving) — assume
    -- it serves the same preview dir and let the browser reach it.
    M._server, M._root, M._port = nil, root, port
    return true
  end
  server:listen(128, function(err)
    if err then return end
    local client = uv.new_tcp()
    server:accept(client)
    serve_request(client, root)
  end)
  M._server, M._root, M._port = server, root, port
  return true
end

return M
