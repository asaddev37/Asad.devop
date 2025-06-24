import 'package:flutter/material.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../widgets/hod_management/hod_management_widget.dart';

class HodManagementScreen extends StatelessWidget {
  final AdminDashboardController controller;
  final ThemeData theme;

  const HodManagementScreen({
    super.key,
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'HOD Management',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    controller.loadData();
                  },
                  tooltip: 'Refresh Data',
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Content
            HodManagementWidget(controller: controller),
          ],
        ),
      ),
    );
  }
}
