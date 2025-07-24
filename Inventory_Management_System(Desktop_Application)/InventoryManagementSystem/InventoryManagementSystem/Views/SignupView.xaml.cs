using InventoryManagementSystem.ViewModels;
using System.Windows;
using System.Windows.Controls;

namespace InventoryManagementSystem.Views
{
    public partial class SignupView : UserControl
    {
        public SignupView()
        {
            InitializeComponent();
            DataContext = new SignupViewModel();
        }

        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            // No code is needed here unless you want to do something manually
        }
    }
}