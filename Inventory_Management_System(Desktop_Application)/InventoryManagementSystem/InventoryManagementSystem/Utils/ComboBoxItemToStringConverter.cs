using System;
using System.Globalization;
using System.Windows.Controls;
using System.Windows.Data;

namespace InventoryManagementSystem.Utils
{
    public class ComboBoxItemToStringConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return value?.ToString();
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value is ComboBoxItem comboBoxItem)
            {
                return comboBoxItem.Content?.ToString();
            }
            return value?.ToString();
        }
    }
}