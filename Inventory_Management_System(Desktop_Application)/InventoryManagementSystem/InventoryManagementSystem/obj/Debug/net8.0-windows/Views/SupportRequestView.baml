   M S B A M L   `   `   `  ����  InventoryManagementSystem8    2InventoryManagementSystem.Views.SupportRequestView   5      W SPresentationCore, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35e aSystem.Windows.Controls.Ribbon, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089R NWindowsBase, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35F 9http://schemas.microsoft.com/winfx/2006/xaml/presentation     5      R NSystem.Xaml, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5      Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5      @d2http://schemas.microsoft.com/expression/blend/2008     5      .��5      �    WindowBackgroundBrush#��[  6   .+�5	   
   � $��20q�6     � RowDefinitions  5
      �� 5      $
��Auto �6    �� 5      $��* �6    �� 5      $
��Auto �6    .+�5      �� $��0��6     FloatingPanelStyle#��[ 6"   $	��100��6N   $��0,0,0,20q�6[   ._�5      �� $��🧬 Request Support��6   $��24(�5      $
��Bold"�5      ���#00FFF0$��Orbitron)�5      $��Center=�5      $��Center=�5      5      �� 5      $��1��6   #��[ 6"   $��0,0,0,20q�6N    �� Padding$ 20q�6`   ._�5      �� $
��Auto=�6   .��5      �   5      �� 5       $
��Auto �6,   �� 5!      $
��Auto �6,    � ColumnDefinitions 5#      �� 5$      $	��200 �6/   �� 5%      $��* �6/   .+�5)      �� $��0��6    $��0��6-   $��	Priority:��5*       ���#00FFF0$��Orbitron)�5,       $��14(�5-       $��	0,0,10,10q�5.       $��Center=�5/       �� 50      $��0��6#   $��1��60   $��0,0,0,10q�53   #   
���   ����	#66000000���#00FFF0$��Orbitron)�57   #   $��14(�58   #   $��5q�59   #   ��51   #   �� *
Priorities+ �� SelectedItem 52   #   �� *
Priority+ � 	Resources 5:       �� 
TargetType �� Property �� Value �� Triggers	 P� Property
 P� Value��%  '��       �� 5;   "   " ��6(   .�5<   &   ��  � �� �#00FFF06C   �� 5=   &    � �� �	#660000006C   �� 5>   &    � ��$ Orbitron)�6C   �� 5?   &    � ��$ 5q�6@    5@   &   P� 5A   *   	 �@J�IsMouseOver$

 True��6I   . �5B   .   ��  � �� �#66CCFF6K   �� 5C   .    � �� �#0000006K   5D   +   P� 5E   *   	 �@��
IsSelected$

 True��6H   . �5F   .   ��  � �� �#33FF996K   �� 5G   .    � �� �#0000006K   5H   +   5J   #   5K      5L      �� 5O      $��1��6    $��0��6-   $��Description:��5P       ���#00FFF0$��Orbitron)�5R       $��14(�5S       $��	0,0,10,10q�5T       $��Center=�5U       �� 5V      $��1��6"   $��1��6/     ModernTextBox#��[ 5X   "   ���#00FFF0���	#66000000���#00FFF0$��Orbitron)�5\   "   $��14(�5]   "   $��5q�5^   "   $��0,0,0,10q�5_   "    �� AcceptsReturn$
 True��5`   "   $	��100��5a   "   ��5W   "   �� *Description+ �� UpdateSourceTrigger$ PropertyChanged=�5a   "   5b      5c      5d      �� 5g      $��2��6    �� Orientation$ 
Horizontal=�6&   $��Right=�6?   $��0,0,10,0q�6[   .+�5h      �� $��Submit��6     ModernButton#��[ 5i      $��5q�5k      ��5j      �� *SubmitRequestCommand+5k      �� 5l      $��Cancel��6   #��[ 5m      $��5q�5o      ��5n      �� *CancelCommand+5o      5p      5q      5r      5s      