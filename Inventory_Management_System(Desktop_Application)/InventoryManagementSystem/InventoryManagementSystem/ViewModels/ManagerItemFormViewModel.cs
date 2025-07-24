using InventoryManagementSystem.Models;
using InventoryManagementSystem.Services;
using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class ManagerItemFormViewModel : ViewModelBase
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
        private List<Supplier> _suppliers;
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

        public List<Supplier> Suppliers
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

        public ManagerItemFormViewModel(User currentUser, Item item, Action refreshCallback)
        {
            _inventoryService = new InventoryService();
            _supplierService = new SupplierService();
            _currentUser = currentUser;
            _item = item ?? throw new ArgumentException("Item cannot be null for Manager edit.");
            _refreshCallback = refreshCallback;

            FormTitle = "Edit Item";
            ItemName = _item.ItemName; // Read-only
            Category = _item.Category; // Read-only
            Quantity = _item.Quantity;
            UnitPrice = _item.UnitPrice;

            Suppliers = _supplierService.GetAllSuppliers();
            SelectedSupplier = Suppliers.Find(s => s.SupplierID == _item.SupplierID);

            SaveCommand = new RelayCommand(o => Save(), o => CanSave());
            CancelCommand = new RelayCommand(o => Cancel());
        }

        private bool CanSave()
        {
            return Quantity >= 0 && UnitPrice >= 0 && SelectedSupplier != null;
        }

        private void Save()
        {
            if (!CanSave())
            {
                MessageBox.Show("Please fill all fields correctly.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            var item = new Item
            {
                ItemID = _item.ItemID,
                ItemName = _item.ItemName,
                Category = _item.Category,
                Quantity = Quantity,
                UnitPrice = UnitPrice,
                SupplierID = SelectedSupplier?.SupplierID,
                LastUpdated = DateTime.Now
            };

            if (_inventoryService.UpdateItem(item, _currentUser.UserID))
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