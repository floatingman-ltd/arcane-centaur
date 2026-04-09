#!/usr/bin/env lua
-- confluence_html_to_md.lua — Convert lightweight HTML (Confluence comment body)
-- to plain markdown text.
--
-- Reads from stdin, writes to stdout.
-- Called by confluence_publish.sh in place of the inline Python HTML stripper.

local function html_to_md(text)
  -- Block-level replacements
  text = text:gsub('<br%s*/?>', '\n')
  text = text:gsub('</?p[^>]*>', '\n')

  -- Inline formatting — use function replacements to avoid %N escape issues
  text = text:gsub('<strong[^>]*>([%s%S]-)</strong>',
    function(c) return '**' .. c .. '**' end)
  text = text:gsub('<em[^>]*>([%s%S]-)</em>',
    function(c) return '*' .. c .. '*' end)
  text = text:gsub('<code[^>]*>([%s%S]-)</code>',
    function(c) return '`' .. c .. '`' end)

  -- Hyperlinks: <a href="URL">text</a>
  text = text:gsub('<a[^>]*href="([^"]*)"[^>]*>([%s%S]-)</a>',
    function(href, content) return '[' .. content .. '](' .. href .. ')' end)

  -- Strip all remaining HTML tags
  text = text:gsub('<[^>]+>', '')

  -- HTML entity decoding
  text = text:gsub('&amp;',  '&')
  text = text:gsub('&lt;',   '<')
  text = text:gsub('&gt;',   '>')
  text = text:gsub('&quot;', '"')
  text = text:gsub('&#39;',  "'")
  text = text:gsub('&nbsp;', ' ')

  -- Collapse runs of 3+ newlines to a single blank line
  text = text:gsub('\n\n\n+', '\n\n')

  -- Trim leading/trailing whitespace
  return text:match('^%s*(.-)%s*$')
end

local input = io.read('*a')
io.write(html_to_md(input))
-- Ensure trailing newline
io.write('\n')
