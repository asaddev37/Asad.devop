   M S B A M L   `   `   `  ����   InventoryManagementSystem2    ,InventoryManagementSystem.Views.SettingsView   W SPresentationCore, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35e aSystem.Windows.Controls.Ribbon, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089R NWindowsBase, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35F 9http://schemas.microsoft.com/winfx/2006/xaml/presentation     R NSystem.Xaml, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     @d2http://schemas.microsoft.com/expression/blend/2008     .��� $��10q�  � RowDefinitions  �� $
��Auto ��� $
��Auto ��� $
��Auto ��� $
��Auto ��� $
��Auto ��� $
��Auto � � ColumnDefinitions �� $	��120 ��� $��* �.+��� $��0��$��2��$��System Settings��   ModernLabel#��[  $��18(�$
��Bold"�$��0,0,0,10q��� $��1��$��0��$��Low Stock Threshold:��#��[  $��0,0,5,5q��� $��1��$��1��  ModernTextBox#��[ $��0,0,0,5q����� *LowStockThreshold+ �� UpdateSourceTrigger$ PropertyChanged=��� $��2��$��0��$��Session Timeout (min):��#��[  $��0,0,5,5q��� $��2��$��1��#��[ $��0,0,0,5q����� *SessionTimeout+$ PropertyChanged=��� $��3��$��0��$��Backup/Restore:��#��[  $��0,0,5,5q��� $��3��$��1��#��[ $��0,0,0,5q� �� 
IsReadOnly$
 True������ *
BackupPath+$ PropertyChanged=��� $��4��$��2��#��[  $��0,0,0,5q����� *StatusMessage+�� $��5��$��2�� �� Orientation$ 
Horizontal=�$��Right=�$��0,10,0,0q�.+��� $��Save Settings��  ModernButton#��[ $��5q����� *SaveSettingsCommand+�� $��Backup Database��#��[ $��5q����� *BackupDatabaseCommand+�� $��Restore Database��#��[ $��5q����� *RestoreDatabaseCommand+