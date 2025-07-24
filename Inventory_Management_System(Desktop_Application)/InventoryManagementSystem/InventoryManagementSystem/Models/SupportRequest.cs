namespace InventoryManagementSystem.Models
{
    public class SupportRequest
    {
        public int RequestID { get; set; }
        public string Description { get; set; }
        public string Priority { get; set; }
        public string Status { get; set; }
        public int SubmittedBy { get; set; }
        public DateTime SubmittedDate { get; set; }
    }
}