import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:targets_cgpa/screens/database_service.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;

  const SettingsPage({super.key, required this.isDarkMode});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _storage = FlutterSecureStorage();
  bool _isHistoryEnabled = true;
  OverlayEntry? _overlayEntry;

  // Attractive error colors
  static const Color _lightModeErrorBg = Colors.black45;
  static const Color _lightModeErrorText = Colors.white;
  static const Color _darkModeErrorBg = Colors.white30;
  static const Color _darkModeErrorText = Colors.black;

  @override
  void initState() {
    super.initState();
    _loadHistoryPreference();
  }

  Future<void> _loadHistoryPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHistoryEnabled = prefs.getBool('isHistoryEnabled') ?? true;
    });
  }

  Future<void> _saveHistoryPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isHistoryEnabled', value);
    setState(() {
      _isHistoryEnabled = value;
    });
  }

  void _showFieldOverlay({
    required String message,
    required GlobalKey fieldKey,
    Duration duration = const Duration(seconds: 2),
  }) {
    _overlayEntry?.remove();
    final RenderBox? renderBox = fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy - 40, // Position above the field
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? _darkModeErrorBg : _lightModeErrorBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: widget.isDarkMode ? _darkModeErrorText : _lightModeErrorText,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(duration, () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPassword = await _storage.read(key: 'history_password');
    if (currentPassword == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No PIN set. Please set a PIN in Secure History first.'),
          backgroundColor: widget.isDarkMode ? Colors.red : Colors.red,
          duration: Duration(seconds: 2),
          action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
        ),
      );
      return;
    }

    final currentPinControllers = List.generate(4, (_) => TextEditingController());
    final newPinControllers = List.generate(4, (_) => TextEditingController());
    final confirmPinControllers = List.generate(4, (_) => TextEditingController());

    final GlobalKey currentPinKey = GlobalKey();
    final GlobalKey newPinKey = GlobalKey();
    final GlobalKey confirmPinKey = GlobalKey();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Change PIN",
            style: TextStyle(color: widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade900),
          ),
          backgroundColor: widget.isDarkMode ? Colors.grey.shade800 : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter Current PIN',
                  style: TextStyle(color: widget.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700),
                ),
                SizedBox(height: 10),
                Row(
                  key: currentPinKey,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: currentPinControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        obscureText: true,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '_',
                          hintStyle: TextStyle(
                              color: widget.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade700),
                          ),
                          filled: true,
                          fillColor: widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
                        ),
                        style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            FocusScope.of(context).nextFocus();
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20),
                Text(
                  'Enter New PIN',
                  style: TextStyle(color: widget.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700),
                ),
                SizedBox(height: 10),
                Row(
                  key: newPinKey,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: newPinControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        obscureText: true,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '_',
                          hintStyle: TextStyle(
                              color: widget.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade700),
                          ),
                          filled: true,
                          fillColor: widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
                        ),
                        style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            FocusScope.of(context).nextFocus();
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20),
                Text(
                  'Confirm New PIN',
                  style: TextStyle(color: widget.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700),
                ),
                SizedBox(height: 10),
                Row(
                  key: confirmPinKey,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: confirmPinControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        obscureText: true,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '_',
                          hintStyle: TextStyle(
                              color: widget.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade700),
                          ),
                          filled: true,
                          fillColor: widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
                        ),
                        style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            FocusScope.of(context).nextFocus();
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade700),
              ),
            ),
            TextButton(
              onPressed: () async {
                final currentPin = currentPinControllers.map((c) => c.text).join();
                final newPin = newPinControllers.map((c) => c.text).join();
                final confirmPin = confirmPinControllers.map((c) => c.text).join();

                // Check if any field is empty
                if (currentPin.isEmpty) {
                  _showFieldOverlay(
                    message: 'Please fill all fields',
                    fieldKey: currentPinKey,
                  );
                  return;
                }
                if (newPin.isEmpty) {
                  _showFieldOverlay(
                    message: 'Please fill all fields',
                    fieldKey: newPinKey,
                  );
                  return;
                }
                if (confirmPin.isEmpty) {
                  _showFieldOverlay(
                    message: 'Please fill all fields',
                    fieldKey: confirmPinKey,
                  );
                  return;
                }

                // Existing length and validation checks
                if (currentPin.length != 4) {
                  _showFieldOverlay(
                    message: 'Must be 4 digits',
                    fieldKey: currentPinKey,
                  );
                  return;
                }
                if (currentPin != currentPassword) {
                  _showFieldOverlay(
                    message: 'Incorrect PIN',
                    fieldKey: currentPinKey,
                  );
                  return;
                }

                if (newPin.length != 4) {
                  _showFieldOverlay(
                    message: 'Must be 4 digits',
                    fieldKey: newPinKey,
                  );
                  return;
                }

                if (confirmPin.length != 4) {
                  _showFieldOverlay(
                    message: 'Must be 4 digits',
                    fieldKey: confirmPinKey,
                  );
                  return;
                }
                if (newPin != confirmPin) {
                  _showFieldOverlay(
                    message: 'Does not match new PIN',
                    fieldKey: confirmPinKey,
                  );
                  return;
                }

                await _storage.write(key: 'history_password', value: newPin);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('PIN updated successfully'),
                    backgroundColor: widget.isDarkMode ? Colors.green.shade700 : Colors.green,
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
                  ),
                );
              },
              child: Text(
                "Save",
                style: TextStyle(color: widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade700),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRemovePasswordDialog() async {
    final currentPassword = await _storage.read(key: 'history_password');
    if (currentPassword == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No PIN currently exists to remove'),
          backgroundColor: widget.isDarkMode ? Colors.red : Colors.red,
          duration: Duration(seconds: 2),
          action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
        ),
      );
      return;
    }

    final pinControllers = List.generate(4, (_) => TextEditingController());
    final GlobalKey pinKey = GlobalKey();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Remove PIN",
            style: TextStyle(color: widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade900),
          ),
          backgroundColor: widget.isDarkMode ? Colors.grey.shade800 : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter your current PIN to remove it",
                style: TextStyle(color: widget.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800),
              ),
              SizedBox(height: 10),
              Row(
                key: pinKey,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextField(
                      controller: pinControllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      obscureText: true,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '_',
                        hintStyle: TextStyle(
                            color: widget.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade700),
                        ),
                        filled: true,
                        fillColor: widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
                      ),
                      style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          FocusScope.of(context).nextFocus();
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade700),
              ),
            ),
            TextButton(
              onPressed: () async {
                final enteredPin = pinControllers.map((c) => c.text).join();

                if (enteredPin.isEmpty) {
                  _showFieldOverlay(
                    message: 'Please fill all fields',
                    fieldKey: pinKey,
                  );
                  return;
                }

                if (enteredPin.length != 4) {
                  _showFieldOverlay(
                    message: 'Must be 4 digits',
                    fieldKey: pinKey,
                  );
                  return;
                }

                if (enteredPin != currentPassword) {
                  _showFieldOverlay(
                    message: 'Incorrect PIN',
                    fieldKey: pinKey,
                  );
                  return;
                }

                await _storage.delete(key: 'history_password');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('PIN removed successfully'),
                    backgroundColor: widget.isDarkMode ? Colors.green.shade700 : Colors.green,
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
                  ),
                );
              },
              child: Text(
                "Remove",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Confirm Clear History",
          style: TextStyle(color: widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade900),
        ),
        content: Text(
          "Are you sure you want to clear all history? This action cannot be undone.",
          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.grey.shade800),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: TextStyle(color: widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Clear",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
        backgroundColor: widget.isDarkMode ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    if (confirmed == true) {
      final db = await DatabaseService.database;
      await db.delete('individual_semester_history');
      await db.delete('target_cgpa_history');
      await db.delete('current_target_cgpa_history');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('History cleared successfully'),
          backgroundColor: widget.isDarkMode ? Colors.green.shade700 : Colors.green,
          duration: Duration(seconds: 2),
          action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.blue.shade800;
    final backgroundGradient = widget.isDarkMode
        ? LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.grey.shade900, Colors.grey.shade800],
    )
        : LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.grey.shade100, Colors.grey.shade200],
    );
    final cardColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.blue.shade900;
    final dividerColor = widget.isDarkMode ? Colors.grey.shade600 : Colors.blue.shade200;
    final switchActiveColor = widget.isDarkMode ? Colors.amberAccent : Colors.amber.shade600;
    final switchInactiveColor = widget.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: appBarColor,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.maxFinite,
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Align(
          alignment: Alignment.topCenter, // Keeps the card centered
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Ensures the card takes only necessary height
                  children: [
                    _buildSettingTile(
                      title: "Enable History Saving",
                      trailing: Switch(
                        value: _isHistoryEnabled,
                        onChanged: _saveHistoryPreference,
                        activeColor: switchActiveColor,
                        inactiveThumbColor: switchInactiveColor,
                      ),
                      textColor: textColor,
                    ),
                    Divider(color: dividerColor, thickness: 1),
                    _buildSettingTile(
                      title: "Change PIN",
                      onTap: _showChangePasswordDialog,
                      textColor: textColor,
                    ),
                    Divider(color: dividerColor, thickness: 1),
                    _buildSettingTile(
                      title: "Remove PIN",
                      onTap: _showRemovePasswordDialog,
                      textColor: Colors.redAccent,
                    ),
                    Divider(color: dividerColor, thickness: 1),
                    _buildSettingTile(
                      title: "Clear History",
                      onTap: _clearHistory,
                      textColor: Colors.redAccent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

    );
  }

  Widget _buildSettingTile({
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? (widget.isDarkMode ? Colors.white : Colors.blue.shade900),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }
}