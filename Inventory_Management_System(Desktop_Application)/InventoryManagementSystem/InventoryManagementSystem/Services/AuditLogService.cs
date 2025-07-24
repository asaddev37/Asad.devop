using InventoryManagementSystem.Models;
using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;

namespace InventoryManagementSystem.Services
{
    public class AuditLogService
    {
        private readonly DatabaseService _dbService;

        public AuditLogService()
        {
            _dbService = new DatabaseService();
        }

        public void LogAction(int? userId, string action, string details)
        {
            try
            {
                using (var conn = _dbService.GetConnection())
                {
                    conn.Open();
                    string query = "INSERT INTO AuditLogs (UserID, Action, Details) VALUES (@UserID, @Action, @Details)";
                    using (var cmd = new MySqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userId ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@Action", action);
                        cmd.Parameters.AddWithValue("@Details", details);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                // Log to console or file (basic error handling)
                Console.WriteLine($"Audit log error: {ex.Message}");
            }
        }

        public List<AuditLog> GetAuditLogs()
        {
            var logs = new List<AuditLog>();
            try
            {
                using (var conn = _dbService.GetConnection())
                {
                    conn.Open();
                    string query = "SELECT * FROM AuditLogs ORDER BY Timestamp DESC";
                    using (var cmd = new MySqlCommand(query, conn))
                    {
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                logs.Add(new AuditLog
                                {
                                    LogID = Convert.ToInt32(reader["LogID"]),
                                    UserID = reader["UserID"] != DBNull.Value ? Convert.ToInt32(reader["UserID"]) : (int?)null,
                                    Action = reader["Action"].ToString(),
                                    Timestamp = Convert.ToDateTime(reader["Timestamp"]),
                                    Details = reader["Details"].ToString()
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogAction(null, "Audit Log Fetch Failed", $"Error fetching audit logs: {ex.Message}");
            }
            return logs;
        }
    }
}