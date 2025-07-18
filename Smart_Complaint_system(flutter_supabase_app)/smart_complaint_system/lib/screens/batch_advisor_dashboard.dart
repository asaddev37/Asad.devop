import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../config/theme_data.dart';
import '../config/supabase_config.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/admin_theme.dart';
import 'package:image_picker/image_picker.dart';

class BatchAdvisorDashboard extends StatefulWidget {
  const BatchAdvisorDashboard({Key? key}) : super(key: key);

  @override
  State<BatchAdvisorDashboard> createState() => _BatchAdvisorDashboardState();
}

class _DrawerItem {
  final String title;
  final IconData icon;
  const _DrawerItem(this.title, this.icon);
}

class _BatchAdvisorDashboardState extends State<BatchAdvisorDashboard> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;
  bool _isLoading = true;
  Map<String, dynamic>? _advisorProfile;
  List<Map<String, dynamic>> _complaints = [];
  List<Map<String, dynamic>> _students = [];
  String? _selectedStatus;
  String? _selectedStudentId;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  List<Map<String, dynamic>> _notifications = [];
  int _unreadNotificationCount = 0;

  final List<_DrawerItem> _drawerItems = [
    _DrawerItem('Dashboard', Icons.dashboard_customize_outlined),
    _DrawerItem('View Complaints', Icons.list_alt),
    _DrawerItem('Update Status', Icons.update),
    _DrawerItem('View Students', Icons.group),
    _DrawerItem('Profile', Icons.person),
    _DrawerItem('Notifications', Icons.notifications),
    _DrawerItem('Help & Support', Icons.help_outline),
    _DrawerItem('Reports', Icons.bar_chart),
    _DrawerItem('Settings', Icons.settings),
    _DrawerItem('Logout', Icons.logout),
  ];

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadData();
    _loadNotifications();
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
      final profile = await SupabaseService.getBatchAdvisorProfile();
      final students =
          await SupabaseService.getStudentsInBatch(profile['batch_id']);
      final complaints = await SupabaseService.getBatchComplaintsFiltered(
        batchId: profile['batch_id'],
        status: _selectedStatus,
        studentId: _selectedStudentId,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      );
      setState(() {
        _advisorProfile = profile;
        _students = students;
        _complaints = complaints;
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

  Future<void> _loadNotifications() async {
    // TODO: Implement notification fetch logic
    setState(() {
      _notifications = [];
      _unreadNotificationCount = 0;
    });
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
        if (mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
      if (index == 5) await _loadNotifications();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme =
        _isDarkMode ? AdminTheme.darkTheme : AdminTheme.lightTheme;
    final advisorName = _advisorProfile?['name'] ?? 'Advisor';
    final advisorEmail = _advisorProfile?['email'] ?? 'advisor@email.com';
    final avatarLetter =
        advisorName.isNotEmpty ? advisorName[0].toUpperCase() : 'A';
    final avatarUrl = _advisorProfile?['avatar_url'] as String?;
    final isDark = _isDarkMode;
    final drawerHeaderColor = isDark
        ? currentTheme.colorScheme.surfaceVariant
        : currentTheme.colorScheme.primary;
    final department =
        _advisorProfile?['batch']?['department']?['name'] ?? 'CS';
    final batch = _advisorProfile?['batch']?['batch_name'] ?? 'N/A';

    return Theme(
      data: currentTheme,
      child: Scaffold(
        backgroundColor: currentTheme.colorScheme.background,
        appBar: AppBar(
          backgroundColor: currentTheme.colorScheme.surface,
          elevation: 0,
          title: Text(
            'Batch Advisor Dashboard',
            style: TextStyle(
              color: currentTheme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: IconThemeData(color: currentTheme.colorScheme.onSurface),
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
                currentAccountPicture: _DrawerAvatar(
                    avatarUrl: avatarUrl,
                    name: advisorName,
                    theme: currentTheme),
                accountName: Text(advisorName),
                accountEmail: Text(advisorEmail),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _drawerItems.length,
                  itemBuilder: (context, i) => ListTile(
                    leading: Stack(
                      children: [
                        Icon(_drawerItems[i].icon,
                            color: currentTheme.colorScheme.primary),
                        if (i == 5 && _unreadNotificationCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$_unreadNotificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
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
                  _BatchAdvisorDashboardHeader(
                    theme: currentTheme,
                    advisorName: advisorName,
                    batch: _advisorProfile?['batch'],
                    avatarUrl: avatarUrl,
                    onRefresh: _loadData,
                  ),
                  Expanded(
                    child: _BatchAdvisorDashboardOverview(
                      complaints: _complaints,
                      students: _students,
                      isLoading: _isLoading,
                      theme: currentTheme,
                      onQuickAction: (int index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      advisorName: advisorName,
                      department: department,
                      batch: batch,
                      onRefresh: _loadData,
                    ),
                  ),
                ],
              )
            : _getBodyWidget(currentTheme, advisorName, department, batch),
      ),
    );
  }

  Widget _getBodyWidget(
      ThemeData theme, String advisorName, String department, String batch) {
    if (_selectedIndex == 1) {
      return _ViewComplaintsWidget(
        theme: theme,
        complaints: _complaints,
        onRefresh: _loadData,
      );
    }
    if (_selectedIndex == 2) {
      return _UpdateStatusWidget(
        theme: theme,
        complaints: _complaints,
        onRefresh: _loadData,
      );
    }
    if (_selectedIndex == 3) {
      return _ViewStudentsWidget(
        theme: theme,
        students: _students,
        onRefresh: _loadData,
      );
    }
    if (_selectedIndex == 4) {
      return _ProfileScreen(
          theme: theme, profile: _advisorProfile, onRefresh: _loadData);
    }
    if (_selectedIndex == 5) {
      return _NotificationsScreen(
          theme: theme,
          notifications: _notifications,
          onRefresh: _loadNotifications);
    }
    if (_selectedIndex == 6) {
      return _HelpSupportScreen(theme: theme);
    }
    if (_selectedIndex == 7) {
      return _ReportsScreen(
        theme: theme,
        complaints: _complaints,
        students: _students,
      );
    }
    if (_selectedIndex == 8) {
      return _SettingsScreen(theme: theme);
    }
    return Center(
        child: Text('Screen for index $_selectedIndex',
            style: theme.textTheme.titleLarge));
  }
}

class _DrawerAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final ThemeData theme;
  const _DrawerAvatar(
      {required this.avatarUrl, required this.name, required this.theme});
  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
          radius: 32, backgroundImage: NetworkImage(avatarUrl!));
    }
    return CircleAvatar(
      radius: 32,
      backgroundColor: theme.colorScheme.secondary,
      child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'A',
          style: TextStyle(fontSize: 28, color: theme.colorScheme.onSecondary)),
    );
  }
}

class _BatchAdvisorDashboardHeader extends StatefulWidget {
  final ThemeData theme;
  final String advisorName;
  final Map<String, dynamic>? batch;
  final String? avatarUrl;
  final VoidCallback onRefresh;
  const _BatchAdvisorDashboardHeader({
    Key? key,
    required this.theme,
    required this.advisorName,
    required this.batch,
    required this.avatarUrl,
    required this.onRefresh,
  }) : super(key: key);
  @override
  State<_BatchAdvisorDashboardHeader> createState() =>
      _BatchAdvisorDashboardHeaderState();
}

class _BatchAdvisorDashboardHeaderState
    extends State<_BatchAdvisorDashboardHeader> {
  String? _departmentName;
  @override
  void initState() {
    super.initState();
    _fetchDepartment();
  }

  Future<void> _fetchDepartment() async {
    final batch = widget.batch;
    String? deptName = batch?['department']?['name'];
    final departmentId = batch != null ? batch['department_id'] : null;
    if (deptName == null && departmentId != null) {
      try {
        final dept = await SupabaseService.getDepartmentById(departmentId);
        setState(() => _departmentName = dept['name'] ?? '');
      } catch (_) {
        setState(() => _departmentName = '');
      }
    } else {
      setState(() => _departmentName = deptName ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final batchName = widget.batch?['batch_name'] ?? 'N/A';
    final department =
        _departmentName ?? widget.batch?['department']?['name'] ?? 'CS';
    return Card(
      color: widget.theme.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty)
              CircleAvatar(
                  radius: 28, backgroundImage: NetworkImage(widget.avatarUrl!))
            else
              CircleAvatar(
                radius: 28,
                backgroundColor: widget.theme.colorScheme.primary,
                child: Text(
                  widget.advisorName.isNotEmpty
                      ? widget.advisorName[0].toUpperCase()
                      : 'A',
                  style: TextStyle(
                      fontSize: 28,
                      color: widget.theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome,',
                      style: widget.theme.textTheme.bodyLarge?.copyWith(
                          color: widget.theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500)),
                  Text(widget.advisorName,
                      style: widget.theme.textTheme.titleLarge?.copyWith(
                          color: widget.theme.colorScheme.primary,
                          fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('Department: $department',
                        style: widget.theme.textTheme.bodyMedium?.copyWith(
                            color: widget.theme.colorScheme.onSurface
                                .withOpacity(0.7))),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('Batch: $batchName',
                        style: widget.theme.textTheme.bodyMedium?.copyWith(
                            color: widget.theme.colorScheme.onSurface
                                .withOpacity(0.7))),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: widget.onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _BatchAdvisorDashboardOverview extends StatelessWidget {
  final List<Map<String, dynamic>> complaints;
  final List<Map<String, dynamic>> students;
  final bool isLoading;
  final ThemeData theme;
  final void Function(int) onQuickAction;
  final String advisorName;
  final String department;
  final String batch;
  final VoidCallback onRefresh;

  const _BatchAdvisorDashboardOverview({
    Key? key,
    required this.complaints,
    required this.students,
    required this.isLoading,
    required this.theme,
    required this.onQuickAction,
    required this.advisorName,
    required this.department,
    required this.batch,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resolved = complaints
        .where(
            (c) => (c['status']?.toString().toLowerCase() ?? '') == 'resolved')
        .length;
    final pending = complaints
        .where(
            (c) => (c['status']?.toString().toLowerCase() ?? '') == 'pending')
        .length;
    final escalated = complaints
        .where(
            (c) => (c['status']?.toString().toLowerCase() ?? '') == 'escalated')
        .length;
    final rejected = complaints
        .where(
            (c) => (c['status']?.toString().toLowerCase() ?? '') == 'rejected')
        .length;
    final total = complaints.length;
    final totalStudents = students.length;
    final cardData = [
      (
        'Total Complaints',
        total,
        Icons.report_problem,
        theme.colorScheme.primary
      ),
      ('Resolved', resolved, Icons.check_circle, Colors.green.shade400),
      ('Pending', pending, Icons.pending, Colors.orange.shade400),
      ('Escalated', escalated, Icons.trending_up, Colors.purple.shade400),
      ('Rejected', rejected, Icons.cancel, Colors.red.shade400),
      (
        'Total Students',
        totalStudents,
        Icons.group,
        theme.colorScheme.secondary
      ),
    ];
    // Quick actions: 3 actions, 2 per row
    final quickActions = [
      QuickActionButton(
        icon: Icons.list_alt,
        label: 'View Complaints',
        color: theme.colorScheme.primary,
        onTap: () => onQuickAction(1),
      ),
      QuickActionButton(
        icon: Icons.update,
        label: 'Update Status',
        color: theme.colorScheme.secondary,
        onTap: () => onQuickAction(2),
      ),
      QuickActionButton(
        icon: Icons.group,
        label: 'View Students',
        color: theme.colorScheme.tertiary,
        onTap: () => onQuickAction(3),
      ),
    ];
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('System Overview',
                    style: theme.textTheme.titleLarge
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
                          child: ProgressCard(
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
                const SizedBox(height: 16),
                Text('Recent Activity',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                RecentActivityCard(theme: theme, complaints: complaints),
                const SizedBox(height: 16),
                Text('Quick Actions',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                // Two buttons per row
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

class _AdvisorComplaintCard extends StatefulWidget {
  final Map<String, dynamic> complaint;
  final VoidCallback onAction;
  const _AdvisorComplaintCard(
      {required this.complaint, required this.onAction});

  @override
  State<_AdvisorComplaintCard> createState() => _AdvisorComplaintCardState();
}

class _AdvisorComplaintCardState extends State<_AdvisorComplaintCard> {
  bool _expanded = false;
  bool _loadingTimeline = false;
  List<Map<String, dynamic>> _timeline = [];
  String? _timelineError;
  bool _actionLoading = false;

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

  Future<void> _handleStatusUpdate(String status,
      {bool requireComment = false, bool escalate = false}) async {
    String? comment;
    String? hodId;
    if (requireComment || escalate) {
      comment = await _showCommentDialog(
        context,
        title: escalate ? 'Escalate to HOD' : 'Add Comment',
        hint: escalate ? 'Reason for escalation' : 'Comment',
      );
      if (comment == null) return;
      if (comment.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment is required.')),
        );
        return;
      }
    }
    setState(() => _actionLoading = true);
    try {
      // If escalating, fetch the HOD for the batch's department
      if (escalate) {
        final batch = widget.complaint['batch'] ?? {};
        String? departmentId = batch['department_id'];
        if (departmentId == null && batch['department'] != null) {
          departmentId = batch['department']['id'];
        }
        if (departmentId != null) {
          final hod = await SupabaseConfig.client
              .from('profiles')
              .select('id')
              .eq('role', 'hod')
              .eq('department_id', departmentId)
              .maybeSingle();
          if (hod != null && hod['id'] != null) {
            hodId = hod['id'];
          }
        }
      }
      await SupabaseService.updateComplaint(
        complaintId: widget.complaint['id'],
        status: status,
        comment: comment,
        hodId: hodId,
      );
      widget.onAction();
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
    } finally {
      setState(() => _actionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status =
        widget.complaint['status']?.toString().toUpperCase() ?? 'UNKNOWN';
    final isEscalated = status == 'ESCALATED';
    final isResolved = status == 'RESOLVED';
    final isRejected = status == 'REJECTED';
    final isInProgress = status == 'IN PROGRESS';
    final isSubmitted = status == 'SUBMITTED';
    Color statusColor;
    if (isResolved) {
      statusColor = Colors.green;
    } else if (isEscalated) {
      statusColor = Colors.red;
    } else if (isRejected) {
      statusColor = Colors.grey;
    } else if (isInProgress) {
      statusColor = Colors.blue;
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
                Text(
                    'From: ${widget.complaint['student']?['name'] ?? 'Unknown'}'),
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
            if (!isEscalated)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (isSubmitted || isInProgress)
                        ElevatedButton.icon(
                          onPressed: _actionLoading
                              ? null
                              : () => _handleStatusUpdate('In Progress'),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('In Progress'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                        ),
                      if (isInProgress || isSubmitted)
                        ElevatedButton.icon(
                          onPressed: _actionLoading
                              ? null
                              : () => _handleStatusUpdate('Resolved',
                                  requireComment: true),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Resolve'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                        ),
                      if (isInProgress || isSubmitted)
                        ElevatedButton.icon(
                          onPressed: _actionLoading
                              ? null
                              : () => _handleStatusUpdate('Rejected',
                                  requireComment: true),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey),
                        ),
                      // Only show escalate if not resolved or rejected
                      if (!isResolved && !isRejected)
                        ElevatedButton.icon(
                          onPressed: _actionLoading
                              ? null
                              : () => _handleStatusUpdate('Escalated',
                                  escalate: true),
                          icon: const Icon(Icons.arrow_upward),
                          label: const Text('Escalate to HOD'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: OutlinedButton.icon(
                      onPressed: _actionLoading
                          ? null
                          : () => _handleStatusUpdate(
                              widget.complaint['status'],
                              requireComment: true),
                      icon: const Icon(Icons.comment),
                      label: const Text('Add Comment'),
                    ),
                  ),
                ],
              ),
            // Timeline Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  setState(() => _expanded = !_expanded);
                  if (!_expanded) return;
                  await _fetchTimeline();
                },
                icon: const Icon(Icons.timeline),
                label: Text(_expanded ? 'Hide Timeline' : 'View Timeline'),
              ),
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

  Future<String?> _showCommentDialog(BuildContext context,
      {required String title, String? hint}) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint ?? 'Comment'),
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

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const _EmptyState({required this.message, required this.icon});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 48, color: theme.colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(message,
              style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7))),
        ],
      ),
    );
  }
}

class _ViewComplaintsWidget extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> complaints;
  final VoidCallback? onRefresh;
  const _ViewComplaintsWidget(
      {required this.theme, required this.complaints, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text('View Complaints',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: onRefresh,
            ),
        ],
      ),
      body: complaints.isEmpty
          ? const _EmptyState(
              message: 'No complaints found.', icon: Icons.report_problem)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: complaints.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return _ComplaintCard(theme: theme, complaint: complaint);
              },
            ),
    );
  }
}

class _ComplaintCard extends StatefulWidget {
  final ThemeData theme;
  final Map<String, dynamic> complaint;
  const _ComplaintCard({required this.theme, required this.complaint});

  @override
  State<_ComplaintCard> createState() => _ComplaintCardState();
}

class _ComplaintCardState extends State<_ComplaintCard> {
  bool _expanded = false;
  bool _loadingTimeline = false;
  List<Map<String, dynamic>> _timeline = [];
  String? _timelineError;

  Future<void> _fetchTimeline() async {
    setState(() {
      _loadingTimeline = true;
      _timelineError = null;
    });
    try {
      // TODO: Replace with actual service call
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _timeline = [
          {
            'status': 'Submitted',
            'comment': '',
            'created_by': {'name': 'Student'},
            'created_at': widget.complaint['created_at']
          },
        ];
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

  @override
  Widget build(BuildContext context) {
    final c = widget.complaint;
    final status = c['status']?.toString().toUpperCase() ?? 'UNKNOWN';
    Color statusColor;
    switch (status) {
      case 'RESOLVED':
        statusColor = Colors.green;
        break;
      case 'ESCALATED':
        statusColor = Colors.red;
        break;
      case 'REJECTED':
        statusColor = Colors.grey;
        break;
      case 'IN PROGRESS':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }
    return Card(
      color: widget.theme.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
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
                    c['title'] ?? 'No Title',
                    style: widget.theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
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
            Text(c['description'] ?? 'No description'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 4),
                Text('From: ${c['student']?['name'] ?? 'Unknown'}'),
                const SizedBox(width: 16),
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Submitted: ${_formatDate(c['created_at'])}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (c['media_url'] != null && c['media_url'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: InkWell(
                        onTap: () => _launchUrl(c['media_url']),
                        child: Text(
                          c['media_url'],
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  setState(() => _expanded = !_expanded);
                  if (!_expanded) return;
                  await _fetchTimeline();
                },
                icon: const Icon(Icons.timeline),
                label: Text(_expanded ? 'Hide Timeline' : 'View Timeline'),
              ),
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
        final date = _formatDate(event['created_at']);
        return ListTile(
          leading: const Icon(Icons.circle, size: 16),
          title: Text('$status by $createdBy'),
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

class ProgressCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final ThemeData theme;
  final bool isLoading;
  const ProgressCard({
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

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const QuickActionButton({
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

class RecentActivityCard extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> complaints;
  const RecentActivityCard({required this.theme, required this.complaints});
  @override
  Widget build(BuildContext context) {
    final recent = complaints.take(3).toList();
    if (recent.isEmpty) {
      return Card(
        color: theme.colorScheme.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No recent activity.', style: theme.textTheme.bodyLarge),
        ),
      );
    }
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

class _UpdateStatusWidget extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> complaints;
  final VoidCallback? onRefresh;
  const _UpdateStatusWidget(
      {required this.theme, required this.complaints, this.onRefresh});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text('Update Status',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: onRefresh,
            ),
        ],
      ),
      body: complaints.isEmpty
          ? const _EmptyState(
              message: 'No complaints found.', icon: Icons.report_problem)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: complaints.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return _AdvisorComplaintCard(
                  complaint: complaint,
                  onAction: onRefresh ?? () {},
                );
              },
            ),
    );
  }
}

class _ViewStudentsWidget extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> students;
  final VoidCallback? onRefresh;
  const _ViewStudentsWidget(
      {required this.theme, required this.students, this.onRefresh});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text('View Students',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: onRefresh,
            ),
        ],
      ),
      body: students.isEmpty
          ? const _EmptyState(message: 'No students found.', icon: Icons.group)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final student = students[index];
                final name = student['name'] ?? 'Unknown';
                final email = student['email'] ?? 'No email';
                return Card(
                  color: theme.colorScheme.surfaceVariant,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(color: theme.colorScheme.onPrimary)),
                    ),
                    title: Text(name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text(email, style: theme.textTheme.bodyMedium),
                  ),
                );
              },
            ),
    );
  }
}

class _ProfileScreen extends StatefulWidget {
  final ThemeData theme;
  final Map<String, dynamic>? profile;
  final VoidCallback? onRefresh;
  const _ProfileScreen({required this.theme, this.profile, this.onRefresh});
  @override
  State<_ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<_ProfileScreen> {
  String? _departmentName;
  bool _editing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _loading = false;
  String? _avatarUrl;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.profile?['name'] ?? '');
    _emailController =
        TextEditingController(text: widget.profile?['email'] ?? '');
    _avatarUrl = widget.profile?['avatar_url'];
    _fetchDepartment();
  }

  Future<void> _fetchDepartment() async {
    final batch = widget.profile?['batch'];
    String? deptName = batch?['department']?['name'];
    final departmentId = batch != null ? batch['department_id'] : null;
    if (deptName == null && departmentId != null) {
      try {
        final dept = await SupabaseService.getDepartmentById(departmentId);
        setState(() => _departmentName = dept['name'] ?? '');
      } catch (_) {
        setState(() => _departmentName = '');
      }
    } else {
      setState(() => _departmentName = deptName ?? '');
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    try {
      await SupabaseService.updateAdvisorProfile(
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated.')));
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
        : (widget.profile?['name'] ?? 'A');
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
    final name = widget.profile?['name'] ?? 'Advisor';
    final email = widget.profile?['email'] ?? 'advisor@email.com';
    final department = _departmentName ??
        widget.profile?['batch']?['department']?['name'] ??
        'CS';
    final batch = widget.profile?['batch']?['batch_name'] ?? 'N/A';
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
      body: Center(
        child: Card(
          color: widget.theme.colorScheme.surfaceVariant,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: _editing
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              _buildAvatar(),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: _uploadingAvatar
                                      ? null
                                      : _pickAndUploadAvatar,
                                  borderRadius: BorderRadius.circular(20),
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor:
                                        widget.theme.colorScheme.primary,
                                    child: const Icon(Icons.camera_alt,
                                        size: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _nameController,
                                  decoration:
                                      const InputDecoration(labelText: 'Name'),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: _emailController,
                                  decoration:
                                      const InputDecoration(labelText: 'Email'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Department: $department',
                          style: widget.theme.textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text('Batch: $batch',
                          style: widget.theme.textTheme.bodyLarge),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _loading ? null : _saveProfile,
                            icon: const Icon(Icons.save),
                            label: _loading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
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
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              _buildAvatar(),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: _uploadingAvatar
                                      ? null
                                      : _pickAndUploadAvatar,
                                  borderRadius: BorderRadius.circular(20),
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor:
                                        widget.theme.colorScheme.primary,
                                    child: const Icon(Icons.camera_alt,
                                        size: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: widget.theme.textTheme.titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(email,
                                    style: widget.theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Department: $department',
                          style: widget.theme.textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text('Batch: $batch',
                          style: widget.theme.textTheme.bodyLarge),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _NotificationsScreen extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> notifications;
  final VoidCallback? onRefresh;
  const _NotificationsScreen(
      {required this.theme, required this.notifications, this.onRefresh});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text('Notifications',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: onRefresh,
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const _EmptyState(
              message: 'No notifications found.', icon: Icons.notifications)
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final n = notifications[i];
                final isRead = n['is_read'] == true;
                return Card(
                  color: isRead
                      ? theme.colorScheme.surface
                      : theme.colorScheme.primary.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: Icon(
                      isRead
                          ? Icons.notifications_none
                          : Icons.notifications_active,
                      color: isRead ? theme.colorScheme.primary : Colors.red,
                    ),
                    title: Text(
                      n['title'] ?? '',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isRead ? FontWeight.normal : FontWeight.bold,
                        color: isRead
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.primary,
                      ),
                    ),
                    subtitle: Text(
                      n['body'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _HelpSupportScreen extends StatelessWidget {
  final ThemeData theme;
  const _HelpSupportScreen({required this.theme});
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
                          'Use the "View Complaints" option from the menu.'),
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

class _ReportsScreen extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> complaints;
  final List<Map<String, dynamic>> students;
  const _ReportsScreen(
      {required this.theme, required this.complaints, required this.students});
  @override
  Widget build(BuildContext context) {
    final total = complaints.length;
    final resolved = complaints
        .where(
            (c) => (c['status']?.toString().toLowerCase() ?? '') == 'resolved')
        .length;
    final pending = complaints
        .where(
            (c) => (c['status']?.toString().toLowerCase() ?? '') == 'pending')
        .length;
    final escalated = complaints
        .where(
            (c) => (c['status']?.toString().toLowerCase() ?? '') == 'escalated')
        .length;
    final rejected = complaints
        .where(
            (c) => (c['status']?.toString().toLowerCase() ?? '') == 'rejected')
        .length;
    final totalStudents = students.length;
    final List<Map<String, dynamic>> stats = [
      {
        'label': 'Total Complaints',
        'value': total,
        'icon': Icons.report_problem,
        'color': theme.colorScheme.primary
      },
      {
        'label': 'Resolved',
        'value': resolved,
        'icon': Icons.check_circle,
        'color': Colors.green.shade400
      },
      {
        'label': 'Pending',
        'value': pending,
        'icon': Icons.pending,
        'color': Colors.orange.shade400
      },
      {
        'label': 'Escalated',
        'value': escalated,
        'icon': Icons.trending_up,
        'color': Colors.purple.shade400
      },
      {
        'label': 'Rejected',
        'value': rejected,
        'icon': Icons.cancel,
        'color': Colors.red.shade400
      },
      {
        'label': 'Total Students',
        'value': totalStudents,
        'icon': Icons.group,
        'color': theme.colorScheme.secondary
      },
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('System Summary',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (stats.length / 2).ceil(),
              itemBuilder: (context, index) {
                final start = index * 2;
                final end = start + 2 > stats.length ? stats.length : start + 2;
                return Row(
                  children: List.generate(
                    end - start,
                    (i) => Expanded(
                      child: ProgressCard(
                        label: stats[start + i]['label'],
                        value: stats[start + i]['value'],
                        icon: stats[start + i]['icon'],
                        color: stats[start + i]['color'],
                        theme: theme,
                        isLoading: false,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Card(
              color: theme.colorScheme.surfaceVariant,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.bar_chart,
                        color: theme.colorScheme.primary, size: 40),
                    const SizedBox(height: 16),
                    Text('Detailed reports and export features coming soon!',
                        style: theme.textTheme.titleLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  final ThemeData theme;
  const _SettingsScreen({required this.theme});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text('Settings',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Center(
        child: Card(
          color: theme.colorScheme.surfaceVariant,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings,
                    color: theme.colorScheme.primary, size: 40),
                const SizedBox(height: 16),
                Text('Settings feature coming soon!',
                    style: theme.textTheme.titleLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
