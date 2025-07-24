using InventoryManagementSystem.Utils;
using InventoryManagementSystem.ViewModels;
using System.Diagnostics;
using System.Windows;

namespace InventoryManagementSystem
{
    public partial class App : Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);
            Debug.WriteLine("Application startup initiated.");
            ShutdownMode = ShutdownMode.OnMainWindowClose;
            var mainWindow = new MainWindow();
            var mainViewModel = mainWindow.DataContext as MainViewModel;
            if (mainViewModel != null)
            {
                Debug.WriteLine("Initializing NavigationService.");
                NavigationService.Initialize(mainViewModel);
                mainViewModel.CurrentView = new LoginViewModel(); // Set initial view
            }
            else
            {
                Debug.WriteLine("Error: MainViewModel is null.");
                MessageBox.Show("Failed to initialize MainViewModel.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            MainWindow = mainWindow;
            mainWindow.Show();
            Debug.WriteLine("MainWindow shown.");

            // Add unhandled exception handler
            DispatcherUnhandledException += App_DispatcherUnhandledException;
        }

        private void App_DispatcherUnhandledException(object sender, System.Windows.Threading.DispatcherUnhandledExceptionEventArgs e)
        {
            Debug.WriteLine($"Unhandled exception: {e.Exception.Message}");
            Debug.WriteLine(e.Exception.StackTrace);
            e.Handled = true;
        }
    }
}