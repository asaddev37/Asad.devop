import 'dart:convert';
import 'package:flutter/material.dart';
import 'home/menu/privacy_policy.dart';
import 'home/today_tasks.dart';
import 'home/completed_tasks.dart';
import 'home/repeated_tasks.dart';
import 'home/menu/settings_page.dart';
import 'home/menu/categories_task.dart';
import 'home/menu/about_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database_helper.dart';
import 'repeated_tasks/detail_repeated_task.dart';

class HomePage extends StatefulWidget {
  final String? initialNotificationPayload;

  const HomePage({Key? key, this.initialNotificationPayload}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;
  Color _lightModeColor = Colors.blueAccent;
  Color _darkModeColor = Colors.blueGrey;
  bool _notificationsEnabled = true;
  final GlobalKey<TodayTasksPageState> _todayTasksKey = GlobalKey<TodayTasksPageState>();
  final GlobalKey<RepeatedTasksPageState> _repeatedTasksKey = GlobalKey<RepeatedTasksPageState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _notificationPayload;

  List<Widget> get _pages => [
    TodayTasksPage(
      key: _todayTasksKey,
      isDarkMode: _isDarkMode,
      lightModeColor: _lightModeColor,
      darkModeColor: _darkModeColor,
      notificationsEnabled: _notificationsEnabled,
      initialNotificationPayload: _notificationPayload,
    ),
    CompletedTasksPage(
      isDarkMode: _isDarkMode,
      lightModeColor: _lightModeColor,
      darkModeColor: _darkModeColor,
    ),
    RepeatedTasksPage(
      key: _repeatedTasksKey,
      isDarkMode: _isDarkMode,
      lightModeColor: _lightModeColor,
      darkModeColor: _darkModeColor,
      notificationsEnabled: _notificationsEnabled,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _notificationPayload = widget.initialNotificationPayload;
    _handleInitialNotification();
  }

  Future<void> _handleInitialNotification() async {
    if (widget.initialNotificationPayload != null) {
      try {
        final payload = jsonDecode(widget.initialNotificationPayload!);
        if (payload.containsKey('id') && payload.containsKey('date')) {
          final taskId = payload['id'] as int;
          final instanceDate = DateTime.parse(payload['date']);
          final task = await DatabaseHelper.instance.getTaskById(taskId);
          if (task != null && mounted) {
            setState(() {
              _selectedIndex = 2;
              _notificationPayload = null;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailRepeatedTasksPage(
                  task: {
                    ...task,
                    'taskId': task['id'],
                    'dueDate': instanceDate.toIso8601String(),
                  },
                  isDarkMode: _isDarkMode,
                  lightModeColor: _lightModeColor,
                  darkModeColor: _darkModeColor,
                  onEdit: (task, {bool fromDetail = false}) {},
                  onDelete: (id, {bool fromDetail = false}) {},
                  onComplete: (id, {bool fromDetail = false}) {},
                  onUndo: (id, {bool fromDetail = false}) {},
                  isTodayView: true,
                  instanceDate: instanceDate,
                  isCompletedInstance: false,
                ),
              ),
            );
          }
        } else {
          final taskId = int.tryParse(widget.initialNotificationPayload!);
          if (taskId != null) {
            setState(() {
              _selectedIndex = 0;
              _notificationPayload = widget.initialNotificationPayload;
            });
          }
        }
      } catch (e) {
        final taskId = int.tryParse(widget.initialNotificationPayload!);
        if (taskId != null) {
          setState(() {
            _selectedIndex = 0;
            _notificationPayload = widget.initialNotificationPayload;
          });
        }
      }
    }
  }

  void _loadSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _isDarkMode = prefs.getBool('isDarkMode') ?? false;
          _lightModeColor = Color(prefs.getInt('lightModeColor') ?? Colors.blueAccent.value);
          _darkModeColor = Color(prefs.getInt('darkModeColor') ?? Colors.blueGrey.value);
          _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load settings: $e',
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.grey[300],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _saveSettings({
    required bool isDarkMode,
    required Color lightModeColor,
    required Color darkModeColor,
    required bool notificationsEnabled,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _isDarkMode = isDarkMode;
        _lightModeColor = lightModeColor;
        _darkModeColor = darkModeColor;
        _notificationsEnabled = notificationsEnabled;
      });
      await prefs.setBool('isDarkMode', isDarkMode);
      await prefs.setInt('lightModeColor', lightModeColor.value);
      await prefs.setInt('darkModeColor', darkModeColor.value);
      await prefs.setBool('notificationsEnabled', notificationsEnabled);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save settings: $e',
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.grey[300],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 0) {
        _notificationPayload = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _isDarkMode
        ? [_darkModeColor, Colors.grey[800]!.withAlpha(78)]
        : [_lightModeColor, Colors.white.withAlpha(178)];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: _isDarkMode ? _darkModeColor : _lightModeColor,
        elevation: 4,
        title: Text(
          'Task Manager',
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            _isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: _isDarkMode ? Colors.white70 : Colors.black87,
            size: 24,
          ),
          onPressed: () async {
            await _saveSettings(
              isDarkMode: !_isDarkMode,
              lightModeColor: _lightModeColor,
              darkModeColor: _darkModeColor,
              notificationsEnabled: _notificationsEnabled,
            );
          },
          tooltip: 'Toggle Theme',
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: _isDarkMode ? Colors.white70 : Colors.black87,
              size: 24,
            ),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            tooltip: 'Menu',
          ),
        ],
      ),
      endDrawer: Drawer(
        width: 280,
        backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _isDarkMode ? _darkModeColor.withAlpha(204) : _lightModeColor.withAlpha(204),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 50,
                      color: _isDarkMode ? Colors.white : Colors.black,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Task Manager',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your productivity companion',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        'About',
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white70 : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(
                        Icons.info,
                        color: Colors.teal[300],
                        size: 28,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 400),
                            pageBuilder: (context, animation, secondaryAnimation) => AboutPage(
                              isDarkMode: _isDarkMode,
                              lightModeColor: _lightModeColor,
                              darkModeColor: _darkModeColor,
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(position: offsetAnimation, child: child);
                            },
                          ),
                        );
                      },
                      hoverColor: _isDarkMode ? Colors.grey[800]!.withAlpha(51) : Colors.grey[200]!.withAlpha(51),
                    ),
                    Divider(
                      color: _isDarkMode ? Colors.white24 : Colors.black12,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white70 : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(
                        Icons.privacy_tip,
                        color: Colors.red[300],
                        size: 28,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 400),
                            pageBuilder: (context, animation, secondaryAnimation) => PrivacyPolicyPage(
                              isDarkMode: _isDarkMode,
                              lightModeColor: _lightModeColor,
                              darkModeColor: _darkModeColor,

                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(position: offsetAnimation, child: child);
                            },
                          ),
                        );
                      },
                      hoverColor: _isDarkMode ? Colors.grey[800]!.withAlpha(51) : Colors.grey[200]!.withAlpha(51),
                    ),
                    Divider(
                      color: _isDarkMode ? Colors.white24 : Colors.black12,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                  ],
                ),
              ),

              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        'Settings',
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white70 : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(
                        Icons.settings,
                        color: Colors.amber[300],
                        size: 28,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 400),
                            pageBuilder: (context, animation, secondaryAnimation) => SettingsPage(
                              isDarkMode: _isDarkMode,
                              lightModeColor: _lightModeColor,
                              darkModeColor: _darkModeColor,
                              notificationsEnabled: _notificationsEnabled,
                              onSettingsChanged:
                                  (isDarkMode, lightModeColor, darkModeColor, notificationsEnabled) {
                                _saveSettings(
                                  isDarkMode: isDarkMode,
                                  lightModeColor: lightModeColor,
                                  darkModeColor: darkModeColor,
                                  notificationsEnabled: notificationsEnabled,
                                );
                              },
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(position: offsetAnimation, child: child);
                            },
                          ),
                        );
                      },
                      hoverColor: _isDarkMode ? Colors.grey[800]!.withAlpha(51) : Colors.grey[200]!.withAlpha(51),
                    ),
                    Divider(
                      color: _isDarkMode ? Colors.white24 : Colors.black12,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        'Categories',
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white70 : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(
                        Icons.category,
                        color: Colors.purple[300],
                        size: 28,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 400),
                            pageBuilder: (context, animation, secondaryAnimation) => CategoriesTaskPage(
                              isDarkMode: _isDarkMode,
                              lightModeColor: _lightModeColor,
                              darkModeColor: _darkModeColor,
                              onCategoriesChanged: () {
                                _todayTasksKey.currentState?.refresh();
                                _repeatedTasksKey.currentState?.refresh();
                              },
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(position: offsetAnimation, child: child);
                            },
                          ),
                        );
                      },
                      hoverColor: _isDarkMode ? Colors.grey[800]!.withAlpha(51) : Colors.grey[200]!.withAlpha(51),
                    ),
                    Divider(
                      color: _isDarkMode ? Colors.white24 : Colors.black12,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Card(
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
        child: Container(
          decoration: BoxDecoration(
            color: _isDarkMode ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.teal[300],
            unselectedItemColor: Colors.amber[300],
            selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 14),
            items: [
              // BottomNavigationBarItem(
              //   icon: Image.asset(
              //     'images/non_repeated.png',
              //     width: 24,
              //     height: 24,
              //     color: _selectedIndex == 0 ? Colors.teal[300] : Colors.amber[300],
              //   ),
              //   label: 'Non-Repeated',
              // ),

              BottomNavigationBarItem(
                icon: Icon(
                  Icons.event_repeat_outlined,
                  size: 24,
                  color: _selectedIndex == 0 ? Colors.teal[300] : Colors.amber[300],
                ),
                label: 'Non-Repeated',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.check_circle,
                  size: 24,
                  color: _selectedIndex == 1 ? Colors.teal[300] : Colors.amber[300],
                ),
                label: 'Completed',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.repeat,
                  size: 24,
                  color: _selectedIndex == 2 ? Colors.teal[300] : Colors.amber[300],
                ),
                label: 'Repeated',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}