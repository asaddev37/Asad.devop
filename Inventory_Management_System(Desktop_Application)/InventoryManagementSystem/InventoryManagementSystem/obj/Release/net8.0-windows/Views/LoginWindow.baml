   M S B A M L   `   `   `  ����   InventoryManagementSystem1    +InventoryManagementSystem.Views.LoginWindow   W SPresentationCore, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35e aSystem.Windows.Controls.Ribbon, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089R NWindowsBase, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35F 9http://schemas.microsoft.com/winfx/2006/xaml/presentation     R NSystem.Xaml, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     _ [Microsoft.Xaml.Behaviors, Version=1.1.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a3i+http://schemas.microsoft.com/xaml/behaviors    � Title$  Login��$	��400��$	��600�� � WindowStartupLocation$ CenterScreen=�   WindowBackground#��[  .��� $��20q� � RowDefinitions �� $
��Auto ��� $��* �.+��� $!��Inventory Management System��$��24(�$
��Bold"�
�������$��Center=�$��0,0,0,20q�� $��1�� �� $
��Auto ��� $
��Auto ��� $
��Auto ��� $
��Auto ��� $
��Auto � � ColumnDefinitions �� $
��Auto ��� $��* �.+��� $��	Username:��$��0��$��0��  ModernLabel#��[ �� -    ��Name$ UsernameTextBox��$��0��$��1��  ModernTextBox#��[ ���� *
Username+ �� UpdateSourceTrigger$ PropertyChanged=��� $��	Password:��$��1��$��0��#��[ G� -    G�Name$ PasswordBox��$��1��$��1��  ModernPasswordBox#��[ �� $��Login��$��2��$��0��$��2��  ModernButton#��[ $��Center=�$��	0,20,0,10q�*  $Microsoft.Xaml.Behaviors.Interaction   Triggers +  %Microsoft.Xaml.Behaviors.EventTrigger     	EventName$ Click��*  $Microsoft.Xaml.Behaviors.TriggerBase	   Actions.	 2  ,Microsoft.Xaml.Behaviors.InvokeCommandAction  
   Command
 �� *LoginCommand+   CommandParameter ��  �� ElementName$ PasswordBox���� -   $��Signup��$��3��$��0��$��2��#��[ $��Center=��� -    ��Name$ ErrorMessage��$��4��$��0��$��2��
���  �� �� TextAlignment$ Center=�$
��0,10q�$y�	Collapsed=�