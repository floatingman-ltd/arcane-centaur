namespace HelloWorld;

class Program
{
    static string Greet(string name) => $"Hello, {name}!";

    static void Main(string[] args)
    {
        Console.WriteLine(Greet("World"));
    }
}
