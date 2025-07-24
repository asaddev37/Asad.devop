using InventoryManagementSystem.Models;
using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;

namespace InventoryManagementSystem.Services
{
    public class SupplierService
    {
        private readonly DatabaseService _dbService;
        private readonly AuditLogService _auditLogService;

        public SupplierService()
        {
            _dbService = new DatabaseService();
            _auditLogService = new AuditLogService();
        }

        public List<Supplier> GetAllSuppliers()
        {
            var suppliers = new List<Supplier>();
            try
            {
                using (var conn = _dbService.GetConnection())
                {
                    conn.Open();
                    string query = "SELECT * FROM Suppliers";
                    using (var cmd = new MySqlCommand(query, conn))
                    {
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                suppliers.Add(new Supplier
                                {
                                    SupplierID = Convert.ToInt32(reader["SupplierID"]),
                                    SupplierName = reader["SupplierName"].ToString(),
                                    ContactInfo = reader["ContactInfo"].ToString(),
                                    Address = reader["Address"].ToString()
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _auditLogService.LogAction(null, "Supplier Fetch Failed", $"Error fetching suppliers: {ex.Message}");
            }
            return suppliers;
        }

        public bool AddSupplier(Supplier supplier, int userId)
        {
            try
            {
                using (var conn = _dbService.GetConnection())
                {
                    conn.Open();
                    string query = "INSERT INTO Suppliers (SupplierName, ContactInfo, Address) VALUES (@SupplierName, @ContactInfo, @Address)";
                    using (var cmd = new MySqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@SupplierName", supplier.SupplierName);
                        cmd.Parameters.AddWithValue("@ContactInfo", supplier.ContactInfo);
                        cmd.Parameters.AddWithValue("@Address", supplier.Address);
                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            _auditLogService.LogAction(userId, "Supplier Added", $"Added supplier {supplier.SupplierName}");
                            return true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _auditLogService.LogAction(userId, "Add Supplier Failed", $"Error adding supplier {supplier.SupplierName}: {ex.Message}");
                return false;
            }
            return false;
        }

        public bool UpdateSupplier(Supplier supplier, int userId)
        {
            try
            {
                using (var conn = _dbService.GetConnection())
                {
                    conn.Open();
                    string query = "UPDATE Suppliers SET SupplierName = @SupplierName, ContactInfo = @ContactInfo, Address = @Address WHERE SupplierID = @SupplierID";
                    using (var cmd = new MySqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@SupplierID", supplier.SupplierID);
                        cmd.Parameters.AddWithValue("@SupplierName", supplier.SupplierName);
                        cmd.Parameters.AddWithValue("@ContactInfo", supplier.ContactInfo);
                        cmd.Parameters.AddWithValue("@Address", supplier.Address);
                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            _auditLogService.LogAction(userId, "Supplier Updated", $"Updated supplier {supplier.SupplierName}");
                            return true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _auditLogService.LogAction(userId, "Update Supplier Failed", $"Error updating supplier {supplier.SupplierName}: {ex.Message}");
                return false;
            }
            return false;
        }

        public bool DeleteSupplier(int supplierId, int userId)
        {
            try
            {
                using (var conn = _dbService.GetConnection())
                {
                    conn.Open();
                    string query = "DELETE FROM Suppliers WHERE SupplierID = @SupplierID";
                    using (var cmd = new MySqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@SupplierID", supplierId);
                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            _auditLogService.LogAction(userId, "Supplier Deleted", $"Deleted supplier ID {supplierId}");
                            return true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _auditLogService.LogAction(userId, "Delete Supplier Failed", $"Error deleting supplier ID {supplierId}: {ex.Message}");
                return false;
            }
            return false;
        }
    }
}