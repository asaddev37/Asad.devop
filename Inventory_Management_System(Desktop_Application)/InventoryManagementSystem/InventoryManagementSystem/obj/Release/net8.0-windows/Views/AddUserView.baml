   M S B A M L   `   `   `  ����   InventoryManagementSystem1    +InventoryManagementSystem.Views.AddUserView   W SPresentationCore, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35e aSystem.Windows.Controls.Ribbon, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089R NWindowsBase, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35F 9http://schemas.microsoft.com/winfx/2006/xaml/presentation     R NSystem.Xaml, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     _ [Microsoft.Xaml.Behaviors, Version=1.1.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a3i+http://schemas.microsoft.com/xaml/behaviors  Dmc;http://schemas.openxmlformats.org/markup-compatibility/2006  :d2http://schemas.microsoft.com/expression/blend/2008  .��� $��20q����	#FF333333  � RowDefinitions  �� $
��Auto ��� $��* ��� $
��Auto �.+��� $��0��$��20(�$
��Bold"�
�������$��Center=�$��0,0,0,20q����� *Title+�� $��1��$��0,0,0,10q�.+��� 
��� ���$��0,0,0,5q����� *
IsEditMode+ �� StringFormat$ IsEditMode: {0}���� $��Username��
�������$��0,0,0,5q���    ModernTextBox#��[  ���� *
Username+ �� UpdateSourceTrigger$ PropertyChanged=�.�� � 	Resources  �� 
TargetType �� Property �� Value �� 
TargetType ��Name	 ��Name
 J� IsHitTestVisible �� Triggers ]� 
Conditions �� Property �� Value �� 
TargetName��%H  '��       �� " ��.���  � �� �� " ��.R��� #��z��#��z��#��z��._�� .+��� $ PART_ContentHost���� $	 PlaceholderText��$��Enter username...��
�������$
 False��$y�	Collapsed=� ]�  ��  � ��$  ����  �@J�	IsFocused$ False��./��� $ PlaceholderText�� � y�$ Visible=�.���� $��Password��
�������$��0,10,0,5q�y��� *ShowPasswordField+   BooleanToVisibilityConverter �� 	Converter# [ G� -    G�Name$ passwordBox��  ModernPasswordBox#��[ y��� *ShowPasswordField+# [ *  $Microsoft.Xaml.Behaviors.Interaction   Triggers +  %Microsoft.Xaml.Behaviors.EventTrigger     	EventName$ PasswordChanged��*  $Microsoft.Xaml.Behaviors.TriggerBase   Actions. 2  ,Microsoft.Xaml.Behaviors.InvokeCommandAction     Command �� *PasswordChangedCommand+   CommandParameter ��  �� ElementName$ passwordBox���� $��Email��
�������$��0,10,0,5q��� #��[  ���� *Email+$ PropertyChanged=�.�� ��%E  '��       �� " ��.���  � �� �� " ��.R��� #��z��#��z��#��z��._�� .+��� $ PART_ContentHost���� $	 PlaceholderText��$��Enter email...��
�������$
 False��$y�	Collapsed=� ]�  ��  � ��$  ����  �@J�	IsFocused$ False��./��� $ PlaceholderText�� � y�$ Visible=�.���� $��	Full Name��
�������$��0,10,0,5q��� #��[  ���� *
FullName+$ PropertyChanged=�.�� ��%I  '��       �� " ��.���  � �� �� " ��.R��� #��z��#��z��#��z��._�� .+��� $ PART_ContentHost���� $	 PlaceholderText��$��Enter full name...��
�������$
 False��$y�	Collapsed=� ]�  ��  � ��$  ����  �@J�	IsFocused$ False��./��� $ PlaceholderText�� � y�$ Visible=�.���� $
��Role��
�������$��0,10,0,5q���   ModernComboBox#��[  �� SelectedItem �� *Role+.@��� $��Admin���� $��Manager���� $��Staff���� 
���  ��
������� �� Padding$ 5q�$��	10,15,0,0q� �� TextAlignment$ Center=�$
��Wrap=�$��40������ *ErrorMessage+�� $��2�� �� Orientation$ 
Horizontal=�$��Center=�$��0,20,0,0q�.+��� $
��Save��  ModernButton#��[ $	��100��$��5q����� *SaveCommand+{��� *IsSaveEnabled+�� $��Cancel��#��[ $	��100��$��5q����� *CancelCommand+