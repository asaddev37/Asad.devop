import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_complaint_system/config/admin_theme.dart';
import 'controllers/admin_dashboard_controller.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/navigation_menu.dart';
import 'widgets/progress_tracking/dashboard_overview.dart';
import 'screens/student_management_screen.dart';
import 'screens/hod_management_screen.dart';
import 'screens/complaint_management_screen.dart';
import 'screens/batch_advisor_screen.dart';
import 'screens/department_batches_screen.dart';
import 'screens/admin_profile_screen.dart';
import 'screens/batch_view_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late AdminDashboardController _controller;
  int _selectedIndex = 0;
  bool _isNavigationExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _controller = AdminDashboardController();
    _controller.loadData();
    _loadThemePreference();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void _onNavigationChanged(int index) {
    setState(() {
      _selectedIndex = index;
      if (MediaQuery.of(context).size.width < 1200) {
        _scaffoldKey.currentState?.closeDrawer();
      }
    });

    // Handle logout
    if (index == 6) {
      _handleLogout();
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    _saveThemePreference();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content:
            const Text('Are you sure you want to logout from the admin panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _controller.logout();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error during logout: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  void _toggleNavigation() {
    setState(() {
      _isNavigationExpanded = !_isNavigationExpanded;
    });
  }

  Widget _buildBody() {
    final currentTheme =
        _isDarkMode ? AdminTheme.darkTheme : AdminTheme.lightTheme;
    switch (_selectedIndex) {
      case 0:
        return DashboardOverview(
          controller: _controller,
          theme: currentTheme,
          onNavigationChanged: _onNavigationChanged,
        );
      case 1:
        return StudentManagementScreen(
            controller: _controller, theme: currentTheme);
      case 2:
        return BatchAdvisorScreen(controller: _controller, theme: currentTheme);
      case 3:
        return HodManagementScreen(
            controller: _controller, theme: currentTheme);
      case 4:
        return ComplaintManagementScreen(
            controller: _controller, theme: currentTheme);
      case 5:
        return DepartmentBatchesScreen(
            controller: _controller, theme: currentTheme);
      // case 6 is logout
      case 7:
        return AdminProfileScreen(
          controller: _controller,
          theme: currentTheme,
        );
      case 8:
        return BatchViewScreen(controller: _controller, theme: currentTheme);
      default:
        return DashboardOverview(
          controller: _controller,
          theme: currentTheme,
          onNavigationChanged: _onNavigationChanged,
        );
    }
  }

  AdminDashboardController get controller => _controller;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;
    final currentTheme =
        _isDarkMode ? AdminTheme.darkTheme : AdminTheme.lightTheme;

    return Theme(
      data: currentTheme,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: currentTheme.colorScheme.background,
        appBar: AppBar(
          backgroundColor: currentTheme.colorScheme.surface,
          elevation: 0,
          title: Text(
            'Admin Dashboard',
            style: TextStyle(
              color: currentTheme.colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: IconThemeData(color: currentTheme.colorScheme.onSurface),
          leading: isSmallScreen
              ? IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                )
              : IconButton(
                  icon: Icon(
                    _isNavigationExpanded ? Icons.menu_open : Icons.menu,
                  ),
                  onPressed: _toggleNavigation,
                ),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
              tooltip: 'Toggle Theme',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
              tooltip: 'Logout',
            ),
          ],
        ),
        drawer: isSmallScreen
            ? Drawer(
                backgroundColor: currentTheme.colorScheme.surface,
                child: NavigationMenu(
                  selectedIndex: _selectedIndex,
                  onNavigationChanged: _onNavigationChanged,
                  controller: _controller,
                  theme: currentTheme,
                ),
              )
            : null,
        body: SafeArea(
          child: Row(
            children: [
              if (!isSmallScreen && _isNavigationExpanded)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 240,
                  child: NavigationMenu(
                    selectedIndex: _selectedIndex,
                    onNavigationChanged: _onNavigationChanged,
                    controller: _controller,
                    theme: currentTheme,
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DashboardHeader(
                        adminName:
                            _controller.adminProfile?['full_name'] ?? 'Admin',
                        adminImageUrl: _controller.adminProfile?['avatar_url'],
                        controller: _controller,
                        onRefresh: _controller.loadData,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Builder(
                          builder: (context) {
                            return _buildBody();
                          },
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
}
