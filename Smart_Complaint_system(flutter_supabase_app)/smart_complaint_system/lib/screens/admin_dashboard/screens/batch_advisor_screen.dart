import 'package:flutter/material.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../widgets/batch_advisor_management/batch_advisor_widget.dart';

class BatchAdvisorScreen extends StatelessWidget {
  final AdminDashboardController controller;
  final ThemeData theme;

  const BatchAdvisorScreen({
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
                  'Batch Advisor Management',
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
            BatchAdvisorWidget(controller: controller),
          ],
        ),
      ),
    );
  }
}
