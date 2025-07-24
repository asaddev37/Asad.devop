using InventoryManagementSystem.Models;
using InventoryManagementSystem.Services;
using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class SupportRequestViewModel : ViewModelBase
    {
        private readonly SupportRequestService _supportRequestService;
        private readonly User _currentUser;
        private string _description;
        private List<string> _priorities;
        private string _selectedPriority;

        public string Description
        {
            get => _description;
            set
            {
                _description = value;
                OnPropertyChanged(nameof(Description));
            }
        }

        public List<string> Priorities
        {
            get => _priorities;
            set
            {
                _priorities = value;
                OnPropertyChanged(nameof(Priorities));
            }
        }

        public string SelectedPriority
        {
            get => _selectedPriority;
            set
            {
                _selectedPriority = value;
                OnPropertyChanged(nameof(SelectedPriority));
            }
        }

        public ICommand SubmitRequestCommand { get; }
        public ICommand CancelCommand { get; }

        public SupportRequestViewModel(User currentUser)
        {
            _supportRequestService = new SupportRequestService();
            _currentUser = currentUser;

            Priorities = new List<string> { "Low", "Medium", "High" };
            SelectedPriority = "Medium";

            SubmitRequestCommand = new RelayCommand(o => SubmitRequest());
            CancelCommand = new RelayCommand(o => Cancel());
        }

        private void SubmitRequest()
        {
            if (string.IsNullOrWhiteSpace(Description))
            {
                MessageBox.Show("Description is required.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var request = new SupportRequest
            {
                Description = Description,
                Priority = SelectedPriority,
                Status = "Pending",
                SubmittedBy = _currentUser.UserID,
                SubmittedDate = DateTime.Now
            };

            bool success = _supportRequestService.AddSupportRequest(request, _currentUser.UserID); // Pass the required userId parameter
            if (success)
            {
                MessageBox.Show("Support request submitted successfully.", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                ClearForm();
            }
            else
            {
                MessageBox.Show("Failed to submit support request.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void ClearForm()
        {
            Description = string.Empty;
            SelectedPriority = "Medium";
        }

        private void Cancel()
        {
            ClearForm();
        }
    }
}