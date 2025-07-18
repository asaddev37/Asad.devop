import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ComplaintList extends StatefulWidget {
  final List<Map<String, dynamic>> complaints;
  final bool isLoading;
  final String selectedStatus;
  final String selectedBatch;
  final String searchQuery;

  const ComplaintList({
    super.key,
    required this.complaints,
    required this.isLoading,
    required this.selectedStatus,
    required this.selectedBatch,
    required this.searchQuery,
  });

  @override
  State<ComplaintList> createState() => _ComplaintListState();
}

class _ComplaintListState extends State<ComplaintList> {
  Set<int> expandedComplaints = {};

  void _toggleExpanded(int index) {
    setState(() {
      if (expandedComplaints.contains(index)) {
        expandedComplaints.remove(index);
      } else {
        expandedComplaints.add(index);
      }
    });
  }

  List<Map<String, dynamic>> _getFilteredComplaints() {
    return widget.complaints.where((complaint) {
      // Filter by status
      if (widget.selectedStatus != 'all' &&
          complaint['status'] != widget.selectedStatus) {
        return false;
      }

      // Filter by batch
      if (widget.selectedBatch != 'all') {
        final batchName = complaint['batch']?['batch_name'] as String?;
        if (batchName != widget.selectedBatch) {
          return false;
        }
      }

      // Filter by search query
      if (widget.searchQuery.isNotEmpty) {
        final title = (complaint['title'] as String? ?? '').toLowerCase();
        final description =
            (complaint['description'] as String? ?? '').toLowerCase();
        final query = widget.searchQuery.toLowerCase();
        if (!title.contains(query) && !description.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Color _getStatusColor(String status, BuildContext context) {
    switch (status) {
      case 'Submitted':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      case 'Rejected':
        return Theme.of(context).colorScheme.error;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Submitted':
        return Icons.schedule;
      case 'In Progress':
        return Icons.work;
      case 'Resolved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(String? mediaUrl) {
    if (mediaUrl == null || mediaUrl.isEmpty) {
      return _buildDetailRow('Media', 'No media attached', Icons.image);
    }
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.link,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Media (Google Drive)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () async {
                    // Open Google Drive link
                    final Uri url = Uri.parse(mediaUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } else {
                      // Show error message if URL cannot be launched
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open the media link'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: theme.colorScheme.secondary.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.link,
                          size: 14,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'View Media',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mediaUrl,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateInfo(Map<String, dynamic> complaint) {
    final status = complaint['status'] as String? ?? 'Unknown';

    // Debug: Print all available fields to help identify the correct structure
    print('=== COMPLAINT DEBUG INFO ===');
    print('Status: $status');
    print('All complaint keys: ${complaint.keys.toList()}');

    // Print all fields that might contain user information
    complaint.keys
        .where((key) =>
            key.contains('by') ||
            key.contains('user') ||
            key.contains('action') ||
            key.contains('handled') ||
            key.contains('update'))
        .forEach((key) {
      print('Field "$key": ${complaint[key]}');
    });
    print('=== END DEBUG INFO ===');

    List<Widget> statusInfoWidgets = [];

    // Get advisor information from the complaint object
    final advisor = complaint['advisor'] as Map<String, dynamic>?;
    final hod = complaint['hod'] as Map<String, dynamic>?;

    // Get advisor name
    final advisorName = advisor?['name'] as String?;

    // Get HOD name
    final hodName = hod?['name'] as String?;

    // Show who is currently handling the complaint based on status
    if (status == 'Submitted' &&
        advisorName != null &&
        advisorName.isNotEmpty) {
      statusInfoWidgets.add(
        _buildDetailRow(
          'Assigned To',
          '$advisorName (Batch Advisor)',
          Icons.person,
        ),
      );
    }

    if (status == 'In Progress' &&
        advisorName != null &&
        advisorName.isNotEmpty) {
      statusInfoWidgets.add(
        _buildDetailRow(
          'In Progress By',
          '$advisorName (Batch Advisor)',
          Icons.work,
        ),
      );
    }

    if (status == 'Escalated' && hodName != null && hodName.isNotEmpty) {
      statusInfoWidgets.add(
        _buildDetailRow(
          'Escalated To',
          '$hodName (HOD)',
          Icons.trending_up,
        ),
      );
    }

    if (status == 'Resolved') {
      if (hodName != null && hodName.isNotEmpty) {
        statusInfoWidgets.add(
          _buildDetailRow(
            'Resolved By',
            '$hodName (HOD)',
            Icons.check_circle,
          ),
        );
      } else if (advisorName != null && advisorName.isNotEmpty) {
        statusInfoWidgets.add(
          _buildDetailRow(
            'Resolved By',
            '$advisorName (Batch Advisor)',
            Icons.check_circle,
          ),
        );
      }
    }

    if (status == 'Rejected') {
      if (hodName != null && hodName.isNotEmpty) {
        statusInfoWidgets.add(
          _buildDetailRow(
            'Rejected By',
            '$hodName (HOD)',
            Icons.cancel,
          ),
        );
      } else if (advisorName != null && advisorName.isNotEmpty) {
        statusInfoWidgets.add(
          _buildDetailRow(
            'Rejected By',
            '$advisorName (Batch Advisor)',
            Icons.cancel,
          ),
        );
      }
    }

    // Show current handler information
    if (statusInfoWidgets.isEmpty) {
      if (hodName != null && hodName.isNotEmpty) {
        statusInfoWidgets.add(
          _buildDetailRow(
            'Current Handler',
            '$hodName (HOD)',
            Icons.person,
          ),
        );
      } else if (advisorName != null && advisorName.isNotEmpty) {
        statusInfoWidgets.add(
          _buildDetailRow(
            'Current Handler',
            '$advisorName (Batch Advisor)',
            Icons.person,
          ),
        );
      } else {
        statusInfoWidgets.add(
          _buildDetailRow(
            'Current Handler',
            'No handler assigned',
            Icons.info,
          ),
        );
      }
    }

    return Column(
      children: statusInfoWidgets,
    );
  }

  bool _hasStatusInfo(Map<String, dynamic> complaint) {
    final advisor = complaint['advisor'] as Map<String, dynamic>?;
    final hod = complaint['hod'] as Map<String, dynamic>?;

    // Check if there's any handler information to display
    final advisorName = advisor?['name'] as String?;
    final hodName = hod?['name'] as String?;

    return (advisorName != null && advisorName.isNotEmpty) ||
        (hodName != null && hodName.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final filteredComplaints = _getFilteredComplaints();

    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (filteredComplaints.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.report_problem_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              widget.complaints.isEmpty
                  ? 'No Complaints Found'
                  : 'No Complaints Match Filters',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.complaints.isEmpty
                  ? 'Complaints will appear here when students submit them'
                  : 'Try adjusting your filters to see more results',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Complaints (${filteredComplaints.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
            ),
            if (filteredComplaints.length != widget.complaints.length)
              Text(
                'Filtered from ${widget.complaints.length} total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Expandable complaint cards
        ...filteredComplaints.asMap().entries.map((entry) {
          final index = entry.key;
          final complaint = entry.value;
          final isExpanded = expandedComplaints.contains(index);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Main complaint info (always visible)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(complaint['status'], context)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getStatusIcon(complaint['status']),
                          color: _getStatusColor(complaint['status'], context),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              complaint['title'] as String? ?? 'No Title',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              complaint['description'] as String? ??
                                  'No description',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: [
                                _buildInfoChip(
                                  context,
                                  _getStatusIcon(complaint['status']),
                                  complaint['status'] as String? ?? 'Unknown',
                                  _getStatusColor(complaint['status'], context),
                                ),
                                _buildInfoChip(
                                  context,
                                  Icons.class_,
                                  complaint['batch']?['batch_name']
                                          as String? ??
                                      'No batch',
                                  Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Expand/collapse button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () => _toggleExpanded(index),
                          icon: Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey[600],
                          ),
                          tooltip: isExpanded
                              ? 'Collapse details'
                              : 'Expand details',
                        ),
                      ),
                    ],
                  ),
                ),
                // Expandable details section
                if (isExpanded)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student details section
                        _buildSection(
                          context,
                          'Student Information',
                          Icons.person,
                          [
                            _buildDetailRow(
                              'Name',
                              complaint['student']?['name'] as String? ??
                                  'Unknown',
                              Icons.person_outline,
                            ),
                            _buildDetailRow(
                              'Email',
                              complaint['student']?['email'] as String? ??
                                  'No email',
                              Icons.email_outlined,
                            ),
                          ],
                        ),

                        // Media section
                        if (complaint['media_url'] != null &&
                            complaint['media_url'].toString().isNotEmpty)
                          _buildSection(
                            context,
                            'Attached Media',
                            Icons.attach_file,
                            [
                              _buildMediaSection(
                                  complaint['media_url'] as String?),
                            ],
                          ),

                        // Timestamps section
                        _buildSection(
                          context,
                          'Timeline',
                          Icons.schedule,
                          [
                            _buildDetailRow(
                              'Created',
                              _formatDate(complaint['created_at']),
                              Icons.add_circle_outline,
                            ),
                            _buildDetailRow(
                              'Last Updated',
                              _formatDate(complaint['updated_at']),
                              Icons.update,
                            ),
                            if (complaint['last_action_at'] != null)
                              _buildDetailRow(
                                'Last Action',
                                _formatDate(complaint['last_action_at']),
                                Icons.history,
                              ),
                          ],
                        ),

                        // Status update info
                        if (_hasStatusInfo(complaint))
                          _buildSection(
                            context,
                            'Status Information',
                            Icons.work,
                            [
                              _buildStatusUpdateInfo(complaint),
                            ],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Not available';
    try {
      return dateStr.substring(0, 16);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget _buildInfoChip(
      BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon,
      List<Widget> children) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
