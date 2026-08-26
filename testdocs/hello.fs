module HelloWorld

let greet name = sprintf "Hello, %s!" name

[<EntryPoint>]
let main _ =
    printfn "%s" (greet "World")
    0

// Indent/fold fixture. F# ships neither an indents.scm nor a folds.scm, and
// fsautocomplete is not installed, so this exercises the indent fallback on
// both axes. See openspec TEST_PLAN, change align-treesitter-providers.

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
