using System.Diagnostics;
using System.Windows;
using System.Windows.Controls;

namespace InventoryManagementSystem.Views
{
    public partial class ManagerDashboardView : UserControl
    {
        public ManagerDashboardView()
        {
            InitializeComponent();
        }
        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            // Add initialization logic here if needed
            Debug.WriteLine("ManagerDashboardView loaded.");
        }
    }

}