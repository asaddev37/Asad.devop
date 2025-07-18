import 'package:flutter/material.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../widgets/complaint_management/complaint_management_widget.dart';

class ComplaintManagementScreen extends StatelessWidget {
  final AdminDashboardController controller;
  final ThemeData theme;

  const ComplaintManagementScreen({
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
                  'Complaint Management',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
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
            ComplaintManagementWidget(controller: controller),
          ],
        ),
      ),
    );
  }
}
