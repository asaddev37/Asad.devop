using InventoryManagementSystem.Models;
using InventoryManagementSystem.Utils;
using System.Windows;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class ManagerDashboardViewModel : ViewModelBase
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

        public ICommand ShowInventoryCommand { get; }
        public ICommand ShowTransactionHistoryCommand { get; }
        public ICommand ShowReportsCommand { get; }
        public ICommand ShowSuppliersCommand { get; }
        public ICommand LogoutCommand { get; }

        public ManagerDashboardViewModel(User currentUser)
        {
            _currentUser = currentUser;

            ShowInventoryCommand = new RelayCommand(o => ShowInventory());
            ShowTransactionHistoryCommand = new RelayCommand(o => ShowTransactionHistory());
            ShowReportsCommand = new RelayCommand(o => ShowReports());
            ShowSuppliersCommand = new RelayCommand(o => ShowSuppliers());
            LogoutCommand = new RelayCommand(o => Logout());

            ShowInventory();
        }

        private void ShowInventory()
        {
            CurrentView = new ManagerInventoryViewModel(_currentUser);
        }

        private void ShowTransactionHistory()
        {
            CurrentView = new TransactionHistoryViewModel(_currentUser);
        }

        private void ShowReports()
        {
            CurrentView = new ReportsViewModel(_currentUser);
        }

        private void ShowSuppliers()
        {
            CurrentView = new SupplierViewModel(_currentUser);
        }

        private void Logout()
        {
            NavigationService.NavigateToLogin();
        }
    }
}