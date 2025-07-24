namespace InventoryManagementSystem.Models
{
    public class Report
    {
        public string ReportType { get; set; } // e.g., "InventoryStatus", "LowStock", "TransactionSummary"
        public DateTime GeneratedOn { get; set; }
        public string Content { get; set; } // Formatted report text
    }
}