using InventoryManagementSystem.Models;
using InventoryManagementSystem.Services;
using System;
using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class ItemFormViewModel : ViewModelBase
    {
        private readonly InventoryService _inventoryService;
        private readonly SupplierService _supplierService;
        private readonly User _currentUser;
        private readonly Item _item;
        private readonly Action _refreshCallback;
        private string _itemName;
        private string _category;
        private int _quantity;
        private decimal _unitPrice;
        private Supplier _selectedSupplier;
        private ObservableCollection<Supplier> _suppliers;
        private string _formTitle;

        public string FormTitle
        {
            get => _formTitle;
            set
            {
                _formTitle = value;
                OnPropertyChanged(nameof(FormTitle));
            }
        }

        public string ItemName
        {
            get => _itemName;
            set
            {
                _itemName = value;
                OnPropertyChanged(nameof(ItemName));
            }
        }

        public string Category
        {
            get => _category;
            set
            {
                _category = value;
                OnPropertyChanged(nameof(Category));
            }
        }

        public int Quantity
        {
            get => _quantity;
            set
            {
                _quantity = value;
                OnPropertyChanged(nameof(Quantity));
            }
        }

        public decimal UnitPrice
        {
            get => _unitPrice;
            set
            {
                _unitPrice = value;
                OnPropertyChanged(nameof(UnitPrice));
            }
        }

        public Supplier SelectedSupplier
        {
            get => _selectedSupplier;
            set
            {
                _selectedSupplier = value;
                OnPropertyChanged(nameof(SelectedSupplier));
            }
        }

        public ObservableCollection<Supplier> Suppliers
        {
            get => _suppliers;
            set
            {
                _suppliers = value;
                OnPropertyChanged(nameof(Suppliers));
            }
        }

        public ICommand SaveCommand { get; }
        public ICommand CancelCommand { get; }

        public ItemFormViewModel(User currentUser, Item item, Action refreshCallback)
        {
            _inventoryService = new InventoryService();
            _supplierService = new SupplierService();
            _currentUser = currentUser;
            _item = item;
            _refreshCallback = refreshCallback;

            // Initialize fields
            if (_item != null)
            {
                FormTitle = "Edit Item";
                ItemName = _item.ItemName;
                Category = _item.Category;
                Quantity = _item.Quantity;
                UnitPrice = _item.UnitPrice;
            }
            else
            {
                FormTitle = "Add Item";
                ItemName = string.Empty;
                Category = string.Empty;
                Quantity = 0;
                UnitPrice = 0;
            }

            // Load suppliers
            Suppliers = new ObservableCollection<Supplier>(_supplierService.GetAllSuppliers());
            SelectedSupplier = Suppliers.FirstOrDefault(s => s.SupplierID == _item?.SupplierID);

            SaveCommand = new RelayCommand(o => Save());
            CancelCommand = new RelayCommand(o => Cancel());
        }

        private void Save()
        {
            if (string.IsNullOrWhiteSpace(ItemName) || string.IsNullOrWhiteSpace(Category) || Quantity < 0 || UnitPrice < 0)
            {
                MessageBox.Show("Please fill all fields correctly.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            var item = new Item
            {
                ItemID = _item?.ItemID ?? 0,
                ItemName = ItemName,
                Category = Category,
                Quantity = Quantity,
                UnitPrice = UnitPrice,
                SupplierID = SelectedSupplier?.SupplierID,
                LastUpdated = DateTime.Now
            };

            bool success;
            if (_item == null)
            {
                success = _inventoryService.AddItem(item, _currentUser.UserID);
            }
            else
            {
                success = _inventoryService.UpdateItem(item, _currentUser.UserID);
            }

            if (success)
            {
                _refreshCallback?.Invoke();
                Application.Current.Windows.OfType<Window>().FirstOrDefault(w => w.Content == this)?.Close();
            }
            else
            {
                MessageBox.Show("Failed to save item.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void Cancel()
        {
            Application.Current.Windows.OfType<Window>().FirstOrDefault(w => w.Content == this)?.Close();
        }
    }
}