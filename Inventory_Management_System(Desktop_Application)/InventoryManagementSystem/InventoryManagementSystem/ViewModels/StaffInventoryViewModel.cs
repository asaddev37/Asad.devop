using InventoryManagementSystem.Models;
using InventoryManagementSystem.Services;
using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class StaffInventoryViewModel : ViewModelBase
    {
        private readonly InventoryService _inventoryService;
        private readonly AuditLogService _auditLogService;
        private ObservableCollection<Item> _inventoryItems;

        public ObservableCollection<Item> InventoryItems
        {
            get => _inventoryItems;
            set
            {
                _inventoryItems = value;
                OnPropertyChanged(nameof(InventoryItems));
            }
        }

        public ICommand BackCommand { get; }

        public StaffInventoryViewModel()
        {
            _inventoryService = new InventoryService();
            _auditLogService = new AuditLogService();
            LoadInventory();
            BackCommand = new RelayCommand(o => NavigateBack(o as Frame));
        }

        private void LoadInventory()
        {
            try
            {
                var items = _inventoryService.GetAllItems();
                Console.WriteLine($"StaffInventoryViewModel: GetAllItems returned {items?.Count ?? 0} items.");
                if (items == null || !items.Any())
                {
                    _auditLogService.LogAction(null, "Inventory Load Failed", "No items found in inventory for staff view.");
                    MessageBox.Show("No items found in inventory.", "Information", MessageBoxButton.OK, MessageBoxImage.Information);
                    InventoryItems = new ObservableCollection<Item>();
                }
                else
                {
                    InventoryItems = new ObservableCollection<Item>(items);
                    Console.WriteLine($"StaffInventoryViewModel: Loaded {InventoryItems.Count} items into InventoryItems.");
                }
            }
            catch (Exception ex)
            {
                string errorMsg = $"Error loading inventory: {ex.Message}";
                _auditLogService.LogAction(null, "Inventory Load Failed", errorMsg);
                Console.WriteLine($"StaffInventoryViewModel: {errorMsg}");
                MessageBox.Show($"Failed to load inventory: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                InventoryItems = new ObservableCollection<Item>();
            }
        }

        private void NavigateBack(Frame frame)
        {
            frame?.GoBack();
        }
    }
}