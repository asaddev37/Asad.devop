namespace InventoryManagementSystem.Models
{
    public class Transaction
    {
        public int TransactionID { get; set; }
        public int ItemID { get; set; }
        public int UserID { get; set; }
        public string TransactionType { get; set; } // ENUM: 'Add', 'Remove', 'Update'
        public int Quantity { get; set; }
        public DateTime TransactionDate { get; set; }
        public string Description { get; set; }
    }
}