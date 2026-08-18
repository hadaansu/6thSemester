using System;

class Student
{
    // Auto-implemented properties
    public string Name { get; set; }
    public int Roll { get; set; }
    public float Marks { get; set; }

    // Constructor
    public Student(string name, int roll, float marks)
    {
        Name = name;
        Roll = roll;
        Marks = marks;
    }

    // Method to display student details
    public void Display()
    {
        Console.WriteLine("Name: " + Name);
        Console.WriteLine("Roll: " + Roll);
        Console.WriteLine("Marks: " + Marks);
    }
}

class Program
{
    static void Main()
    {
        // Object creation
        Student s1 = new Student("Ram", 1, 85.5f);

        // Display student details
        s1.Display();
    }
}