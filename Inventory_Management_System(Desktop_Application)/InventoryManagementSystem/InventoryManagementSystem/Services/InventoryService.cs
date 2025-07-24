    using InventoryManagementSystem.Models;
    using MySql.Data.MySqlClient;
    using System;
    using System.Collections.Generic;

    namespace InventoryManagementSystem.Services
    {
        public class InventoryService
        {
            private readonly DatabaseService _dbService;
            private readonly AuditLogService _auditLogService;

            public InventoryService()
            {
                _dbService = new DatabaseService();
                _auditLogService = new AuditLogService();
            }

            public List<Item> GetAllItems()
            {
                var items = new List<Item>();
                try
                {
                    using (var conn = _dbService.GetConnection())
                    {
                        conn.Open();
                        string query = "SELECT * FROM Inventory";
                        using (var cmd = new MySqlCommand(query, conn))
                        {
                            using (var reader = cmd.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    items.Add(new Item
                                    {
                                        ItemID = Convert.ToInt32(reader["ItemID"]),
                                        ItemName = reader["ItemName"].ToString(),
                                        Category = reader["Category"].ToString(),
                                        Quantity = Convert.ToInt32(reader["Quantity"]),
                                        UnitPrice = Convert.ToDecimal(reader["UnitPrice"]),
                                        SupplierID = reader["SupplierID"] != DBNull.Value ? Convert.ToInt32(reader["SupplierID"]) : (int?)null,
                                        LastUpdated = Convert.ToDateTime(reader["LastUpdated"])
                                    });
                                }
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    _auditLogService.LogAction(null, "Inventory Fetch Failed", $"Error fetching items: {ex.Message}");
                }
                return items;
            }

            public bool AddItem(Item item, int userId)
            {
                try
                {
                    using (var conn = _dbService.GetConnection())
                    {
                        conn.Open();
                        string query = "INSERT INTO Inventory (ItemName, Category, Quantity, UnitPrice, SupplierID) VALUES (@ItemName, @Category, @Quantity, @UnitPrice, @SupplierID)";
                        using (var cmd = new MySqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@ItemName", item.ItemName);
                            cmd.Parameters.AddWithValue("@Category", item.Category);
                            cmd.Parameters.AddWithValue("@Quantity", item.Quantity);
                            cmd.Parameters.AddWithValue("@UnitPrice", item.UnitPrice);
                            cmd.Parameters.AddWithValue("@SupplierID", item.SupplierID ?? (object)DBNull.Value);
                            int rowsAffected = cmd.ExecuteNonQuery();
                            if (rowsAffected > 0)
                            {
                                _auditLogService.LogAction(userId, "Item Added", $"Added item {item.ItemName}");
                                return true;
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    _auditLogService.LogAction(userId, "Add Item Failed", $"Error adding item {item.ItemName}: {ex.Message}");
                    return false;
                }
                return false;
            }

            public bool UpdateItem(Item item, int userId)
            {
                try
                {
                    using (var conn = _dbService.GetConnection())
                    {
                        conn.Open();
                        string query = "UPDATE Inventory SET ItemName = @ItemName, Category = @Category, Quantity = @Quantity, UnitPrice = @UnitPrice, SupplierID = @SupplierID, LastUpdated = NOW() WHERE ItemID = @ItemID";
                        using (var cmd = new MySqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@ItemID", item.ItemID);
                            cmd.Parameters.AddWithValue("@ItemName", item.ItemName);
                            cmd.Parameters.AddWithValue("@Category", item.Category);
                            cmd.Parameters.AddWithValue("@Quantity", item.Quantity);
                            cmd.Parameters.AddWithValue("@UnitPrice", item.UnitPrice);
                            cmd.Parameters.AddWithValue("@SupplierID", item.SupplierID ?? (object)DBNull.Value);
                            int rowsAffected = cmd.ExecuteNonQuery();
                            if (rowsAffected > 0)
                            {
                                _auditLogService.LogAction(userId, "Item Updated", $"Updated item {item.ItemName}");
                                return true;
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    _auditLogService.LogAction(userId, "Update Item Failed", $"Error updating item {item.ItemName}: {ex.Message}");
                    return false;
                }
                return false;
            }

            public bool DeleteItem(int itemId, int userId)
            {
                try
                {
                    using (var conn = _dbService.GetConnection())
                    {
                        conn.Open();
                        string query = "DELETE FROM Inventory WHERE ItemID = @ItemID";
                        using (var cmd = new MySqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@ItemID", itemId);
                            int rowsAffected = cmd.ExecuteNonQuery();
                            if (rowsAffected > 0)
                            {
                                _auditLogService.LogAction(userId, "Item Deleted", $"Deleted item ID {itemId}");
                                return true;
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    _auditLogService.LogAction(userId, "Delete Item Failed", $"Error deleting item ID {itemId}: {ex.Message}");
                    return false;
                }
                return false;
            }
        }
    }