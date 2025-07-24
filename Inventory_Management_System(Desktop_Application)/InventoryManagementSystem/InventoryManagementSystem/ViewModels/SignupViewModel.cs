using InventoryManagementSystem.Services;
using InventoryManagementSystem.Utils;
using MySql.Data.MySqlClient;
using System;
using System.Diagnostics;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class SignupViewModel : ViewModelBase
    {
        private readonly DatabaseService _dbService;
        private string _username;
        private string _password;
        private string _email;
        private string _fullName;
        private string _role;
        private string _errorMessage;
        private bool _isSaved;
        private bool _isEditMode;
        private int _userID;

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

        public string Email
        {
            get => _email;
            set
            {
                _email = value;
                OnPropertyChanged(nameof(Email));
            }
        }

        public string FullName
        {
            get => _fullName;
            set
            {
                _fullName = value;
                OnPropertyChanged(nameof(FullName));
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
            }
        }

        public bool IsSaved
        {
            get => _isSaved;
            set
            {
                _isSaved = value;
                OnPropertyChanged(nameof(IsSaved));
            }
        }

        public bool IsEditMode
        {
            get => _isEditMode;
            set
            {
                _isEditMode = value;
                OnPropertyChanged(nameof(IsEditMode));
            }
        }

        public int UserID
        {
            get => _userID;
            set
            {
                _userID = value;
                OnPropertyChanged(nameof(UserID));
            }
        }

        public ICommand SignupCommand { get; }
        public ICommand PasswordChangedCommand { get; }
        public ICommand NavigateToLoginCommand { get; }

        public SignupViewModel()
        {
            _dbService = new DatabaseService();
            SignupCommand = new RelayCommand(o => Save(), o => CanSave());
            PasswordChangedCommand = new RelayCommand(obj =>
            {
                if (obj is PasswordBox passwordBox)
                {
                    Password = passwordBox.Password;
                    Debug.WriteLine($"Password updated: {Password}");
                }
            });
            NavigateToLoginCommand = new RelayCommand(o => NavigateToLogin());
            IsEditMode = false;
        }

        private bool CanSave()
        {
            bool canExecute = !string.IsNullOrWhiteSpace(Username) &&
                             !string.IsNullOrWhiteSpace(Email) &&
                             !string.IsNullOrWhiteSpace(FullName) &&
                             !string.IsNullOrWhiteSpace(Role);
            if (!IsEditMode)
                canExecute = canExecute && !string.IsNullOrWhiteSpace(Password);
            Debug.WriteLine($"CanSave: {canExecute}, Username: {Username}, Password: {Password}, Role: {Role}, IsEditMode: {IsEditMode}");
            return canExecute;
        }

        private void Save()
        {
            Debug.WriteLine($"Executing {(IsEditMode ? "Update" : "Signup")} for Username: {Username}, Role: {Role}");
            try
            {
                if (IsEditMode)
                {
                    string query = "UPDATE Users SET Username = @username, Email = @email, FullName = @fullName, Role = @role WHERE UserID = @userID";
                    using (var connection = _dbService.GetConnection())
                    {
                        connection.Open();
                        using (var command = new MySqlCommand(query, connection))
                        {
                            command.Parameters.AddWithValue("@username", Username);
                            command.Parameters.AddWithValue("@email", Email);
                            command.Parameters.AddWithValue("@fullName", FullName);
                            command.Parameters.AddWithValue("@role", Role);
                            command.Parameters.AddWithValue("@userID", UserID);
                            int rowsAffected = command.ExecuteNonQuery();
                            if (rowsAffected > 0)
                            {
                                IsSaved = true;
                                NavigateToLogin();
                            }
                        }
                    }
                }
                else
                {
                    string hashedPassword = PasswordHasher.HashPassword(Password);
                    string query = "INSERT INTO Users (Username, Password, Role, Email, FullName) VALUES (@username, @password, @role, @email, @fullName)";
                    using (var connection = _dbService.GetConnection())
                    {
                        connection.Open();
                        Debug.WriteLine("Database connection opened successfully for signup.");
                        using (var command = new MySqlCommand(query, connection))
                        {
                            command.Parameters.AddWithValue("@username", Username);
                            command.Parameters.AddWithValue("@password", hashedPassword);
                            command.Parameters.AddWithValue("@role", Role);
                            command.Parameters.AddWithValue("@email", Email);
                            command.Parameters.AddWithValue("@fullName", FullName);
                            int rowsAffected = command.ExecuteNonQuery();
                            Debug.WriteLine($"Rows affected: {rowsAffected}");
                            if (rowsAffected > 0)
                            {
                                IsSaved = true;
                                MessageBox.Show("Sign up successful! Please log in.", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                                NavigateToLogin();
                            }
                        }
                    }
                }
            }
            catch (MySqlException ex)
            {
                Debug.WriteLine($"Signup/Update error: {ex.Message}");
                if (ex.Number == 1062) // Duplicate entry error
                {
                    ErrorMessage = "Username or email already exists.";
                }
                else
                {
                    ErrorMessage = $"{(IsEditMode ? "Update" : "Signup")} error: {ex.Message}";
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Unexpected {(IsEditMode ? "update" : "signup")} error: {ex.Message}");
                ErrorMessage = $"Unexpected error: {ex.Message}";
            }
        }

        private void NavigateToLogin()
        {
            NavigationService.NavigateToLogin();
        }
    }
}