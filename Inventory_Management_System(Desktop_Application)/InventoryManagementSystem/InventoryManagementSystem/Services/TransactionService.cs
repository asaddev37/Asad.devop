using InventoryManagementSystem.Models;
using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;

namespace InventoryManagementSystem.Services
{
    public class TransactionService
    {
        private readonly DatabaseService _databaseService;
        private readonly AuditLogService _auditLogService;

        public TransactionService()
        {
            _databaseService = new DatabaseService();
            _auditLogService = new AuditLogService();
        }

        public List<Transaction> GetAllTransactions()
        {
            var transactions = new List<Transaction>();
            try
            {
                using (var conn = _databaseService.GetConnection())
                {
                    conn.Open();
                    string query = "SELECT * FROM Transactions";
                    using (var cmd = new MySqlCommand(query, conn))
                    {
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                transactions.Add(new Transaction
                                {
                                    TransactionID = Convert.ToInt32(reader["TransactionID"]),
                                    ItemID = Convert.ToInt32(reader["ItemID"]),
                                    UserID = Convert.ToInt32(reader["UserID"]),
                                    TransactionType = reader["TransactionType"].ToString(),
                                    Quantity = Convert.ToInt32(reader["Quantity"]),
                                    TransactionDate = Convert.ToDateTime(reader["TransactionDate"]),
                                    Description = reader["Description"].ToString()
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _auditLogService.LogAction(null, "Transaction Fetch Failed", $"Error fetching transactions: {ex.Message}");
            }
            return transactions;
        }

        public bool AddTransaction(Transaction transaction)
        {
            try
            {
                using (var conn = _databaseService.GetConnection())
                {
                    // Debug connection state
                    Console.WriteLine($"Connection State: {conn.State}");
                    conn.Open();
                    string query = "INSERT INTO Transactions (ItemID, UserID, TransactionType, Quantity, TransactionDate, Description) " +
                                   "VALUES (@ItemID, @UserID, @TransactionType, @Quantity, @TransactionDate, @Description)";
                    using (var cmd = new MySqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ItemID", transaction.ItemID);
                        cmd.Parameters.AddWithValue("@UserID", transaction.UserID);
                        cmd.Parameters.AddWithValue("@TransactionType", transaction.TransactionType);
                        cmd.Parameters.AddWithValue("@Quantity", transaction.Quantity);
                        cmd.Parameters.AddWithValue("@TransactionDate", transaction.TransactionDate);
                        cmd.Parameters.AddWithValue("@Description", (object)transaction.Description ?? DBNull.Value);
                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            _auditLogService.LogAction(transaction.UserID, "Transaction Added",
                                $"Added {transaction.TransactionType} for ItemID {transaction.ItemID}, Quantity: {transaction.Quantity}");
                            return true;
                        }
                        else
                        {
                            _auditLogService.LogAction(transaction.UserID, "Transaction Add Failed", "No rows affected by insert query.");
                            return false;
                        }
                    }
                }
            }
            catch (MySqlException ex)
            {
                string errorMsg = $"MySQL Error: {ex.Number} - {ex.Message}";
                _auditLogService.LogAction(transaction.UserID, "Transaction Add Failed", errorMsg);
                Console.WriteLine($"MySQL Error: {errorMsg}");
                return false;
            }
            catch (Exception ex)
            {
                _auditLogService.LogAction(transaction.UserID, "Transaction Add Failed", $"Error: {ex.Message}");
                Console.WriteLine($"General Error: {ex.Message}");
                return false;
            }
        }

        public void LogTransaction(int itemId, int userId, string transactionType, int quantity, string description)
        {
            try
            {
                using (var conn = _databaseService.GetConnection())
                {
                    conn.Open();
                    string query = "INSERT INTO Transactions (ItemID, UserID, TransactionType, Quantity, TransactionDate, Description) " +
                                   "VALUES (@ItemID, @UserID, @TransactionType, @Quantity, @TransactionDate, @Description)";
                    using (var cmd = new MySqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ItemID", itemId);
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        cmd.Parameters.AddWithValue("@TransactionType", transactionType);
                        cmd.Parameters.AddWithValue("@Quantity", quantity);
                        cmd.Parameters.AddWithValue("@TransactionDate", DateTime.Now);
                        cmd.Parameters.AddWithValue("@Description", description);
                        cmd.ExecuteNonQuery();
                        _auditLogService.LogAction(userId, "Transaction Logged", $"Logged {transactionType} for ItemID {itemId}");
                    }
                }
            }
            catch (Exception ex)
            {
                _auditLogService.LogAction(userId, "Transaction Log Failed", $"Error logging transaction: {ex.Message}");
            }
        }
    }
}