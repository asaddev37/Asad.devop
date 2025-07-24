using InventoryManagementSystem.ViewModels;
using System.Windows.Controls;

namespace InventoryManagementSystem.Views
{
    public partial class StaffInventoryView : UserControl
    {
        public StaffInventoryView()
        {
            InitializeComponent();
            DataContext = new StaffInventoryViewModel();
        }
    }
}