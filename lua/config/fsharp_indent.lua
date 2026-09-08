-- Treesitter support for the vendored F# indent script (indent/fsharp.vim).
--
-- That file is third-party and is kept as close to upstream as possible so it
-- can be diffed against the commit recorded in its header. This module holds
-- the one behaviour that had to change for this configuration, so the change
-- lives in Lua alongside everything else here rather than as more Vimscript.
--
-- Upstream detects comments and strings with synID()/synIDattr(), which need a
-- Vim `:syntax` file. F# here is highlighted by treesitter and
-- `b:current_syntax` is unset, so upstream's synID() always returns 0 and its
-- predicate always answered "not a comment". Because it is the skip predicate
-- handed to searchpairpos(), brace/bracket/paren matching could not skip
-- delimiters written inside comments or string literals.

local M = {}

-- Captures, not node types. Node types would miss one case: a char literal
-- holding a brace, `'{'`, is node type `char`, which matches neither "comment"
-- nor "string". Its capture is `string`, so capture-based detection covers all
-- six comment and string forms F# has:
--
--   //             -> line_comment           / comment
--   (* *)          -> block_comment_content  / comment
--   "..."          -> string                 / string
--   @"..."         -> verbatim_string        / string
--   """..."""      -> triple_quoted_string   / string
--   '{'            -> char                   / string
--
-- while real code (`brace_expression`, capture `punctuation.bracket`) is
-- correctly excluded.
local SKIP_CAPTURES = { comment = true, string = true }

--- Is the cursor inside a comment or a string literal?
---
--- Called from `s:IsInCommentOrString()` in indent/fsharp.vim via `luaeval`.
--- Returns a tri-state rather than a boolean so the caller can fall back to
--- upstream's synID path, which keeps behaviour no worse than upstream anywhere
--- treesitter is unavailable.
---
--- Deliberately does **not** call `parser:parse()`. This runs inside
--- searchpairpos(), which invokes it once per candidate delimiter, itself inside
--- `indentexpr`, which runs on keystrokes -- forcing a parse here would put a
--- full reparse in the typing path. A live buffer's tree is already current, and
--- an unavailable tree yields no captures, which reads as 0: the safe answer.
---
---@return integer # 1 in a comment or string, 0 in code, -1 undecidable
function M.at_cursor_is_comment_or_string()
  local buf = vim.api.nvim_get_current_buf()

  -- No treesitter highlighting for this buffer: let the caller use synID.
  if not vim.treesitter.highlighter.active[buf] then
    return -1
  end

  local pos = vim.api.nvim_win_get_cursor(0)
  local row, col = pos[1], pos[2]
  local ok, captures = pcall(vim.treesitter.get_captures_at_pos, buf, row - 1, math.max(0, col))
  if not ok then
    return -1
  end

  for _, capture in ipairs(captures) do
    if SKIP_CAPTURES[capture.capture] then
      return 1
    end
  end

  return 0
end

return M
