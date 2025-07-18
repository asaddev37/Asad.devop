import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import 'package:intl/intl.dart';
import '../config/admin_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class HODDashboard extends StatefulWidget {
  const HODDashboard({super.key});

  @override
  State<HODDashboard> createState() => _HODDashboardState();
}

class _DrawerItem {
  final String title;
  final IconData icon;
  const _DrawerItem(this.title, this.icon);
}

class _HODDashboardState extends State<HODDashboard> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;
  bool _isLoading = true;
  Map<String, dynamic>? _hodProfile;
  List<Map<String, dynamic>> _complaints = [];
  List<Map<String, dynamic>> _advisors = [];
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _batches = [];
  String? _selectedFilter;
  String? _selectedBatchFilter;
  String? _selectedAdvisorFilter;
  String? _selectedStudentFilter;
  Map<String, dynamic>? _departmentInfo;

  final List<_DrawerItem> _drawerItems = [
    _DrawerItem('Dashboard', Icons.dashboard_customize_outlined),
    _DrawerItem('Escalated Complaints', Icons.warning_amber_rounded),
    _DrawerItem('View Batch Advisors', Icons.group),
    _DrawerItem('Update Status', Icons.update),
    _DrawerItem('Profile', Icons.person),
    _DrawerItem('Notifications', Icons.notifications),
    _DrawerItem('Support & Help', Icons.help_outline),
    _DrawerItem('Reports', Icons.bar_chart),
    _DrawerItem('Settings', Icons.settings),
    _DrawerItem('Logout', Icons.logout),
  ];

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadData();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
      prefs.setBool('isDarkMode', _isDarkMode);
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await SupabaseService.getHODProfile();
      final complaints = await SupabaseService.getHODComplaints();
      final advisors = await SupabaseService.getBatchAdvisors();
      final batches = await SupabaseService.getBatchesWithAdvisors();
      // Get department information
      Map<String, dynamic>? departmentInfo;
      if (profile?['department_id'] != null) {
        try {
          final deptResponse = await SupabaseService.getCurrentDepartment();
          departmentInfo = deptResponse;
        } catch (e) {
          print('Error fetching department info: $e');
        }
      }
      // Extract unique students from complaints
      final students = <Map<String, dynamic>>{};
      for (final c in complaints) {
        if (c['student'] != null) students.add(c['student']);
      }
      setState(() {
        _hodProfile = profile;
        _complaints = complaints;
        _advisors = advisors;
        _batches = batches;
        _students = students.toList();
        _departmentInfo = departmentInfo;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleStatusUpdate(
      Map<String, dynamic> complaint, String status) async {
    final controller = TextEditingController();
    final comment = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Comment'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Comment'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (comment == null || comment.trim().isEmpty) return;
    try {
      await SupabaseService.updateComplaint(
        complaintId: complaint['id'],
        status: status,
        comment: comment,
      );
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint $status successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  List<String> _getUniqueBatches() {
    final batches = <String>{};
    for (final complaint in _complaints) {
      if (complaint['batch']?['batch_name'] != null) {
        batches.add(complaint['batch']['batch_name']);
      }
    }
    return batches.toList()..sort();
  }

  List<Map<String, dynamic>> _getFilteredComplaints() {
    List<Map<String, dynamic>> filtered = _complaints;
    if (_selectedFilter != null && _selectedFilter != 'all') {
      filtered = filtered.where((c) => c['status'] == _selectedFilter).toList();
    }
    if (_selectedBatchFilter != null && _selectedBatchFilter != 'all') {
      filtered = filtered
          .where((c) => c['batch']?['batch_name'] == _selectedBatchFilter)
          .toList();
    }
    if (_selectedAdvisorFilter != null && _selectedAdvisorFilter != 'all') {
      filtered = filtered
          .where((c) => c['batch']?['advisor']?['id'] == _selectedAdvisorFilter)
          .toList();
    }
    if (_selectedStudentFilter != null && _selectedStudentFilter != 'all') {
      filtered = filtered
          .where((c) => c['student']?['id'] == _selectedStudentFilter)
          .toList();
    }
    return filtered;
  }

  void _onDrawerItemTap(int index) async {
    if (index == 9) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
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
          await SupabaseService.signOut();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error logging out: $e')),
            );
          }
        }
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme =
        _isDarkMode ? AdminTheme.darkTheme : AdminTheme.lightTheme;
    final hodName = _hodProfile?['name'] ?? 'HOD';
    final hodEmail = _hodProfile?['email'] ?? 'hod@email.com';
    final avatarUrl = _hodProfile?['avatar_url'] as String?;
    final avatarLetter = hodName.isNotEmpty ? hodName[0].toUpperCase() : 'H';
    final department = _departmentInfo?['name'] ?? 'CS';
    final isDark = _isDarkMode;
    final drawerHeaderColor = isDark
        ? currentTheme.colorScheme.surfaceVariant
        : currentTheme.colorScheme.primary;
    return Theme(
      data: currentTheme,
      child: Scaffold(
        backgroundColor: currentTheme.colorScheme.background,
        appBar: AppBar(
          backgroundColor: currentTheme.colorScheme.surface,
          elevation: 0,
          title: Text(
            'HOD Dashboard',
            style: TextStyle(
              color: currentTheme.colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: IconThemeData(color: currentTheme.colorScheme.onSurface),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
              tooltip: 'Toggle Theme',
              onPressed: _toggleTheme,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () => _onDrawerItemTap(9),
            ),
          ],
        ),
        drawer: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: drawerHeaderColor,
                ),
                currentAccountPicture: avatarUrl != null &&
                        avatarUrl!.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(avatarUrl!),
                        backgroundColor: currentTheme.colorScheme.secondary,
                      )
                    : CircleAvatar(
                        backgroundColor: currentTheme.colorScheme.secondary,
                        child: Text(avatarLetter,
                            style: TextStyle(
                                fontSize: 24,
                                color: currentTheme.colorScheme.onSecondary)),
                      ),
                accountName: Text(hodName),
                accountEmail: Text(hodEmail),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _drawerItems.length,
                  itemBuilder: (context, i) => ListTile(
                    leading: Icon(_drawerItems[i].icon,
                        color: currentTheme.colorScheme.primary),
                    title: Text(_drawerItems[i].title),
                    selected: _selectedIndex == i,
                    onTap: () => _onDrawerItemTap(i),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: _selectedIndex == 0
            ? Column(
                children: [
                  _HODDashboardHeader(
                    theme: currentTheme,
                    hodName: hodName,
                    department: department,
                    avatarUrl: avatarUrl,
                    onRefresh: _loadData,
                  ),
                  Expanded(
                    child: _HODDashboardOverview(
                      complaints: _complaints,
                      advisors: _advisors,
                      isLoading: _isLoading,
                      theme: currentTheme,
                      onQuickAction: (int index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      hodName: hodName,
                      department: department,
                      onRefresh: _loadData,
                    ),
                  ),
                ],
              )
            : _getBodyWidget(currentTheme, hodName, department),
      ),
    );
  }

  Widget _getBodyWidget(ThemeData theme, String hodName, String department) {
    switch (_selectedIndex) {
      case 1:
        return _AllComplaintsScreen(theme: theme, batches: _batches);
      case 2:
        return _ViewBatchAdvisorsScreen(theme: theme);
      case 3:
        return _UpdateStatusScreen(theme: theme, batches: _batches);
      case 4:
        return _HODProfileScreen(
            theme: theme, profile: _hodProfile, onRefresh: _loadData);
      case 5:
        return _HODNotificationsScreen(theme: theme);
      case 6:
        return _HODHelpSupportScreen(theme: theme);
      case 7:
        return _HODReportsScreen(
            theme: theme,
            complaints: _complaints,
            advisors: _advisors,
            isLoading: _isLoading,
            onRefresh: _loadData);
      case 8:
        return _HODSettingsScreen(
          theme: theme,
          isDarkMode: _isDarkMode,
          onThemeChanged: (val) {
            _toggleTheme();
          },
        );
      default:
        return Center(
            child: Text('Screen for HOD: $hodName ($department)',
                style: theme.textTheme.titleLarge));
    }
  }
}

class _HODComplaintCard extends StatefulWidget {
  final Map<String, dynamic> complaint;
  final VoidCallback onAction;
  final List<Map<String, dynamic>> batches;
  const _HODComplaintCard(
      {required this.complaint, required this.onAction, required this.batches});

  @override
  State<_HODComplaintCard> createState() => _HODComplaintCardState();
}

class _HODComplaintCardState extends State<_HODComplaintCard> {
  bool _expanded = false;
  bool _loadingTimeline = false;
  List<Map<String, dynamic>> _timeline = [];
  String? _timelineError;
  bool _actionLoading = false;
  String? _fetchedBatchName;

  @override
  void initState() {
    super.initState();
    _maybeFetchBatch();
  }

  void _maybeFetchBatch() {
    final batch = widget.complaint['batch'];
    if (batch == null && widget.complaint['batch_id'] != null) {
      final complaintBatchId =
          widget.complaint['batch_id'].toString().toLowerCase();
      bool foundMatch = false;
      for (final b in widget.batches) {
        final batchId = b['id']?.toString().toLowerCase();
        // Debug print
        // ignore: avoid_print
        print(
            'Comparing complaint batch_id: $complaintBatchId with batch id: $batchId');
        if (batchId != null && batchId == complaintBatchId) {
          if (b['batch_name'] != null) {
            setState(() => _fetchedBatchName = b['batch_name']);
            foundMatch = true;
            break;
          }
        }
      }
      if (!foundMatch) {
        // Try matching by uuid string (case-insensitive)
        for (final b in widget.batches) {
          final batchId = b['id']?.toString().toLowerCase();
          if (batchId != null &&
              batchId.replaceAll('-', '') ==
                  complaintBatchId.replaceAll('-', '')) {
            if (b['batch_name'] != null) {
              setState(() => _fetchedBatchName = b['batch_name']);
              print('Fallback match by uuid string: $batchId');
              break;
            }
          }
        }
      }
    }
  }

  String _getBatchName() {
    final batch = widget.complaint['batch'];
    if (batch != null && batch['batch_name'] != null) {
      return batch['batch_name'];
    }
    if (_fetchedBatchName != null) {
      return _fetchedBatchName!;
    }
    if (widget.complaint['batch_name'] != null) {
      return widget.complaint['batch_name'];
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final status =
        widget.complaint['status']?.toString().toUpperCase() ?? 'UNKNOWN';
    final isResolved = status == 'RESOLVED';
    final isRejected = status == 'REJECTED';
    final isEscalated = status == 'ESCALATED';
    Color statusColor;
    if (isResolved) {
      statusColor = Colors.green;
    } else if (isEscalated) {
      statusColor = Colors.red;
    } else if (isRejected) {
      statusColor = Colors.grey;
    } else {
      statusColor = Colors.orange;
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.complaint['title'] ?? 'No Title',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label:
                      Text(status, style: const TextStyle(color: Colors.white)),
                  backgroundColor: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.complaint['description'] ?? 'No description'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 4),
                Flexible(
                    child: Text(
                        'Student: ${widget.complaint['student']?['name'] ?? 'Unknown'}',
                        overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 16),
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Submitted: ${_formatDate(widget.complaint['created_at'])}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.complaint['media_url'] != null &&
                widget.complaint['media_url'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: InkWell(
                        onTap: () => _launchUrl(widget.complaint['media_url']),
                        child: Text(
                          widget.complaint['media_url'],
                          style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            // Action Buttons
            if (!isResolved && !isRejected)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _actionLoading
                        ? null
                        : () async {
                            final controller = TextEditingController();
                            final comment = await showDialog<String>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Add Resolution Comment'),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                      hintText: 'Comment'),
                                  maxLines: 3,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context)
                                        .pop(controller.text),
                                    child: const Text('Submit'),
                                  ),
                                ],
                              ),
                            );
                            if (comment != null && comment.trim().isNotEmpty) {
                              setState(() => _actionLoading = true);
                              try {
                                await SupabaseService.updateComplaint(
                                  complaintId: widget.complaint['id'],
                                  status: 'Resolved',
                                  comment: comment,
                                );
                                widget.onAction();
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              } finally {
                                setState(() => _actionLoading = false);
                              }
                            }
                          },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Resolve'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  ElevatedButton.icon(
                    onPressed: _actionLoading
                        ? null
                        : () async {
                            final controller = TextEditingController();
                            final comment = await showDialog<String>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Add Rejection Comment'),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                      hintText: 'Comment'),
                                  maxLines: 3,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context)
                                        .pop(controller.text),
                                    child: const Text('Submit'),
                                  ),
                                ],
                              ),
                            );
                            if (comment != null && comment.trim().isNotEmpty) {
                              setState(() => _actionLoading = true);
                              try {
                                await SupabaseService.updateComplaint(
                                  complaintId: widget.complaint['id'],
                                  status: 'Rejected',
                                  comment: comment,
                                );
                                widget.onAction();
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              } finally {
                                setState(() => _actionLoading = false);
                              }
                            }
                          },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Reject'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  ),
                  OutlinedButton.icon(
                    onPressed: _actionLoading
                        ? null
                        : () => setState(() => _expanded = !_expanded),
                    icon: const Icon(Icons.timeline),
                    label: Text(_expanded ? 'Hide Timeline' : 'View Timeline'),
                  ),
                ],
              ),
            if (_expanded)
              _loadingTimeline
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _timelineError != null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Error: $_timelineError',
                              style: const TextStyle(color: Colors.red)),
                        )
                      : _timeline.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('No timeline events.'),
                            )
                          : _buildTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _timeline.map((event) {
        final status = event['status']?.toString().toUpperCase() ?? '';
        final comment = event['comment'] ?? '';
        final createdBy = event['created_by']?['name'] ?? 'System';
        final role = event['created_by']?['role'] ?? '';
        final date = _formatDate(event['created_at']);
        return ListTile(
          leading: const Icon(Icons.circle, size: 16),
          title:
              Text('$status by $createdBy${role.isNotEmpty ? ' ($role)' : ''}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (comment.isNotEmpty) Text('Comment: $comment'),
              Text(date,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString.toString());
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  void _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link.')),
        );
      }
    }
  }
}

class _HODDashboardHeader extends StatelessWidget {
  final ThemeData theme;
  final String hodName;
  final String department;
  final String? avatarUrl;
  final VoidCallback onRefresh;
  const _HODDashboardHeader({
    Key? key,
    required this.theme,
    required this.hodName,
    required this.department,
    this.avatarUrl,
    required this.onRefresh,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            avatarUrl != null && avatarUrl!.isNotEmpty
                ? CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(avatarUrl!),
                    backgroundColor: theme.colorScheme.primary,
                  )
                : CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      hodName.isNotEmpty ? hodName[0].toUpperCase() : 'H',
                      style: TextStyle(
                          fontSize: 28,
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome,',
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500)),
                  Text(hodName,
                      style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('Department: $department',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.7))),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _HODDashboardOverview extends StatefulWidget {
  final List<Map<String, dynamic>> complaints;
  final List<Map<String, dynamic>> advisors;
  final bool isLoading;
  final ThemeData theme;
  final void Function(int) onQuickAction;
  final String hodName;
  final String department;
  final VoidCallback onRefresh;
  const _HODDashboardOverview({
    Key? key,
    required this.complaints,
    required this.advisors,
    required this.isLoading,
    required this.theme,
    required this.onQuickAction,
    required this.hodName,
    required this.department,
    required this.onRefresh,
  }) : super(key: key);
  @override
  State<_HODDashboardOverview> createState() => _HODDashboardOverviewState();
}

class _HODDashboardOverviewState extends State<_HODDashboardOverview> {
  List<Map<String, dynamic>> _advisors = [];
  bool _loadingAdvisors = false;
  @override
  void initState() {
    super.initState();
    _fetchAdvisors();
  }

  Future<void> _fetchAdvisors() async {
    if (widget.advisors.isNotEmpty) {
      setState(() => _advisors = widget.advisors);
      return;
    }
    setState(() => _loadingAdvisors = true);
    try {
      final fetched = await SupabaseService.getBatchAdvisors();
      setState(() => _advisors = fetched);
    } catch (_) {
      setState(() => _advisors = []);
    } finally {
      setState(() => _loadingAdvisors = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAdvisors = _advisors.length;
    final totalComplaints = widget.complaints.length;
    final escalated = widget.complaints
        .where(
            (c) => (c['status']?.toString().toLowerCase() ?? '') == 'escalated')
        .length;
    final resolved = widget.complaints
        .where(
            (c) => (c['status']?.toString().toLowerCase() ?? '') == 'resolved')
        .length;
    final pending = widget.complaints
        .where(
            (c) => (c['status']?.toString().toLowerCase() ?? '') == 'pending')
        .length;
    final rejected = widget.complaints
        .where(
            (c) => (c['status']?.toString().toLowerCase() ?? '') == 'rejected')
        .length;
    final cardData = [
      (
        'Total Advisors',
        totalAdvisors,
        Icons.group,
        widget.theme.colorScheme.primary
      ),
      (
        'Total Complaints',
        totalComplaints,
        Icons.report_problem,
        widget.theme.colorScheme.secondary
      ),
      (
        'Escalated',
        escalated,
        Icons.warning_amber_rounded,
        Colors.orange.shade400
      ),
      ('Resolved', resolved, Icons.check_circle, Colors.green.shade400),
      ('Pending', pending, Icons.pending, Colors.purple.shade400),
      ('Rejected', rejected, Icons.cancel, Colors.red.shade400),
    ];
    // Quick actions: 2 per row
    final quickActions = [
      _QuickActionButton(
        icon: Icons.warning_amber_rounded,
        label: 'Escalated Complaints',
        color: widget.theme.colorScheme.primary,
        onTap: () => widget.onQuickAction(1),
      ),
      _QuickActionButton(
        icon: Icons.group,
        label: 'View Advisors',
        color: widget.theme.colorScheme.secondary,
        onTap: () => widget.onQuickAction(2),
      ),
      _QuickActionButton(
        icon: Icons.update,
        label: 'Update Status',
        color: widget.theme.colorScheme.tertiary,
        onTap: () => widget.onQuickAction(3),
      ),
      _QuickActionButton(
        icon: Icons.person,
        label: 'Profile',
        color: widget.theme.colorScheme.primary,
        onTap: () => widget.onQuickAction(4),
      ),
    ];
    return widget.isLoading || _loadingAdvisors
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('System Overview',
                    style: widget.theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                ListView.builder(
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
                          child: _ProgressCard(
                            label: cardData[start + i].$1,
                            value: cardData[start + i].$2,
                            icon: cardData[start + i].$3,
                            color: cardData[start + i].$4,
                            theme: widget.theme,
                            isLoading: widget.isLoading,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text('Recent Activity',
                    style: widget.theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                _RecentActivityCard(
                    theme: widget.theme, complaints: widget.complaints),
                const SizedBox(height: 16),
                Text('Quick Actions',
                    style: widget.theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                Column(
                  children: List.generate(
                    (quickActions.length / 2).ceil(),
                    (row) {
                      final start = row * 2;
                      final end = (start + 2 > quickActions.length)
                          ? quickActions.length
                          : start + 2;
                      final rowActions = quickActions.sublist(start, end);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: rowActions.length == 1
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.spaceEvenly,
                          children: rowActions
                              .map((action) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: action,
                                    ),
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}

class _ProgressCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final ThemeData theme;
  final bool isLoading;
  const _ProgressCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
    required this.isLoading,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 120,
        height: 90,
        alignment: Alignment.center,
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(height: 6),
                  Text('$value',
                      style: theme.textTheme.headlineSmall?.copyWith(
                          color: color, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(label,
                      style:
                          theme.textTheme.bodyMedium?.copyWith(color: color)),
                ],
              ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(label,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> complaints;
  const _RecentActivityCard({required this.theme, required this.complaints});
  @override
  Widget build(BuildContext context) {
    if (complaints.isEmpty) {
      return Card(
        color: theme.colorScheme.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No recent activity.', style: theme.textTheme.bodyLarge),
        ),
      );
    }
    final recent = complaints.take(3).toList();
    return Column(
      children: recent.map((c) {
        final status = c['status']?.toString().toUpperCase() ?? 'UNKNOWN';
        final title = c['title'] ?? 'No Title';
        final date = c['created_at'] ?? '';
        return Card(
          color: theme.colorScheme.surfaceVariant,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading:
                Icon(Icons.report_problem, color: theme.colorScheme.primary),
            title: Text(title, style: theme.textTheme.titleMedium),
            subtitle: Text('Status: $status\n$date'),
          ),
        );
      }).toList(),
    );
  }
}

class _AllComplaintsScreen extends StatefulWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> batches;
  const _AllComplaintsScreen({required this.theme, required this.batches});
  @override
  State<_AllComplaintsScreen> createState() => _AllComplaintsScreenState();
}

class _AllComplaintsScreenState extends State<_AllComplaintsScreen> {
  List<Map<String, dynamic>> _complaints = [];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    setState(() => _loading = true);
    try {
      final all = await SupabaseService.getHODComplaints();
      setState(() {
        _complaints = all
            .where((c) =>
                (c['status']?.toString()?.trim().toLowerCase() ?? '') ==
                'escalated')
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load complaints: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: widget.theme.colorScheme.surface,
        elevation: 0,
        title: Text('Escalated Complaints',
            style: widget.theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: widget.theme.colorScheme.onSurface),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _complaints.isEmpty
              ? const Center(child: Text('No escalated complaints found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _complaints.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final c = _complaints[i];
                    return _EscalatedComplaintCard(
                      complaint: c,
                      batches: widget.batches,
                    );
                  },
                ),
    );
  }
}

class _EscalatedComplaintCard extends StatefulWidget {
  final Map<String, dynamic> complaint;
  final List<Map<String, dynamic>> batches;
  const _EscalatedComplaintCard(
      {required this.complaint, required this.batches});
  @override
  State<_EscalatedComplaintCard> createState() =>
      _EscalatedComplaintCardState();
}

class _EscalatedComplaintCardState extends State<_EscalatedComplaintCard> {
  bool _expanded = false;
  bool _loadingTimeline = false;
  List<Map<String, dynamic>> _timeline = [];
  String? _timelineError;
  String? _fetchedBatchName;
  bool _fetchingBatch = false;

  @override
  void initState() {
    super.initState();
    _maybeFetchBatch();
  }

  void _maybeFetchBatch() {
    final batch = widget.complaint['batch'];
    if (batch == null && widget.complaint['batch_id'] != null) {
      final complaintBatchId =
          widget.complaint['batch_id'].toString().toLowerCase();
      bool foundMatch = false;
      for (final b in widget.batches) {
        final batchId = b['id']?.toString().toLowerCase();
        // Debug print
        // ignore: avoid_print
        print(
            'Comparing complaint batch_id: $complaintBatchId with batch id: $batchId');
        if (batchId != null && batchId == complaintBatchId) {
          if (b['batch_name'] != null) {
            setState(() => _fetchedBatchName = b['batch_name']);
            foundMatch = true;
            break;
          }
        }
      }
      if (!foundMatch) {
        // Try matching by uuid string (case-insensitive)
        for (final b in widget.batches) {
          final batchId = b['id']?.toString().toLowerCase();
          if (batchId != null &&
              batchId.replaceAll('-', '') ==
                  complaintBatchId.replaceAll('-', '')) {
            if (b['batch_name'] != null) {
              setState(() => _fetchedBatchName = b['batch_name']);
              print('Fallback match by uuid string: $batchId');
              break;
            }
          }
        }
      }
    }
  }

  String _getBatchName() {
    final batch = widget.complaint['batch'];
    if (batch != null && batch['batch_name'] != null) {
      return batch['batch_name'];
    }
    if (_fetchedBatchName != null) {
      return _fetchedBatchName!;
    }
    if (_fetchingBatch) {
      return 'Loading...';
    }
    if (widget.complaint['batch_name'] != null) {
      return widget.complaint['batch_name'];
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.complaint;
    final status = c['status']?.toString().toUpperCase() ?? 'ESCALATED';
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(c['title'] ?? 'No Title',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Chip(
                  label:
                      Text(status, style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(c['description'] ?? 'No description'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 4),
                Flexible(
                    child: Text(
                        'Student: ${c['student']?['name'] ?? 'Unknown'}',
                        overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 16),
                const Icon(Icons.class_, size: 16),
                const SizedBox(width: 4),
                Flexible(
                    child: Text('Batch: ${_getBatchName()}',
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                setState(() => _expanded = !_expanded);
                if (_expanded && _timeline.isEmpty && !_loadingTimeline) {
                  await _fetchTimeline();
                }
              },
              icon: const Icon(Icons.timeline),
              label: Text(_expanded ? 'Hide Timeline' : 'View Timeline'),
            ),
            if (_expanded)
              _loadingTimeline
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _timelineError != null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Error: $_timelineError',
                              style: const TextStyle(color: Colors.red)),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_timeline.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('No timeline events.'),
                              )
                            else ...[
                              // Show escalation event details
                              Builder(builder: (context) {
                                final escalation = _getEscalationEvent();
                                if (escalation == null) {
                                  return const SizedBox();
                                }
                                final comment = escalation['comment'] ?? '';
                                final advisor = escalation['created_by'] ?? {};
                                final advisorName =
                                    advisor['name'] ?? 'Unknown';
                                final advisorEmail =
                                    advisor['email'] ?? 'Unknown';
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(),
                                    Text('Escalated by: $advisorName',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium),
                                    Text('Advisor Email: $advisorEmail',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                    if (comment.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                            'Escalation Comment: $comment',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                      ),
                                    const Divider(),
                                  ],
                                );
                              }),
                              // Show full timeline
                              ..._timeline.map((event) {
                                final status = event['status']
                                        ?.toString()
                                        ?.toUpperCase() ??
                                    '';
                                final comment = event['comment'] ?? '';
                                final createdBy =
                                    event['created_by']?['name'] ?? 'System';
                                final role = event['created_by']?['role'] ?? '';
                                final date = event['created_at'] ?? '';
                                return ListTile(
                                  leading: const Icon(Icons.circle, size: 16),
                                  title: Text(
                                      '$status by $createdBy${role.isNotEmpty ? ' ($role)' : ''}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (comment.isNotEmpty)
                                        Text('Comment: $comment'),
                                      Text(date,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ]
                          ],
                        ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchTimeline() async {
    setState(() {
      _loadingTimeline = true;
      _timelineError = null;
    });
    try {
      final timeline =
          await SupabaseService.getComplaintTimeline(widget.complaint['id']);
      setState(() {
        _timeline = timeline;
      });
    } catch (e) {
      setState(() {
        _timelineError = e.toString();
      });
    } finally {
      setState(() {
        _loadingTimeline = false;
      });
    }
  }

  Map<String, dynamic>? _getEscalationEvent() {
    for (final event in _timeline) {
      if ((event['status']?.toString()?.toLowerCase() ?? '') == 'escalated') {
        return event;
      }
    }
    return null;
  }
}

class _UpdateStatusScreen extends StatefulWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> batches;
  const _UpdateStatusScreen({required this.theme, required this.batches});
  @override
  State<_UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends State<_UpdateStatusScreen> {
  List<Map<String, dynamic>> _complaints = [];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    setState(() => _loading = true);
    try {
      final all = await SupabaseService.getHODComplaints();
      setState(() {
        _complaints = all;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load complaints: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: widget.theme.colorScheme.surface,
        elevation: 0,
        title: Text('Update Status',
            style: widget.theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: widget.theme.colorScheme.onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetchComplaints,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _complaints.isEmpty
              ? const Center(child: Text('No complaints found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _complaints.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final c = _complaints[i];
                    return _HODComplaintCard(
                      complaint: c,
                      onAction: _fetchComplaints,
                      batches: widget.batches,
                    );
                  },
                ),
    );
  }
}

class _ViewBatchAdvisorsScreen extends StatefulWidget {
  final ThemeData theme;
  const _ViewBatchAdvisorsScreen({required this.theme});
  @override
  State<_ViewBatchAdvisorsScreen> createState() =>
      _ViewBatchAdvisorsScreenState();
}

class _ViewBatchAdvisorsScreenState extends State<_ViewBatchAdvisorsScreen> {
  List<Map<String, dynamic>> _advisors = [];
  List<Map<String, dynamic>> _batches = [];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _fetchAdvisors();
  }

  Future<void> _fetchAdvisors() async {
    setState(() => _loading = true);
    try {
      final advisors = await SupabaseService.getBatchAdvisors();
      final batches = await SupabaseService.getBatchesWithAdvisors();
      setState(() {
        _advisors = advisors;
        _batches = batches;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load advisors: $e')));
    }
  }

  List<String> _getBatchNamesForAdvisor(String advisorId) {
    final batches = _batches
        .where((b) =>
            b['advisor_id'] == advisorId ||
            (b['advisor'] != null && b['advisor']['id'] == advisorId))
        .toList();
    return batches.map((b) => b['batch_name']?.toString() ?? 'N/A').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: widget.theme.colorScheme.surface,
        elevation: 0,
        title: Text('Batch Advisors',
            style: widget.theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: widget.theme.colorScheme.onSurface),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _advisors.isEmpty
              ? const Center(child: Text('No batch advisors found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _advisors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final a = _advisors[i];
                    final batchNames = _getBatchNamesForAdvisor(a['id']);
                    return Card(
                      color: widget.theme.colorScheme.surfaceVariant,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: widget.theme.colorScheme.primary,
                          child: Text(
                              a['name'] != null && a['name'].isNotEmpty
                                  ? a['name'][0].toUpperCase()
                                  : 'A',
                              style: TextStyle(
                                  color: widget.theme.colorScheme.onPrimary)),
                        ),
                        title: Text(a['name'] ?? 'Advisor',
                            style: widget.theme.textTheme.titleMedium),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${a['email'] ?? 'N/A'}'),
                            Text(
                                'Batch: ${batchNames.isNotEmpty ? batchNames.join(', ') : 'N/A'}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// --- HOD Profile Screen ---
class _HODProfileScreen extends StatefulWidget {
  final ThemeData theme;
  final Map<String, dynamic>? profile;
  final VoidCallback? onRefresh;
  const _HODProfileScreen({required this.theme, this.profile, this.onRefresh});
  @override
  State<_HODProfileScreen> createState() => _HODProfileScreenState();
}

class _HODProfileScreenState extends State<_HODProfileScreen> {
  bool _editing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _loading = false;
  String? _avatarUrl;
  bool _uploadingAvatar = false;
  String? _departmentName;
  String? _batchName;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.profile?['name'] ?? '');
    _emailController =
        TextEditingController(text: widget.profile?['email'] ?? '');
    _avatarUrl = widget.profile?['avatar_url'];
    _fetchDepartmentAndBatch();
  }

  Future<void> _fetchDepartmentAndBatch() async {
    final departmentId = widget.profile?['department_id'];
    if (departmentId != null) {
      try {
        final dept = await SupabaseService.getCurrentDepartment();
        setState(() => _departmentName = dept?['name'] ?? '');
      } catch (_) {
        setState(() => _departmentName = '');
      }
    }
    setState(
        () => _batchName = widget.profile?['batch']?['batch_name'] ?? 'N/A');
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    try {
      await SupabaseService.updateHODProfile(
        userId: widget.profile?['id'],
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        avatarUrl: _avatarUrl,
      );
      if (widget.onRefresh != null) widget.onRefresh!();
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    setState(() => _uploadingAvatar = true);
    try {
      final url = await SupabaseService.uploadProfilePicture(picked.path);
      setState(() => _avatarUrl = url);
      await _saveProfile(); // Immediately save profile with new avatar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload picture: $e')));
    } finally {
      setState(() => _uploadingAvatar = false);
    }
  }

  Widget _buildAvatar() {
    final name = _nameController.text.isNotEmpty
        ? _nameController.text
        : (widget.profile?['name'] ?? 'H');
    if (_uploadingAvatar) {
      return const CircleAvatar(radius: 38, child: CircularProgressIndicator());
    }
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return CircleAvatar(
          radius: 38, backgroundImage: NetworkImage(_avatarUrl!));
    }
    return CircleAvatar(
      radius: 38,
      backgroundColor: widget.theme.colorScheme.primary,
      child: Text(name[0].toUpperCase(),
          style: TextStyle(
              fontSize: 34, color: widget.theme.colorScheme.onPrimary)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _nameController.text.isNotEmpty
        ? _nameController.text
        : (widget.profile?['name'] ?? 'HOD');
    final email = _emailController.text.isNotEmpty
        ? _emailController.text
        : (widget.profile?['email'] ?? 'hod@email.com');
    final department =
        _departmentName ?? widget.profile?['department']?['name'] ?? 'N/A';
    final batch = _batchName ?? 'N/A';
    return Scaffold(
      backgroundColor: widget.theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: widget.theme.colorScheme.surface,
        elevation: 0,
        title: Text('Profile',
            style: widget.theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: widget.theme.colorScheme.onSurface),
        actions: [
          if (widget.onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: widget.onRefresh,
            ),
          IconButton(
            icon: Icon(_editing ? Icons.close : Icons.edit),
            tooltip: _editing ? 'Cancel' : 'Edit Profile',
            onPressed: () => setState(() => _editing = !_editing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_editing ? 'Edit Profile' : 'My Profile',
                          style: widget.theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(email, style: widget.theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text('Personal Information',
                style: widget.theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              enabled: _editing,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              enabled: _editing,
              decoration: InputDecoration(
                labelText: 'Email',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 24),
            Text('Academic Information',
                style: widget.theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.school, color: widget.theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text('Department: $department',
                        style: widget.theme.textTheme.bodyLarge)),
                const SizedBox(width: 16),
                Icon(Icons.group, color: widget.theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text('Batch: $batch',
                        style: widget.theme.textTheme.bodyLarge)),
              ],
            ),
            const SizedBox(height: 24),
            if (_editing)
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _saveProfile,
                    icon: const Icon(Icons.save),
                    label: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() => _editing = false),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed:
                  _editing || _uploadingAvatar ? null : _pickAndUploadAvatar,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Change Profile Picture'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HOD Notifications Screen ---
class _HODNotificationsScreen extends StatefulWidget {
  final ThemeData theme;
  const _HODNotificationsScreen({required this.theme});
  @override
  State<_HODNotificationsScreen> createState() =>
      _HODNotificationsScreenState();
}

class _HODNotificationsScreenState extends State<_HODNotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _loading = true);
    try {
      _notifications = await SupabaseService.getHODNotifications();
    } catch (_) {
      _notifications = [];
    }
    setState(() => _loading = false);
  }

  void _markAsRead(String notificationId) async {
    await SupabaseService.markNotificationAsRead(notificationId);
    await _fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: widget.theme.colorScheme.surface,
        elevation: 0,
        title: Text('Notifications',
            style: widget.theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: widget.theme.colorScheme.onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('No notifications found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final n = _notifications[i];
                    final isRead = n['is_read'] == true;
                    return Card(
                      color: isRead
                          ? widget.theme.colorScheme.surface
                          : widget.theme.colorScheme.primary.withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: Icon(
                          isRead
                              ? Icons.notifications_none
                              : Icons.notifications_active,
                          color: isRead
                              ? widget.theme.colorScheme.primary
                              : Colors.red,
                        ),
                        title: Text(
                          n['title'] ?? '',
                          style: widget.theme.textTheme.titleMedium?.copyWith(
                            fontWeight:
                                isRead ? FontWeight.normal : FontWeight.bold,
                            color: isRead
                                ? widget.theme.colorScheme.onSurface
                                : widget.theme.colorScheme.primary,
                          ),
                        ),
                        subtitle: Text(
                          n['body'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: widget.theme.textTheme.bodyMedium,
                        ),
                        trailing: isRead
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.mark_email_read),
                                tooltip: 'Mark as read',
                                onPressed: () => _markAsRead(n['id']),
                              ),
                        onTap: () async {
                          if (!isRead) _markAsRead(n['id']);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(n['title'] ?? ''),
                              content: Text(n['body'] ?? ''),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

// --- HOD Help & Support Screen ---
class _HODHelpSupportScreen extends StatelessWidget {
  final ThemeData theme;
  const _HODHelpSupportScreen({required this.theme});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text('Help & Support',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Card(
            color: theme.colorScheme.surfaceVariant,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline,
                          color: theme.colorScheme.primary, size: 32),
                      const SizedBox(width: 12),
                      Text('Help & Support',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(),
                  Text(
                      'For any issues, questions, or feedback, please contact:',
                      style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.email, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('support@smartcomplaint.com',
                          style: theme.textTheme.bodyLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('+92 300 1234567', style: theme.textTheme.bodyLarge),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Frequently Asked Questions',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _FaqItem(
                      question: 'How do I view complaints?',
                      answer:
                          'Use the "Escalated Complaints" or "Update Status" options from the menu.'),
                  _FaqItem(
                      question: 'How do I update complaint status?',
                      answer:
                          'Go to "Update Status" to resolve, reject, or escalate complaints.'),
                  _FaqItem(
                      question: 'Who can I contact for urgent issues?',
                      answer:
                          'Use the contact info above or visit the admin office.'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.question_answer,
                  color: theme.colorScheme.primary, size: 18),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(question,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 2),
            child: Text(answer, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// --- Reports Screen ---
class _HODReportsScreen extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> complaints;
  final List<Map<String, dynamic>> advisors;
  final bool isLoading;
  final VoidCallback onRefresh;
  const _HODReportsScreen({
    Key? key,
    required this.theme,
    required this.complaints,
    required this.advisors,
    required this.isLoading,
    required this.onRefresh,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Calculate statistics
    final totalAdvisors = advisors.length;
    final totalComplaints = complaints.length;
    final escalated = complaints
        .where((c) =>
            (c['status']?.toString()?.toLowerCase() ?? '') == 'escalated')
        .length;
    final resolved = complaints
        .where(
            (c) => (c['status']?.toString()?.toLowerCase() ?? '') == 'resolved')
        .length;
    final pending = complaints
        .where((c) =>
            (c['status']?.toString()?.toLowerCase() ?? '') == 'pending' ||
            (c['status']?.toString()?.toLowerCase() ?? '') == 'submitted')
        .length;
    final rejected = complaints
        .where(
            (c) => (c['status']?.toString()?.toLowerCase() ?? '') == 'rejected')
        .length;
    final cardData = [
      ('Total Advisors', totalAdvisors, Icons.group, theme.colorScheme.primary),
      (
        'Total Complaints',
        totalComplaints,
        Icons.report_problem,
        theme.colorScheme.secondary
      ),
      (
        'Escalated',
        escalated,
        Icons.warning_amber_rounded,
        Colors.orange.shade400
      ),
      ('Resolved', resolved, Icons.check_circle, Colors.green.shade400),
      ('Pending', pending, Icons.pending, Colors.purple.shade400),
      ('Rejected', rejected, Icons.cancel, Colors.red.shade400),
    ];
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text('Reports',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: onRefresh,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text('System Overview',
                      style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  ListView.builder(
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
                            child: _ProgressCard(
                              label: cardData[start + i].$1,
                              value: cardData[start + i].$2,
                              icon: cardData[start + i].$3,
                              color: cardData[start + i].$4,
                              theme: theme,
                              isLoading: isLoading,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

// --- Settings Screen ---
class _HODSettingsScreen extends StatefulWidget {
  final ThemeData theme;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  const _HODSettingsScreen(
      {required this.theme,
      required this.isDarkMode,
      required this.onThemeChanged});
  @override
  State<_HODSettingsScreen> createState() => _HODSettingsScreenState();
}

class _HODSettingsScreenState extends State<_HODSettingsScreen> {
  bool _notificationsEnabled = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: widget.theme.colorScheme.surface,
        elevation: 0,
        title: Text('Settings',
            style: widget.theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: widget.theme.colorScheme.onSurface),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged,
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
            secondary: const Icon(Icons.notifications),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Smart Complaint System v1.0'),
          ),
        ],
      ),
    );
  }
}
