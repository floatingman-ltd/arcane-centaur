module IndentFixture

// Fixture for the F# indentation cases in openspec/TEST_PLAN.md.
//
// Indentation comes from indent/fsharp.vim, a vendored third-party indent
// script. Nothing here needs a language server: indentation must work with
// fsautocomplete absent entirely.
//
// THIS FILE IS DELIBERATELY A BARE .fs OUTSIDE ANY PROJECT, so fsautocomplete
// cannot resolve options for it and will log
//     Couldn't find <path> in LoadedProjects
// on open. That is expected, and the error is a price worth paying:
//
//   Format-on-save goes through fsautocomplete, which needs resolved project
//   options. Outside a project it cannot run -- which is what protects this
//   file. Inside a project, a single :w would hand it to Fantomas, and Fantomas
//   collapses precisely the multi-line constructs every case below depends on:
//   `let inner y =` / `y + 1` becomes one line, the match arms collapse, the
//   if/elif/else chain collapses, the pipeline collapses. Measured: 41 lines
//   changed, every test case flattened.
//
// So do NOT "fix" the error by adding this file to HelloFs.fsproj or moving it
// into the project directory. Doing so makes the fixture destroy itself the
// first time someone saves it.
//
// Because that rejection fires once per EDIT rather than once on open, run the
// indentation cases with the server absent, or every Enter raises a hit-enter
// prompt you have to dismiss before the next keystroke:
//
//     env PATH=/usr/bin:/bin ~/nvim-linux-x86_64.appimage testdocs/indent-fixture.fs
//
// Indentation needs no server, so this costs no coverage. FI.5 covers the
// server-attached direction on testdocs/fsharp-project/Program.fs, which has a
// real .fsproj and produces no rejection at all.
//
// Every case below is checked by pressing Enter at the end of a line and then
// TYPING A CHARACTER. Vim strips autoindent from a line left empty, so `o`
// followed by <Esc> reports zero indent whatever the setting -- a false
// negative that has already caught two changes in this repository.

// --- Bodies that must be indented one shiftwidth deeper ---------------------

let outer x =
    let inner y =
        y + 1

    inner x

let area shape =
    match shape with
    | Circle r ->
        System.Math.PI * r * r
    | Rect (w, h) ->
        w * h

let describe n =
    if n > 100 then
        "large"
    elif n > 10 then
        "medium"
    else
        "small"

type Shape =
    | Circle of float
    | Rect of float * float

// --- Cases that already worked before the indent script, and must not regress

let plain a =
    a + 1

let pipeline xs =
    xs
    |> List.map (fun x -> x * x)
    |> List.sum

// --- Delimiters inside comments and strings ---------------------------------
//
// These exercise the LOCAL DEVIATION in indent/fsharp.vim: pair matching must
// not treat a delimiter written inside a comment or a string as a real one.
// Upstream's synID()-based check is inert here because F# is highlighted by
// treesitter, so without the deviation every decoy below wins.
//
// TWO THINGS ARE STRUCTURALLY NECESSARY, and both were wrong on the first
// attempt at this fixture:
//
//   1. The closing delimiter must be ON ITS OWN LINE. The indent script's
//      dedent branches match '^}$', '^]$' and '^)$' exactly, so a trailing
//      `Value = 1 }` never reaches the pair-matching path at all.
//
//   2. The decoy must be INSIDE the pair, between the opener and the closer.
//      searchpairpos() searches backwards for the nearest unmatched opener, so
//      a decoy placed before the construct is unreachable -- the real opener is
//      found first and the decoy never wins.
//
// Each closing delimiter below must reindent to 4, aligning with the line that
// opened it. Without the deviation they align with the decoy instead, at 6.

let recordWithCommentDecoy =
    { Name = "real"
      // a stray opening brace inside the record: {
      Value = 1
}

let recordWithStringDecoy =
    { A = 1
      B = "a stray opening brace in a string: {"
      C = 2
}

let recordWithBlockCommentDecoy =
    { A = 1
      (* a stray opening brace in a block comment: { *)
      B = 2
}

let recordWithCharDecoy =
    { A = 1
      B = '{'
      C = 2
}

let recordWithVerbatimDecoy =
    { A = 1
      B = @"a stray opening brace in a verbatim string: {"
      C = 2
}

// The bracket variant, same two requirements.

let listWithDecoy =
    [ 1
      // a stray opening bracket in a comment: [
      2
]

// Control: no decoy at all. Must also reindent to 4, which proves the
// deviation has not broken ordinary pair matching.

let plainRecord =
    { A = 1
      B = 2
}

let main _ =
    printfn "%s" (describe 50)
    printfn "%f" (area (Circle 2.0))
    0
