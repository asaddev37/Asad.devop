using InventoryManagementSystem.Models;
using InventoryManagementSystem.Services;
using Microsoft.Extensions.Configuration; // Added this using directive
using System;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class ManagerInventoryViewModel : ViewModelBase
    {
        private readonly InventoryService _inventoryService;
        private readonly User _currentUser;
        private ObservableCollection<Item> _items;
        private Item _selectedItem;
        private int _lowStockThreshold;

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

        public ICommand EditItemCommand { get; }
        public ICommand ViewLowStockCommand { get; }

        public ManagerInventoryViewModel(User currentUser)
        {
            _inventoryService = new InventoryService();
            _currentUser = currentUser;

            LoadSettings();
            LoadItems();
            UpdateLowStockStatus();

            EditItemCommand = new RelayCommand(o => EditItem(), o => SelectedItem != null);
            ViewLowStockCommand = new RelayCommand(o => ViewLowStock());
        }

        private void LoadSettings()
        {
            try
            {
                var builder = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);
                var configuration = builder.Build();
                _lowStockThreshold = configuration.GetValue<int>("Settings:LowStockThreshold", 10); // Explicitly specify type
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Failed to load settings: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                _lowStockThreshold = 10; // Fallback value
            }
        }

        private void LoadItems()
        {
            try
            {
                var items = _inventoryService.GetAllItems();
                if (items == null || !items.Any())
                {
                    MessageBox.Show("No items found in inventory.", "Information", MessageBoxButton.OK, MessageBoxImage.Information);
                }
                Items = new ObservableCollection<Item>(items);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Failed to load inventory: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                Items = new ObservableCollection<Item>();
            }
        }

        private void UpdateLowStockStatus()
        {
            if (Items == null) return;
            foreach (var item in Items)
            {
                item.IsLowStock = item.Quantity <= _lowStockThreshold;
            }
        }

        private void EditItem()
        {
            var window = new Window
            {
                Title = "Edit Item",
                Width = 400,
                Height = 300,
                WindowStartupLocation = WindowStartupLocation.CenterOwner,
                Content = new ManagerItemFormViewModel(_currentUser, SelectedItem, () =>
                {
                    LoadItems();
                    UpdateLowStockStatus();
                })
            };
            window.ShowDialog();
        }

        private void ViewLowStock()
        {
            var lowStockItems = Items.Where(i => i.IsLowStock).ToList();
            if (lowStockItems.Any())
            {
                var message = string.Join("\n", lowStockItems.Select(i => $"{i.ItemName}: {i.Quantity} units"));
                MessageBox.Show($"Low Stock Items:\n{message}", "Low Stock Alert", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            else
            {
                MessageBox.Show("No items are low on stock.", "Low Stock Alert", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }
    }
}