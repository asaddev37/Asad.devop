import 'package:flutter/material.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../screens/admin_profile_screen.dart';
import '../screens/hod_management_screen.dart';
import '../screens/batch_advisor_screen.dart';
import '../screens/student_management_screen.dart';
import '../screens/complaint_management_screen.dart';
import '../screens/batch_view_screen.dart';
import '../screens/department_batches_screen.dart';

// Custom slide transition page route
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final SlideDirection direction;

  SlidePageRoute({
    required this.child,
    this.direction = SlideDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            switch (direction) {
              case SlideDirection.right:
                begin = const Offset(1.0, 0.0);
                break;
              case SlideDirection.left:
                begin = const Offset(-1.0, 0.0);
                break;
              case SlideDirection.up:
                begin = const Offset(0.0, 1.0);
                break;
              case SlideDirection.down:
                begin = const Offset(0.0, -1.0);
                break;
            }

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

enum SlideDirection { left, right, up, down }

class NavigationMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onNavigationChanged;
  final AdminDashboardController controller;
  final ThemeData theme;

  const NavigationMenu({
    super.key,
    required this.selectedIndex,
    required this.onNavigationChanged,
    required this.controller,
    required this.theme,
  });

  void _navigateWithSlideTransition(BuildContext context, Widget screen) {
    // Add a small delay for better visual feedback
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.push(
        context,
        SlidePageRoute(
          child: screen,
          direction: SlideDirection.right,
        ),
      );
    });
  }

  void _navigateToScreen(BuildContext context, int index) {
    switch (index) {
      case 0: // Dashboard
      case 1: // Students
        _navigateWithSlideTransition(context,
            StudentManagementScreen(controller: controller, theme: theme));
        break;
      case 2: // Batch Advisors
        _navigateWithSlideTransition(
            context, BatchAdvisorScreen(controller: controller, theme: theme));
        break;
      case 3: // HODs
        _navigateWithSlideTransition(
            context, HodManagementScreen(controller: controller, theme: theme));
        break;
      case 4: // Complaints
        _navigateWithSlideTransition(context,
            ComplaintManagementScreen(controller: controller, theme: theme));
        break;
      case 5: // Department & Batches
        _navigateWithSlideTransition(context,
            DepartmentBatchesScreen(controller: controller, theme: theme));
        break;
      case 6: // Logout
        onNavigationChanged(index);
        break;
      case 7: // My Profile
        _navigateWithSlideTransition(
            context, AdminProfileScreen(controller: controller, theme: theme));
        break;
      case 8: // Batch View
        _navigateWithSlideTransition(
            context, BatchViewScreen(controller: controller, theme: theme));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = controller.adminProfile;
    final adminName = admin?['name'] ?? 'Admin';
    final adminEmail = admin?['email'] ?? 'admin@example.com';
    final adminAvatarUrl = admin?['avatar_url'];

    return Container(
      color: theme.colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(theme, adminName, adminEmail, adminAvatarUrl),
          const SizedBox(height: 16),
          _buildListTile(
            theme: theme,
            icon: Icons.dashboard_customize_outlined,
            title: 'Dashboard',
            index: 0,
            isSelected: selectedIndex == 0,
            onTap: () => onNavigationChanged(0),
          ),
          _buildListTile(
            theme: theme,
            icon: Icons.person_pin,
            title: 'Profile',
            index: 7,
            isSelected: selectedIndex == 7,
            onTap: () => onNavigationChanged(7),
          ),
          _buildListTile(
            theme: theme,
            icon: Icons.business_center_outlined,
            title: 'Department & Batches',
            index: 5,
            isSelected: selectedIndex == 5,
            onTap: () => onNavigationChanged(5),
          ),
          _buildListTile(
            theme: theme,
            icon: Icons.school_outlined,
            title: 'HODs',
            index: 3,
            isSelected: selectedIndex == 3,
            onTap: () => onNavigationChanged(3),
          ),
          _buildListTile(
            theme: theme,
            icon: Icons.supervised_user_circle_outlined,
            title: 'Batch Advisors',
            index: 2,
            isSelected: selectedIndex == 2,
            onTap: () => onNavigationChanged(2),
          ),

          _buildListTile(
            theme: theme,
            icon: Icons.people_alt_outlined,
            title: 'Students',
            index: 1,
            isSelected: selectedIndex == 1,
            onTap: () => onNavigationChanged(1),
          ),

          _buildListTile(
            theme: theme,
            icon: Icons.visibility_outlined,
            title: 'View Batches',
            index: 8,
            isSelected: selectedIndex == 8,
            onTap: () => onNavigationChanged(8),
          ),
          _buildListTile(
            theme: theme,
            icon: Icons.report_problem_outlined,
            title: 'Complaints',
            index: 4,
            isSelected: selectedIndex == 4,
            onTap: () => onNavigationChanged(4),
          ),
          const Divider(height: 32, thickness: 0.5),
          _buildListTile(
            theme: theme,
            icon: Icons.logout,
            title: 'Logout',
            index: 6,
            isSelected: selectedIndex == 6,
            onTap: () => onNavigationChanged(6),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String adminName, String adminEmail,
      String? adminAvatarUrl) {
    return UserAccountsDrawerHeader(
      accountName: Text(
        adminName,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      accountEmail: Text(
        adminEmail,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: theme.colorScheme.surface,
        backgroundImage:
            adminAvatarUrl != null ? NetworkImage(adminAvatarUrl) : null,
        child: adminAvatarUrl == null
            ? Text(
                adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              )
            : null,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface,
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border(
                    left:
                        BorderSide(color: theme.colorScheme.primary, width: 4))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyLarge?.color,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
