using InventoryManagementSystem.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration.Json; // Added
using System;
using System.IO;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class SettingsViewModel : ViewModelBase
    {
        private readonly DatabaseService _databaseService;
        private int _lowStockThreshold;
        private int _sessionTimeout;
        private string _backupPath;
        private string _statusMessage;

        public int LowStockThreshold
        {
            get => _lowStockThreshold;
            set
            {
                _lowStockThreshold = value;
                OnPropertyChanged(nameof(LowStockThreshold));
            }
        }

        public int SessionTimeout
        {
            get => _sessionTimeout;
            set
            {
                _sessionTimeout = value;
                OnPropertyChanged(nameof(SessionTimeout));
            }
        }

        public string BackupPath
        {
            get => _backupPath;
            set
            {
                _backupPath = value;
                OnPropertyChanged(nameof(BackupPath));
            }
        }

        public string StatusMessage
        {
            get => _statusMessage;
            set
            {
                _statusMessage = value;
                OnPropertyChanged(nameof(StatusMessage));
            }
        }

        public ICommand SaveSettingsCommand { get; }
        public ICommand BackupDatabaseCommand { get; }
        public ICommand RestoreDatabaseCommand { get; }

        public SettingsViewModel()
        {
            _databaseService = new DatabaseService();
            LoadSettings();
            SaveSettingsCommand = new RelayCommand(o => SaveSettings());
            BackupDatabaseCommand = new RelayCommand(o => BackupDatabase());
            RestoreDatabaseCommand = new RelayCommand(o => RestoreDatabase());
        }

        private void LoadSettings()
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory()) // Fixed with using directive
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);
            var configuration = builder.Build();

        
            BackupPath = Path.Combine("Backups", $"backup_{DateTime.Now:yyyyMMdd_HHmmss}.sql");
            StatusMessage = "Settings loaded.";
        }

        private void SaveSettings()
        {
            if (LowStockThreshold <= 0 || SessionTimeout <= 0)
            {
                StatusMessage = "Low stock threshold and session timeout must be positive.";
                return;
            }

            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory()) // Fixed with using directive
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);
            var configuration = builder.Build();

            var settings = new
            {
                Settings = new
                {
                    LowStockThreshold = LowStockThreshold,
                    SessionTimeout = SessionTimeout
                }
            };

            var json = System.Text.Json.JsonSerializer.Serialize(settings);
            File.WriteAllText("appsettings.json", json);

            StatusMessage = "Settings saved successfully.";
        }

        private void BackupDatabase()
        {
            try
            {
                if (!Directory.Exists("Backups"))
                    Directory.CreateDirectory("Backups");

                _databaseService.BackupDatabase(BackupPath);
                StatusMessage = $"Backup successful. File saved at: {BackupPath}";
            }
            catch (Exception ex)
            {
                StatusMessage = $"Backup failed: {ex.Message}";
            }
        }

        private void RestoreDatabase()
        {
            if (string.IsNullOrEmpty(BackupPath) || !File.Exists(BackupPath))
            {
                StatusMessage = "No valid backup file selected.";
                return;
            }

            if (System.Windows.MessageBox.Show("This will overwrite the current database. Proceed?", "Confirm Restore",
                System.Windows.MessageBoxButton.YesNo, System.Windows.MessageBoxImage.Warning) == System.Windows.MessageBoxResult.Yes)
            {
                try
                {
                    _databaseService.RestoreDatabase(BackupPath);
                    StatusMessage = "Restore successful.";
                }
                catch (Exception ex)
                {
                    StatusMessage = $"Restore failed: {ex.Message}";
                }
            }
        }
    }
}