using InventoryManagementSystem.Models;
using InventoryManagementSystem.ViewModels;
using System;
using System.Windows;
using System.Windows.Controls;
using System.Diagnostics;

namespace InventoryManagementSystem.Views
{
    public partial class AdminDashboardView : UserControl
    {
        public AdminDashboardView()
        {
            try
            {
                InitializeComponent();
                Debug.WriteLine("AdminDashboardView initialized.");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error initializing AdminDashboardView: {ex.Message}");
                MessageBox.Show($"Failed to load Admin Dashboard: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        public void SetUser(User user)
        {
            try
            {
                DataContext = new AdminViewModel(user);
                Debug.WriteLine("AdminDashboardView DataContext set with AdminViewModel.");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error setting DataContext in AdminDashboardView: {ex.Message}");
                MessageBox.Show($"Failed to initialize Admin Dashboard data: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            try
            {
                Debug.WriteLine("AdminDashboardView loaded successfully.");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error in AdminDashboardView Loaded event: {ex.Message}");
                MessageBox.Show($"Error loading Admin Dashboard: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}