import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/main.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: isDarkMode ? themeProvider.darkPrimaryColor : themeProvider.lightPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [themeProvider.darkPrimaryColor, themeProvider.darkSecondaryColor]
                : [themeProvider.lightPrimaryColor.withOpacity(0.2), themeProvider.lightSecondaryColor.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customize Your Experience',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Choose your favorite colors to make the app look awesome! 🌟',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _showColorPickerDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDarkMode
                                  ? [Colors.purple.shade600, Colors.blue.shade600]
                                  : [Colors.blue.shade400, Colors.cyan.shade400],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: const Text(
                            'Choose Color Scheme',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return ColorPickerDialog(
          lightPrimary: themeProvider.lightPrimaryColor,
          lightSecondary: themeProvider.lightSecondaryColor,
          darkPrimary: themeProvider.darkPrimaryColor,
          darkSecondary: themeProvider.darkSecondaryColor,
          showColorPicker: _showColorPicker,
          onApply: (lightPrimary, lightSecondary, darkPrimary, darkSecondary) {
            themeProvider.setCustomColors(
              lightPrimary: lightPrimary,
              lightSecondary: lightSecondary,
              darkPrimary: darkPrimary,
              darkSecondary: darkSecondary,
            );
          },
        );
      },
    );
  }

  Future<Color?> _showColorPicker(BuildContext context, Color initialColor) async {
    Color? selectedColor = initialColor;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a Color'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Colors.red,
                    Colors.pink,
                    Colors.purple,
                    Colors.deepPurple,
                    Colors.indigo,
                    Colors.blue,
                    Colors.cyan,
                    Colors.teal,
                    Colors.green,
                    Colors.lime,
                    Colors.yellow,
                    Colors.amber,
                    Colors.orange,
                    Colors.deepOrange,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {
                        selectedColor = color;
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color ? Colors.black : Colors.grey,
                            width: selectedColor == color ? 3 : 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
    return selectedColor;
  }
}

class ColorPickerDialog extends StatefulWidget {
  final Color lightPrimary;
  final Color lightSecondary;
  final Color darkPrimary;
  final Color darkSecondary;
  final Future<Color?> Function(BuildContext, Color) showColorPicker;
  final Function(Color, Color, Color, Color) onApply;

  const ColorPickerDialog({
    super.key,
    required this.lightPrimary,
    required this.lightSecondary,
    required this.darkPrimary,
    required this.darkSecondary,
    required this.showColorPicker,
    required this.onApply,
  });

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _lightPrimary;
  late Color _lightSecondary;
  late Color _darkPrimary;
  late Color _darkSecondary;

  @override
  void initState() {
    super.initState();
    _lightPrimary = widget.lightPrimary;
    _lightSecondary = widget.lightSecondary;
    _darkPrimary = widget.darkPrimary;
    _darkSecondary = widget.darkSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Color Scheme'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Light Mode Colors'),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Primary Color'),
              trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _lightPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              onTap: () async {
                final color = await widget.showColorPicker(context, _lightPrimary);
                if (color != null) {
                  setState(() {
                    _lightPrimary = color;
                  });
                }
              },
            ),
            ListTile(
              title: const Text('Secondary Color'),
              trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _lightSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              onTap: () async {
                final color = await widget.showColorPicker(context, _lightSecondary);
                if (color != null) {
                  setState(() {
                    _lightSecondary = color;
                  });
                }
              },
            ),
            const Divider(),
            const Text('Dark Mode Colors'),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Primary Color'),
              trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _darkPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              onTap: () async {
                final color = await widget.showColorPicker(context, _darkPrimary);
                if (color != null) {
                  setState(() {
                    _darkPrimary = color;
                  });
                }
              },
            ),
            ListTile(
              title: const Text('Secondary Color'),
              trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _darkSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              onTap: () async {
                final color = await widget.showColorPicker(context, _darkSecondary);
                if (color != null) {
                  setState(() {
                    _darkSecondary = color;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onApply(
              _lightPrimary,
              _lightSecondary,
              _darkPrimary,
              _darkSecondary,
            );
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}