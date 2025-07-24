using InventoryManagementSystem.Models;
using InventoryManagementSystem.ViewModels;
using System.Diagnostics;
using System.Windows;

namespace InventoryManagementSystem.Utils
{
    public static class NavigationService
    {
        private static MainViewModel _mainViewModel;

        public static void Initialize(MainViewModel mainViewModel)
        {
            if (mainViewModel == null) throw new ArgumentNullException(nameof(mainViewModel));
            _mainViewModel = mainViewModel;
            Debug.WriteLine("NavigationService initialized.");
        }

        public static void NavigateToLogin()
        {
            if (_mainViewModel == null) throw new InvalidOperationException("NavigationService not initialized.");
            Debug.WriteLine("Navigating to Login view.");
            _mainViewModel.CurrentView = new LoginViewModel();
        }

        public static void NavigateToSignup()
        {
            if (_mainViewModel == null) throw new InvalidOperationException("NavigationService not initialized.");
            Debug.WriteLine("Navigating to Signup view.");
            _mainViewModel.CurrentView = new SignupViewModel();
        }

        public static void NavigateToDashboard(string role, User user)
        {
            if (_mainViewModel == null) throw new InvalidOperationException("NavigationService not initialized.");
            Debug.WriteLine($"Navigating to dashboard for role: {role}");
            switch (role)
            {
                case "Admin":
                    _mainViewModel.CurrentView = new AdminViewModel(user);
                    break;
                case "Manager":
                    _mainViewModel.CurrentView = new ManagerDashboardViewModel(user);
                    break;
                case "Staff":
                    _mainViewModel.CurrentView = new StaffViewModel(user);
                    break;
                default:
                    MessageBox.Show("Invalid role.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    Debug.WriteLine("Invalid role specified.");
                    return;
            }
        }
    }
}