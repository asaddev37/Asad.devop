using System.Diagnostics;
using System.Windows;
using System.Windows.Controls;

namespace InventoryManagementSystem.Views
{
    public partial class StaffDashboard : UserControl
    {
        public StaffDashboard()
        {
            try
            {
                InitializeComponent();
                Debug.WriteLine("StaffDashboard initialized successfully.");
            }
            catch (System.Windows.Markup.XamlParseException ex)
            {
                Debug.WriteLine($"XamlParseException in StaffDashboard: {ex.Message}");
                Debug.WriteLine($"Inner Exception: {ex.InnerException?.Message}");
                Debug.WriteLine($"Stack Trace: {ex.StackTrace}");
                throw;
            }
        }
        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            // Add initialization logic here if needed
            Debug.WriteLine("StaffDashboard loaded.");
        }
    }
}