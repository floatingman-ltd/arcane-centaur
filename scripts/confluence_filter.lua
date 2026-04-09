-- confluence_filter.lua — pandoc Lua filter producing Confluence storage format
--
-- Transformations applied to the AST before HTML output:
--   Link    → replaces relative links with Confluence URLs from the page map
--   CodeBlock → Confluence ac:structured-macro code block
--   CodeBlock (plantuml) → inline PNG via local PlantUML server, or code macro fallback
--
-- Environment variables (set by confluence_publish.sh):
--   CONFLUENCE_PAGE_MAP   absolute path to docs/confluence-page-map.md
--   CONFLUENCE_SELF_URL   Confluence URL of the page being published
--   CONFLUENCE_DOCS_DIR   absolute path to the docs/ directory
--   CONFLUENCE_FILE_PATH  absolute path of the markdown file being converted
--   PLANTUML_SERVER       base URL of the local PlantUML server (default: http://localhost:8080)

local self_url       = os.getenv("CONFLUENCE_SELF_URL")  or ""
local docs_dir       = os.getenv("CONFLUENCE_DOCS_DIR")  or ""
local file_path      = os.getenv("CONFLUENCE_FILE_PATH") or ""
local map_file       = os.getenv("CONFLUENCE_PAGE_MAP")  or ""
local puml_server    = os.getenv("PLANTUML_SERVER")      or "http://localhost:8080"

-- ── Page map ─────────────────────────────────────────────────────────────────

local page_map = {}

if map_file ~= "" then
  local f = io.open(map_file, "r")
  if f then
    for line in f:lines() do
      -- Match table rows: | `local/path.md` | Display Name | https://... |
      local path, name, url = line:match("^|%s*`([^`]+)`%s*|%s*(.-)%s*|%s*(https?://[^%s|]+)%s*|")
      if path then
        page_map[path] = { name = name, url = url }
      end
    end
    f:close()
  end
end

-- ── Path resolution ───────────────────────────────────────────────────────────

-- Resolve a relative link target to a docs/-relative key.
local function resolve_to_key(rel_target)
  local file_dir = file_path:match("^(.*)/[^/]*$") or ""

  -- Build an absolute path by walking the segments
  local parts = {}
  for p in (file_dir .. "/"):gmatch("([^/]+)/") do
    table.insert(parts, p)
  end
  for seg in rel_target:gmatch("[^/]+") do
    if seg == ".." then
      if #parts > 0 then table.remove(parts) end
    elseif seg ~= "." then
      table.insert(parts, seg)
    end
  end

  local abs = "/" .. table.concat(parts, "/")

  -- Strip the docs_dir prefix to get the page-map key
  local escaped = docs_dir:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
  return abs:gsub("^" .. escaped .. "/?", "")
end

-- ── Link transformation ───────────────────────────────────────────────────────

function Link(el)
  local target = el.target

  -- Bare anchor: point at the current page's Confluence URL
  if target:match("^#") then
    if self_url ~= "" then
      el.target = self_url .. target
    end
    return el
  end

  -- Leave absolute URLs untouched
  if target:match("^https?://") or target:match("^mailto:") then
    return el
  end

  -- Split path from anchor fragment
  local path  = target
  local anchor = ""
  local hash   = target:find("#", 1, true)
  if hash then
    path   = target:sub(1, hash - 1)
    anchor = target:sub(hash)
  end

  if path == "" then return el end

  local key   = resolve_to_key(path)
  local entry = page_map[key]
  if not entry then return el end

  if entry.url and entry.url ~= "" then
    el.target  = entry.url .. anchor
    el.content = pandoc.Inlines(pandoc.Str(entry.name))
    return el
  end

  -- In the page map but no Confluence URL assigned yet
  return pandoc.Strong(pandoc.Inlines(pandoc.Str("TODO: LINK MISSING " .. entry.name)))
end

-- ── Code block transformation ─────────────────────────────────────────────────

local lang_map = {
  csharp = "c#", cs = "c#",
  js     = "javascript", ts = "typescript",
  sh     = "bash", shell = "bash",
}

-- Attempt to render a PlantUML source block to a base64 PNG via the local server.
local function render_plantuml(source)
  local tmp = os.tmpname()
  local f   = io.open(tmp, "w")
  if not f then return nil end
  f:write(source)
  f:close()

  local cmd    = string.format(
    "curl -sf --max-time 10 -X POST --data-binary @%s %s/png 2>/dev/null | base64 -w 0",
    tmp, puml_server
  )
  local handle = io.popen(cmd)
  local b64    = handle and handle:read("*a") or ""
  if handle then handle:close() end
  os.remove(tmp)

  if b64 ~= "" then return b64 end
  return nil
end

-- Base64-encode source text for safe embedding in an HTML comment.
-- Runs the system `base64` tool via a temp file to avoid shell-escaping issues.
local function encode_b64(source)
  local tmp = os.tmpname()
  local f   = io.open(tmp, "w")
  if not f then return nil end
  f:write(source)
  f:close()
  local handle = io.popen("base64 -w 0 < " .. tmp)
  local result = handle and handle:read("*a") or ""
  if handle then handle:close() end
  os.remove(tmp)
  result = result:match("^(.-)%s*$")  -- trim trailing whitespace
  return result ~= "" and result or nil
end

local function confluence_code_macro(lang, code)
  local conf_lang = lang_map[lang:lower()] or (lang ~= "" and lang:lower() or "none")
  local safe_code = code:gsub("%]%]>", "]] >")
  return string.format(
    '<ac:structured-macro ac:name="code">'
      .. '<ac:parameter ac:name="language">%s</ac:parameter>'
      .. '<ac:parameter ac:name="linenumbers">false</ac:parameter>'
      .. '<ac:plain-text-body><![CDATA[%s]]></ac:plain-text-body>'
      .. '</ac:structured-macro>',
    conf_lang, safe_code
  )
end

function CodeBlock(el)
  local lang = (el.classes[1] or ""):gsub("^language%-", "")

  -- PlantUML: try inline PNG, fall back to code macro.
  -- When rendering succeeds the source is stashed in an HTML comment immediately
  -- before the <img> tag so that confluence_preproc.py can recover the fenced
  -- block when pulling the page back (round-trip).
  if lang:lower() == "plantuml" or lang:lower() == "puml" then
    local b64 = render_plantuml(el.text)
    if b64 then
      local src_b64 = encode_b64(el.text)
      local comment = src_b64
        and string.format("<!-- plantuml_src_b64: %s -->", src_b64)
        or  ""
      return pandoc.RawBlock("html",
        string.format('%s<p><img src="data:image/png;base64,%s" /></p>', comment, b64))
    end
    return pandoc.RawBlock("html", confluence_code_macro("none", el.text))
  end

  return pandoc.RawBlock("html", confluence_code_macro(lang, el.text))
end
