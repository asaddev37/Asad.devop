using InventoryManagementSystem.Models;
using InventoryManagementSystem.ViewModels;
using System.Windows.Controls;
using System.Windows.Input;

namespace InventoryManagementSystem.Views
{
    public partial class TransactionFormView : UserControl
    {
        public TransactionFormView()
        {
            InitializeComponent();
        }

        private void ItemComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (DataContext is TransactionFormViewModel vm)
            {
                vm.SelectedItem = ItemComboBox.SelectedItem as Item;
            }
        }

        private void TransactionTypeComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (DataContext is TransactionFormViewModel vm)
            {
                vm.SelectedTransactionType = TransactionTypeComboBox.SelectedItem as string;
            }
        }

        private void TextBox_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            e.Handled = !IsTextAllowed(e.Text);
        }

        private static bool IsTextAllowed(string text)
        {
            return int.TryParse(text, out _);
        }
    }
}