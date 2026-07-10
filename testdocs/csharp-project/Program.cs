// Sample C# project — a real `.csproj` so roslyn.nvim gives completions/hover/
// go-to-def, and easy-dotnet + nvim-dap can run/debug/test it (Change 07).
//
// Test: open this file — roslyn attaches and completions work. Set a breakpoint
// in Main (<F9>) and press <F5> to debug; easy-dotnet's runner maps (,tr / ,tt)
// operate on this project too.

namespace HelloCs;

public static class Greeter
{
    public static string Greet(string name) => $"Hello, {name}!";

    public static int SumOfSquares(IEnumerable<int> numbers)
    {
        var total = 0;
        foreach (var n in numbers)
        {
            total += n * n;
        }
        return total;
    }
}

public static class Program
{
    public static void Main(string[] args)
    {
        Console.WriteLine(Greeter.Greet("C#"));
        Console.WriteLine($"add 2 + 3 = {2 + 3}");
        Console.WriteLine($"sum of squares = {Greeter.SumOfSquares(new[] { 1, 2, 3, 4, 5 })}");
    }
}
