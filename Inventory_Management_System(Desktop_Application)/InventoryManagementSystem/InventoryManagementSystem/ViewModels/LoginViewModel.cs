using InventoryManagementSystem.Services;
using InventoryManagementSystem.Utils;
using System.ComponentModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Diagnostics;

namespace InventoryManagementSystem.ViewModels
{
    public class LoginViewModel : ViewModelBase
    {
        private readonly AuthService _authService;
        private string _username;
        private string _password;
        private string _role;
        private string _errorMessage;
        private Visibility _errorVisibility;

        public string Username
        {
            get => _username;
            set
            {
                _username = value;
                OnPropertyChanged(nameof(Username));
            }
        }

        public string Password
        {
            get => _password;
            set
            {
                _password = value;
                OnPropertyChanged(nameof(Password));
            }
        }

        public string Role
        {
            get => _role;
            set
            {
                _role = value;
                OnPropertyChanged(nameof(Role));
            }
        }

        public string ErrorMessage
        {
            get => _errorMessage;
            set
            {
                _errorMessage = value;
                OnPropertyChanged(nameof(ErrorMessage));
                ErrorVisibility = string.IsNullOrEmpty(value) ? Visibility.Collapsed : Visibility.Visible;
            }
        }

        public Visibility ErrorVisibility
        {
            get => _errorVisibility;
            set
            {
                _errorVisibility = value;
                OnPropertyChanged(nameof(ErrorVisibility));
            }
        }

        public ICommand LoginCommand { get; }
        public ICommand PasswordChangedCommand { get; }
        public ICommand NavigateToSignupCommand { get; }

        public LoginViewModel()
        {
            _authService = new AuthService();
            LoginCommand = new RelayCommand(o => Login(), o => CanLogin());
            PasswordChangedCommand = new RelayCommand(obj =>
            {
                if (obj is PasswordBox passwordBox)
                {
                    Password = passwordBox.Password;
                    Debug.WriteLine($"Password updated: {Password}");
                }
            });
            NavigateToSignupCommand = new RelayCommand(o => NavigateToSignup());
            ErrorVisibility = Visibility.Collapsed;
        }

        private bool CanLogin()
        {
            bool canExecute = !string.IsNullOrEmpty(Username) &&
                             !string.IsNullOrEmpty(Password) &&
                             !string.IsNullOrEmpty(Role);
            Debug.WriteLine($"CanLogin: {canExecute}, Username: {Username}, Password: {Password}, Role: {Role}");
            return canExecute;
        }

        private void Login()
        {
            Debug.WriteLine($"Executing Login for Username: {Username}, Role: {Role}");
            try
            {
                var user = _authService.Login(Username, Password, Role);
                if (user != null)
                {
                    Debug.WriteLine("Login successful, navigating to dashboard.");
                    NavigationService.NavigateToDashboard(Role, user);
                }
                else
                {
                    Debug.WriteLine("Login failed: Invalid credentials.");
                    ErrorMessage = "Invalid username, password, or role.";
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Login error: {ex.Message}");
                ErrorMessage = "Login error: " + ex.Message;
            }
        }

        private void NavigateToSignup()
        {
            NavigationService.NavigateToSignup();
        }
    }
    public class RelayCommand : ICommand
    {
        private readonly Action<object> _execute;
        private readonly Predicate<object> _canExecute;

        public RelayCommand(Action<object> execute, Predicate<object> canExecute = null)
        {
            _execute = execute ?? throw new ArgumentNullException(nameof(execute));
            _canExecute = canExecute;
        }

        public bool CanExecute(object parameter)
        {
            return _canExecute == null || _canExecute(parameter);
        }

        public void Execute(object parameter)
        {
            _execute(parameter);
        }

        public event EventHandler CanExecuteChanged
        {
            add => CommandManager.RequerySuggested += value;
            remove => CommandManager.RequerySuggested -= value;
        }
    }
}