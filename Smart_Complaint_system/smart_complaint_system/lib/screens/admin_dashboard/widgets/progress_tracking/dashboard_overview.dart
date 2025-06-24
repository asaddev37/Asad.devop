import 'package:flutter/material.dart';
import '../../controllers/admin_dashboard_controller.dart';
import '../../screens/student_management_screen.dart';
import '../../screens/batch_advisor_screen.dart';
import '../../screens/complaint_management_screen.dart';
import '../../../../services/csv_service.dart';
import '../../../../services/pdf_service.dart';

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

class DashboardOverview extends StatelessWidget {
  final AdminDashboardController controller;
  final ThemeData theme;
  final Function(int) onNavigationChanged;

  const DashboardOverview({
    super.key,
    required this.controller,
    required this.theme,
    required this.onNavigationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Overview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final totalComplaints = controller.totalComplaints;
              final resolvedComplaints = controller.resolvedComplaints;
              final pendingComplaints = controller.pendingComplaints;
              final rejectedComplaints = controller.complaints
                  .where((c) => c['status'] == 'Rejected')
                  .length;
              final escalatedComplaints = controller.complaints
                  .where((c) => c['status'] == 'Escalated')
                  .length;
              final cardData = [
                (
                  'Total Users',
                  '${controller.totalUsers}',
                  Icons.people,
                  Colors.blue
                ),
                (
                  'Total Complaints',
                  '$totalComplaints',
                  Icons.report_problem,
                  Colors.red
                ),
                (
                  'Resolved',
                  '$resolvedComplaints',
                  Icons.check_circle,
                  Colors.green
                ),
                ('Pending', '$pendingComplaints', Icons.pending, Colors.orange),
                ('Rejected', '$rejectedComplaints', Icons.cancel, Colors.red),
                (
                  'Escalated',
                  '$escalatedComplaints',
                  Icons.trending_up,
                  Colors.purple
                ),
              ];

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.background,
                      theme.colorScheme.surface,
                    ],
                  ),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (cardData.length / 2).ceil(),
                  itemBuilder: (context, index) {
                    final start = index * 2;
                    final end = start + 2 > cardData.length
                        ? cardData.length
                        : start + 2;
                    return Row(
                      children: List.generate(
                        end - start,
                        (i) => Expanded(
                          child: _buildProgressCard(
                            context,
                            cardData[start + i].$1,
                            cardData[start + i].$2,
                            cardData[start + i].$3,
                            cardData[start + i].$4,
                            controller.isLoading,
                          ),
                        ),
                      ).toList(),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Recent Activity',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          _buildRecentActivityCard(context),
          const SizedBox(height: 16),
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          _buildQuickActionsGrid(context),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isLoading,
  ) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    if (isLoading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentActivityCard(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final recentActivities = _generateRecentActivities();

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Recent Activities',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (recentActivities.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No recent activities',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                ...recentActivities
                    .take(5)
                    .map((activity) => _buildActivityItem(
                          context,
                          activity['title'],
                          activity['time'],
                          activity['icon'],
                          activity['color'],
                        )),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _generateRecentActivities() {
    final activities = <Map<String, dynamic>>[];

    // Get recent complaints (last 5)
    final recentComplaints = controller.complaints
        .take(5)
        .where((complaint) => complaint['created_at'] != null)
        .toList();

    for (final complaint in recentComplaints) {
      final status = complaint['status'] as String? ?? 'Submitted';
      final createdAt = complaint['created_at'] as String?;
      final studentName =
          complaint['student']?['name'] as String? ?? 'Unknown Student';
      final batchName =
          complaint['batch']?['batch_name'] as String? ?? 'Unknown Batch';

      String title;
      IconData icon;
      Color color;

      switch (status) {
        case 'Resolved':
          title = 'Complaint resolved for $studentName ($batchName)';
          icon = Icons.check_circle;
          color = Colors.green;
          break;
        case 'Rejected':
          title = 'Complaint rejected for $studentName ($batchName)';
          icon = Icons.cancel;
          color = Colors.red;
          break;
        case 'Escalated':
          title = 'Complaint escalated for $studentName ($batchName)';
          icon = Icons.trending_up;
          color = Colors.purple;
          break;
        case 'In Progress':
          title = 'Complaint in progress for $studentName ($batchName)';
          icon = Icons.pending;
          color = Colors.orange;
          break;
        default:
          title = 'New complaint from $studentName ($batchName)';
          icon = Icons.report_problem;
          color = Colors.blue;
      }

      activities.add({
        'title': title,
        'time': _formatTimeAgo(createdAt),
        'icon': icon,
        'color': color,
        'timestamp': createdAt,
      });
    }

    // Get recent students (last 3)
    final recentStudents = controller.students
        .take(3)
        .where((student) => student['created_at'] != null)
        .toList();

    for (final student in recentStudents) {
      final studentName = student['name'] as String? ?? 'Unknown Student';
      final batchName =
          student['batch']?['batch_name'] as String? ?? 'Unknown Batch';
      final createdAt = student['created_at'] as String?;

      activities.add({
        'title': 'New student registered: $studentName ($batchName)',
        'time': _formatTimeAgo(createdAt),
        'icon': Icons.person_add,
        'color': Colors.green,
        'timestamp': createdAt,
      });
    }

    // Get recent advisor assignments (last 3)
    final recentAdvisors = controller.advisors
        .take(3)
        .where((advisor) => advisor['created_at'] != null)
        .toList();

    for (final advisor in recentAdvisors) {
      final advisorName = advisor['name'] as String? ?? 'Unknown Advisor';
      final advisorId = advisor['id'] as String?;
      final createdAt = advisor['created_at'] as String?;

      // Find the batch this advisor is assigned to
      String batchName = 'Unknown Batch';
      if (advisorId != null) {
        // Try multiple ways to find the batch
        final assignedBatch = controller.batches
            .where((batch) => batch['advisor_id'] == advisorId)
            .firstOrNull;

        if (assignedBatch != null) {
          batchName = assignedBatch['batch_name'] as String? ?? 'Unknown Batch';
        } else {
          // Fallback: try to find by batch_id in advisor profile
          final advisorBatchId = advisor['batch_id'] as String?;
          if (advisorBatchId != null) {
            final batchById = controller.batches
                .where((batch) => batch['id'] == advisorBatchId)
                .firstOrNull;
            if (batchById != null) {
              batchName = batchById['batch_name'] as String? ?? 'Unknown Batch';
            }
          }
        }
      }

      activities.add({
        'title': 'Batch advisor assigned: $advisorName ($batchName)',
        'time': _formatTimeAgo(createdAt),
        'icon': Icons.supervisor_account,
        'color': Colors.orange,
        'timestamp': createdAt,
      });
    }

    // Add HOD information if available
    if (controller.hodProfile != null) {
      final hodName =
          controller.hodProfile!['name'] as String? ?? 'Unknown HOD';
      final hodCreatedAt = controller.hodProfile!['created_at'] as String?;

      activities.add({
        'title': 'HOD assigned: $hodName',
        'time': _formatTimeAgo(hodCreatedAt),
        'icon': Icons.admin_panel_settings,
        'color': Colors.indigo,
        'timestamp': hodCreatedAt,
      });
    }

    // Add department information if available
    if (controller.state.currentDepartment != null) {
      final deptName = controller.state.currentDepartment!['name'] as String? ??
          'Unknown Department';
      final deptCreatedAt =
          controller.state.currentDepartment!['created_at'] as String?;

      activities.add({
        'title': 'Department configured: $deptName',
        'time': _formatTimeAgo(deptCreatedAt),
        'icon': Icons.business,
        'color': Colors.teal,
        'timestamp': deptCreatedAt,
      });
    }

    // Sort by timestamp (most recent first)
    activities.sort((a, b) {
      final aTime = a['timestamp'] as String? ?? '';
      final bTime = b['timestamp'] as String? ?? '';
      return bTime.compareTo(aTime);
    });

    return activities;
  }

  String _formatTimeAgo(String? timestamp) {
    if (timestamp == null) return 'Unknown time';

    try {
      final createdAt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(createdAt);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else {
        return '${difference.inDays ~/ 7} week${(difference.inDays ~/ 7) == 1 ? '' : 's'} ago';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 9,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3 / 1.2,
      children: [
        _buildQuickActionCard(
          theme: theme,
          icon: Icons.person_add_alt_1,
          label: 'Add Student',
          color: Colors.blue.shade400,
          onTap: () {
            // Navigate to student management (index 1)
            onNavigationChanged(1);
          },
        ),
        _buildQuickActionCard(
          theme: theme,
          icon: Icons.supervised_user_circle,
          label: 'Add Advisor',
          color: Colors.green.shade400,
          onTap: () {
            // Navigate to batch advisor management (index 2)
            onNavigationChanged(2);
          },
        ),
        _buildQuickActionCard(
          theme: theme,
          icon: Icons.report_problem,
          label: 'View Complaints',
          color: Colors.orange.shade400,
          onTap: () {
            // Navigate to complaint management (index 4)
            onNavigationChanged(4);
          },
        ),
        _buildQuickActionCard(
          theme: theme,
          icon: Icons.bar_chart,
          label: 'Generate Report',
          color: Colors.red.shade400,
          onTap: () {
            // Show export options dialog
            _showExportDialog(context);
          },
        ),
      ],
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.download, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Export Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.blue),
              title: const Text('Export as CSV'),
              subtitle: const Text('Download data in spreadsheet format'),
              onTap: () {
                Navigator.pop(context);
                _exportDataAsCSV(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export as PDF'),
              subtitle: const Text('Download data in document format'),
              onTap: () {
                Navigator.pop(context);
                _exportDataAsPDF(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportDataAsCSV(BuildContext context) {
    _showExportOptionsDialog(context, 'CSV');
  }

  void _exportDataAsPDF(BuildContext context) {
    _showExportOptionsDialog(context, 'PDF');
  }

  void _showExportOptionsDialog(BuildContext context, String format) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              format == 'CSV' ? Icons.table_chart : Icons.picture_as_pdf,
              color: format == 'CSV' ? Colors.blue : Colors.red,
            ),
            const SizedBox(width: 8),
            Text('Export as $format'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Students Data'),
              subtitle: const Text('Export all student information'),
              onTap: () {
                Navigator.pop(context);
                _exportStudentsData(context, format);
              },
            ),
            ListTile(
              leading: const Icon(Icons.supervisor_account),
              title: const Text('Advisors Data'),
              subtitle: const Text('Export all advisor information'),
              onTap: () {
                Navigator.pop(context);
                _exportAdvisorsData(context, format);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('Complaints Data'),
              subtitle: const Text('Export all complaint information'),
              onTap: () {
                Navigator.pop(context);
                _exportComplaintsData(context, format);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('All Data'),
              subtitle: const Text('Export complete system data'),
              onTap: () {
                Navigator.pop(context);
                _exportAllData(context, format);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportStudentsData(BuildContext context, String format) async {
    try {
      if (format == 'CSV') {
        await _exportStudentsCSV(context);
      } else {
        await _exportStudentsPDF(context);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to export students data: $e');
    }
  }

  void _exportAdvisorsData(BuildContext context, String format) async {
    try {
      if (format == 'CSV') {
        await _exportAdvisorsCSV(context);
      } else {
        await _exportAdvisorsPDF(context);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to export advisors data: $e');
    }
  }

  void _exportComplaintsData(BuildContext context, String format) async {
    try {
      if (format == 'CSV') {
        await _exportComplaintsCSV(context);
      } else {
        await _exportComplaintsPDF(context);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to export complaints data: $e');
    }
  }

  void _exportAllData(BuildContext context, String format) async {
    try {
      if (format == 'CSV') {
        await _exportAllDataCSV(context);
      } else {
        await _exportAllDataPDF(context);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to export all data: $e');
    }
  }

  // Test function to verify services are working
  Future<void> _testServices(BuildContext context) async {
    try {
      print('Testing CSV service...');
      final testData = [
        {'name': 'Test', 'email': 'test@test.com'}
      ];
      final csvData = await CsvService.generateStudentsCSV(testData);
      print('CSV generation test successful');

      print('Testing PDF service...');
      await PDFService.generateStudentsPDF(
        students: testData,
        departmentName: 'Test Department',
      );
      print('PDF generation test successful');

      _showSuccessSnackBar(context, 'Services are working correctly!');
    } catch (e, stackTrace) {
      print('Service test failed: $e');
      print('Stack trace: $stackTrace');
      _showErrorSnackBar(context, 'Service test failed: $e');
    }
  }

  // CSV Export Methods with fallback
  Future<void> _exportStudentsCSV(BuildContext context) async {
    _showLoadingDialog(context, 'Generating CSV...');

    try {
      print('Starting CSV export for students...');
      print('Students count: ${controller.students.length}');

      final csvData = await CsvService.generateStudentsCSV(controller.students);
      print('CSV data generated successfully');

      // Try to download, if it fails, show the data in a dialog
      try {
        await CsvService.downloadCSV(csvData, 'students_data.csv');
        print('CSV file downloaded successfully');
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          _showSuccessSnackBar(context,
              'Students data generated successfully! Check console for data.');
        }
      } catch (downloadError) {
        print('Download failed, showing data in dialog: $downloadError');
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          _showCSVDataDialog(context, csvData, 'Students Data');
        }
      }
    } catch (e, stackTrace) {
      print('Error exporting students CSV: $e');
      print('Stack trace: $stackTrace');
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar(context, 'Failed to export students CSV: $e');
      }
    }
  }

  // Helper method to show CSV data in a dialog
  void _showCSVDataDialog(BuildContext context, String csvData, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$title (CSV)'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CSV data generated successfully!'),
              SizedBox(height: 10),
              Text('Copy this data and save it as a .csv file:'),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  csvData,
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAdvisorsCSV(BuildContext context) async {
    _showLoadingDialog(context, 'Generating CSV...');

    try {
      print('Starting CSV export for advisors...');
      print('Advisors count: ${controller.advisors.length}');

      final csvData = await CsvService.generateAdvisorsCSV(controller.advisors);
      print('CSV data generated successfully');

      // Try to download, if it fails, show the data in a dialog
      try {
        await CsvService.downloadCSV(csvData, 'advisors_data.csv');
        print('CSV file downloaded successfully');
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          _showSuccessSnackBar(context,
              'Advisors data generated successfully! Check console for data.');
        }
      } catch (downloadError) {
        print('Download failed, showing data in dialog: $downloadError');
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          _showCSVDataDialog(context, csvData, 'Advisors Data');
        }
      }
    } catch (e, stackTrace) {
      print('Error exporting advisors CSV: $e');
      print('Stack trace: $stackTrace');
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar(context, 'Failed to export advisors CSV: $e');
      }
    }
  }

  Future<void> _exportComplaintsCSV(BuildContext context) async {
    _showLoadingDialog(context, 'Generating CSV...');

    try {
      print('Starting CSV export for complaints...');
      print('Complaints count: ${controller.complaints.length}');

      final csvData =
          await CsvService.generateComplaintsCSV(controller.complaints);
      print('CSV data generated successfully');

      // Try to download, if it fails, show the data in a dialog
      try {
        await CsvService.downloadCSV(csvData, 'complaints_data.csv');
        print('CSV file downloaded successfully');
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          _showSuccessSnackBar(context,
              'Complaints data generated successfully! Check console for data.');
        }
      } catch (downloadError) {
        print('Download failed, showing data in dialog: $downloadError');
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          _showCSVDataDialog(context, csvData, 'Complaints Data');
        }
      }
    } catch (e, stackTrace) {
      print('Error exporting complaints CSV: $e');
      print('Stack trace: $stackTrace');
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar(context, 'Failed to export complaints CSV: $e');
      }
    }
  }

  Future<void> _exportAllDataCSV(BuildContext context) async {
    _showLoadingDialog(context, 'Generating CSV...');

    try {
      print('Starting CSV export for all data...');
      print(
          'Students: ${controller.students.length}, Advisors: ${controller.advisors.length}, Complaints: ${controller.complaints.length}, Batches: ${controller.batches.length}');

      final csvData = await CsvService.generateAllDataCSV(
        students: controller.students,
        advisors: controller.advisors,
        complaints: controller.complaints,
        batches: controller.batches,
      );
      print('CSV data generated successfully');

      // Try to download, if it fails, show the data in a dialog
      try {
        await CsvService.downloadCSV(csvData, 'all_data.csv');
        print('CSV file downloaded successfully');
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          _showSuccessSnackBar(context,
              'All data generated successfully! Check console for data.');
        }
      } catch (downloadError) {
        print('Download failed, showing data in dialog: $downloadError');
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          _showCSVDataDialog(context, csvData, 'All Data');
        }
      }
    } catch (e, stackTrace) {
      print('Error exporting all data CSV: $e');
      print('Stack trace: $stackTrace');
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar(context, 'Failed to export all data CSV: $e');
      }
    }
  }

  // PDF Export Methods
  Future<void> _exportStudentsPDF(BuildContext context) async {
    _showLoadingDialog(context, 'Generating PDF...');

    try {
      print('Starting PDF export for students...');
      print('Students count: ${controller.students.length}');

      await PDFService.generateStudentsPDF(
        students: controller.students,
        departmentName:
            controller.state.currentDepartment?['name'] ?? 'Unknown Department',
      );
      print('PDF generated successfully');

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showSuccessSnackBar(context, 'Students PDF generated successfully!');
      }
    } catch (e, stackTrace) {
      print('Error generating students PDF: $e');
      print('Stack trace: $stackTrace');
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar(context, 'Failed to generate students PDF: $e');
      }
    }
  }

  Future<void> _exportAdvisorsPDF(BuildContext context) async {
    _showLoadingDialog(context, 'Generating PDF...');

    try {
      print('Starting PDF export for advisors...');
      print('Advisors count: ${controller.advisors.length}');

      await PDFService.generateAdvisorsPDF(
        advisors: controller.advisors,
        batches: controller.batches,
        departmentName:
            controller.state.currentDepartment?['name'] ?? 'Unknown Department',
      );
      print('PDF generated successfully');

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showSuccessSnackBar(context, 'Advisors PDF generated successfully!');
      }
    } catch (e, stackTrace) {
      print('Error generating advisors PDF: $e');
      print('Stack trace: $stackTrace');
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar(context, 'Failed to generate advisors PDF: $e');
      }
    }
  }

  Future<void> _exportComplaintsPDF(BuildContext context) async {
    _showLoadingDialog(context, 'Generating PDF...');

    try {
      print('Starting PDF export for complaints...');
      print('Complaints count: ${controller.complaints.length}');

      await PDFService.generateComplaintsPDF(
        complaints: controller.complaints,
        departmentName:
            controller.state.currentDepartment?['name'] ?? 'Unknown Department',
      );
      print('PDF generated successfully');

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showSuccessSnackBar(context, 'Complaints PDF generated successfully!');
      }
    } catch (e, stackTrace) {
      print('Error generating complaints PDF: $e');
      print('Stack trace: $stackTrace');
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar(context, 'Failed to generate complaints PDF: $e');
      }
    }
  }

  Future<void> _exportAllDataPDF(BuildContext context) async {
    _showLoadingDialog(context, 'Generating PDF...');

    try {
      print('Starting PDF export for all data...');
      print(
          'Students: ${controller.students.length}, Advisors: ${controller.advisors.length}, Complaints: ${controller.complaints.length}, Batches: ${controller.batches.length}');

      await PDFService.generateAllDataPDF(
        students: controller.students,
        advisors: controller.advisors,
        complaints: controller.complaints,
        batches: controller.batches,
        departmentName:
            controller.state.currentDepartment?['name'] ?? 'Unknown Department',
      );
      print('PDF generated successfully');

      // Check if context is still mounted before accessing Navigator
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showSuccessSnackBar(
            context, 'Complete PDF report generated successfully!');
      }
    } catch (e, stackTrace) {
      print('Error generating all data PDF: $e');
      print('Stack trace: $stackTrace');
      // Check if context is still mounted before accessing Navigator
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar(context, 'Failed to generate complete PDF: $e');
      }
    }
  }

  // Helper Methods
  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildQuickActionCard({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            )
          ],
        ),
      ),
    );
  }
}
