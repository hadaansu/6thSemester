using System;

class Week
{
    string[] days = {
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday"
    };

    public string this[int index]
    {
        get
        {
            return days[index];
        }
    }
}

class Program
{
    static void Main()
    {
        Week week = new Week();

        Console.WriteLine("week[0] = " + week[0]);
        Console.WriteLine("week[1] = " + week[1]);
        Console.WriteLine("week[2] = " + week[2]);
        Console.WriteLine("week[6] = " + week[6]);
    }
}