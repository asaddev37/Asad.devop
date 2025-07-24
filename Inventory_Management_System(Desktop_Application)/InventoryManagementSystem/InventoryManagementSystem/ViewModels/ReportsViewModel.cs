using InventoryManagementSystem.Models;
using InventoryManagementSystem.Services;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class ReportsViewModel : ViewModelBase
    {
        private readonly InventoryService _inventoryService;
        private readonly TransactionService _transactionService;
        private readonly User _currentUser;
        private string _reportOutput;
        private int _lowStockThreshold;

        public string ReportOutput
        {
            get => _reportOutput;
            set
            {
                _reportOutput = value;
                OnPropertyChanged(nameof(ReportOutput));
            }
        }

        public ICommand GenerateInventoryStatusCommand { get; }
        public ICommand GenerateLowStockReportCommand { get; }
        public ICommand GenerateTransactionSummaryCommand { get; }

        public ReportsViewModel(User currentUser)
        {
            _inventoryService = new InventoryService();
            _transactionService = new TransactionService();
            _currentUser = currentUser;

            LoadSettings();
            GenerateInventoryStatusCommand = new RelayCommand(o => GenerateInventoryStatus());
            GenerateLowStockReportCommand = new RelayCommand(o => GenerateLowStockReport());
            GenerateTransactionSummaryCommand = new RelayCommand(o => GenerateTransactionSummary());
        }

        private void LoadSettings()
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);
            var configuration = builder.Build();
            _lowStockThreshold = configuration.GetValue("Settings:LowStockThreshold", 10);
        }

        private void GenerateInventoryStatus()
        {
            var items = _inventoryService.GetAllItems();
            var totalItems = items.Count;
            var totalQuantity = items.Sum(i => i.Quantity);
            var totalValue = items.Sum(i => i.Quantity * i.UnitPrice);

            var sb = new StringBuilder();
            sb.AppendLine("Inventory Status Report");
            sb.AppendLine($"Generated on: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            sb.AppendLine($"Total Items: {totalItems}");
            sb.AppendLine($"Total Quantity: {totalQuantity}");
            sb.AppendLine($"Total Value: ${totalValue:F2}");

            ReportOutput = sb.ToString();
        }

        private void GenerateLowStockReport()
        {
            var items = _inventoryService.GetAllItems();
            var lowStockItems = items.Where(i => i.Quantity <= _lowStockThreshold).ToList();

            var sb = new StringBuilder();
            sb.AppendLine("Low Stock Report");
            sb.AppendLine($"Generated on: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            if (lowStockItems.Any())
            {
                foreach (var item in lowStockItems)
                {
                    sb.AppendLine($"{item.ItemName} (ID: {item.ItemID}): {item.Quantity} units (Supplier ID: {item.SupplierID ?? 0})");
                }
            }
            else
            {
                sb.AppendLine("No items are low on stock.");
            }

            ReportOutput = sb.ToString();
        }

        private void GenerateTransactionSummary()
        {
            var transactions = _transactionService.GetAllTransactions();
            var totalTransactions = transactions.Count;
            var transactionsToday = transactions.Count(t => t.TransactionDate.Date == DateTime.Today);

            var sb = new StringBuilder();
            sb.AppendLine("Transaction Summary Report");
            sb.AppendLine($"Generated on: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            sb.AppendLine($"Total Transactions: {totalTransactions}");
            sb.AppendLine($"Transactions Today: {transactionsToday}");
            sb.AppendLine("\nRecent Transactions (Last 5):");
            var recentTransactions = transactions.OrderByDescending(t => t.TransactionDate).Take(5);
            foreach (var trans in recentTransactions)
            {
                sb.AppendLine($"{trans.TransactionDate:yyyy-MM-dd} - User {trans.UserID}: {trans.TransactionType} (Item ID: {trans.ItemID}, Qty: {trans.Quantity})");
            }

            ReportOutput = sb.ToString();
        }
    }
}