   M S B A M L   `   `   `  ����  InventoryManagementSystem8    2InventoryManagementSystem.Views.UserManagementView   5      W SPresentationCore, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35e aSystem.Windows.Controls.Ribbon, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089R NWindowsBase, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35F 9http://schemas.microsoft.com/winfx/2006/xaml/presentation     5      R NSystem.Xaml, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5      Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5      @d2http://schemas.microsoft.com/expression/blend/2008     5      .��5      �    WindowBackgroundBrush#��[  6   .+�5	   
   � $��20q�6     � RowDefinitions  5
      �� 5      $
��Auto �6    �� 5      $
��Auto �6    �� 5      $��* �6    .+�5      �� $��0��6     FloatingPanelStyle#��[ 6"   $	��100��6N   $��0,0,0,20q�6[   ._�5      �� $��🧬 User Management��6   $��24(�5      $
��Bold"�5      ���#00FFF0$��Orbitron)�5      $��Center=�5      $��Center=�5      5      �� 5      $��1��6    �� Orientation$ 
Horizontal=�6&   $��Right=�6?   $��0,0,0,20q�6[   .+�5      �� $��Add User��6     ModernButton#��[ 5      $	��100��5       $��5q�5!      ��5      �� *AddUserCommand+5!      �� 5"      $��	Edit User��6   #��[ 5#      $	��100��5%      $��5q�5&      ��5$      �� *EditUserCommand+5&      �� 5'      $��Delete User��6   #��[ 5(      $	��100��5*      $��5q�5+      ��5)      �� *DeleteUserCommand+5+      �� 5,      $��Reset Password��6   #��[ 5-      $	��100��5/      $��5q�50      ��5.      �� *ResetPasswordCommand+50      51      �� 54      $��2��6   #��[ 6"   $��0,0,0,20q�6N    �� Padding$ 20q�6`   ._�55      &   System.Windows.Controls.DataGrid     AutoGenerateColumns$ False��57         CanUserAddRows$ False��58      ���	#33000000���#00FFF0���#00FFF0$��1q�5<         GridLinesVisibility$
 None=�5=      ��55      �� *Users+ �� FallbackValue Z�  �� SelectedItem 56      �� *SelectedUser+ �� Mode$ TwoWay=�	 �� UpdateSourceTrigger$	 PropertyChanged=� Z� 
 � 	Resources
 5>      =  7System.Windows.Controls.Primitives.DataGridColumnHeader �� 
TargetType �� Property �� Value*  $System.Windows.Controls.DataGridCell��%_  '        '  ?    �� 5?      "  6    .�5@      ��  � �� �	#660000006;   �� 5A       � �� �#00FFF06;   �� 5B       � ��$ Orbitron)�6;   �� 5C       � ��$ 16(�69   �� 5D       � ��$ 10q�68   �� 5E       � �� �#00FFF06<   �� 5F       � ��$ 0,0,1,1q�6@   5G      �� 5H      "  6    .�5I      ��  � ��
 ���� 6;   �� 5J       � �� �#00FFF06;   �� 5K       � ��$ Orbitron)�6;   �� 5L       � ��$ 14(�69   �� 5M       � ��
 ���� 6<   �� 5N       � ��$ 10q�68   5O      5P         RowStyle 5Q      �� 5R      )  #System.Windows.Controls.DataGridRow"  6     �� BasedOn# [B 69   .�5S      ��  � �� �	#660000006;    �� Triggers 5T      P� 5V   "    P� Property �@J�IsMouseOver P� Value$
 True��6A   . �5W   &   ��  � �� �#66CCFF6C   �� 5X   &    � �� �#0000006C   5Y   #   P� 5[   "    �@ 
IsSelected$
 True��6@   . �5\   &   ��  � ��
 �   �6C   �� 5]   &    � �� �#0000006C   5^   #   5`         Columns 5b      0  *System.Windows.Controls.DataGridTextColumn  5c      ,  &System.Windows.Controls.DataGridColumn   Header$ User ID��6-      
IsReadOnly$
 True��6Y      Width5  /System.Windows.Controls.DataGridLengthConverter$
 0.1* 6k   1  +System.Windows.Controls.DataGridBoundColumn   Binding 6>   �� *UserID+6k     5d      $ Username��6-   $
 0.2* 6\    6?   �� *
Username+6\     5e      $ Email��6-   $
 0.2* 6V    6<   �� *Email+6V     5f      $ 	Full Name��6-   $
 0.2* 6]    6@   �� *
FullName+6]     5g      $
 Role��6-   $ 0.15* 6T    6;   �� *Role+6T     5h      $ 
Created At��6-   $ 0.15* 6�    6A   �� *	CreatedAt+ �� StringFormat$ yyyy-MM-dd HH:mm:ss��6�     5i      $ 
Last Login��6-   $ 0.15* 6�    6A   �� *	LastLogin+$ yyyy-MM-dd HH:mm:ss��  NullToVisibilityConverter �� 	Converter# [ 6�   5k      5l      5m      5n      5o      