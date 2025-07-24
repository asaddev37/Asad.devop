using InventoryManagementSystem.Models;
using InventoryManagementSystem.Services;
using System.Collections.ObjectModel;
using System.Linq;
using System.Windows;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class InventoryViewModel : ViewModelBase
    {
        private readonly InventoryService _inventoryService;
        private readonly User _currentUser;
        private ObservableCollection<Item> _items;
        private Item _selectedItem;
        private bool _isLowStockView;

        public ObservableCollection<Item> Items
        {
            get => _items;
            set
            {
                _items = value;
                OnPropertyChanged(nameof(Items));
            }
        }

        public Item SelectedItem
        {
            get => _selectedItem;
            set
            {
                _selectedItem = value;
                OnPropertyChanged(nameof(SelectedItem));
            }
        }

        public ICommand AddItemCommand { get; }
        public ICommand EditItemCommand { get; }
        public ICommand DeleteItemCommand { get; }
        public ICommand ViewLowStockCommand { get; }

        public InventoryViewModel(User currentUser)
        {
            _inventoryService = new InventoryService();
            _currentUser = currentUser;
            _isLowStockView = false;
            Items = new ObservableCollection<Item>(_inventoryService.GetAllItems());
            AddItemCommand = new RelayCommand(o => AddItem());
            EditItemCommand = new RelayCommand(o => EditItem(), o => SelectedItem != null);
            DeleteItemCommand = new RelayCommand(o => DeleteItem(), o => SelectedItem != null);
            ViewLowStockCommand = new RelayCommand(o => ViewLowStock());
        }

        private void AddItem()
        {
            var window = new Window
            {
                Title = "Add Item",
                Width = 400,
                Height = 300,
                WindowStartupLocation = WindowStartupLocation.CenterOwner,
                Content = new ItemFormViewModel(_currentUser, null, RefreshItems)
            };
            window.ShowDialog();
        }

        private void EditItem()
        {
            var window = new Window
            {
                Title = "Edit Item",
                Width = 400,
                Height = 300,
                WindowStartupLocation = WindowStartupLocation.CenterOwner,
                Content = new ItemFormViewModel(_currentUser, SelectedItem, RefreshItems)
            };
            window.ShowDialog();
        }

        private void DeleteItem()
        {
            if (MessageBox.Show($"Are you sure you want to delete {SelectedItem.ItemName}?", "Confirm Delete",
                MessageBoxButton.YesNo, MessageBoxImage.Warning) == MessageBoxResult.Yes)
            {
                if (_inventoryService.DeleteItem(SelectedItem.ItemID, _currentUser.UserID))
                {
                    Items.Remove(SelectedItem);
                }
            }
        }

        private void ViewLowStock()
        {
            _isLowStockView = !_isLowStockView;
            if (_isLowStockView)
            {
                Items = new ObservableCollection<Item>(_inventoryService.GetAllItems().Where(i => i.Quantity < 10));
            }
            else
            {
                Items = new ObservableCollection<Item>(_inventoryService.GetAllItems());
            }
        }

        private void RefreshItems()
        {
            Items = new ObservableCollection<Item>(_inventoryService.GetAllItems());
            _isLowStockView = false;
        }
    }
}