using InventoryManagementSystem.Models;
using InventoryManagementSystem.Services;
using InventoryManagementSystem.Utils;
using InventoryManagementSystem.Views;
using MySql.Data.MySqlClient;
using System;
using System.Diagnostics;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class AddUserViewModel : ViewModelBase
    {
        private readonly DatabaseService _dbService;
        private readonly AuditLogService _auditLogService;
        private readonly User _currentUser;
        private readonly Action _refreshCallback;
        private readonly bool _isEditMode;
        private readonly string[] _validRoles = { "Admin", "Manager", "Staff" };
        private int _userID;
        private string _username;
        private string _password;
        private string _email;
        private string _fullName;
        private string _role;
        private string _errorMessage;
        private string _title;

        public int UserID
        {
            get => _userID;
            set
            {
                _userID = value;
                OnPropertyChanged(nameof(UserID));
            }
        }

        public string Username
        {
            get => _username;
            set
            {
                _username = value;
                OnPropertyChanged(nameof(Username));
                UpdateSaveEnablement();
                Debug.WriteLine($"Username set to: {value}, CanSave: {CanSave()}");
            }
        }

        public string Password
        {
            get => _password;
            set
            {
                _password = value;
                OnPropertyChanged(nameof(Password));
                UpdateSaveEnablement();
                Debug.WriteLine($"Password set to: {value}, CanSave: {CanSave()}");
            }
        }

        public string Email
        {
            get => _email;
            set
            {
                _email = value;
                OnPropertyChanged(nameof(Email));
                UpdateSaveEnablement();
                Debug.WriteLine($"Email set to: {value}, CanSave: {CanSave()}");
            }
        }

        public string FullName
        {
            get => _fullName;
            set
            {
                _fullName = value;
                OnPropertyChanged(nameof(FullName));
                UpdateSaveEnablement();
                Debug.WriteLine($"FullName set to: {value}, CanSave: {CanSave()}");
            }
        }

        public string Role
        {
            get => _role;
            set
            {
                _role = value?.Trim();
                if (!string.IsNullOrEmpty(_role))
                {
                    // Capitalize first letter to match valid roles
                    _role = char.ToUpper(_role[0]) + _role.Substring(1).ToLower();
                    // Validate Role against allowed values
                    if (!_validRoles.Contains(_role))
                    {
                        _role = "Staff"; // Default to Staff if invalid
                    }
                }
                OnPropertyChanged(nameof(Role));
                UpdateSaveEnablement();
                Debug.WriteLine($"Role set to: {_role}, CanSave: {CanSave()}");
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

        public string Title
        {
            get => _title;
            set
            {
                _title = value;
                OnPropertyChanged(nameof(Title));
            }
        }

        public bool IsEditMode => _isEditMode;

        public bool ShowPasswordField => !_isEditMode;

        public bool IsSaveEnabled => CanSave();

        public ICommand SaveCommand { get; }
        public ICommand CancelCommand { get; }
        public ICommand PasswordChangedCommand { get; }

        public AddUserViewModel(User currentUser, User user, Action refreshCallback)
        {
            _dbService = new DatabaseService();
            _auditLogService = new AuditLogService();
            _currentUser = currentUser;
            _refreshCallback = refreshCallback;
            _isEditMode = user != null;

            if (_isEditMode)
            {
                UserID = user.UserID;
                Username = user.Username;
                Email = user.Email;
                FullName = user.FullName;
                Role = user.Role; // This will validate and normalize the Role
                Title = $"Edit User: {Username}";
            }
            else
            {
                Role = "Staff"; // Default role, will be validated
                Title = "Add New User";
            }

            SaveCommand = new RelayCommand(o => Save(), o => CanSave());
            CancelCommand = new RelayCommand(o => Cancel());
            PasswordChangedCommand = new RelayCommand(obj =>
            {
                if (obj is PasswordBox passwordBox)
                {
                    Password = passwordBox.Password;
                    OnPropertyChanged(nameof(Password));
                    Debug.WriteLine($"Password changed: {Password}, CanSave: {CanSave()}");
                }
            });

            Debug.WriteLine($"AddUserViewModel initialized. IsEditMode: {_isEditMode}, ShowPasswordField: {ShowPasswordField}");
        }

        private bool CanSave()
        {
            bool isValid = !string.IsNullOrWhiteSpace(Username) &&
                           !string.IsNullOrWhiteSpace(Email) &&
                           !string.IsNullOrWhiteSpace(FullName) &&
                           !string.IsNullOrWhiteSpace(Role);
            if (!_isEditMode)
            {
                isValid = isValid && !string.IsNullOrWhiteSpace(Password) && Password.Length >= 6;
            }
            Debug.WriteLine($"CanSave: {isValid}, Username: {Username}, Email: {Email}, FullName: {FullName}, Role: {Role}, Password: {Password}");
            return isValid;
        }

        private void UpdateSaveEnablement()
        {
            OnPropertyChanged(nameof(IsSaveEnabled));
            Debug.WriteLine($"UpdateSaveEnablement called. IsSaveEnabled: {IsSaveEnabled}");
        }

        private void Save()
        {
            try
            {
                using (var conn = _dbService.GetConnection())
                {
                    conn.Open();
                    if (_isEditMode)
                    {
                        string query = "UPDATE Users SET Username = @Username, Email = @Email, FullName = @FullName, Role = @Role WHERE UserID = @UserID";
                        using (var cmd = new MySqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@Username", Username);
                            cmd.Parameters.AddWithValue("@Email", Email);
                            cmd.Parameters.AddWithValue("@FullName", FullName);
                            cmd.Parameters.AddWithValue("@Role", Role);
                            cmd.Parameters.AddWithValue("@UserID", UserID);
                            int rowsAffected = cmd.ExecuteNonQuery();
                            if (rowsAffected > 0)
                            {
                                _auditLogService.LogAction(_currentUser.UserID, "User Edited", $"Edited user {Username}");
                                _refreshCallback();
                                MessageBox.Show($"{Username} updated successfully.", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                                CloseWindow();
                            }
                            else
                            {
                                ErrorMessage = "Failed to update user. User may no longer exist.";
                            }
                        }
                    }
                    else
                    {
                        string hashedPassword = PasswordHasher.HashPassword(Password);
                        string query = "INSERT INTO Users (Username, Password, Role, Email, FullName, CreatedAt) VALUES (@Username, @Password, @Role, @Email, @FullName, @CreatedAt)";
                        using (var cmd = new MySqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@Username", Username);
                            cmd.Parameters.AddWithValue("@Password", hashedPassword);
                            cmd.Parameters.AddWithValue("@Role", Role);
                            cmd.Parameters.AddWithValue("@Email", Email);
                            cmd.Parameters.AddWithValue("@FullName", FullName);
                            cmd.Parameters.AddWithValue("@CreatedAt", DateTime.Now);
                            Debug.WriteLine($"Executing INSERT with Role: {Role}, Type: {Role.GetType()}");
                            int rowsAffected = cmd.ExecuteNonQuery();
                            if (rowsAffected > 0)
                            {
                                _auditLogService.LogAction(_currentUser.UserID, "User Added", $"Added user {Username}");
                                _refreshCallback();
                                MessageBox.Show($"{Username} added successfully.", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                                CloseWindow();
                            }
                            else
                            {
                                ErrorMessage = "Failed to add user.";
                            }
                        }
                    }
                }
            }
            catch (MySqlException ex)
            {
                if (ex.Number == 1062) // Duplicate entry
                {
                    ErrorMessage = "Username or email already exists.";
                }
                else
                {
                    ErrorMessage = $"Database error: {ex.Message}";
                }
                _auditLogService.LogAction(_currentUser.UserID, _isEditMode ? "Edit User Failed" : "Add User Failed", $"Error: {ex.Message}");
            }
            catch (Exception ex)
            {
                ErrorMessage = $"Unexpected error: {ex.Message}";
                _auditLogService.LogAction(_currentUser.UserID, _isEditMode ? "Edit User Failed" : "Add User Failed", $"Error: {ex.Message}");
            }
        }

        private void Cancel()
        {
            CloseWindow();
        }

        private void CloseWindow()
        {
            var window = Application.Current.Windows.OfType<Window>().SingleOrDefault(w => w.Content is AddUserView && w.Content is DependencyObject dc && dc.GetValue(FrameworkElement.DataContextProperty) == this);
            window?.Close();
        }
    }
}