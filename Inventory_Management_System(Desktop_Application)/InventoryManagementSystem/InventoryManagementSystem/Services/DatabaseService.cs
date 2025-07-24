using MySql.Data.MySqlClient;
using System;
using System.Diagnostics;
using System.IO;
using System.Configuration;

namespace InventoryManagementSystem.Services
{
    public class DatabaseService
    {
        private readonly string _connectionString;

        public DatabaseService()
        {
            _connectionString = ConfigurationManager.ConnectionStrings["InventoryDB"].ConnectionString;
        }

        public void BackupDatabase(string backupPath)
        {
            try
            {
                if (!Directory.Exists("Backups"))
                    Directory.CreateDirectory("Backups");

                var processInfo = new ProcessStartInfo
                {
                    FileName = "mysqldump",
                    Arguments = $"-u root -pak37 InventoryDB -r \"{backupPath}\"",
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                };

                using (var process = Process.Start(processInfo))
                {
                    process.WaitForExit();
                    if (process.ExitCode != 0)
                        throw new Exception("Backup failed. Check MySQL credentials or mysqldump availability.");
                }

                if (!File.Exists(backupPath))
                    throw new Exception("Backup file was not created.");
            }
            catch (Exception ex)
            {
                throw new Exception($"Backup failed: {ex.Message}");
            }
        }

        public void RestoreDatabase(string backupPath)
        {
            try
            {
                if (!File.Exists(backupPath))
                    throw new Exception("Backup file not found.");

                var processInfo = new ProcessStartInfo
                {
                    FileName = "mysql",
                    Arguments = $"-u root -pak37 InventoryDB < \"{backupPath}\"",
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                };

                using (var process = Process.Start(processInfo))
                {
                    process.WaitForExit();
                    if (process.ExitCode != 0)
                        throw new Exception("Restore failed. Check MySQL credentials or mysql availability.");
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Restore failed: {ex.Message}");
            }
        }

        public MySqlConnection GetConnection()
        {
            // Return an unopened connection; let the caller manage opening and closing
            return new MySqlConnection(_connectionString);
        }
    }
}