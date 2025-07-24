using InventoryManagementSystem.Models;
using InventoryManagementSystem.Services;
using System;
using System.Windows;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class SupplierFormViewModel : ViewModelBase
    {
        private readonly SupplierService _supplierService;
        private readonly User _currentUser;
        private readonly Action _refreshCallback;
        private Supplier _supplier;
        private string _supplierName;
        private string _contactInfo;
        private string _address;
        private string _formTitle;

        public string FormTitle
        {
            get => _formTitle;
            set
            {
                _formTitle = value;
                OnPropertyChanged(nameof(FormTitle));
            }
        }

        public string SupplierName
        {
            get => _supplierName;
            set
            {
                _supplierName = value;
                OnPropertyChanged(nameof(SupplierName));
            }
        }

        public string ContactInfo
        {
            get => _contactInfo;
            set
            {
                _contactInfo = value;
                OnPropertyChanged(nameof(ContactInfo));
            }
        }

        public string Address
        {
            get => _address;
            set
            {
                _address = value;
                OnPropertyChanged(nameof(Address));
            }
        }

        public ICommand SaveCommand { get; }
        public ICommand CancelCommand { get; }

        public SupplierFormViewModel(User currentUser, Supplier supplier, Action refreshCallback)
        {
            _supplierService = new SupplierService();
            _currentUser = currentUser;
            _refreshCallback = refreshCallback;
            _supplier = supplier ?? new Supplier();

            // Initialize fields
            if (_supplier.SupplierID == 0)
            {
                FormTitle = "Add Supplier";
            }
            else
            {
                FormTitle = "Edit Supplier";
            }
            SupplierName = _supplier.SupplierName;
            ContactInfo = _supplier.ContactInfo;
            Address = _supplier.Address;

            SaveCommand = new RelayCommand(o => Save());
            CancelCommand = new RelayCommand(o => Cancel());
        }

        private void Save()
        {
            if (string.IsNullOrWhiteSpace(SupplierName))
            {
                MessageBox.Show("Supplier name is required.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var supplier = new Supplier
            {
                SupplierID = _supplier.SupplierID,
                SupplierName = SupplierName,
                ContactInfo = ContactInfo,
                Address = Address
            };

            bool success = _supplier.SupplierID == 0 ?
                _supplierService.AddSupplier(supplier, _currentUser.UserID) :
                _supplierService.UpdateSupplier(supplier, _currentUser.UserID);

            if (success)
            {
                _refreshCallback();
                var window = Application.Current.Windows.OfType<Window>().SingleOrDefault(w => w.Content == this);
                window?.Close();
            }
            else
            {
                MessageBox.Show("Failed to save supplier.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void Cancel()
        {
            var window = Application.Current.Windows.OfType<Window>().SingleOrDefault(w => w.Content == this);
            window?.Close();
        }
    }
}