using InventoryManagementSystem.Models;
using InventoryManagementSystem.Services;
using InventoryManagementSystem.Utils;
using InventoryManagementSystem.Views;
using MySql.Data.MySqlClient;
using System;
using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class UserManagementViewModel : ViewModelBase
    {
        private readonly AuditLogService _auditLogService;
        private readonly DatabaseService _dbService;
        private readonly User _currentUser;
        private ObservableCollection<User> _users;
        private User _selectedUser;

        public ObservableCollection<User> Users
        {
            get => _users;
            set
            {
                _users = value;
                OnPropertyChanged(nameof(Users));
            }
        }

        public User SelectedUser
        {
            get => _selectedUser;
            set
            {
                _selectedUser = value;
                OnPropertyChanged(nameof(SelectedUser));
            }
        }

        public ICommand AddUserCommand { get; }
        public ICommand EditUserCommand { get; }
        public ICommand DeleteUserCommand { get; }
        public ICommand ResetPasswordCommand { get; }

        public UserManagementViewModel(User currentUser)
        {
            _auditLogService = new AuditLogService();
            _dbService = new DatabaseService();
            _currentUser = currentUser;
            Users = new ObservableCollection<User>();
            LoadUsers();

            AddUserCommand = new RelayCommand(o => AddUser());
            EditUserCommand = new RelayCommand(o => EditUser(), o => SelectedUser != null);
            DeleteUserCommand = new RelayCommand(o => DeleteUser(), o => SelectedUser != null && SelectedUser.Role != "Admin");
            ResetPasswordCommand = new RelayCommand(o => ResetPassword(), o => SelectedUser != null);
        }

        private void LoadUsers()
        {
            try
            {
                Users.Clear();
                using (var conn = _dbService.GetConnection())
                {
                    conn.Open();
                    string query = "SELECT UserID, Username, Role, Email, FullName, CreatedAt, LastLogin FROM Users";
                    using (var cmd = new MySqlCommand(query, conn))
                    {
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                Users.Add(new User
                                {
                                    UserID = reader.GetInt32("UserID"),
                                    Username = reader.GetString("Username"),
                                    Role = reader.GetString("Role"),
                                    Email = reader.GetString("Email"),
                                    FullName = reader.GetString("FullName"),
                                    CreatedAt = reader.GetDateTime("CreatedAt"),
                                    LastLogin = reader.IsDBNull(reader.GetOrdinal("LastLogin")) ? (DateTime?)null : reader.GetDateTime("LastLogin")
                                });
                            }
                        }
                    }
                }
                _auditLogService.LogAction(_currentUser.UserID, "Viewed Users", "User list loaded in UserManagementView");
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading users: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                _auditLogService.LogAction(_currentUser.UserID, "Load Users Failed", $"Error: {ex.Message}");
            }
        }

        private void AddUser()
        {
            var addUserViewModel = new AddUserViewModel(_currentUser, null, LoadUsers);
            var window = new Window
            {
                Title = "Add New User",
                SizeToContent = SizeToContent.WidthAndHeight,
                WindowStartupLocation = WindowStartupLocation.CenterScreen
            };
            var addUserView = new AddUserView();
            addUserView.DataContext = addUserViewModel;
            window.Content = addUserView;
            window.ShowDialog();
        }

        private void EditUser()
        {
            if (SelectedUser == null)
            {
                MessageBox.Show("Please select a user to edit.", "Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }
            var addUserViewModel = new AddUserViewModel(_currentUser, SelectedUser, LoadUsers);
            var window = new Window
            {
                Title = $"Edit User: {SelectedUser.Username}",
                SizeToContent = SizeToContent.WidthAndHeight,
                WindowStartupLocation = WindowStartupLocation.CenterScreen
            };
            var addUserView = new AddUserView();
            addUserView.DataContext = addUserViewModel;
            window.Content = addUserView;
            window.ShowDialog();
        }

        private void DeleteUser()
        {
            if (SelectedUser == null)
            {
                MessageBox.Show("Please select a user to delete.", "Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }
            if (SelectedUser.Role == "Admin")
            {
                MessageBox.Show("Cannot delete an Admin user.", "Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }
            // Store the username before deletion
            string usernameToDelete = SelectedUser.Username;
            if (MessageBox.Show($"Are you sure you want to delete {usernameToDelete}?", "Confirm Delete",
                MessageBoxButton.YesNo, MessageBoxImage.Warning) == MessageBoxResult.Yes)
            {
                try
                {
                    using (var conn = _dbService.GetConnection())
                    {
                        conn.Open();
                        string query = "DELETE FROM Users WHERE UserID = @UserID AND Role != 'Admin'";
                        using (var cmd = new MySqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@UserID", SelectedUser.UserID);
                            int rowsAffected = cmd.ExecuteNonQuery();
                            if (rowsAffected > 0)
                            {
                                Users.Remove(SelectedUser);
                                SelectedUser = null; // Explicitly clear SelectedUser
                                _auditLogService.LogAction(_currentUser.UserID, "User Deleted", $"Deleted user {usernameToDelete}");
                                MessageBox.Show($"{usernameToDelete} deleted successfully.", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                            }
                            else
                            {
                                MessageBox.Show("Failed to delete user. User may have already been deleted.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error deleting user: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    _auditLogService.LogAction(_currentUser.UserID, "Delete User Failed", $"Error: {ex.Message}");
                }
            }
        }

        private void ResetPassword()
        {
            if (SelectedUser == null)
            {
                MessageBox.Show("Please select a user to reset password.", "Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }
            if (MessageBox.Show($"Reset password for {SelectedUser.Username}?", "Confirm Reset",
                MessageBoxButton.YesNo, MessageBoxImage.Question) == MessageBoxResult.Yes)
            {
                try
                {
                    string tempPassword = GenerateTempPassword();
                    string hashedPassword = PasswordHasher.HashPassword(tempPassword);
                    using (var conn = _dbService.GetConnection())
                    {
                        conn.Open();
                        string query = "UPDATE Users SET Password = @Password WHERE UserID = @UserID";
                        using (var cmd = new MySqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@Password", hashedPassword);
                            cmd.Parameters.AddWithValue("@UserID", SelectedUser.UserID);
                            int rowsAffected = cmd.ExecuteNonQuery();
                            if (rowsAffected > 0)
                            {
                                MessageBox.Show($"Temporary password for {SelectedUser.Username}: {tempPassword}\nUser must change it on next login.", "Password Reset", MessageBoxButton.OK, MessageBoxImage.Information);
                                _auditLogService.LogAction(_currentUser.UserID, "Password Reset", $"Reset password for user {SelectedUser.Username}");
                            }
                            else
                            {
                                MessageBox.Show("Failed to reset password. User may no longer exist.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error resetting password: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    _auditLogService.LogAction(_currentUser.UserID, "Password Reset Failed", $"Error: {ex.Message}");
                }
            }
        }

        private string GenerateTempPassword()
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            var random = new Random();
            return new string(Enumerable.Repeat(chars, 8).Select(s => s[random.Next(s.Length)]).ToArray());
        }
    }
}