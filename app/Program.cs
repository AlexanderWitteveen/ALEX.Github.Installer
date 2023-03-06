using System;
using System.Reflection;
using System.Text.Json;

namespace Install
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Installing...");
            Console.WriteLine();

            foreach (var name in Assembly.GetExecutingAssembly().GetManifestResourceNames())
                Console.WriteLine("Res: " + name);

            ReadConfig();
            if (_config == null)
            {
                Console.WriteLine("Error: No config");
            }
            else
            {
                Console.WriteLine("Create folders...");
                CreateFolder();

                ReadZip();
                var appPath = Path.Join(_config.rootfolder, _config.appfolder);
                var zipPath = Path.Join(appPath, "install.zip");

                if (_buffer!=null)
                    File.WriteAllBytes(zipPath, _buffer);
            }

            Console.WriteLine("Press [Enter]");

            Console.ReadLine();
        }

        static Config? _config;
        static byte[]? _buffer = null;

        static void ReadConfig()
        {
            var configStream = Assembly.GetExecutingAssembly().GetManifestResourceStream("Install.config.json");
            if (configStream == null)
                return;

            var reader = new StreamReader(configStream);
            var configJson = reader.ReadToEnd();
            reader.Close();
            reader.Dispose();
            configStream.Close();
            configStream.Dispose();
            if (configJson == null)
                return;

            _config = JsonSerializer.Deserialize<Config>(configJson);
        }

        static void ReadZip()
        {
            var zipStream = Assembly.GetExecutingAssembly().GetManifestResourceStream("Install.folder.zip");
            if (zipStream == null)
                return;

            var reader = new BinaryReader(zipStream);

            _buffer = reader.ReadBytes((int)zipStream.Length);
            reader.Close();
            reader.Dispose();
            zipStream.Close();
            zipStream.Dispose();
        }

        static void CreateFolder()
        {
            if (_config?.rootfolder != null)
            {
                if (!Directory.Exists(_config.rootfolder))
                {
                    Console.WriteLine("Create " + _config.rootfolder);
                    Directory.CreateDirectory(_config.rootfolder);
                }

                if (_config.appfolder != null)
                {
                    var appPath = Path.Join(_config.rootfolder, _config.appfolder);
                    if (!Directory.Exists(appPath))
                    {
                        Console.WriteLine("Create " + appPath);
                        Directory.CreateDirectory(appPath);
                    }
                }
            }
        }
    }
}