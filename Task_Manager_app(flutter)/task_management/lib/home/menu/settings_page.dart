import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final Color lightModeColor;
  final Color darkModeColor;
  final bool notificationsEnabled;
  final Function(bool, Color, Color, bool) onSettingsChanged;

  const SettingsPage({
    Key? key,
    required this.isDarkMode,
    required this.lightModeColor,
    required this.darkModeColor,
    required this.notificationsEnabled,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _tempDarkMode;
  late Color _tempLightModeColor;
  late Color _tempDarkModeColor;
  late bool _tempNotificationsEnabled;
  List<Color> _customLightColors = [];
  List<Color> _customDarkColors = [];

  @override
  void initState() {
    super.initState();
    _tempDarkMode = widget.isDarkMode;
    _tempLightModeColor = widget.lightModeColor;
    _tempDarkModeColor = widget.darkModeColor;
    _tempNotificationsEnabled = widget.notificationsEnabled;
    _loadCustomColors();
  }

  void _loadCustomColors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _customLightColors = (prefs.getStringList('customLightColors') ?? [])
          .map((color) => Color(int.parse(color)))
          .toList();
      _customDarkColors = (prefs.getStringList('customDarkColors') ?? [])
          .map((color) => Color(int.parse(color)))
          .toList();
    });
  }

  void _saveSettings({bool navigateBack = true}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      widget.onSettingsChanged(
        _tempDarkMode,
        _tempLightModeColor,
        _tempDarkModeColor,
        _tempNotificationsEnabled,
      );

      await prefs.setBool('isDarkMode', _tempDarkMode);
      await prefs.setInt('lightModeColor', _tempLightModeColor.value);
      await prefs.setInt('darkModeColor', _tempDarkModeColor.value);
      await prefs.setBool('notificationsEnabled', _tempNotificationsEnabled);
      await prefs.setStringList(
          'customLightColors', _customLightColors.map((c) => c.value.toString()).toList());
      await prefs.setStringList(
          'customDarkColors', _customDarkColors.map((c) => c.value.toString()).toList());
      if (navigateBack && mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e')),
        );
      }
    }
  }

  void _clearSettings() {
    setState(() {
      _tempDarkMode = widget.isDarkMode;
      _tempLightModeColor = widget.lightModeColor;
      _tempDarkModeColor = widget.darkModeColor;
      _tempNotificationsEnabled = widget.notificationsEnabled;
      _customLightColors.clear();
      _customDarkColors.clear();
    });
    _saveSettings(navigateBack: false);
  }

  Widget _colorOption(Color color, Color selectedColor, Function(Color) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: color == selectedColor
                ? (widget.isDarkMode ? Colors.white : Colors.black87)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPickerDialog(bool isLightMode, StateSetter setState) {
    Color pickerColor = isLightMode ? _tempLightModeColor : _tempDarkModeColor;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick a ${isLightMode ? 'Light' : 'Dark'} Mode Color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                setState(() {
                  if (isLightMode) {
                    if (!_customLightColors.contains(pickerColor)) {
                      _customLightColors.add(pickerColor);
                    }
                    _tempLightModeColor = pickerColor;
                  } else {
                    if (!_customDarkColors.contains(pickerColor)) {
                      _customDarkColors.add(pickerColor);
                    }
                    _tempDarkModeColor = pickerColor;
                  }
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: widget.isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Choose Color Scheme',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      value: _tempDarkMode,
                      onChanged: (value) {
                        setState(() {
                          _tempDarkMode = value;
                        });
                      },
                      activeColor: _tempDarkModeColor,
                      inactiveThumbColor: Colors.grey[400],
                      activeTrackColor: _tempDarkModeColor.withAlpha(153),
                      inactiveTrackColor: Colors.grey[600],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Light Mode Color',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: widget.isDarkMode ? Colors.white70 : Colors.black87),
                          onPressed: () => _showColorPickerDialog(true, setState),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: [
                        ...[
                          Colors.pink,
                          Colors.blueAccent,
                          Colors.purpleAccent,
                          Colors.orangeAccent,
                          Colors.grey.shade50,
                        ].map((color) => _colorOption(color, _tempLightModeColor, (color) {
                          setState(() {
                            _tempLightModeColor = color;
                          });
                        })),
                        ..._customLightColors.map((color) => _colorOption(color, _tempLightModeColor, (color) {
                          setState(() {
                            _tempLightModeColor = color;
                          });
                        })),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dark Mode Color',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: widget.isDarkMode ? Colors.white70 : Colors.black87),
                          onPressed: () => _showColorPickerDialog(false, setState),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: [
                        ...[
                          Colors.deepOrange,
                          Colors.blueGrey,
                          Color(0xFF1A0B36),
                          Colors.grey.shade800,
                        ].map((color) => _colorOption(color, _tempDarkModeColor, (color) {
                          setState(() {
                            _tempDarkModeColor = color;
                          });
                        })),
                        ..._customDarkColors.map((color) => _colorOption(color, _tempDarkModeColor, (color) {
                          setState(() {
                            _tempDarkModeColor = color;
                          });
                        })),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearSettings();
                Navigator.pop(context);
              },
              child: Text(
                'Clear',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _saveSettings(navigateBack: false);
                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.amber : Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.isDarkMode
        ? [widget.darkModeColor, Colors.grey[800]!.withAlpha(78)]
        : [widget.lightModeColor, Colors.white.withAlpha(178)];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: widget.isDarkMode
                        ? [widget.darkModeColor.withAlpha(204), Colors.grey[850]!]
                        : [widget.lightModeColor.withAlpha(204), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.palette,
                        color: widget.isDarkMode ? Colors.white70 : Colors.grey.shade800,
                        size: 28,
                      ),
                      title: Text(
                        'Choose Color Scheme',
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                        size: 20,
                      ),
                      onTap: _showSettingsDialog,
                    ),
                    Divider(color: widget.isDarkMode ? Colors.white24 : Colors.black12),
                    ListTile(
                      leading: Icon(
                        Icons.notifications,
                        color: widget.isDarkMode ? Colors.white70 : Colors.grey.shade800,
                        size: 28,
                      ),
                      title: Text(
                        'Notifications',
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      trailing: Switch(
                        value: _tempNotificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _tempNotificationsEnabled = value;
                            _saveSettings(navigateBack: false);
                          });
                        },
                        activeColor: widget.darkModeColor,
                        inactiveThumbColor: Colors.grey[400],
                        activeTrackColor: widget.darkModeColor.withAlpha(153),
                        inactiveTrackColor: Colors.grey[600],
                      ),

                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}