" ============================================================================
" VENDORED THIRD-PARTY FILE -- not written here, and not byte-identical to
" upstream.  Read this before editing.
"
"   Upstream:  https://github.com/ionide/Ionide-vim
"   Path:      indent/fsharp.vim
"   Commit:    094e7dbb8f77  (2026-04-07, "Rewrite indent function based on
"              PhilT's vim-fsharp plugin")
"   Licence:   MIT -- see the attribution block below, which is upstream's and
"              is left untouched.
"
" WHY VENDORED RATHER THAN INSTALLED
"   F# has no indentation support from any other source: nvim-treesitter ships
"   no indents.scm for F# (there is no queries/fsharp directory at all), LSP has
"   no indent-as-you-type concept, and smartindent keys off braces F# never
"   uses.  A hand-written indentexpr is the only mechanism, and this is the only
"   maintained one.
"
"   This file is self-contained -- it references nothing else in Ionide-vim -- so
"   only it is taken.  Installing the plugin would also bring a second
"   FsAutoComplete LSP client, `setl fdm=syntax` (replacing the LSP folds this
"   configuration validated), a regex syntax/fsharp.vim (worse than treesitter),
"   commentstring=(*%s*), and FSI keymaps colliding with iron.nvim -- five
"   duplicates of things already working here.
"
" LOCAL DEVIATION -- ONE FUNCTION DIFFERS FROM UPSTREAM
"   s:IsInCommentOrString() has been rewritten.  Upstream detects comments and
"   strings with synID()/synIDattr(), which require a Vim :syntax file.  F# here
"   is highlighted by treesitter and b:current_syntax is unset, so upstream's
"   synID() always returns 0 and the predicate always answered "not a comment".
"   Since it is the skip predicate passed to searchpairpos(), that left brace,
"   bracket and paren matching unable to skip delimiters inside comments and
"   string literals.
"
"   The replacement asks treesitter and falls back to upstream's synID path when
"   treesitter is unavailable, so behaviour is never worse than upstream.  See
"   lua/config/fsharp_indent.lua.
"
" REFRESHING FROM UPSTREAM
"   1. Diff against the recorded commit:
"        git -C <clone> diff 094e7dbb8f77 -- indent/fsharp.vim
"   2. Apply what you want, then bump the Commit: line above.
"   3. RE-APPLY THE DEVIATION.  A straight overwrite reverts it, and does so
"      silently -- the reverted predicate returns a plausible answer rather than
"      erroring, so nothing breaks visibly and pair matching quietly regresses.
"
" See openspec/changes/archive/*-add-fsharp-indent/ for the full rationale.
" ============================================================================

" Vim indent file
" Language:     FSharp
" Maintainers:  Jean-Francois Yuen   <jfyuen@happycoders.org>
"               Mike Leary           <leary@nwlink.com>
"               Markus Mottl         <markus.mottl@gmail.com>
"               Rudi Grinberg        <rudi.grinberg@gmail.com>
"               Gregor Uhlenheuer    <kongo2002@gmail.com>
"               Phil Thompson        <phil@electricvisions.com>
"               Julian Pottle        <julian.pottle@gmail.com>
" Last Change:  2013 Jun 29
"               2005 Jun 25 - Fixed multiple bugs due to 'else\nreturn ind' working
"               2005 May 09 - Added an option to not indent OCaml-indents specially (MM)
"               2013 June   - commented textwidth (Marc Weber)
"               2014 August - Ported to F#
"               2014 August - F# specific cleanup
"               2026 April  - Rewrite based on PhilT's vim-fsharp plugin

" Only load this indent file when no other was loaded.

if exists("b:did_indent")
    finish
endif
let b:did_indent = 1

setlocal indentexpr=FSharpIndent()
setlocal indentkeys+=0=\|,0=\|],0=when,0=elif,0=else,0=\|\>,==,=with

" Only define the function once
if exists("*FsharpIndent")
    finish
endif

" Debug logging
if $VIM_FS_VERBOSE == 'true'
    command! -nargs=1 Log echom <args>
else
    command! -nargs=1 Log echom
endif

let s:funcRegex = '^\s*\(let\|member\|default\|override\) .\+ =\s*$'
let s:classRegex = '^\s*type .\+ =\s*$'
let s:letClassRegex = s:funcRegex.'\|'.s:classRegex
let s:moduleRegex = '^\s*module .\+ =\s*$'
let s:matchRegex = '\s*match .\+ with$'
let s:matchCaseRegex = '^\s*| .\+ ->.*$'
let s:recordRegex = '^\s*.\+ with$\|{$'

function! s:TrimSpacesAndComments(line)
    let line = substitute(a:line, '\v(.*)\/\/.*', '\1', '')
    return substitute(line, '\v^\s*(.{-})\s*$', '\1', '')
endfunction

function! s:ScopedFind(regex, start_line, scope)
    let lnum = a:start_line
    let max_indent = a:scope
    let indent = a:scope
    let line = ''
    let in_comment = 0
    let blank_lines = 0

    Log 'ScopedFind scope is '.a:scope

    " This loop terminates when a line matches the regex,
    " we reach the top of the file,
    " or we go out of function scope (2 blank lines)
    " In addition, it ignores lines that are indented further
    while lnum > 0 && blank_lines < 2 && (
            \ in_comment || line == "" || indent > max_indent ||
            \ line !~ a:regex
            \ )
        let lnum -= 1
        let line = getline(lnum)
        let indent = indent(lnum)

        Log 'lnum:'.lnum.', indent:'.indent.', max_indent:'.max_indent
        Log 'in_comment:'.in_comment.', line:'.line

        " Indicate if we are in a multiline comment
        if line =~ '*)$'
            let in_comment = 1
        endif
        if line =~ '^\s*(*'
            let in_comment = 0
        endif
        if line == ''
            blank_lines += 1
        else
            blank_lines = 0
        endif
    endwhile

    Log 'Blank lines '.blank_lines
    Log 'ScopedFind matched on line '.lnum.': ['.line.']'
    return line =~ a:regex ? lnum : -1
endfunction

" >>> LOCAL DEVIATION FROM UPSTREAM -- see the header. A refresh MUST re-apply
"     this, and will revert it silently if it does not.
"
"     Upstream's body was:
"         let symbol_type = synIDattr(synID(line("."), col("."), 0), "name")
"         return (symbol_type =~? 'comment\|string')
"
"     synID() needs a Vim :syntax file. F# here is highlighted by treesitter and
"     b:current_syntax is unset, so synID() returns 0 and that always answered
"     "not a comment" -- leaving searchpairpos() unable to skip delimiters
"     inside comments and strings.
"
"     The Lua helper returns 1 / 0 / -1; -1 means "cannot tell" and falls
"     through to upstream's logic, so this is never worse than upstream.
function! s:IsInCommentOrString()
    let l:ts = luaeval('require("config.fsharp_indent").at_cursor_is_comment_or_string()')
    if l:ts >= 0
        Log 'IsInCommentOrString (treesitter): '.l:ts.' at line '.line('.').', col '.col('.')
        return l:ts
    endif
    let symbol_type = synIDattr(synID(line("."), col("."), 0), "name")
    Log 'IsInCommentOrString (syntax fallback): '.symbol_type.' at line '.line('.').', col '.col('.')
    return (symbol_type =~? 'comment\|string')
endfunction

function! s:SkipFunc()
    return s:IsInCommentOrString()
endfunction

function! s:FindPair(start_word, middle_word, end_word)
    Log 'FindPair: Currently at line: '.line('.').' and column: '.col('.')

    " Make sure we're inside the pair if outside but doesn't affect
    " if we're already inside due to auto-pairs
    let [lnum, col] = searchpairpos(a:start_word, a:middle_word, a:end_word,
            \ 'bWn', 's:SkipFunc()')

    Log 'FindPair matched on line '.lnum.': ['.getline(lnum).']'
    return lnum
endfunction

function! s:IndentPair(start_word, middle_word, end_word)
    return indent(s:FindPair(a:start_word, a:middle_word, a:end_word))
endfunction

let s:matchKeyword = '^\s*|$'
let s:matchCase = '^\s*| .*$'
let s:whenKeyword = '^\s*when$'
let s:whenClause = '^\s*when .\+ ->$'
let s:defaultCase = '^\s*| _ -> .\+$'

function! s:IndentMatchExpression(lnum)
    let curr_line = getline(a:lnum)
    let prev_lnum = prevnonblank(a:lnum - 1)
    let prev_line = getline(prev_lnum)
    let prev_indent = indent(prev_lnum)
    let indent = -1

    Log 'Current line: '.curr_line
    Log 'Previous line: '.prev_line

    if curr_line =~ s:matchKeyword.'\|'.s:matchCase.'\|'.s:whenKeyword ||
            \ prev_line =~ s:matchCase.'\|'.s:whenClause.'\|'.s:defaultCase

        let match_lnum = s:ScopedFind(s:matchRegex, a:lnum, prev_indent)

        if match_lnum != -1
            if prev_line =~ s:defaultCase
                Log '!match: default case'
                let indent = indent(match_lnum) - shiftwidth()
            elseif curr_line =~ s:matchKeyword.'\|'.s:matchCase
                Log '!match: case'
                let indent = indent(match_lnum)
            else
                Log '!match: result'
                let indent = indent(match_lnum) + shiftwidth()
            endif
        endif
    endif

    return indent
endfunction

function! FSharpIndent()
    let current_line = s:TrimSpacesAndComments(getline(v:lnum))
    let current_indent = indent(v:lnum)
    let previous_lnum = prevnonblank(v:lnum - 1)
    let previous_indent = indent(previous_lnum)
    let previous_line = s:TrimSpacesAndComments(getline(previous_lnum))
    let indent = previous_indent

    Log 'Detecting...'

    if v:lnum == 0
        Log '! at line 0. Setting indent to 0'
        return 0
    endif

    let indentForMatch = s:IndentMatchExpression(v:lnum)

    if indentForMatch != -1
        let indent = indentForMatch

    elseif current_line =~ '^}$'
        let indent = s:IndentPair('{', '', '}')
        Log '! dedent `}`: '.indent

    elseif current_line =~ '^\(]\||]\)$'
        let indent = s:IndentPair('\[', '', '\]')
        Log '! dedent `]`: '.indent

    elseif current_line =~ '^)$'
        let indent = s:IndentPair('(', '', ')')
        Log '! dedent `)`: '.indent

    elseif current_line =~ '^|>$'
        Log '! `|>` pipeline operator on current line'
        let indent = previous_indent

    elseif current_line =~ '^\(elif\( .* then\)\?\|else\)$'
        Log '! `elif/else` on current line'
        if previous_line =~ '^\(if\|elif\)'
            let indent = previous_indent
        else
            let indent = previous_indent - shiftwidth()
        endif

    elseif current_line =~ '^\s*\w\+ =$'
        Log '! Potential field'
        let lnum = s:ScopedFind(s:recordRegex.'\|'.s:matchRegex, v:lnum, previous_indent)
        let line = lnum == -1 ? '' : getline(lnum)
        if line !~ s:matchRegex && lnum != -1
            let indent = indent(lnum) + shiftwidth()
            let indent += line =~ '^\s*{.\+ with$' ? shiftwidth() : 0
        endif

    elseif current_line =~ '^\s*with$'
        Log '! with'
        let indent = previous_indent - shiftwidth()

    elseif previous_line =~ '^\s*\(try\|with\)$'
        Log '! try/with'
        let indent = previous_indent + shiftwidth()

    elseif previous_line =~ '=\s*$'
        Log '! let/module/member etc ='
        let indent = previous_indent + shiftwidth()

    elseif previous_line =~ '^\(let\|type\).*=\(\s\({\|[\|[|\)\)\?$'
        Log '! type/record/array/list'
        let indent = previous_indent + shiftwidth()

    elseif previous_line =~ '\([\|[|\|{\|[{\|(\)$'
        Log '! list/record/tuple'
        let indent = previous_indent + shiftwidth()

    elseif previous_line =~ '^{ .\+ with$'
        Log '! record copy and update expression (same line)'
        let indent = previous_indent + shiftwidth()

    elseif previous_line =~ '^.\+ with$'
        Log '! record copy and update expression (newline)'
        let indent = previous_indent + shiftwidth()

    elseif previous_line =~ '(fun\s.*->$'
        Log '! lambda'
        let indent = previous_indent + shiftwidth()

    elseif previous_line =~ '(\s*$'
        Log '! parens'
        let indent = previous_indent + shiftwidth()

    elseif previous_line =~ '^|>$'
        Log '! `|>` on previous line'
        let indent = previous_indent + shiftwidth()

    elseif (previous_lnum + 3) <= v:lnum
        Log '! two blank lines for end of function'
        if current_line == ''
            let lnum = s:ScopedFind(s:letClassRegex, v:lnum, previous_indent)
            let indent = lnum == -1 ? 0 : indent(lnum)
        else
            let indent = current_indent
        endif

    elseif previous_line =~ '^\s*\(if\|elif\) .* then$'
            \ || previous_line =~ '^else$'
        Log '! if/elif then'
        let indent = previous_indent + shiftwidth()

    elseif previous_line =~ '\sdo$'
        Log '! while/for do'
        let indent = previous_indent + shiftwidth()

    else
        Log '- keep indent of previous line'
        Log 'line matched ['.line.']'

    endif

    Log 'End of detection. Indent: '.indent

    return indent
endfunction

" vim: sw=4 et sts=4
