using System.ComponentModel;
using System.Diagnostics;

namespace InventoryManagementSystem.ViewModels
{
    public class MainViewModel : ViewModelBase
    {
        private object _currentView;

        public object CurrentView
        {
            get => _currentView;
            set
            {
                _currentView = value;
                Debug.WriteLine($"CurrentView set to: {value?.GetType().Name ?? "null"}");
                OnPropertyChanged(nameof(CurrentView));
            }
        }

        public MainViewModel()
        {
            Debug.WriteLine("MainViewModel initialized.");
        }
    }
}