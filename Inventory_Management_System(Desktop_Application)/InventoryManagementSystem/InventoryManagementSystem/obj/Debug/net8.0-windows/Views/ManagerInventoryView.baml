   M S B A M L   `   `   `  ����  InventoryManagementSystem:    4InventoryManagementSystem.Views.ManagerInventoryView   5      W SPresentationCore, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35e aSystem.Windows.Controls.Ribbon, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089R NWindowsBase, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35F 9http://schemas.microsoft.com/winfx/2006/xaml/presentation     5      R NSystem.Xaml, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5      Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5      @d2http://schemas.microsoft.com/expression/blend/2008     5      .��5      �    WindowBackgroundBrush#��[  6   .+�5	   
   � $��20q�6     � RowDefinitions  5
      �� 5      $
��Auto �6    �� 5      $��* �6    �� 5      $
��Auto �6    .+�5      �� $��0��6     FloatingPanelStyle#��[ 6"   $	��100��6N   $��0,0,0,20q�6[   ._�5      �� $'��!🧬 Manager Inventory Management��6   $��24(�5      $
��Bold"�5      ���#00FFF0$��Orbitron)�5      $��Center=�5      $��Center=�5      5      �� 5      $��1��6   #��[ 6"   $��0,0,0,20q�6N    �� Padding$ 20q�6`   ._�5      &   System.Windows.Controls.DataGrid     AutoGenerateColumns$ False��5         CanUserAddRows$ False��5       ���	#33000000���#00FFF0���#00FFF0$��1q�5$         GridLinesVisibility$
 None=�5%      ��5      �� *Items+ �� FallbackValue Z�  �� SelectedItem 5      �� *SelectedItem+ �� Mode$ TwoWay=� �� UpdateSourceTrigger$ PropertyChanged=� Z� 	 � 	Resources	 5&      =  7System.Windows.Controls.Primitives.DataGridColumnHeader
 �� 
TargetType �� Property �� Value*  $System.Windows.Controls.DataGridCell��%_  '        '  ?    �� 5'      "
  6    .�5(      ��  � �� �	#660000006;   �� 5)       � �� �#00FFF06;   �� 5*       � ��$ Orbitron)�6;   �� 5+       � ��$ 16(�69   �� 5,       � ��$ 10q�68   �� 5-       � �� �#00FFF06<   �� 5.       � ��$ 0,0,1,1q�6@   5/      �� 50      "
  6    .�51      ��  � ��
 ���� 6;   �� 52       � �� �#00FFF06;   �� 53       � ��$ Orbitron)�6;   �� 54       � ��$ 14(�69   �� 55       � ��
 ���� 6<   �� 56       � ��$ 10q�68   57      58         RowStyle 59      �� 5:      )  #System.Windows.Controls.DataGridRow"
  6     �� BasedOn# [B 69   .�5;      ��  � �� �	#660000006;    �� Triggers 5<      �� 5>   "    �� Binding 6.   �� *
IsLowStock+ �� Value True6M   .a�5?   &   ��  � �� �#FF55556C   �� 5@   &    � �� �#0000006C   5A   #   P� 5C   "    P� Property �@J�IsMouseOver P� Value$
 True��6A   . �5D   &   ��  � �� �#66CCFF6C   �� 5E   &    � �� �#0000006C   5F   #   P� 5H   "    �@ 
IsSelected$
 True��6@   . �5I   &   ��  � ��
 �   �6C   �� 5J   &    � �� �#0000006C   5K   #   5M         Columns 5O      0  *System.Windows.Controls.DataGridTextColumn  5P      ,  &System.Windows.Controls.DataGridColumn   Header$ Item ID��6-      Width5  /System.Windows.Controls.DataGridLengthConverter$
 0.1* 6Y   1  +System.Windows.Controls.DataGridBoundColumn   Binding 6>   �� *ItemID+6Y     5Q      $ 	Item Name��6-   $
 0.3* 6]    6@   �� *
ItemName+6]     5R      $ Category��6-   $
 0.2* 6\    6?   �� *
Category+6\     5S      $ Quantity��6-   $
 0.1* 6\    6?   �� *
Quantity+6\     5T      $ 
Unit Price��6-   $ 0.15* 6o    6A   �� *	UnitPrice+ �� StringFormat$ C��6o     5U      $ Supplier ID��6-   $ 0.15* 6a    6B   �� *
SupplierID+6a   5W      5X      �� 5[      $��2��6    �� Orientation$ 
Horizontal=�6&   $��Right=�6?   $��0,0,10,0q�6[   .+�5\      �� $��	Edit Item��6     ModernButton#��[ 6-   $��5q�6w   ��6S   �� *EditItemCommand+6w   �� 5]      $��View Low Stock��6   #��[ 62   $��5q�6�   ��6X   �� *ViewLowStockCommand+6�   5^      5_      5`      5a      