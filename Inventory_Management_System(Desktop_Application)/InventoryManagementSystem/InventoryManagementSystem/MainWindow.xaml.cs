using InventoryManagementSystem.ViewModels;
using System.Windows;

namespace InventoryManagementSystem
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            DataContext = new MainViewModel();
        }
    }
}