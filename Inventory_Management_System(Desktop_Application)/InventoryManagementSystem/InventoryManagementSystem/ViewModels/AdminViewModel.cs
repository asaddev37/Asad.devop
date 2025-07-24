using InventoryManagementSystem.Models;
using InventoryManagementSystem.Utils;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class AdminViewModel : ViewModelBase
    {
        private readonly User _currentUser;
        private object _currentView;

        public object CurrentView
        {
            get => _currentView;
            set
            {
                _currentView = value;
                OnPropertyChanged(nameof(CurrentView));
            }
        }

        public ICommand ShowUserManagementCommand { get; }
        public ICommand ShowInventoryManagementCommand { get; }
        public ICommand ShowSupplierManagementCommand { get; }
        public ICommand ShowAuditLogsCommand { get; }
        public ICommand ShowSettingsCommand { get; }
        public ICommand LogoutCommand { get; }

        public AdminViewModel(User user)
        {
            _currentUser = user;
            ShowUserManagementCommand = new RelayCommand(o => CurrentView = new UserManagementViewModel(_currentUser));
            ShowInventoryManagementCommand = new RelayCommand(o => CurrentView = new InventoryViewModel(_currentUser));
            ShowSupplierManagementCommand = new RelayCommand(o => CurrentView = new SupplierViewModel(_currentUser));
            ShowAuditLogsCommand = new RelayCommand(o => CurrentView = new AuditLogViewModel());
            ShowSettingsCommand = new RelayCommand(o => CurrentView = new SettingsViewModel());
            LogoutCommand = new RelayCommand(o => Logout());

            // Default view
            CurrentView = new UserManagementViewModel(_currentUser);
        }

        private void Logout()
        {
            NavigationService.NavigateToLogin();
        }
    }
}