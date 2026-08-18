using System;

abstract class Employee
{
    public string Name;

    public Employee(string name)
    {
        Name = name;
    }

    public abstract double CalculateSalary();
}

class Manager : Employee
{
    public Manager(string name) : base(name)
    {
    }

    public override double CalculateSalary()
    {
        return 50000 + 10000;
    }
}

class Clerk : Employee
{
    public Clerk(string name) : base(name)
    {
    }

    public override double CalculateSalary()
    {
        return 25000 + 3000;
    }
}

class Program
{
    static void Main()
    {
        Manager manager = new Manager("Anshu");
        Clerk clerk = new Clerk("Utsah");

        Console.WriteLine("Manager Name: " + manager.Name);
        Console.WriteLine("Manager Salary: " + manager.CalculateSalary());

        Console.WriteLine();

        Console.WriteLine("Clerk Name: " + clerk.Name);
        Console.WriteLine("Clerk Salary: " + clerk.CalculateSalary());
    }
}
