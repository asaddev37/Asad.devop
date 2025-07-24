using InventoryManagementSystem.Models;
using InventoryManagementSystem.Services;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class TransactionFormViewModel : ViewModelBase
    {
        private readonly InventoryService _inventoryService;
        private readonly TransactionService _transactionService;
        private readonly User _currentUser;
        private ObservableCollection<Item> _items;
        private Item _selectedItem;
        private List<string> _transactionTypes;
        private string _selectedTransactionType;
        private int _quantity = 1; // Default to 1 to avoid empty input issues
        private string _description;

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

        public List<string> TransactionTypes
        {
            get => _transactionTypes;
            set
            {
                _transactionTypes = value;
                OnPropertyChanged(nameof(TransactionTypes));
            }
        }

        public string SelectedTransactionType
        {
            get => _selectedTransactionType;
            set
            {
                _selectedTransactionType = value;
                OnPropertyChanged(nameof(SelectedTransactionType));
            }
        }

        public int Quantity
        {
            get => _quantity;
            set
            {
                if (value <= 0) value = 1; // Ensure quantity is at least 1
                _quantity = value;
                OnPropertyChanged(nameof(Quantity));
            }
        }

        public string Description
        {
            get => _description;
            set
            {
                _description = value;
                OnPropertyChanged(nameof(Description));
            }
        }

        public ICommand SubmitTransactionCommand { get; }
        public ICommand CancelCommand { get; }

        public TransactionFormViewModel(User currentUser)
        {
            _inventoryService = new InventoryService();
            _transactionService = new TransactionService();
            _currentUser = currentUser;

            TransactionTypes = new List<string> { "Stock In", "Stock Out", "Transfer" };
            LoadItems();

            SubmitTransactionCommand = new RelayCommand(o => SubmitTransaction());
            CancelCommand = new RelayCommand(o => Cancel());
        }

        private void LoadItems()
        {
            try
            {
                var items = _inventoryService.GetAllItems();
                Items = new ObservableCollection<Item>(items ?? new List<Item>());
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Failed to load items: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                Items = new ObservableCollection<Item>();
            }
        }

        private void SubmitTransaction()
        {
            Console.WriteLine($"SelectedItem: {(SelectedItem != null ? SelectedItem.ItemName : "null")}");
            Console.WriteLine($"SelectedTransactionType: {SelectedTransactionType ?? "null"}");
            Console.WriteLine($"Quantity: {Quantity}");
            Console.WriteLine($"Description: {Description ?? "null"}");

            if (SelectedItem == null)
            {
                MessageBox.Show("Please select an item.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }
            if (string.IsNullOrWhiteSpace(SelectedTransactionType))
            {
                MessageBox.Show("Please select a transaction type.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }
            if (Quantity <= 0)
            {
                MessageBox.Show("Quantity must be greater than 0.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var transaction = new Transaction
            {
                ItemID = SelectedItem.ItemID,
                UserID = _currentUser.UserID,
                TransactionType = SelectedTransactionType,
                Quantity = Quantity,
                TransactionDate = DateTime.Now,
                Description = Description
            };

            Console.WriteLine($"Transaction: ItemID={transaction.ItemID}, UserID={transaction.UserID}, Type={transaction.TransactionType}, Quantity={transaction.Quantity}, Date={transaction.TransactionDate}, Desc={transaction.Description}");

            bool success = _transactionService.AddTransaction(transaction);
            if (success)
            {
                if (SelectedTransactionType == "Stock In")
                {
                    SelectedItem.Quantity += Quantity;
                }
                else if (SelectedTransactionType == "Stock Out")
                {
                    if (SelectedItem.Quantity < Quantity)
                    {
                        MessageBox.Show("Not enough stock to remove.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    SelectedItem.Quantity -= Quantity;
                }
                _inventoryService.UpdateItem(SelectedItem, _currentUser.UserID);

                MessageBox.Show("Transaction recorded successfully.", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                ClearForm();
            }
            else
            {
                MessageBox.Show("Failed to record transaction. Check audit log or Output window for details.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void ClearForm()
        {
            SelectedItem = null;
            SelectedTransactionType = null;
            Quantity = 1; // Reset to default
            Description = string.Empty;
        }

        private void Cancel()
        {
            ClearForm();
        }
    }
}