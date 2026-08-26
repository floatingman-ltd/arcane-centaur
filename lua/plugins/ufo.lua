-- ufo's provider_selector accepts at most TWO providers, a main and a
-- fallback (ufo/fold/manager.lua:110-121). A third throws
-- UnhandledPromiseRejection and ufo then produces *no folds at all* -- it
-- does not degrade. So the second slot has to be chosen deliberately
-- rather than chaining lsp -> treesitter -> indent.
--
-- The choice mirrors the indent guard in lua/plugins/treesitter.lua: use
-- treesitter only where nvim-treesitter ships a folds.scm for the
-- language, and fall back to indent where it does not. Computed rather
-- than listed, so it stays correct as queries come and go upstream.
-- Filetype and language names differ, hence the resolve.
local function has_fold_query(ft)
  local ok, lang = pcall(vim.treesitter.language.get_lang, ft)
  if not ok or not lang then
    return false
  end
  return #vim.api.nvim_get_runtime_file("queries/" .. lang .. "/folds.scm", true) > 0
end

return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    opts = {
      -- HISTORY, worth keeping: treesitter folding was removed from *every*
      -- filetype in May 2026 (commit 1912875) because of UnhandledPromiseRejection
      -- errors in glow's preview buffer when pressing ,pp. That was a fix made
      -- broader than its cause -- Lua, C#, Haskell and the whole Lisp family lost
      -- structural folding to resolve an error in one plugin's terminal buffer.
      --
      -- It is restored because the cause is gone three ways over: glow was removed
      -- in replace-glow-renderer, the in-editor float that replaced it is
      -- buftype=nofile with foldmethod=manual and was verified not to reproduce the
      -- error, and ufo now checks for a folds.scm itself before using the provider
      -- (ufo/provider/treesitter.lua:160).
      --
      -- Note the original commit blamed "special/temporary buffers" rather than
      -- glow specifically, so if UnhandledPromiseRejection ever returns, suspect
      -- the provider list shape first -- that is what produces it today.
      provider_selector = function(_, filetype, _)
        -- asciidoctor manages its own section folding (foldmethod=expr via
        -- vim-asciidoctor); let it own folds rather than ufo's providers.
        if filetype == "asciidoctor" then
          return ""
        end

        -- markdown has no language server installed (marksman is configured but
        -- absent), so the lsp slot would be dead weight -- and with only two slots
        -- it would cost the indent fallback that keeps list folding working.
        -- treesitter is what supplies heading folds here.
        if filetype == "markdown" then
          return { "treesitter", "indent" }
        end

        -- LSP first everywhere else, so Roslyn's C# #region folds keep precedence.
        return { "lsp", has_fold_query(filetype) and "treesitter" or "indent" }
      end,
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ("  ··· %d lines ···"):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "UfoFoldedEllipsis" })
        return newVirtText
      end,
    },
  },
}
