using InventoryManagementSystem.Models;
using InventoryManagementSystem.Utils;
using InventoryManagementSystem.ViewModels;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class StaffViewModel : ViewModelBase
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
        public ICommand ShowTransactionFormCommand { get; }
        public ICommand ShowTransactionHistoryCommand { get; }
        public ICommand ShowSupportRequestCommand { get; }
        public ICommand LogoutCommand { get; }

        public StaffViewModel(User currentUser)
        {
            _currentUser = currentUser;

            ShowInventoryCommand = new RelayCommand(o => ShowInventory());
            ShowTransactionFormCommand = new RelayCommand(o => ShowTransactionForm());
            ShowTransactionHistoryCommand = new RelayCommand(o => ShowTransactionHistory());
            ShowSupportRequestCommand = new RelayCommand(o => ShowSupportRequest());
            LogoutCommand = new RelayCommand(o => Logout());

            ShowInventory(); // Default view
        }

        private void ShowInventory()
        {
            CurrentView = new StaffInventoryViewModel();
        }

        private void ShowTransactionForm()
        {
            CurrentView = new TransactionFormViewModel(_currentUser);
        }

        private void ShowTransactionHistory()
        {
            CurrentView = new TransactionHistoryViewModel(_currentUser);
        }

        private void ShowSupportRequest()
        {
            CurrentView = new SupportRequestViewModel(_currentUser);
        }

        private void Logout()
        {
            NavigationService.NavigateToLogin();
        }
    }
}