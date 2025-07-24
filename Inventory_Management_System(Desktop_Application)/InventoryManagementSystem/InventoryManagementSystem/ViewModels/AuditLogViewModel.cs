using InventoryManagementSystem.Models;
using InventoryManagementSystem.Services;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Windows.Input;

namespace InventoryManagementSystem.ViewModels
{
    public class AuditLogViewModel : ViewModelBase
    {
        private readonly AuditLogService _auditLogService;
        private ObservableCollection<AuditLog> _allLogs;
        private ObservableCollection<AuditLog> _filteredLogs;
        private List<string> _users;
        private List<string> _actionTypes;
        private string _selectedUser;
        private DateTime? _selectedDate;
        private string _selectedAction;

        public ObservableCollection<AuditLog> FilteredLogs
        {
            get => _filteredLogs;
            set
            {
                _filteredLogs = value;
                OnPropertyChanged(nameof(FilteredLogs));
            }
        }

        public List<string> Users
        {
            get => _users;
            set
            {
                _users = value;
                OnPropertyChanged(nameof(Users));
            }
        }

        public List<string> ActionTypes
        {
            get => _actionTypes;
            set
            {
                _actionTypes = value;
                OnPropertyChanged(nameof(ActionTypes));
            }
        }

        public string SelectedUser
        {
            get => _selectedUser;
            set
            {
                _selectedUser = value;
                OnPropertyChanged(nameof(SelectedUser));
            }
        }

        public DateTime? SelectedDate
        {
            get => _selectedDate;
            set
            {
                _selectedDate = value;
                OnPropertyChanged(nameof(SelectedDate));
            }
        }

        public string SelectedAction
        {
            get => _selectedAction;
            set
            {
                _selectedAction = value;
                OnPropertyChanged(nameof(SelectedAction));
            }
        }

        public ICommand ApplyFiltersCommand { get; }
        public ICommand ResetFiltersCommand { get; }

        public AuditLogViewModel()
        {
            _auditLogService = new AuditLogService();
            LoadLogs();
            ApplyFiltersCommand = new RelayCommand(o => ApplyFilters());
            ResetFiltersCommand = new RelayCommand(o => ResetFilters());
        }

        private void LoadLogs()
        {
            _allLogs = new ObservableCollection<AuditLog>(_auditLogService.GetAuditLogs());
            FilteredLogs = new ObservableCollection<AuditLog>(_allLogs);

            // Populate filter options
            Users = new List<string> { "All Users" };
            Users.AddRange(_allLogs.Where(log => log.UserID.HasValue).Select(log => log.UserID.Value.ToString()).Distinct().OrderBy(id => id));

            ActionTypes = new List<string> { "All Actions" };
            ActionTypes.AddRange(_allLogs.Select(log => log.Action).Distinct().OrderBy(action => action));

            SelectedUser = "All Users";
            SelectedDate = null;
            SelectedAction = "All Actions";
        }

        private void ApplyFilters()
        {
            var filtered = _allLogs.AsEnumerable();

            // Filter by User
            if (SelectedUser != "All Users")
            {
                if (int.TryParse(SelectedUser, out int userId))
                {
                    filtered = filtered.Where(log => log.UserID == userId);
                }
            }

            // Filter by Date
            if (SelectedDate.HasValue)
            {
                var selectedDate = SelectedDate.Value.Date;
                filtered = filtered.Where(log => log.Timestamp.Date == selectedDate);
            }

            // Filter by Action
            if (SelectedAction != "All Actions")
            {
                filtered = filtered.Where(log => log.Action == SelectedAction);
            }

            FilteredLogs = new ObservableCollection<AuditLog>(filtered);
        }

        private void ResetFilters()
        {
            SelectedUser = "All Users";
            SelectedDate = null;
            SelectedAction = "All Actions";
            FilteredLogs = new ObservableCollection<AuditLog>(_allLogs);
        }
    }
}