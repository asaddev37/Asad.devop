using InventoryManagementSystem.ViewModels;
using System.Windows;
using System.Windows.Controls;

namespace InventoryManagementSystem.Views
{
    public partial class LoginView : UserControl
    {
        public LoginView()
        {
            InitializeComponent();
            DataContext = new LoginViewModel();
        }
        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            // No code is needed here unless you want to do something manually
        }

    }
}