   M S B A M L   `   `   `  ����T  PInventoryManagementSystem, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null[2clr-namespace:InventoryManagementSystem.ViewModels$InventoryManagementSystem.ViewModels  5      8    2InventoryManagementSystem.Views.StaffInventoryView   5      W SPresentationCore, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35e aSystem.Windows.Controls.Ribbon, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089R NWindowsBase, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35F 9http://schemas.microsoft.com/winfx/2006/xaml/presentation     5      R NSystem.Xaml, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5      Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5      @d2http://schemas.microsoft.com/expression/blend/2008     5      I
viewmodels2clr-namespace:InventoryManagementSystem.ViewModels     5      .��5
      �    WindowBackgroundBrush#��[  6   .+�5   
   � $��20q�6     � RowDefinitions  5      �� 5      $
��Auto �6    �� 5      $��* �6    �� 5      $
��Auto �6    .+�5      �� $��0��6     FloatingPanelStyle#��[ 6"   $	��100��6N   $��0,0,0,20q�6[   ._�5      �� $��🧬 Staff Inventory View��6   $��24(�5      $
��Bold"�5      ���#00FFF0$��Orbitron)�5      $��Center=�5      $��Center=�5      5      �� 5      $��1��6   #��[ 6"   $��0,0,0,20q�6N    �� Padding$ 20q�6`   ._�5      &   System.Windows.Controls.DataGrid     AutoGenerateColumns$ False��5          
IsReadOnly$
 True��5!      ���	#33000000���#00FFF0���#00FFF0$��1q�5%         GridLinesVisibility$
 None=�5&      ��5      �� *InventoryItems+ �� FallbackValue Z�  � 	Resources 5'      =  7System.Windows.Controls.Primitives.DataGridColumnHeader �� 
TargetType �� Property	 �� Value*  $System.Windows.Controls.DataGridCell��%_  '        '  ?    �� 5(      "  6    .�5)      ��  � ��	 �	#660000006;   �� 5*       � ��	 �#00FFF06;   �� 5+       � ��$	 Orbitron)�6;   �� 5,       � ��$	 16(�69   �� 5-       � ��$	 10q�68   �� 5.       � ��	 �#00FFF06<   �� 5/       � ��$	 0,0,1,1q�6@   50      �� 51      "  6    .�52      ��  � ��
	 ���� 6;   �� 53       � ��	 �#00FFF06;   �� 54       � ��$	 Orbitron)�6;   �� 55       � ��$	 14(�69   �� 56       � ��
	 ���� 6<   �� 57       � ��$	 10q�68   58      59      
   RowStyle
 5:      �� 5;      )  #System.Windows.Controls.DataGridRow"  6     �� BasedOn# [B 69   .�5<      ��  � ��	 �	#660000006;    �� Triggers 5=      �� 5?   "    �� Binding 6.   �� *
IsLowStock+ �� Value True6M   .a�5@   &   ��  � ��	 �#FF55556C   �� 5A   &    � ��	 �#0000006C   5B   #   P� 5D   "    P� Property �@J�IsMouseOver P� Value$
 True��6A   . �5E   &   ��  � ��	 �#66CCFF6C   �� 5F   &    � ��	 �#0000006C   5G   #   5I         Columns 5K      0  *System.Windows.Controls.DataGridTextColumn  5L      ,  &System.Windows.Controls.DataGridColumn   Header$ Item ID��6-      Width5  /System.Windows.Controls.DataGridLengthConverter$
 0.1* 6Y      
IsReadOnly$
 True��6f   1  +System.Windows.Controls.DataGridBoundColumn   Binding 6>   �� *ItemID+6f     5M      $ 	Item Name��6-   $
 0.2* 6]   $
 True��6j    6@   �� *
ItemName+6j     5N      $ Category��6-   $ 0.15* 6\   $
 True��6j    6?   �� *
Category+6j     5O      $ Quantity��6-   $
 0.1* 6\   $
 True��6i    6?   �� *
Quantity+6i     5P      $ 
Unit Price��6-   $
 0.1* 6o   $
 True��6|    6A   �� *	UnitPrice+ �� StringFormat$ C��6|     5Q      $ Supplier ID��6-   $ 0.15* 6a   $
 True��6o    6B   �� *
SupplierID+6o     5R      $ Last Updated��6-   $
 0.2* 6�   $
 True��6�    6C   �� *LastUpdated+$ yyyy-MM-dd HH:mm:ss��6�   5T      5U      �� 5X      $��2��6    �� Orientation$ 
Horizontal=�6&   $��Right=�6?   $��0,0,10,0q�6[   .+�5Y      �� $
��Back��6     ModernButton#��[ 5Z      $��5q�5\      ��5[      �� *BackCommand+5\      5]      5^      5_      5`      