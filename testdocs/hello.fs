module HelloWorld

let greet name = sprintf "Hello, %s!" name

[<EntryPoint>]
let main _ =
    printfn "%s" (greet "World")
    0
