   M S B A M L   `   `   `  ����   InventoryManagementSystem<    6InventoryManagementSystem.Views.TransactionHistoryView   W SPresentationCore, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35e aSystem.Windows.Controls.Ribbon, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089R NWindowsBase, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35F 9http://schemas.microsoft.com/winfx/2006/xaml/presentation     R NSystem.Xaml, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     @d2http://schemas.microsoft.com/expression/blend/2008     .��� $��10q�  � RowDefinitions  �� $
��Auto ��� $
��Auto ��� $��* �.+��� $��0��$��Transaction History��   ModernLabel#��[  $��18(�$
��Bold"�$��0,0,0,10q��� $��1�� �� Orientation$ 
Horizontal=�$��0,0,0,10q�.+��� $��Filter by Date:��#��[  $��0,0,5,0q�(  "System.Windows.Controls.DatePicker  $	��120��$��0,0,10,0q�   SelectedDate �� *SelectedDate+�� $��Filter by Item ID:��#��[  $��0,0,5,0q���  �� DisplayMemberPath$ ItemID��$	��120��$��0,0,10,0q����� *Items+ �� SelectedItem �� *SelectedItem+�� $��Filter by User ID:��#��[  $��0,0,5,0q��� $	��120��$��0,0,10,0q����� *Users+ �� *SelectedUser+�� $��Apply Filters��  ModernButton#��[ $��5q����� *ApplyFiltersCommand+�� $��Reset Filters��#��[ $��5q����� *ResetFiltersCommand+&   System.Windows.Controls.DataGrid  $��2��   AutoGenerateColumns$ False��   CanUserAddRows$ False��   
IsReadOnly$
 True������ *FilteredTransactions+   Columns 0  *System.Windows.Controls.DataGridTextColumn  ,  &System.Windows.Controls.DataGridColumn	   Header$	 Transaction ID��
   Width5  /System.Windows.Controls.DataGridLengthConverter$	
 100 1  +System.Windows.Controls.DataGridBoundColumn   Binding �� *TransactionID+  $	 Item ID��$
 80  �� *ItemID+  $	 User ID��$
 80  �� *UserID+  $
	 Type��$	
 100  �� *TransactionType+  $	 Quantity��$
 80  �� *
Quantity+  $
	 Date��$	
 100  �� *TransactionDate+ �� StringFormat$ 
yyyy-MM-dd��  $	 Description��$
 *  �� *Description+