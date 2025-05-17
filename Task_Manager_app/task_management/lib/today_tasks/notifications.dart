import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationsPage extends StatefulWidget {
  final bool isDarkMode;
  final Color lightModeColor;
  final Color darkModeColor;

  const NotificationsPage({
    Key? key,
    required this.isDarkMode,
    required this.lightModeColor,
    required this.darkModeColor,
  }) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _dbHelper = DatabaseHelper.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  List<Map<String, dynamic>> _scheduledTasks = [];
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadScheduledTasks();
  }

  Future<void> _loadCategories() async {
    final categories = await _dbHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _loadScheduledTasks() async {
    final tasks = await _dbHelper.getTasks();
    final prefs = await SharedPreferences.getInstance();
    List<String>? scheduledNotifications = prefs.getStringList('scheduled_notifications');

    setState(() {
      _scheduledTasks = tasks
          .where((task) =>
      task['isCompleted'] == 0 &&
          DateTime.parse(task['dueDate']).isAfter(DateTime.now()))
          .toList();

      if (scheduledNotifications != null) {
        _scheduledTasks = _scheduledTasks.where((task) {
          return scheduledNotifications.any((notificationJson) {
            final notification = jsonDecode(notificationJson);
            return notification['id'] == task['id'];
          });
        }).toList();
      }

      // Sort tasks by dueDate (earliest first)
      _scheduledTasks.sort((a, b) => DateTime.parse(a['dueDate']).compareTo(DateTime.parse(b['dueDate'])));
    });
  }

  Future<void> _removeScheduledNotification(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> scheduledNotifications = prefs.getStringList('scheduled_notifications') ?? [];
    scheduledNotifications.removeWhere((taskJson) {
      final task = jsonDecode(taskJson);
      return task['id'] == id;
    });
    await prefs.setStringList('scheduled_notifications', scheduledNotifications);
    await flutterLocalNotificationsPlugin.cancel(id);
    await _loadScheduledTasks(); // Ensure UI updates after removal
  }

  Future<void> _clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    for (var task in _scheduledTasks) {
      await _removeScheduledNotification(task['id']);
    }
    await prefs.setStringList('scheduled_notifications', []);
    _loadScheduledTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'All notifications cleared',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: widget.isDarkMode ? Colors.grey[800] : Colors.grey[300],
      ),
    );
  }

  Future<bool> _confirmCancelNotification(int id) async {
    final task = _scheduledTasks.firstWhere((t) => t['id'] == id, orElse: () => {'title': 'Task'});
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cancel Notification?',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel the notification for "${task['title']}"?',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          backgroundColor: widget.isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false); // Do not dismiss
              },
            ),
            TextButton(
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm dismissal
              },
            ),
          ],
        );
      },
    ) ?? false; // Default to false if dialog is dismissed without choice
  }

  Future<void> _cancelNotification(int id) async {
    final shouldCancel = await _confirmCancelNotification(id);
    if (shouldCancel) {
      await _removeScheduledNotification(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Notification cancelled',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: widget.isDarkMode ? Colors.grey[800] : Colors.grey[300],
        ),
      );
    }
  }

  Future<void> _showClearConfirmationDialog() async {
    if (_scheduledTasks.isNotEmpty) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Clear All Notifications?',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            content: Text(
              'Are you sure you want to delete all scheduled notifications?',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            backgroundColor: widget.isDarkMode ? Colors.grey[850] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _clearAllNotifications();
                },
              ),
            ],
          );
        },
      );
    } else {
      _loadScheduledTasks();
    }
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
            fontSize: 20,
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: widget.isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: _showClearConfirmationDialog,
            tooltip: 'Refresh and Clear',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _scheduledTasks.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off,
                size: 80,
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(height: 16),
              Text(
                'No scheduled notifications',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _scheduledTasks.length,
          itemBuilder: (context, index) {
            final task = _scheduledTasks[index];
            final dueDate = DateTime.parse(task['dueDate']);
            return Dismissible(
              key: Key(task['id'].toString()),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await _confirmCancelNotification(task['id']);
              },
              onDismissed: (direction) async {
                await _removeScheduledNotification(task['id']);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Notification cancelled',
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: widget.isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  ),
                );
              },
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.cancel, color: Colors.white),
              ),
              child: Card(
                elevation: 6,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: widget.isDarkMode
                            ? widget.darkModeColor.withAlpha(204)
                            : widget.lightModeColor.withAlpha(204),
                        child: Icon(
                          Icons.alarm,
                          color: widget.isDarkMode ? Colors.white : Colors.black87,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task['title'] ?? 'Task',
                              style: TextStyle(
                                color: widget.isDarkMode ? Colors.white : Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              task['description'] ?? '',
                              style: TextStyle(
                                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Due: ${DateFormat('MMM dd, yyyy HH:mm').format(dueDate)}',
                              style: TextStyle(
                                color: widget.isDarkMode ? Colors.amber : Colors.blueAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Category: ${_categories.firstWhere((c) => c['id'] == task['categoryId'], orElse: () => {'name': 'Uncategorized'})['name']}',
                              style: TextStyle(
                                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.redAccent),
                        onPressed: () => _cancelNotification(task['id']),
                        tooltip: 'Cancel Notification',
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}