using System;

class Shape
{
    public virtual void Area()
    {
        Console.WriteLine("Area of Shape");
    }
}

class Circle : Shape
{
    private double radius;

    public Circle(double r)
    {
        radius = r;
    }

    public override void Area()
    {
        double area = 3.14 * radius * radius;
        Console.WriteLine("Area of Circle = " + area);
    }
}

class Rectangle : Shape
{
    private double length;
    private double breadth;

    public Rectangle(double l, double b)
    {
        length = l;
        breadth = b;
    }

    public override void Area()
    {
        double area = length * breadth;
        Console.WriteLine("Area of Rectangle = " + area);
    }
}

class Program
{
    static void Main()
    {
        Shape shape;

        shape = new Circle(5);
        shape.Area();

        shape = new Rectangle(10, 4);
        shape.Area();
    }
}