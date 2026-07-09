module HelloFs.Program

// Sample F# project — a real `.fsproj` so fsautocomplete resolves *project*
// options (unlike a standalone `.fsx`) and completions work reliably.
//
// Test: open this file, wait for fsautocomplete to finish loading, then type
// `List.` — the completion menu should list `map`, `filter`, `sum`, …
// (`gd`/`K`/`gr` and hover should also work.)

let greet name =
    sprintf "Hello, %s!" name

let add a b = a + b

let numbers = [ 1; 2; 3; 4; 5 ]

let sumOfSquares (xs: int list) =
    xs |> List.map (fun x -> x * x) |> List.sum

[<EntryPoint>]
let main _argv =
    printfn "%s" (greet "F#")
    printfn "add 2 3 = %d" (add 2 3)
    printfn "sum of squares = %d" (sumOfSquares numbers)
    0
