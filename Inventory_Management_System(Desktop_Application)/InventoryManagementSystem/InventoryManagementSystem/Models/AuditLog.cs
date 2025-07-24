namespace InventoryManagementSystem.Models
{
    public class AuditLog
    {
        public int LogID { get; set; }
        public int? UserID { get; set; }
        public string Action { get; set; }
        public DateTime Timestamp { get; set; }
        public string Details { get; set; }
    }
}