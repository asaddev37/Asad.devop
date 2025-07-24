using InventoryManagementSystem.Models;
using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;

namespace InventoryManagementSystem.Services
{
    public class SupportRequestService
    {
        private readonly DatabaseService _dbService;
        private readonly AuditLogService _auditLogService;

        public SupportRequestService()
        {
            _dbService = new DatabaseService();
            _auditLogService = new AuditLogService();
        }

        public bool AddSupportRequest(SupportRequest request, int userId)
        {
            try
            {
                using (var conn = _dbService.GetConnection())
                {
                    conn.Open();
                    string query = "INSERT INTO SupportRequests (Description, Priority, Status, SubmittedBy, SubmittedDate) VALUES (@Description, @Priority, @Status, @SubmittedBy, @SubmittedDate)";
                    using (var cmd = new MySqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Description", request.Description);
                        cmd.Parameters.AddWithValue("@Priority", request.Priority);
                        cmd.Parameters.AddWithValue("@Status", request.Status);
                        cmd.Parameters.AddWithValue("@SubmittedBy", request.SubmittedBy);
                        cmd.Parameters.AddWithValue("@SubmittedDate", request.SubmittedDate);
                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            _auditLogService.LogAction(userId, "Support Request Submitted", $"Request ID {request.RequestID} submitted by User ID {userId}");
                            return true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _auditLogService.LogAction(userId, "Support Request Failed", $"Error submitting support request: {ex.Message}");
                return false;
            }
            return false;
        }

        public List<SupportRequest> GetSupportRequestsByUser(int userId)
        {
            var requests = new List<SupportRequest>();
            try
            {
                using (var conn = _dbService.GetConnection())
                {
                    conn.Open();
                    string query = "SELECT * FROM SupportRequests WHERE SubmittedBy = @UserID";
                    using (var cmd = new MySqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var request = new SupportRequest
                                {
                                    RequestID = Convert.ToInt32(reader["RequestID"]),
                                    Description = reader["Description"].ToString(),
                                    Priority = reader["Priority"].ToString(),
                                    Status = reader["Status"].ToString(),
                                    SubmittedBy = Convert.ToInt32(reader["SubmittedBy"]),
                                    SubmittedDate = Convert.ToDateTime(reader["SubmittedDate"])
                                };
                                requests.Add(request);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _auditLogService.LogAction(userId, "Fetch Support Requests Failed", $"Error fetching support requests: {ex.Message}");
            }
            return requests;
        }
    }
}