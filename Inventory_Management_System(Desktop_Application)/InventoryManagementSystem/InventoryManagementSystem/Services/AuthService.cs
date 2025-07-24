using InventoryManagementSystem.Models;
using InventoryManagementSystem.Utils;
using MySql.Data.MySqlClient;
using System.Diagnostics;

namespace InventoryManagementSystem.Services
{
    public class AuthService
    {
        private readonly DatabaseService _dbService;

        public AuthService()
        {
            _dbService = new DatabaseService();
        }

        public User Login(string username, string password, string role)
        {
            Debug.WriteLine($"Attempting login for Username: {username}, Role: {role}");
            string query = "SELECT * FROM Users WHERE LOWER(Username) = LOWER(@username) AND Role = @role";
            try
            {
                using (var connection = _dbService.GetConnection())
                {
                    connection.Open();
                    Debug.WriteLine("Database connection opened successfully.");
                    using (var command = new MySqlCommand(query, connection))
                    {
                        command.Parameters.AddWithValue("@username", username);
                        command.Parameters.AddWithValue("@role", role);
                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                Debug.WriteLine("User found in database.");
                                var storedPassword = reader["Password"].ToString();
                                if (PasswordHasher.VerifyPassword(password, storedPassword))
                                {
                                    Debug.WriteLine("Password verified successfully.");
                                    return new User
                                    {
                                        UserID = reader.GetInt32("UserID"),
                                        Username = reader.GetString("Username"),
                                        Role = reader.GetString("Role"),
                                        Email = reader.GetString("Email"),
                                        FullName = reader.GetString("FullName"),
                                        CreatedAt = reader.GetDateTime("CreatedAt"),
                                        LastLogin = reader.IsDBNull(reader.GetOrdinal("LastLogin")) ? (DateTime?)null : reader.GetDateTime("LastLogin")
                                    };
                                }
                                else
                                {
                                    Debug.WriteLine("Password verification failed.");
                                }
                            }
                            else
                            {
                                Debug.WriteLine("No user found with the given username and role.");
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Login error: {ex.Message}");
                throw;
            }
            return null;
        }
    }
}