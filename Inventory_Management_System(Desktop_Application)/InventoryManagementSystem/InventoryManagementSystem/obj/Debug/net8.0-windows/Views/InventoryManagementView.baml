   M S B A M L   `   `   `  ����  InventoryManagementSystem=    7InventoryManagementSystem.Views.InventoryManagementView   5      W SPresentationCore, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35e aSystem.Windows.Controls.Ribbon, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089R NWindowsBase, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35F 9http://schemas.microsoft.com/winfx/2006/xaml/presentation     5      R NSystem.Xaml, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5      Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5      @d2http://schemas.microsoft.com/expression/blend/2008     5      -   5        .��5	      �    WindowBackgroundBrush#��[  6   .+�5
   
   � $��20q�6     � RowDefinitions  5      �� 5      $
��Auto �6    �� 5      $��* �6    �� 5      $
��Auto �6    .+�5      �� $��0��6     FloatingPanelStyle#��[ 6"   $	��100��6N   $��0,0,0,20q�6[   ._�5      �� $��🧬 Inventory Management��6   $��24(�5      $
��Bold"�5      ���#00FFF0$��Orbitron)�5      $��Center=�5      $��Center=�5      5      &   System.Windows.Controls.DataGrid  5      $��1��6      AutoGenerateColumns$ False��5          CanUserAddRows$ False��5!      $��0,0,0,20q�5"      ���	#33000000���#00FFF0���#00FFF0$��1q�5&         GridLinesVisibility$
 None=�5'      ��5      �� *Items+ �� FallbackValue Z�  �� SelectedItem 5      �� *SelectedItem+ �� Mode$ TwoWay=� �� UpdateSourceTrigger$ PropertyChanged=� Z�  � 	Resources 5(      =  7System.Windows.Controls.Primitives.DataGridColumnHeader	 �� 
TargetType
 �� Property �� Value*  $System.Windows.Controls.DataGridCell��%_  '        '  ?    �� 5)      "	  6   .�5*      �� 
 � �� �	#6600000067   �� 5+      
 � �� �#00FFF067   �� 5,      
 � ��$ Orbitron)�67   �� 5-      
 � ��$ 16(�65   �� 5.      
 � ��$ 10q�64   �� 5/      
 � �� �#00FFF068   �� 50      
 � ��$ 0,0,1,1q�6<   51      �� 52      "	  6   .�53      �� 
 � ��
 ���� 67   �� 54      
 � �� �#00FFF067   �� 55      
 � ��$ Orbitron)�67   �� 56      
 � ��$ 14(�65   �� 57      
 � ��
 ���� 68   �� 58      
 � ��$ 10q�64   59      5:         RowStyle 5;      �� 5<      )  #System.Windows.Controls.DataGridRow"	  6    �� BasedOn# [B 65   .�5=      �� 
 � �� �	#6600000067    �� Triggers 5>      P� 5@       P� Property �@J�IsMouseOver P� Value$
 True��6=   . �5A   "   �� 
 � �� �#66CCFF6?   �� 5B   "   
 � �� �#0000006?   5C      P� 5E       �@ 
IsSelected$
 True��6<   . �5F   "   �� 
 � ��
 �   �6?   �� 5G   "   
 � �� �#0000006?   5H      5J         Columns 5L      0  *System.Windows.Controls.DataGridTextColumn  5M      ,  &System.Windows.Controls.DataGridColumn   Header$ Item ID��6)      
IsReadOnly$
 True��6U      Width5  /System.Windows.Controls.DataGridLengthConverter$
 0.1* 6g   1  +System.Windows.Controls.DataGridBoundColumn   Binding 6:   �� *ItemID+6g     5N      $
 Name��6)   $
 0.2* 6T    67   �� *
ItemName+6T     5O      $ Category��6)   $ 0.15* 6X    6;   �� *
Category+6X     5P      $ Quantity��6)   $
 0.1* 6X    6;   �� *
Quantity+6X     5Q      $ 
Unit Price��6)   $ 0.15* 6k    6=   �� *	UnitPrice+ �� StringFormat$ C��6k     5R      $ Supplier ID��6)   $ 0.15* 6]    6>   �� *
SupplierID+6]     5S      $ Last Updated��6)   $ 0.15* 6x    6?   �� *LastUpdated+$ 
yyyy-MM-dd��6x   5U      �� 5X      $��2��6    �� Orientation$ 
Horizontal=�6&   $��Right=�6?   $��0,0,10,0q�6[   .+�5Y      �� $��Add Item��6     ModernButton#��[ 6,   $��5q�6u   ��6R   �� *AddItemCommand+6u   �� 5Z      $��	Edit Item��6   #��[ 6-   $��5q�6�   ��6S   �� *EditItemCommand+{�6w   �� *SelectedItem+  NullToVisibilityConverter �� 	Converter# [  �� ConverterParameter$ Inverse��6�   �� 5[      $��Delete Item��6   #��[ 6/   $��5q�6�   ��6U   �� *DeleteItemCommand+{�6{   �� *SelectedItem+# [ $ Inverse��6�   �� 5\      $��View Low Stock��6   #��[ 62   $��5q�6�   ��6X   �� *ViewLowStockCommand+6�   5]      5^      5_      5`      