#!/usr/bin/env lua
-- confluence_preproc.lua — Pre-process Confluence storage-format HTML into
-- standard HTML suitable for conversion to CommonMark via pandoc.
--
-- Usage (drop-in replacement for confluence_preproc.py):
--   cat storage.html | lua confluence_preproc.lua | pandoc --from=html --to=commonmark
--
-- Called automatically by confluence_publish.sh --pull.
--
-- Transformations applied (in order, matching confluence_preproc.py behaviour):
--   plantuml_src_b64 comment + <img>         → <pre><code class="language-plantuml">
--   ac:structured-macro name="code"          → <pre><code class="language-X">
--   ac:structured-macro name="info|note|.."  → <blockquote>
--   ac:structured-macro name="expand"        → unwrapped rich-text body
--   Remaining ac:structured-macro elements   → stripped (content discarded)
--   CDATA sections                           → HTML-escaped inline text
--   ac:* and ri:* namespace tags             → stripped (inner text kept)

-- ── HTML helpers ──────────────────────────────────────────────────────────────

local function html_escape(s)
  return (s:gsub('&', '&amp;')
            :gsub('<', '&lt;')
            :gsub('>', '&gt;')
            :gsub('"', '&quot;'))
end

-- Decode a base64 string using the system `base64` command (via temp file).
local function b64_decode(b64)
  local tmp = os.tmpname()
  local f = io.open(tmp, 'w')
  if not f then return nil end
  f:write(b64)
  f:close()
  local handle = io.popen('base64 -d < ' .. tmp .. ' 2>/dev/null')
  local result = handle and handle:read('*a') or ''
  if handle then handle:close() end
  os.remove(tmp)
  return result ~= '' and result or nil
end

-- Trim leading/trailing whitespace.
local function trim(s)
  return s:match('^%s*(.-)%s*$')
end

-- ── Macro converters ──────────────────────────────────────────────────────────

-- Convert a Confluence code macro block to an HTML <pre><code> block.
local function convert_code_macro(block)
  local lang = block:match('ac:name="language"[^>]*>([^<]*)</ac:parameter>') or ''
  -- CDATA body takes priority; fall back to plain-text-body
  local body = block:match('<!%[CDATA%[([%s%S]-)%]%]>')
            or block:match('<ac:plain%-text%-body>([%s%S]-)</ac:plain%-text%-body>')
            or ''
  return '<pre><code class="language-' .. trim(lang) .. '">'
      .. html_escape(trim(body))
      .. '</code></pre>'
end

-- Convert info/note/warning/tip panel macros to <blockquote> elements.
local function convert_panel(macro_type, block)
  local body = block:match('<ac:rich%-text%-body>([%s%S]-)</ac:rich%-text%-body>') or ''
  return '<blockquote><p><strong>' .. macro_type:upper() .. ':</strong></p>\n'
      .. trim(body) .. '\n</blockquote>'
end

-- ── Main preprocessing ────────────────────────────────────────────────────────

local function preprocess(text)
  -- PlantUML round-trip: recover source from the HTML comment stashed on publish.
  -- Pattern: <!-- plantuml_src_b64: BASE64 --><p><img .../></p>
  text = text:gsub(
    '<!%-%- plantuml_src_b64: ([A-Za-z0-9+/=]+) %-%->[%s]*<p><img[^>]-/></p>',
    function(b64)
      local src = b64_decode(b64)
      if not src then return '<!-- plantuml decode failed -->' end
      return '<pre><code class="language-plantuml">' .. html_escape(src) .. '</code></pre>'
    end)

  -- Code macros — must run before the global CDATA sweep so the code body
  -- is extracted before CDATA delimiters are HTML-escaped.
  text = text:gsub(
    '<ac:structured%-macro[^>]*ac:name="code"[^>]*>[%s%S]-</ac:structured%-macro>',
    convert_code_macro)

  -- Info / note / warning / tip panel macros.
  for _, t in ipairs({ 'info', 'warning', 'note', 'tip' }) do
    text = text:gsub(
      '<ac:structured%-macro[^>]*ac:name="' .. t .. '"[^>]*>[%s%S]-</ac:structured%-macro>',
      function(block) return convert_panel(t, block) end)
  end

  -- Expand / collapsible macros — keep the rich-text body content.
  text = text:gsub(
    '<ac:structured%-macro[^>]*ac:name="expand"[^>]*>[%s%S]-</ac:structured%-macro>',
    function(block)
      local body = block:match('<ac:rich%-text%-body>([%s%S]-)</ac:rich%-text%-body>') or ''
      return trim(body)
    end)

  -- Drop any remaining structured macros (TOC, status, Jira, etc.).
  text = text:gsub('<ac:structured%-macro[^>]*>[%s%S]-</ac:structured%-macro>', '')

  -- Remaining CDATA sections (outside macros) → HTML-escaped text.
  text = text:gsub('<!%[CDATA%[([%s%S]-)%]%]>', function(c)
    return html_escape(c)
  end)

  -- Strip ac: and ri: namespace tags, keeping any inner text content.
  -- Handle both self-closing and regular open/close tags.
  text = text:gsub('<ac:[^>]-/>', '')
  text = text:gsub('</?ac:[^>]->', '')
  text = text:gsub('<ri:[^>]-/>', '')
  text = text:gsub('</?ri:[^>]->', '')

  return text
end

-- ── Entry point ───────────────────────────────────────────────────────────────

local input = io.read('*a')
io.write(preprocess(input))
