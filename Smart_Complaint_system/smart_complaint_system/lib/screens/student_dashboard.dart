import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/complaint_form.dart';
import '../widgets/complaint_tile.dart';
import '../models/complaint.dart';
import '../models/user_profile.dart';
import '../config/theme_data.dart';
import '../utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/admin_theme.dart'; // Reuse AdminTheme for now
import 'package:image_picker/image_picker.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;
  bool _isLoading = true;
  Map<String, dynamic>? _studentProfile;
  List<Map<String, dynamic>> _complaints = [];
  List<Map<String, dynamic>> _pendingComplaints = [];
  List<Map<String, dynamic>> _resolvedComplaints = [];
  String? _selectedFilter;
  bool _showComplaintForm = false;
  List<Map<String, dynamic>> _notifications = [];
  int _unreadNotificationCount = 0;

  final List<_DrawerItem> _drawerItems = [
    _DrawerItem('Dashboard', Icons.dashboard_customize_outlined),
    _DrawerItem('Send Complaint', Icons.send),
    _DrawerItem('View All Complaints', Icons.list_alt),
    _DrawerItem('Profile', Icons.person),
    _DrawerItem('Notifications', Icons.notifications),
    _DrawerItem('Help & Support', Icons.help_outline),
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
      final profile = await SupabaseService.getStudentProfile();
      final complaints = await SupabaseService.getStudentComplaints();

      // Debug: Print profile data to understand structure
      print('Student Profile: $profile');
      print('Batch ID: ${profile['batch_id']}');
      print('Batch Data: ${profile['batch']}');
      if (profile['batch'] != null) {
        print('Department Data: ${profile['batch']['department']}');
        print('Advisor Data: ${profile['batch']['advisor']}');
      }

      setState(() {
        _studentProfile = profile;
        _complaints = complaints;
        _pendingComplaints =
            complaints.where((c) => c['status'] == 'pending').toList();
        _resolvedComplaints =
            complaints.where((c) => c['status'] == 'resolved').toList();
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
    try {
      final notifications = await SupabaseService.getStudentNotifications();
      final unreadCount =
          notifications.where((n) => n['is_read'] == false).length;
      setState(() {
        _notifications = notifications;
        _unreadNotificationCount = unreadCount;
      });
    } catch (e) {
      setState(() {
        _notifications = [];
        _unreadNotificationCount = 0;
      });
    }
  }

  void _markNotificationAsRead(String notificationId) async {
    await SupabaseService.markNotificationAsRead(notificationId);
    await _loadNotifications();
  }

  void _showAddComplaintForm() {
    setState(() => _showComplaintForm = true);
  }

  void _hideComplaintForm() {
    setState(() => _showComplaintForm = false);
  }

  Future<void> _onComplaintSubmitted() async {
    _hideComplaintForm();
    await _loadData(); // Reload data after submitting complaint
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _onDrawerItemTap(int index) async {
    if (index == 6) {
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
        // TODO: Add real logout logic
        if (mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
      if (index == 4) await _loadNotifications();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme =
        _isDarkMode ? AdminTheme.darkTheme : AdminTheme.lightTheme;
    final studentName = _studentProfile?['name'] ?? 'Student';
    final studentEmail = _studentProfile?['email'] ?? 'student@email.com';
    final avatarLetter =
        studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S';
    final avatarUrl = _studentProfile?['avatar_url'] as String?;
    final isDark = _isDarkMode;
    final drawerHeaderColor = isDark
        ? currentTheme.colorScheme.surfaceVariant
        : currentTheme.colorScheme.primary;

    // Extract department and batch safely
    String department = 'CS';
    final batchMap = _studentProfile?['batch'] as Map<String, dynamic>?;
    if (batchMap != null) {
      final deptMap = batchMap['department'] as Map<String, dynamic>?;
      if (deptMap != null &&
          deptMap['name'] != null &&
          deptMap['name'].toString().trim().isNotEmpty) {
        department = deptMap['name'];
      }
    }
    debugPrint('StudentDashboardHeader - Using department: $department');
    final batch = batchMap?['batch_name'] ?? 'N/A';

    return Theme(
      data: currentTheme,
      child: Scaffold(
        backgroundColor: currentTheme.colorScheme.background,
        appBar: AppBar(
          backgroundColor: currentTheme.colorScheme.surface,
          elevation: 0,
          title: Text(
            'Student Dashboard',
            style: TextStyle(
              color: currentTheme.colorScheme.onSurface,
              fontSize: 20,
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
              onPressed: () => _onDrawerItemTap(6),
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
                    name: studentName,
                    theme: currentTheme),
                accountName: Text(studentName),
                accountEmail: Text(studentEmail),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _drawerItems.length,
                  itemBuilder: (context, i) => ListTile(
                    leading: Stack(
                      children: [
                        Icon(_drawerItems[i].icon,
                            color: currentTheme.colorScheme.primary),
                        if (i == 4 && _unreadNotificationCount > 0)
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
        body: _getBodyWidget(
            currentTheme, studentName, department, batch, avatarUrl),
      ),
    );
  }

  Widget _getBodyWidget(ThemeData theme, String studentName, String department,
      String batch, String? avatarUrl) {
    final studentId = _studentProfile?['id'] ?? '';
    final batchId = _studentProfile?['batch']?['id'] ?? '';
    final advisorId = _studentProfile?['batch']?['advisor']?['id'] ?? '';
    switch (_selectedIndex) {
      case 1:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ComplaintForm(
            studentId: studentId,
            batchId: batchId,
            advisorId: advisorId,
            onSubmit: _onComplaintSubmitted,
            onCancel: () {
              setState(() {
                _selectedIndex = 0;
              });
            },
            hideBatchFields: true,
            cancelTextColor: theme.colorScheme.primary,
          ),
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: _ViewComplaintsWidget(theme: theme, complaints: _complaints),
        );
      case 3:
        return StudentProfileScreen(
          profile: _studentProfile,
          theme: theme,
          onProfileUpdated: _loadData,
        );
      case 4:
        return NotificationScreen(
          theme: theme,
          notifications: _notifications,
          onMarkRead: _markNotificationAsRead,
        );
      case 5:
        return HelpSupportScreen(theme: theme);
      default:
        return Column(
          children: [
            _StudentDashboardHeader(
              theme: theme,
              studentName: studentName,
              department: department,
              batch: batch,
              avatarUrl: avatarUrl,
              onRefresh: _loadData,
            ),
            Expanded(
              child: _StudentDashboardOverview(
                complaints: _complaints,
                isLoading: _isLoading,
                theme: theme,
                onQuickAction: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                studentName: studentName,
                department: department,
                batch: batch,
                onRefresh: _loadData,
              ),
            ),
          ],
        );
    }
  }
}

class _DrawerItem {
  final String title;
  final IconData icon;
  const _DrawerItem(this.title, this.icon);
}

class _StudentDashboardOverview extends StatelessWidget {
  final List<Map<String, dynamic>> complaints;
  final bool isLoading;
  final ThemeData theme;
  final void Function(int) onQuickAction;
  final String studentName;
  final String department;
  final String batch;
  final VoidCallback? onRefresh;
  const _StudentDashboardOverview({
    required this.complaints,
    required this.isLoading,
    required this.theme,
    required this.onQuickAction,
    required this.studentName,
    required this.department,
    required this.batch,
    this.onRefresh,
  });
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
    final cardData = [
      ('Total', total, Icons.report_problem, theme.colorScheme.primary),
      ('Resolved', resolved, Icons.check_circle, Colors.green.shade400),
      ('Pending', pending, Icons.pending, Colors.orange.shade400),
      ('Escalated', escalated, Icons.trending_up, Colors.purple.shade400),
      ('Rejected', rejected, Icons.cancel, Colors.red.shade400),
    ];
    return SingleChildScrollView(
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
              final end =
                  start + 2 > cardData.length ? cardData.length : start + 2;
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
          const SizedBox(height: 16),
          Text('Recent Activity',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          _RecentActivityCard(theme: theme, complaints: complaints),
          const SizedBox(height: 16),
          Text('Quick Actions',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickActionButton(
                icon: Icons.send,
                label: 'Send Complaint',
                color: theme.colorScheme.primary,
                onTap: () => onQuickAction(1),
              ),
              _QuickActionButton(
                icon: Icons.list_alt,
                label: 'View Complaints',
                color: theme.colorScheme.secondary,
                onTap: () => onQuickAction(2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudentDashboardHeader extends StatelessWidget {
  final ThemeData theme;
  final String studentName;
  final String department;
  final String batch;
  final String? avatarUrl;
  final VoidCallback? onRefresh;
  const _StudentDashboardHeader(
      {required this.theme,
      required this.studentName,
      required this.department,
      required this.batch,
      required this.avatarUrl,
      this.onRefresh});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            if (avatarUrl != null && avatarUrl!.isNotEmpty)
              CircleAvatar(
                  radius: 28, backgroundImage: NetworkImage(avatarUrl!))
            else
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
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
                  Text(studentName,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('Batch: $batch',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.7))),
                  ),
                ],
              ),
            ),
            if (onRefresh != null)
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
  const _QuickActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      this.onTap});
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
        color: theme.colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No recent activity.', style: theme.textTheme.bodyMedium),
        ),
      );
    }
    final last = complaints.last;
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last Complaint:',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Subject: ${last['title'] ?? 'N/A'}',
                style: theme.textTheme.bodyMedium),
            Text('Status: ${last['status'] ?? 'N/A'}',
                style: theme.textTheme.bodyMedium),
            Text('Date: ${last['created_at'] ?? 'N/A'}',
                style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ViewComplaintsWidget extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> complaints;
  const _ViewComplaintsWidget(
      {Key? key, required this.theme, required this.complaints})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (complaints.isEmpty) {
      return Center(
        child: Text('No complaints found.', style: theme.textTheme.bodyLarge),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Text('My Complaints',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: complaints.length,
            itemBuilder: (context, i) {
              final c = complaints[i];
              return _ComplaintWithTimelineCard(complaint: c, theme: theme);
            },
          ),
        ),
      ],
    );
  }
}

class _ComplaintWithTimelineCard extends StatefulWidget {
  final Map<String, dynamic> complaint;
  final ThemeData theme;
  const _ComplaintWithTimelineCard(
      {required this.complaint, required this.theme});

  @override
  State<_ComplaintWithTimelineCard> createState() =>
      _ComplaintWithTimelineCardState();
}

class _ComplaintWithTimelineCardState
    extends State<_ComplaintWithTimelineCard> {
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

  @override
  Widget build(BuildContext context) {
    final c = widget.complaint;
    return Card(
      color: widget.theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title:
            Text(c['title'] ?? '', style: widget.theme.textTheme.titleMedium),
        subtitle: Text(
            'Status: ${c['status'] ?? ''}\nDate: ${c['created_at'] ?? ''}',
            style: widget.theme.textTheme.bodyMedium),
        trailing: _statusChip(c['status'], widget.theme),
        onExpansionChanged: (expanded) {
          setState(() {
            _expanded = expanded;
          });
          if (expanded && _timeline.isEmpty && !_loadingTimeline) {
            _fetchTimeline();
          }
        },
        children: [
          if (_expanded)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                color: widget.theme.colorScheme.surfaceVariant,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((c['media_url'] ?? '').toString().isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.link, size: 18),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () async {
                                final url = c['media_url'];
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url),
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Text(
                                'Google Drive Link',
                                style:
                                    widget.theme.textTheme.bodyLarge?.copyWith(
                                  color: widget.theme.colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if ((c['media_url'] ?? '').toString().isNotEmpty)
                        const SizedBox(height: 8),
                      Text('Description:',
                          style: widget.theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(c['description'] ?? '-',
                          style: widget.theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text('Status Info:',
                          style: widget.theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Current Status: ${c['status'] ?? '-'}',
                          style: widget.theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ),
          if (_loadingTimeline)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_timelineError != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Failed to load timeline: \\$_timelineError',
                  style: TextStyle(color: Colors.red)),
            )
          else if (_timeline.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('No timeline events.'),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _timeline
                    .map((event) =>
                        _TimelineEventTile(event: event, theme: widget.theme))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusChip(String? status, ThemeData theme) {
    Color color;
    switch (status) {
      case 'resolved':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'escalated':
        color = Colors.purple;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = theme.colorScheme.primary;
    }
    return Chip(
      label: Text(status?.toUpperCase() ?? '',
          style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}

class _TimelineEventTile extends StatelessWidget {
  final Map<String, dynamic> event;
  final ThemeData theme;
  const _TimelineEventTile({required this.event, required this.theme});

  @override
  Widget build(BuildContext context) {
    final status = event['status'] ?? '';
    final comment = event['comment'] ?? '';
    final createdBy = event['created_by']?['name'] ?? 'Unknown';
    final role = event['created_by']?['role'] ?? '';
    final createdAt = event['created_at'] ?? '';
    return ListTile(
      leading: const Icon(Icons.timeline),
      title: Text('$status by $createdBy ($role)',
          style: theme.textTheme.bodyLarge),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (comment.isNotEmpty) Text('Comment: $comment'),
          Text('At: $createdAt', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ProfileWidget extends StatelessWidget {
  final ThemeData theme;
  final Map<String, dynamic>? profile;
  const _ProfileWidget({Key? key, required this.theme, required this.profile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile', style: theme.textTheme.headlineMedium),
    );
  }
}

class _NotificationsWidget extends StatelessWidget {
  final ThemeData theme;
  const _NotificationsWidget({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Notifications', style: theme.textTheme.headlineMedium),
    );
  }
}

class _HelpSupportWidget extends StatelessWidget {
  final ThemeData theme;
  const _HelpSupportWidget({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Help & Support', style: theme.textTheme.headlineMedium),
    );
  }
}

class _ComplaintHistoryCard extends StatefulWidget {
  final Map<String, dynamic> complaint;
  const _ComplaintHistoryCard({required this.complaint});

  @override
  State<_ComplaintHistoryCard> createState() => _ComplaintHistoryCardState();
}

class _ComplaintHistoryCardState extends State<_ComplaintHistoryCard> {
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

  @override
  Widget build(BuildContext context) {
    final status =
        widget.complaint['status']?.toString().toUpperCase() ?? 'UNKNOWN';
    final isResolved = status == 'RESOLVED';
    final isEscalated = status == 'ESCALATED';
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
    // Handler logic
    String handler = 'Advisor';
    if (isEscalated || widget.complaint['hod_id'] != null) {
      handler = 'HOD';
    } else if (widget.complaint['advisor_id'] == null) {
      handler = 'N/A';
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Batch Info Section
            if (widget.complaint['batch'] != null) ...[
              Text('Batch Information',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor)),
              const SizedBox(height: 4),
              _batchInfoRow(Icons.numbers, 'Batch',
                  widget.complaint['batch']['batch_name'] ?? 'N/A'),
              _batchInfoRow(
                  Icons.person,
                  'Advisor',
                  widget.complaint['batch']['advisor']?['name'] ??
                      'Not Assigned'),
              _batchInfoRow(
                  Icons.school,
                  'HOD',
                  widget.complaint['batch']['department']?['hod']?['name'] ??
                      'Not Assigned'),
              const SizedBox(height: 8),
            ],
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
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 4),
                Text('Handler: $handler'),
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
            AnimatedCrossFade(
              firstChild: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    setState(() => _expanded = true);
                    await _fetchTimeline();
                  },
                  icon: const Icon(Icons.timeline),
                  label: const Text('View Timeline'),
                ),
              ),
              secondChild: _loadingTimeline
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
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            if (_expanded)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() => _expanded = false),
                  icon: const Icon(Icons.close),
                  label: const Text('Hide Timeline'),
                ),
              ),
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

  Widget _batchInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Student Profile Screen ---
class StudentProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? profile;
  final ThemeData theme;
  final VoidCallback? onProfileUpdated;
  const StudentProfileScreen(
      {Key? key, this.profile, required this.theme, this.onProfileUpdated})
      : super(key: key);
  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
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
  }

  @override
  void didUpdateWidget(covariant StudentProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile != oldWidget.profile) {
      _nameController.text = widget.profile?['name'] ?? '';
      _emailController.text = widget.profile?['email'] ?? '';
      _avatarUrl = widget.profile?['avatar_url'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isEditing = false);
    try {
      await SupabaseService.updateStudentProfile(
        userId: widget.profile?['id'],
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        avatarUrl: _avatarUrl,
      );
      if (widget.onProfileUpdated != null) widget.onProfileUpdated!();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile updated!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickAvatar() async {
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
        : (widget.profile?['name'] ?? 'S');
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
    final theme = widget.theme;
    final profile = widget.profile ?? {};
    final department = profile['batch']?['department']?['name'] ?? 'CS';
    final batch = profile['batch']?['batch_name'] ?? 'N/A';
    return Center(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      _buildAvatar(),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _uploadingAvatar ? null : _pickAvatar,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: theme.colorScheme.surface,
                            child: Icon(Icons.camera_alt,
                                size: 16, color: theme.colorScheme.primary),
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
                        Text(_isEditing ? 'Edit Profile' : 'My Profile',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Text(profile['email'] ?? '',
                            style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isEditing ? Icons.save : Icons.edit,
                        color: theme.colorScheme.primary),
                    tooltip: _isEditing ? 'Save' : 'Edit',
                    onPressed: () {
                      if (_isEditing) {
                        _saveProfile();
                      } else {
                        setState(() => _isEditing = true);
                      }
                    },
                  ),
                  if (_isEditing)
                    IconButton(
                      icon: Icon(Icons.cancel, color: Colors.red),
                      tooltip: 'Cancel',
                      onPressed: () => setState(() => _isEditing = false),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Personal Information',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 24),
              Text('Academic Information',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.school, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text('Department: $department',
                          style: theme.textTheme.bodyLarge)),
                  const SizedBox(width: 16),
                  Icon(Icons.group, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text('Batch: $batch',
                          style: theme.textTheme.bodyLarge)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Help & Support Screen ---
class HelpSupportScreen extends StatelessWidget {
  final ThemeData theme;
  const HelpSupportScreen({Key? key, required this.theme}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
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
              Text('For any issues, questions, or feedback, please contact:',
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
                  question: 'How do I send a complaint?',
                  answer: 'Use the "Send Complaint" option from the menu.'),
              _FaqItem(
                  question: 'How do I view my complaint status?',
                  answer:
                      'Go to "View All Complaints" to see the status and timeline of your complaints.'),
              _FaqItem(
                  question: 'Who can I contact for urgent issues?',
                  answer:
                      'Use the contact info above or visit the admin office.'),
            ],
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

// --- Notification Screen ---
class NotificationScreen extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> notifications;
  final void Function(String notificationId) onMarkRead;
  const NotificationScreen(
      {Key? key,
      required this.theme,
      required this.notifications,
      required this.onMarkRead})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child:
            Text('No notifications found.', style: theme.textTheme.bodyLarge),
      );
    }
    return ListView.separated(
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: Icon(
              isRead ? Icons.notifications_none : Icons.notifications_active,
              color: isRead ? theme.colorScheme.primary : Colors.red,
            ),
            title: Text(
              n['title'] ?? '',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
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
            trailing: isRead
                ? null
                : IconButton(
                    icon: const Icon(Icons.mark_email_read),
                    tooltip: 'Mark as read',
                    onPressed: () => onMarkRead(n['id']),
                  ),
            onTap: () async {
              if (!isRead) onMarkRead(n['id']);
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
    );
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
      child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'S',
          style: TextStyle(fontSize: 28, color: theme.colorScheme.onSecondary)),
    );
  }
}
