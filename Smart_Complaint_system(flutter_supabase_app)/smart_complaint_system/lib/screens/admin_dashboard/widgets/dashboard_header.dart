import 'package:flutter/material.dart';
import '../controllers/admin_dashboard_controller.dart';
import 'common/statistics_card.dart';

class DashboardHeader extends StatelessWidget {
  final String adminName;
  final String? adminImageUrl;
  final AdminDashboardController controller;
  final VoidCallback onRefresh;

  const DashboardHeader({
    super.key,
    required this.adminName,
    this.adminImageUrl,
    required this.controller,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Row(
            children: [
              AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final adminProfile = controller.adminProfile;
                  final avatarUrl = adminProfile?['avatar_url'] as String?;
                  final adminName = adminProfile?['name'] as String? ?? 'Admin';

                  return CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).primaryColor,
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? Text(
                            adminName.isNotEmpty
                                ? adminName[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        : null,
                  );
                },
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) {
                        final adminName =
                            controller.adminProfile?['name'] ?? 'Administrator';
                        return Text(
                          'Welcome, $adminName!',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your Smart Complaint System',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: controller,
                          builder: (context, child) {
                            final department =
                                controller.state.currentDepartment;
                            final departmentName = department?['name'] ?? 'CS';

                            // Debug: Print department data
                            print(
                                'DashboardHeader - Department data: $department');
                            print(
                                'DashboardHeader - Department name: $departmentName');

                            return Text(
                              'of $departmentName Department',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                    fontSize: 10,
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: controller.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 20),
                onPressed: controller.isLoading ? null : onRefresh,
                tooltip: 'Refresh Data',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Statistics Cards
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth > 600
                      ? (constraints.maxWidth - 24) / 4
                      : (constraints.maxWidth - 8) / 2;

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: StatisticsCard(
                          title: 'Total Users',
                          value: controller.totalUsers.toString(),
                          icon: Icons.people,
                          color: Colors.blue,
                          isLoading: controller.isLoading,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatisticsCard(
                          title: 'Total Complaints',
                          value: controller.totalComplaints.toString(),
                          icon: Icons.report_problem,
                          color: Colors.orange,
                          isLoading: controller.isLoading,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatisticsCard(
                          title: 'Resolved',
                          value: controller.resolvedComplaints.toString(),
                          icon: Icons.check_circle,
                          color: Colors.green,
                          isLoading: controller.isLoading,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatisticsCard(
                          title: 'Resolution Rate',
                          value:
                              '${controller.resolutionRate.toStringAsFixed(1)}%',
                          icon: Icons.trending_up,
                          color: Colors.purple,
                          isLoading: controller.isLoading,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          // Error Message
          if (controller.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color:
                        Theme.of(context).colorScheme.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Theme.of(context).colorScheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.errorMessage!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: Theme.of(context).colorScheme.error, size: 16),
                    onPressed: () {
                      // Assuming clearError exists in controller
                      controller.clearError();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
