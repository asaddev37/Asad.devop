   M S B A M L   `   `   `  ����   InventoryManagementSystem2    ,InventoryManagementSystem.Views.ItemFormView   W SPresentationCore, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35e aSystem.Windows.Controls.Ribbon, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089R NWindowsBase, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35F 9http://schemas.microsoft.com/winfx/2006/xaml/presentation     R NSystem.Xaml, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     @d2http://schemas.microsoft.com/expression/blend/2008     .��� $��10q�  � RowDefinitions  �� $
��Auto ��� $
��Auto ��� $
��Auto ��� $
��Auto ��� $
��Auto ��� $
��Auto ��� $
��Auto � � ColumnDefinitions �� $	��120 ��� $��* �.+��� $��0��$��2��   ModernLabel#��[  $��16(�$
��Bold"�$��0,0,0,10q����� *	FormTitle+�� $��1��$��0��$��
Item Name:��#��[  $��0,0,5,5q��� $��1��$��1��  ModernTextBox#��[ $��0,0,0,5q����� *
ItemName+ �� UpdateSourceTrigger$ PropertyChanged=�.�� J� InputBindings �� 
 �� Key$ Enter�� �� Command �� *SaveCommand+.���� $��2��$��0��$��	Category:��#��[  $��0,0,5,5q��� $��2��$��1��#��[ $��0,0,0,5q����� *
Category+$ PropertyChanged=�.�� �� $ Enter�� �� *SaveCommand+.���� $��3��$��0��$��	Quantity:��#��[  $��0,0,5,5q��� $��3��$��1��#��[ $��0,0,0,5q����� *
Quantity+$ PropertyChanged=�.�� �� $ Enter�� �� *SaveCommand+.���� $��4��$��0��$��Unit Price:��#��[  $��0,0,5,5q��� $��4��$��1��#��[ $��0,0,0,5q����� *	UnitPrice+$ PropertyChanged=�.�� �� $ Enter�� �� *SaveCommand+.���� $��5��$��0��$��	Supplier:��#��[  $��0,0,5,5q��� $��5��$��1�� �� DisplayMemberPath$ SupplierName��  ModernComboBox#��[ $��0,0,0,5q����� *	Suppliers+ �� SelectedItem �� *SelectedSupplier+�� $��6��$��2�� �� Orientation$ 
Horizontal=�$��Right=�$��0,10,0,0q�.+��� $
��Save��  ModernButton#��[ $��5q����� *SaveCommand+�� $��Cancel��#��[ $��5q����� *CancelCommand+