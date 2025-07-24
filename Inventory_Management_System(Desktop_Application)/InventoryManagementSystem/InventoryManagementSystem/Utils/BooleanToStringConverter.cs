using System;
using System.Globalization;
using System.Windows.Data;

namespace InventoryManagementSystem.Utils
{
    public class BooleanToStringConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value is bool boolValue && parameter is string param)
            {
                var options = param.Split('|');
                return boolValue ? options[1] : options[0];
            }
            return value;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}