   M S B A M L   `   `   `  ����   InventoryManagementSystem8    2InventoryManagementSystem.Views.UserManagementView   W SPresentationCore, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35e aSystem.Windows.Controls.Ribbon, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089R NWindowsBase, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35F 9http://schemas.microsoft.com/winfx/2006/xaml/presentation     R NSystem.Xaml, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     @d2http://schemas.microsoft.com/expression/blend/2008     .��� $��10q�  � RowDefinitions  �� $
��Auto ��� $
��Auto ��� $��* �.+��� $��0��$��User Management��   ModernLabel#��[  $��20(�$
��Bold"�$��Center=�$��0,0,0,10q��� $��1�� �� Orientation$ 
Horizontal=�$��0,0,0,10q�.+��� $��Add User��  ModernButton#��[ $	��100��$��5q����� *AddUserCommand+�� $��	Edit User��#��[ $	��100��$��5q����� *EditUserCommand+�� $��Delete User��#��[ $	��100��$��5q����� *DeleteUserCommand+�� $��Reset Password��#��[ $	��100��$��5q����� *ResetPasswordCommand+&   System.Windows.Controls.DataGrid  $��2��   AutoGenerateColumns$ False��   CanUserAddRows$ False������ *Users+ �� SelectedItem �� *SelectedUser+   Columns 0  *System.Windows.Controls.DataGridTextColumn  ,  &System.Windows.Controls.DataGridColumn   Header$ User ID��   
IsReadOnly$
 True��1  +System.Windows.Controls.DataGridBoundColumn   Binding �� *UserID+  $ Username�� �� *
Username+  $ Email�� �� *Email+  $ 	Full Name�� �� *
FullName+  $
 Role�� �� *Role+  $ 
Created At�� �� *	CreatedAt+	 �� StringFormat$	 yyyy-MM-dd HH:mm:ss��  $ 
Last Login�� �� *	LastLogin+$	 yyyy-MM-dd HH:mm:ss��  NullToVisibilityConverter
 �� 	Converter#
 [ 