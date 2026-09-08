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
// on open. That is expected and is the point: if indentation works here, it is
// demonstrably independent of the language server. Do not "fix" it by adding
// the file to HelloFs.fsproj -- that would remove the property being tested.
// Use testdocs/fsharp-project/Program.fs for anything that needs the server.
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
// treesitter, so without the deviation every brace below is treated as real.

// a decoy opening brace in a line comment: {

(* a decoy opening brace in a block comment: { *)

let decoyString = "an opening brace in a string: {"

let decoyVerbatim = @"an opening brace in a verbatim string: {"

let decoyTriple =
    """
    an opening brace in a triple-quoted string: {
    """

let decoyChar = '{'

// The record below is the control: its braces are real code, and the closing
// brace must align with the line that opened it -- not with any decoy above.
let record =
    { Name = "real"
      Value = 1 }

let nested =
    { Outer =
        { Inner = 1 }
      Other = 2 }

// --- A bracket variant, same idea -------------------------------------------

// decoy opening bracket in a comment: [

let listValue =
    [ 1
      2
      3 ]

let main _ =
    printfn "%s" (describe 50)
    printfn "%f" (area (Circle 2.0))
    0
