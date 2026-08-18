using System;
using System.Collections.Generic;
using System.Linq;

class Program
{
    static void Main()
    {
        List<int> numbers = new List<int>()
        {
            5, 12, 8, 20, 15, 30, 10, 18, 25
        };

        var result = numbers
            .Where(x => x > 10 && x % 2 == 0)
            .OrderByDescending(x => x);

        Console.WriteLine("Even numbers greater than 10 in descending order:");

        foreach (int num in result)
        {
            Console.WriteLine(num);
        }
    }
}
