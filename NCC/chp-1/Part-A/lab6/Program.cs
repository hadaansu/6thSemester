using System;
using System.Collections.Generic;

interface IPayable
{
    void Pay();
}

class Invoice : IPayable
{
    public double Amount;

    public Invoice(double amount)
    {
        Amount = amount;
    }

    public void Pay()
    {
        Console.WriteLine("Invoice paid: $" + Amount);
    }
}

class Salary : IPayable
{
    public double Amount;

    public Salary(double amount)
    {
        Amount = amount;
    }

    public void Pay()
    {
        Console.WriteLine("Salary paid: $" + Amount);
    }
}

class Program
{
    static void Main()
    {
        List<IPayable> payments = new List<IPayable>();

        payments.Add(new Invoice(5000));
        payments.Add(new Salary(30000));

        foreach (IPayable payment in payments)
        {
            payment.Pay();
        }
    }
}