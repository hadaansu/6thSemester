using System;
using System.Threading.Tasks;

class Program
{
    static async Task DownloadFile(string fileName, int time)
    {
        Console.WriteLine(fileName + " download started.");

        await Task.Delay(time);

        Console.WriteLine(fileName + " download completed.");
    }

    static async Task Main()
    {
        Task file1 = DownloadFile("File1", 3000);
        Task file2 = DownloadFile("File2", 2000);

        await Task.WhenAll(file1, file2);

        Console.WriteLine("Both downloads are complete.");
    }
}
