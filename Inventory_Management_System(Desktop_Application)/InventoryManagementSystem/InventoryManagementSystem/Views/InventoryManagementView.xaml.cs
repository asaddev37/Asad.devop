using InventoryManagementSystem.Models;
using InventoryManagementSystem.ViewModels;
using System;
using System.Windows;
using System.Windows.Controls;
using System.Diagnostics;

namespace InventoryManagementSystem.Views
{
    public partial class InventoryManagementView : UserControl
    {
        public InventoryManagementView()
        {
            try
            {
                InitializeComponent();
                Debug.WriteLine("InventoryManagementView initialized.");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error initializing InventoryManagementView: {ex.Message}");
                MessageBox.Show($"Failed to load Inventory Management: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        public void SetUser(User user)
        {
            try
            {
                DataContext = new InventoryViewModel(user);
                Debug.WriteLine("InventoryManagementView DataContext set with InventoryViewModel.");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error setting DataContext in InventoryManagementView: {ex.Message}");
                MessageBox.Show($"Failed to initialize Inventory Management data: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            try
            {
                Debug.WriteLine("InventoryManagementView loaded successfully.");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error in InventoryManagementView Loaded event: {ex.Message}");
                MessageBox.Show($"Error loading Inventory Management: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}