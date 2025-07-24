using InventoryManagementSystem.Models;
using InventoryManagementSystem.Services;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class TransactionHistoryViewModel : ViewModelBase
    {
        private readonly TransactionService _transactionService;
        private readonly InventoryService _inventoryService;
        private readonly User _currentUser;
        private ObservableCollection<Transaction> _allTransactions;
        private ObservableCollection<Transaction> _filteredTransactions;
        private List<Item> _items;
        private List<int> _users;
        private Item _selectedItem;
        private int? _selectedUser;
        private DateTime? _selectedDate;

        public ObservableCollection<Transaction> FilteredTransactions
        {
            get => _filteredTransactions;
            set
            {
                _filteredTransactions = value;
                OnPropertyChanged(nameof(FilteredTransactions));
            }
        }

        public List<Item> Items
        {
            get => _items;
            set
            {
                _items = value;
                OnPropertyChanged(nameof(Items));
            }
        }

        public List<int> Users
        {
            get => _users;
            set
            {
                _users = value;
                OnPropertyChanged(nameof(Users));
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

        public int? SelectedUser
        {
            get => _selectedUser;
            set
            {
                _selectedUser = value;
                OnPropertyChanged(nameof(SelectedUser));
            }
        }

        public DateTime? SelectedDate
        {
            get => _selectedDate;
            set
            {
                _selectedDate = value;
                OnPropertyChanged(nameof(SelectedDate));
            }
        }

        public ICommand ApplyFiltersCommand { get; }
        public ICommand ResetFiltersCommand { get; }

        public TransactionHistoryViewModel(User currentUser)
        {
            _transactionService = new TransactionService();
            _inventoryService = new InventoryService();
            _currentUser = currentUser;

            LoadTransactions();
            ApplyFiltersCommand = new RelayCommand(o => ApplyFilters());
            ResetFiltersCommand = new RelayCommand(o => ResetFilters());
        }

        private void LoadTransactions()
        {
            _allTransactions = new ObservableCollection<Transaction>(_transactionService.GetAllTransactions());
            FilteredTransactions = new ObservableCollection<Transaction>(_allTransactions);

            Items = new List<Item> { new Item { ItemID = 0, ItemName = "All Items" } };
            Items.AddRange(_inventoryService.GetAllItems());

            Users = new List<int> { 0 }; // 0 for "All Users"
            Users.AddRange(_allTransactions.Select(t => t.UserID).Distinct().OrderBy(id => id));

            SelectedItem = Items[0];
            SelectedUser = 0;
            SelectedDate = null;
        }

        private void ApplyFilters()
        {
            var filtered = _allTransactions.AsEnumerable();

            if (SelectedItem != null && SelectedItem.ItemID != 0)
            {
                filtered = filtered.Where(t => t.ItemID == SelectedItem.ItemID);
            }

            if (SelectedUser.HasValue && SelectedUser != 0)
            {
                filtered = filtered.Where(t => t.UserID == SelectedUser);
            }

            if (SelectedDate.HasValue)
            {
                filtered = filtered.Where(t => t.TransactionDate.Date == SelectedDate.Value.Date);
            }

            FilteredTransactions = new ObservableCollection<Transaction>(filtered);
        }

        private void ResetFilters()
        {
            SelectedItem = Items[0];
            SelectedUser = 0;
            SelectedDate = null;
            FilteredTransactions = new ObservableCollection<Transaction>(_allTransactions);
        }
    }
}