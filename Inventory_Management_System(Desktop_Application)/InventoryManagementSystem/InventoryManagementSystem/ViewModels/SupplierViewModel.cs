using InventoryManagementSystem.Models;
using InventoryManagementSystem.Services;
using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class SupplierViewModel : ViewModelBase
    {
        private readonly SupplierService _supplierService;
        private readonly User _currentUser;
        private ObservableCollection<Supplier> _suppliers;
        private Supplier _selectedSupplier;

        public ObservableCollection<Supplier> Suppliers
        {
            get => _suppliers;
            set
            {
                _suppliers = value;
                OnPropertyChanged(nameof(Suppliers));
            }
        }

        public Supplier SelectedSupplier
        {
            get => _selectedSupplier;
            set
            {
                _selectedSupplier = value;
                OnPropertyChanged(nameof(SelectedSupplier));
            }
        }

        public ICommand AddSupplierCommand { get; }
        public ICommand EditSupplierCommand { get; }
        public ICommand DeleteSupplierCommand { get; }

        public SupplierViewModel(User currentUser)
        {
            _supplierService = new SupplierService();
            _currentUser = currentUser;
            Suppliers = new ObservableCollection<Supplier>(_supplierService.GetAllSuppliers());
            AddSupplierCommand = new RelayCommand(o => AddSupplier());
            EditSupplierCommand = new RelayCommand(o => EditSupplier(), o => SelectedSupplier != null);
            DeleteSupplierCommand = new RelayCommand(o => DeleteSupplier(), o => SelectedSupplier != null);
        }

        private void AddSupplier()
        {
            var window = new Window
            {
                Title = "Add Supplier",
                Width = 400,
                Height = 300,
                WindowStartupLocation = WindowStartupLocation.CenterOwner,
                Content = new SupplierFormViewModel(_currentUser, null, () => Suppliers = new ObservableCollection<Supplier>(_supplierService.GetAllSuppliers()))
            };
            window.ShowDialog();
        }

        private void EditSupplier()
        {
            var window = new Window
            {
                Title = "Edit Supplier",
                Width = 400,
                Height = 300,
                WindowStartupLocation = WindowStartupLocation.CenterOwner,
                Content = new SupplierFormViewModel(_currentUser, SelectedSupplier, () => Suppliers = new ObservableCollection<Supplier>(_supplierService.GetAllSuppliers()))
            };
            window.ShowDialog();
        }

        private void DeleteSupplier()
        {
            if (MessageBox.Show($"Are you sure you want to delete {SelectedSupplier.SupplierName}?", "Confirm Delete",
                MessageBoxButton.YesNo, MessageBoxImage.Warning) == MessageBoxResult.Yes)
            {
                if (_supplierService.DeleteSupplier(SelectedSupplier.SupplierID, _currentUser.UserID))
                {
                    Suppliers.Remove(SelectedSupplier);
                }
            }
        }
    }
}