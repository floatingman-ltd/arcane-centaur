module HelloWorld

let greet name = sprintf "Hello, %s!" name

[<EntryPoint>]
let main _ =
    printfn "%s" (greet "World")
    0

// Indent/fold fixture. F# ships neither an indents.scm nor a folds.scm, so this
// exercises the indent fallback on both axes. See openspec TEST_PLAN, change
// align-treesitter-providers.
//
// fsautocomplete IS installed now, but it cannot answer for this file: a bare
// .fs outside any project is never added to its loaded projects, so requests
// fail with "Couldn't find <path> in LoadedProjects" and opening the file alone
// logs an UnhandledPromiseRejection. That is fine for the indent/fold cases,
// which need no server response. Cases that do need one use hello.fsx.

type Shape =
    | Circle of float
    | Rect of float * float

let area shape =
    match shape with
    | Circle r ->
        System.Math.PI * r * r
    | Rect (w, h) ->
        w * h

let describe shape =
    let a = area shape
    if a > 100.0 then
        "large"
    elif a > 10.0 then
        "medium"
    else
        "small"

let summarise shapes =
    shapes
    |> List.map area
    |> List.sum
    |> printfn "total: %f"
