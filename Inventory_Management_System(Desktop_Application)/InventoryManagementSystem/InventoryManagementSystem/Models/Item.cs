using InventoryManagementSystem.ViewModels;

namespace InventoryManagementSystem.Models
{
    public class Item : ViewModelBase
    {
        private bool _isLowStock;
        public int ItemID { get; set; }
        public string ItemName { get; set; }
        public string Category { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public int? SupplierID { get; set; }
        public DateTime LastUpdated { get; set; }

        public bool IsLowStock
        {
            get => _isLowStock;
            set
            {
                _isLowStock = value;
                OnPropertyChanged(nameof(IsLowStock));
            }
        }
    }
}