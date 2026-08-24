using System;
using System.IO;

class FileProcessing
{
    static void Main()
    {
        string inputFile = "input.txt";
        string outputFile = "output.txt";

        try
        {
            using (StreamReader reader = new StreamReader(inputFile))
            using (StreamWriter writer = new StreamWriter(outputFile))
            {
                string line;

                while ((line = reader.ReadLine()) != null)
                {
                    // Process the data: convert it to uppercase
                    string processedLine = line.ToUpper();

                    writer.WriteLine(processedLine);
                }
            }

            Console.WriteLine("Data processed successfully.");
        }
        catch (FileNotFoundException)
        {
            Console.WriteLine("Error: Input file not found.");
        }
        catch (IOException ex)
        {
            Console.WriteLine("File I/O Error: " + ex.Message);
        }
        catch (Exception ex)
        {
            Console.WriteLine("Error: " + ex.Message);
        }
        finally
        {
            Console.WriteLine("File processing completed.");
        }
    }
}
