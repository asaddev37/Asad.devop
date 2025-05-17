import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationsRepeatedPage extends StatefulWidget {
  final bool isDarkMode;
  final Color lightModeColor;
  final Color darkModeColor;

  const NotificationsRepeatedPage({
    Key? key,
    required this.isDarkMode,
    required this.lightModeColor,
    required this.darkModeColor,
  }) : super(key: key);

  @override
  _NotificationsRepeatedPageState createState() => _NotificationsRepeatedPageState();
}

class _NotificationsRepeatedPageState extends State<NotificationsRepeatedPage> {
  final _dbHelper = DatabaseHelper.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  Map<int, List<Map<String, dynamic>>> _scheduledNotificationsByTask = {};
  Map<int, bool> _expandedTasks = {};
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadScheduledNotifications();
  }

  Future<void> _loadCategories() async {
    final categories = await _dbHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _loadScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? scheduledNotificationsJson =
    prefs.getStringList('scheduled_notifications_repeated');
    final tasks = await _dbHelper.getTasks();

    setState(() {
      if (scheduledNotificationsJson != null) {
        final notifications = scheduledNotificationsJson
            .map((json) => jsonDecode(json) as Map<String, dynamic>)
            .where((n) => DateTime.parse(n['dueDate']).isAfter(DateTime.now()))
            .toList()
          ..sort((a, b) => DateTime.parse(a['dueDate']).compareTo(DateTime.parse(b['dueDate'])));
        _scheduledNotificationsByTask = {};
        for (var notification in notifications) {
          final taskId = notification['id'] as int;
          final task = tasks.firstWhere((t) => t['id'] == taskId, orElse: () => {});
          if (task.isNotEmpty) {
            notification['categoryId'] = task['categoryId'];
            _scheduledNotificationsByTask[taskId] ??= [];
            _scheduledNotificationsByTask[taskId]!.add(notification);
          }
        }
        _expandedTasks = {for (var taskId in _scheduledNotificationsByTask.keys) taskId: false};
        _filterNotificationsByCategory();
      } else {
        _scheduledNotificationsByTask = {};
        _expandedTasks = {};
      }
    });
  }

  void _filterNotificationsByCategory() {
    if (_selectedCategory == 'All') return;
    setState(() {
      _scheduledNotificationsByTask = Map.from(_scheduledNotificationsByTask)
        ..removeWhere((taskId, notifications) {
          final categoryId = notifications.first['categoryId'];
          final category = _categories.firstWhere(
                (c) => c['id'] == categoryId,
            orElse: () => {'id': null, 'name': 'Uncategorized'},
          );
          return category['name'] != _selectedCategory;
        });
      _expandedTasks = {for (var taskId in _scheduledNotificationsByTask.keys) taskId: false};
    });
  }

  Future<void> _removeScheduledNotification(int taskId, int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
    final prefs = await SharedPreferences.getInstance();
    List<String> scheduledNotifications =
        prefs.getStringList('scheduled_notifications_repeated') ?? [];
    final instanceDate = _scheduledNotificationsByTask[taskId]
        ?.firstWhere((n) => n['notificationId'] == notificationId)['dueDate'];
    scheduledNotifications.removeWhere((taskJson) {
      final task = jsonDecode(taskJson);
      return task['notificationId'] == notificationId && task['id'] == taskId;
    });
    await prefs.setStringList('scheduled_notifications_repeated', scheduledNotifications);
    if (instanceDate != null) {
      await _dbHelper.markTaskInstanceCompleted(taskId, DateTime.parse(instanceDate));
    }
    setState(() {
      _scheduledNotificationsByTask[taskId]?.removeWhere((n) => n['notificationId'] == notificationId);
      if (_scheduledNotificationsByTask[taskId]?.isEmpty ?? true) {
        _scheduledNotificationsByTask.remove(taskId);
        _expandedTasks.remove(taskId);
      }
      _filterNotificationsByCategory();
    });
  }

  Future<void> _clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> scheduledNotifications =
        prefs.getStringList('scheduled_notifications_repeated') ?? [];
    for (var notificationJson in scheduledNotifications) {
      final notification = jsonDecode(notificationJson);
      await flutterLocalNotificationsPlugin.cancel(notification['notificationId']);
    }
    await prefs.setStringList('scheduled_notifications_repeated', []);
    setState(() {
      _scheduledNotificationsByTask.clear();
      _expandedTasks.clear();
    });
    _showSnackBar('All notifications cleared');
  }

  Future<bool> _confirmCancelNotification(int taskId, int notificationId, String title) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cancel Notification',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Cancel the notification for "$title" on ${DateFormat('EEE, MMM dd, HH:mm').format(DateTime.parse(_scheduledNotificationsByTask[taskId]!.firstWhere((n) => n['notificationId'] == notificationId)['dueDate']))}?',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 16,
            ),
          ),
          backgroundColor: widget.isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                ),
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _cancelNotification(int taskId, int notificationId, String title) async {
    final shouldCancel = await _confirmCancelNotification(taskId, notificationId, title);
    if (shouldCancel) {
      await _removeScheduledNotification(taskId, notificationId);
      _showSnackBar('Notification cancelled');
    }
  }

  Future<void> _showClearConfirmationDialog() async {
    if (_scheduledNotificationsByTask.isNotEmpty) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Clear All Notifications',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to delete all scheduled notifications?',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 16,
              ),
            ),
            backgroundColor: widget.isDarkMode ? Colors.grey[850] : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 16,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _clearAllNotifications();
                },
              ),
            ],
          );
        },
      );
    } else {
      _showSnackBar('No notifications to clear');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: widget.isDarkMode ? Colors.grey[800] : Colors.grey[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.isDarkMode
        ? [widget.darkModeColor, Colors.grey[800]!.withAlpha(77)]
        : [widget.lightModeColor, Colors.white.withAlpha(179)];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Scheduled Notifications',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: _scheduledNotificationsByTask.isNotEmpty
          ? FloatingActionButton(
        onPressed: _showClearConfirmationDialog,
        backgroundColor: widget.isDarkMode ? Colors.amber : widget.lightModeColor,
        child: const Icon(Icons.delete_sweep, color: Colors.black),
        tooltip: 'Clear All Notifications',
      )
          : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          crossFadeState: _selectedCategory != null
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            underline: const SizedBox(),
                            style: TextStyle(
                              color: widget.isDarkMode ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                            dropdownColor: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                            items: ['All', ..._categories.map((c) => c['name'] as String)]
                                .map((name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                                _loadScheduledNotifications();
                              });
                            },
                          ),
                          secondChild: const SizedBox(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: _scheduledNotificationsByTask.isEmpty
                  ? Center(
                child: AnimatedOpacity(
                  opacity: _scheduledNotificationsByTask.isEmpty ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 60,
                            color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Scheduled Notifications',
                            style: TextStyle(
                              color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: _scheduledNotificationsByTask.length,
                itemBuilder: (context, index) {
                  final taskId = _scheduledNotificationsByTask.keys.elementAt(index);
                  final notifications = _scheduledNotificationsByTask[taskId]!;
                  final taskTitle = notifications.first['title'] ?? 'Task';
                  final categoryId = notifications.first['categoryId'];
                  final category = _categories.firstWhere(
                        (c) => c['id'] == categoryId,
                    orElse: () => {'name': 'Uncategorized'},
                  );
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: widget.isDarkMode ? Colors.grey[900] : Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() =>
                              _expandedTasks[taskId] = !_expandedTasks[taskId]!),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notifications_active,
                                    color: widget.isDarkMode
                                        ? Colors.amber
                                        : widget.lightModeColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      taskTitle,
                                      style: TextStyle(
                                        color: widget.isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: _expandedTasks[taskId]! ? 0.5 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                      color: widget.isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Category: ${category['name']}',
                              style: TextStyle(
                                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 300),
                              crossFadeState: _expandedTasks[taskId]!
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: const SizedBox(),
                              secondChild: Column(
                                children: notifications.map((notification) {
                                  final dueDate = DateTime.parse(notification['dueDate']);
                                  return Dismissible(
                                    key: Key(
                                        '$taskId-${notification['notificationId']}-${dueDate.millisecondsSinceEpoch}'),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (direction) async {
                                      return await _confirmCancelNotification(
                                        notification['id'],
                                        notification['notificationId'],
                                        notification['title'] ?? 'Task',
                                      );
                                    },
                                    onDismissed: (direction) async {
                                      await _removeScheduledNotification(
                                        notification['id'],
                                        notification['notificationId'],
                                      );
                                    },
                                    background: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      child: const Icon(Icons.cancel, color: Colors.white),
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                            color: widget.isDarkMode
                                                ? Colors.amber
                                                : widget.lightModeColor,
                                            width: 4,
                                          ),
                                        ),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 12),
                                        leading: Icon(
                                          Icons.circle,
                                          size: 12,
                                          color: widget.isDarkMode
                                              ? Colors.amber
                                              : widget.lightModeColor,
                                        ),
                                        title: Text(
                                          DateFormat('EEE, MMM dd, HH:mm').format(dueDate),
                                          style: TextStyle(
                                            color: widget.isDarkMode
                                                ? Colors.white70
                                                : Colors.black54,
                                            fontSize: 16,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(
                                            Icons.cancel,
                                            color: widget.isDarkMode
                                                ? Colors.amber
                                                : Colors.redAccent,
                                          ),
                                          onPressed: () => _cancelNotification(
                                            notification['id'],
                                            notification['notificationId'],
                                            notification['title'] ?? 'Task',
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}