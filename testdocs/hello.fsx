// F# script fixture for the LSP cases in openspec/TEST_PLAN.md.
//
// This is a .fsx rather than a .fs deliberately. fsautocomplete resolves scripts
// on their own, but a bare .fs outside any project is never added to its loaded
// projects, so every request against one fails with
//   "Couldn't find <path> in LoadedProjects"
// and surfaces as an UnhandledPromiseRejection. See LS.4.
//
// testdocs/hello.fs stays as the loose-file indent/fold fixture; use this file
// wherever a case needs the server to actually answer.

let greet name = sprintf "Hello, %s!" name

type Shape =
    | Circle of float
    | Rect of float * float

let area shape =
    match shape with
    | Circle r -> System.Math.PI * r * r
    | Rect(w, h) -> w * h

let describe shape =
    let a = area shape

    if a > 100.0 then "large"
    elif a > 10.0 then "medium"
    else "small"

let summarise shapes = shapes |> List.map area |> List.sum

printfn "%s" (greet "World")
printfn "%s" (describe (Circle 5.0))
printfn "total area: %f" (summarise [ Circle 1.0; Rect(2.0, 3.0) ])
