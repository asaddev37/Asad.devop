   M S B A M L   `   `   `  ����   InventoryManagementSystem=    7InventoryManagementSystem.Views.InventoryManagementView   W SPresentationCore, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35e aSystem.Windows.Controls.Ribbon, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089R NWindowsBase, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35F 9http://schemas.microsoft.com/winfx/2006/xaml/presentation     R NSystem.Xaml, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     @d2http://schemas.microsoft.com/expression/blend/2008     .��� $��10q�  � RowDefinitions  �� $
��Auto ��� $��* ��� $
��Auto �.+��� $��0��$��Inventory Management��   ModernLabel#��[  $��18(�$
��Bold"�$��0,0,0,10q�&   System.Windows.Controls.DataGrid  $��1��   AutoGenerateColumns$ False��   CanUserAddRows$ False��$��0,0,0,10q����� *Items+ �� SelectedItem �� *SelectedItem+   Columns 0  *System.Windows.Controls.DataGridTextColumn  ,  &System.Windows.Controls.DataGridColumn   Header$ Item ID��   
IsReadOnly$
 True��   Width5  /System.Windows.Controls.DataGridLengthConverter$ 80 1  +System.Windows.Controls.DataGridBoundColumn   Binding �� *ItemID+  $
 Name��$	 150  �� *
ItemName+  $ Category��$	 100  �� *
Category+  $ Quantity��$ 80  �� *
Quantity+  $ 
Unit Price��$	 100  �� *	UnitPrice+	 �� StringFormat$	 C��  $ Supplier ID��$	 100  �� *
SupplierID+  $ Last Updated��$ *  �� *LastUpdated+$	 
yyyy-MM-dd���� $��2��
 �� Orientation$
 
Horizontal=�$��Right=�.+��� $��Add Item��  ModernButton#��[ $��5q����� *AddItemCommand+�� $��	Edit Item��#��[ $��5q����� *EditItemCommand+{��� *SelectedItem+  NullToVisibilityConverter �� 	Converter# [  �� ConverterParameter$ Inverse���� $��Delete Item��#��[ $��5q����� *DeleteItemCommand+{��� *SelectedItem+# [ $ Inverse���� $��View Low Stock��#��[ $��5q����� *ViewLowStockCommand+