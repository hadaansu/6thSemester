using System;

class Stack<T>
{
    private T[] items = new T[10];
    private int top = -1;

    public void Push(T item)
    {
        if (top == items.Length - 1)
        {
            Console.WriteLine("Stack Overflow");
        }
        else
        {
            top++;
            items[top] = item;
            Console.WriteLine(item + " pushed into stack.");
        }
    }

    public T Pop()
    {
        if (top == -1)
        {
            Console.WriteLine("Stack Underflow");
            return default(T);
        }

        T item = items[top];
        top--;

        return item;
    }

    public T Peek()
    {
        if (top == -1)
        {
            Console.WriteLine("Stack is empty.");
            return default(T);
        }

        return items[top];
    }
}

class Program
{
    static void Main()
    {
        // Stack with integer data
        Stack<int> intStack = new Stack<int>();

        intStack.Push(10);
        intStack.Push(20);
        intStack.Push(30);

        Console.WriteLine("Top integer: " + intStack.Peek());
        Console.WriteLine("Popped integer: " + intStack.Pop());

        Console.WriteLine();

        // Stack with string data
        Stack<string> stringStack = new Stack<string>();

        stringStack.Push("Apple");
        stringStack.Push("Banana");
        stringStack.Push("Mango");

        Console.WriteLine("Top string: " + stringStack.Peek());
        Console.WriteLine("Popped string: " + stringStack.Pop());
    }
}
