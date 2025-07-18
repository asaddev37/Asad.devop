import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../repeated_tasks/detail_repeated_task.dart';
import '../repeated_tasks/edit_repeated_task.dart';
import '../repeated_tasks/notifications_repeated.dart';
import '../repeated_tasks/add_repeated_task.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class RepeatedTasksPage extends StatefulWidget {
  final bool isDarkMode;
  final Color lightModeColor;
  final Color darkModeColor;
  final bool notificationsEnabled;
  final VoidCallback? onRefreshNeeded;

  const RepeatedTasksPage({
    Key? key,
    required this.isDarkMode,
    required this.lightModeColor,
    required this.darkModeColor,
    required this.notificationsEnabled,
    this.onRefreshNeeded,
  }) : super(key: key);

  @override
  RepeatedTasksPageState createState() => RepeatedTasksPageState();
}

class RepeatedTasksPageState extends State<RepeatedTasksPage> {
  final _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategory = 'All';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  Timer? _debounce;
  bool _isLoading = false;
  bool _isTodayView = true;
  String _sortBy = 'dueDate';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
    _loadCategories();
    _loadTasks();
    if (widget.notificationsEnabled) {
      _restoreScheduledNotifications();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    if (widget.notificationsEnabled) {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        if (granted != true) {
          _showSnackBar('Notification permission denied.');
        }
        final exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();
        if (exactAlarmGranted != true) {
          _showSnackBar('Exact alarm permission denied.');
        }
      }
      await _restoreScheduledNotifications();
    }
  }
  Future<void> _scheduleNextInstance(Map<String, dynamic> task, DateTime currentInstanceDate) async {
    final repeatDays = task['repeatDays'].split(',').asMap();
    final dueTime = DateTime.parse(task['dueDate']);

    // Find the next occurrence after the current instance
    DateTime? nextInstance;
    for (int i = 0; i < 7; i++) {
      if (repeatDays[i] == '1') {
        // Calculate the next occurrence after current instance
        final candidate = _getNextOccurrence(
            currentInstanceDate.add(Duration(seconds: 1)), i, dueTime.hour, dueTime.minute);
        if (nextInstance == null || candidate.isBefore(nextInstance)) {
          nextInstance = candidate;
        }
      }
    }

    if (nextInstance != null) {
      // Schedule the next instance
      await _dbHelper.insertTaskInstance({
        'taskId': task['id'],
        'dueDate': nextInstance.toIso8601String(),
        'isCompleted': 0,
      });

      if (widget.notificationsEnabled) {
        const androidDetails = AndroidNotificationDetails(
          'repeated_task_channel_id',
          'Repeated Task Reminders',
          channelDescription: 'Notifications for repeated task reminders',
          importance: Importance.max,
          priority: Priority.high,
          enableLights: true,
          playSound: true,
        );
        const notificationDetails = NotificationDetails(android: androidDetails);

        await flutterLocalNotificationsPlugin.zonedSchedule(
          task['id'] * 1000 + nextInstance.weekday % 7,
          task['title'] ?? 'Task',
          task['description'] ?? '',
          tz.TZDateTime.from(nextInstance, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          payload: jsonEncode({'id': task['id'], 'date': nextInstance.toIso8601String()}),
        );
      }
    }
  }

  Future<void> _navigateToTaskDetail(int taskId) async {
    final task = await _dbHelper.getTaskById(taskId);
    if (task != null && mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) => DetailRepeatedTasksPage(
            task: task,
            isDarkMode: widget.isDarkMode,
            lightModeColor: widget.lightModeColor,
            darkModeColor: widget.darkModeColor,
            onEdit: _editTask,
            onDelete: _deleteTask,
            onComplete: _markInstanceAsCompleted,
            isTodayView: _isTodayView,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    } else if (mounted) {
      _showSnackBar('Task not found');
    }
  }

  static DateTime _getNextOccurrence(DateTime fromDate, int dayIndex, int hour, int minute) {
    int targetWeekday = (dayIndex + 1) % 7;
    if (targetWeekday == 0) targetWeekday = 7;

    // Calculate days until next occurrence
    int daysUntilNext = ((targetWeekday - fromDate.weekday + 7) % 7);

    // If it's the same day but time hasn't passed yet, return today
    if (daysUntilNext == 0) {
      final todayOccurrence = DateTime(fromDate.year, fromDate.month, fromDate.day, hour, minute);
      if (todayOccurrence.isAfter(fromDate)) {
        return todayOccurrence;
      }
    }

    // Calculate the next occurrence
    DateTime nextOccurrence = DateTime(fromDate.year, fromDate.month, fromDate.day + daysUntilNext, hour, minute);

    // If the calculated time is still in the past (can happen if we're checking late in the day)
    if (nextOccurrence.isBefore(fromDate)) {
      nextOccurrence = nextOccurrence.add(const Duration(days: 7));
    }

    return nextOccurrence;
  }

  DateTime _getEarliestNextOccurrence(Map<String, dynamic> task) {
    final repeatDays = task['repeatDays'].split(',').asMap();
    final dueTime = DateTime.parse(task['dueDate']);
    final now = DateTime.now();
    DateTime? earliestDate;

    for (int i = 0; i < 7; i++) {
      if (repeatDays[i] == '1') {
        final nextOccurrence = _getNextOccurrence(now, i, dueTime.hour, dueTime.minute);
        if (earliestDate == null || nextOccurrence.isBefore(earliestDate)) {
          earliestDate = nextOccurrence;
        }
      }
    }
    return earliestDate ?? DateTime.now().add(const Duration(days: 365)); // Fallback
  }

  Future<void> _scheduleAllNotifications(Map<String, dynamic> task) async {
    if (!widget.notificationsEnabled) return;
    final prefs = await SharedPreferences.getInstance();
    List<String> scheduledNotifications =
        prefs.getStringList('scheduled_notifications_repeated') ?? [];
    scheduledNotifications.removeWhere((json) => jsonDecode(json)['id'] == task['id']);

    final repeatDays = task['repeatDays'].split(',').asMap();
    final dueTime = DateTime.parse(task['dueDate']);
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      if (repeatDays[i] == '1') {
        for (int week = 0; week < 4; week++) {
          final nextDate =
          _getNextOccurrence(now, i, dueTime.hour, dueTime.minute).add(Duration(days: week * 7));
          if (nextDate.isAfter(now)) {
            final notificationId = task['id'] * 1000 + i * 10 + week;
            scheduledNotifications.add(jsonEncode({
              'id': task['id'],
              'notificationId': notificationId,
              'title': task['title'],
              'description': task['description'],
              'dueDate': nextDate.toIso8601String(),
              'repeatDay': i,
            }));

            const androidDetails = AndroidNotificationDetails(
              'repeated_task_channel_id',
              'Repeated Task Reminders',
              channelDescription: 'Notifications for repeated task reminders',
              importance: Importance.max,
              priority: Priority.high,
              enableLights: true,
              playSound: true,
            );
            const notificationDetails = NotificationDetails(android: androidDetails);
            await flutterLocalNotificationsPlugin.zonedSchedule(
              notificationId,
              task['title'] ?? 'Task',
              task['description'] ?? '',
              tz.TZDateTime.from(nextDate, tz.local),
              notificationDetails,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
              payload: jsonEncode({'id': task['id'], 'date': nextDate.toIso8601String()}),
            );

            await _dbHelper.insertTaskInstance({
              'taskId': task['id'],
              'dueDate': nextDate.toIso8601String(),
              'isCompleted': 0,
            });
          }
        }
      }
    }
    await prefs.setStringList('scheduled_notifications_repeated', scheduledNotifications);
  }

  Future<void> _restoreScheduledNotifications() async {
    if (!widget.notificationsEnabled) return;
    final prefs = await SharedPreferences.getInstance();
    List<String>? scheduledNotifications =
    prefs.getStringList('scheduled_notifications_repeated');
    if (scheduledNotifications != null) {
      for (String taskJson in scheduledNotifications) {
        Map<String, dynamic> task = jsonDecode(taskJson);
        final dueDate = DateTime.parse(task['dueDate']);
        if (dueDate.isAfter(DateTime.now())) {
          const androidDetails = AndroidNotificationDetails(
            'repeated_task_channel_id',
            'Repeated Task Reminders',
            channelDescription: 'Notifications for repeated task reminders',
            importance: Importance.max,
            priority: Priority.high,
            enableLights: true,
            playSound: true,
          );
          const notificationDetails = NotificationDetails(android: androidDetails);
          await flutterLocalNotificationsPlugin.zonedSchedule(
            task['notificationId'],
            task['title'] ?? 'Task',
            task['description'] ?? '',
            tz.TZDateTime.from(dueDate, tz.local),
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
            payload: jsonEncode({'id': task['id'], 'date': task['dueDate']}),
          );
        }
      }
    }
  }

  Future<void> _removeAllScheduledNotifications(int taskId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> scheduledNotifications =
        prefs.getStringList('scheduled_notifications_repeated') ?? [];
    scheduledNotifications.removeWhere((taskJson) {
      final task = jsonDecode(taskJson);
      return task['id'] == taskId;
    });
    await prefs.setStringList('scheduled_notifications_repeated', scheduledNotifications);
    for (int i = 0; i < 7; i++) {
      for (int week = 0; week < 4; week++) {
        await flutterLocalNotificationsPlugin.cancel(taskId * 1000 + i * 10 + week);
      }
    }
    await _dbHelper.deleteTaskInstances(taskId);
  }

  Future<void> _loadCategories() async {
    final categories = await _dbHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<List<Map<String, dynamic>>> _filterTasks(List<Map<String, dynamic>> tasks,
      {String? searchQuery}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filteredTasks = await compute(_filterTasksIsolate, {
      'tasks': tasks,
      'categories': _categories,
      'selectedCategory': _selectedCategory,
      'isTodayView': _isTodayView,
      'today': today.toIso8601String(),
      'searchQuery': searchQuery,
    });

    filteredTasks.sort((a, b) {
      if (_sortBy == 'dueDate') {
        final aDue = _getEarliestNextOccurrence(a);
        final bDue = _getEarliestNextOccurrence(b);
        return aDue.compareTo(bDue);
      } else {
        return (a['title'] as String).compareTo(b['title'] as String);
      }
    });

    return filteredTasks;
  }

  static List<Map<String, dynamic>> _filterTasksIsolate(Map<String, dynamic> params) {
    final List<Map<String, dynamic>> tasks = params['tasks'] as List<Map<String, dynamic>>;
    final List<Map<String, dynamic>> categories = params['categories'] as List<Map<String, dynamic>>;
    final String selectedCategory = params['selectedCategory'] as String;
    final bool isTodayView = params['isTodayView'] as bool;
    final DateTime today = DateTime.parse(params['today'] as String);
    final String? searchQuery = params['searchQuery'] as String?;
    final List<Map<String, dynamic>> instances = (params['instances'] as List<Map<String, dynamic>>)
        .where((inst) => inst['isDeleted'] != 1)
        .toList();
    final now = DateTime.now();

    print('[DEBUG] Filtering tasks - Today view: $isTodayView, Selected category: $selectedCategory');
    print('[DEBUG] Current date/time: ${now.toString()}');
    print('[DEBUG] Today date: ${today.toString()}');
    print('[DEBUG] Total tasks: ${tasks.length}, Total instances: ${instances.length}');

    List<Map<String, dynamic>> filteredTasks = [];

    for (var task in tasks) {
      final bool isRepeatedAndActive = task['isRepeated'] == 1 && task['isCompleted'] == 0;
      if (!isRepeatedAndActive) {
        print('[DEBUG] Task ${task['id']} skipped - not repeated or not active');
        continue;
      }

      final matchesSearch = searchQuery == null ||
          searchQuery.isEmpty ||
          task['title'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          task['description'].toString().toLowerCase().contains(searchQuery.toLowerCase());

      if (!matchesSearch) {
        print('[DEBUG] Task ${task['id']} skipped - doesn\'t match search query');
        continue;
      }

      final repeatDays = task['repeatDays'].split(',').asMap();
      final dueTime = DateTime.parse(task['dueDate']);
      bool hasTodayInstance = false;
      bool isTodayInstanceCompleted = false;
      bool hasFutureInstance = false;
      DateTime? nextInstanceDate;

      for (int i = 0; i < 7; i++) {
        if (repeatDays[i] == '1') {
          int targetWeekday = (i + 1) % 7;
          if (targetWeekday == 0) targetWeekday = 7;
          int daysUntilNext = ((targetWeekday - now.weekday + 7) % 7);
          final nextOccurrence =
          DateTime(now.year, now.month, now.day + daysUntilNext, dueTime.hour, dueTime.minute);

          // Check if this is today's instance
          if (nextOccurrence.day == today.day &&
              nextOccurrence.month == today.month &&
              nextOccurrence.year == today.year) {
            final instance = instances.firstWhere(
                  (inst) =>
              inst['taskId'] == task['id'] &&
                  DateTime.parse(inst['dueDate']).day == today.day &&
                  DateTime.parse(inst['dueDate']).month == today.month &&
                  DateTime.parse(inst['dueDate']).year == today.year &&
                  inst['isDeleted'] != 1,
              orElse: () => <String, dynamic>{},
            );
            hasTodayInstance = instance.isNotEmpty || nextOccurrence.isAfter(now);
            isTodayInstanceCompleted = instance.isNotEmpty && instance['isCompleted'] == 1;
          }

          // Check for future instances (including today if it hasn't passed yet)
          if (nextOccurrence.isAfter(now) ||
              (nextOccurrence.day == now.day &&
                  nextOccurrence.month == now.month &&
                  nextOccurrence.year == now.year)) {
            hasFutureInstance = true;
            if (nextInstanceDate == null || nextOccurrence.isBefore(nextInstanceDate)) {
              nextInstanceDate = nextOccurrence;
            }
          }
        }
      }

      if (isTodayView) {
        // For Today view - show tasks with today's instance that aren't completed
        if (hasTodayInstance && !isTodayInstanceCompleted) {
          if (_matchesCategory(task, categories, selectedCategory)) {
            filteredTasks.add(task);
          }
        }
      } else {
        // For Future view - only show tasks that:
        // 1. Don't have today's instance, AND
        // 2. Have future instances

        bool hasTodayInstance = false;
        bool hasFutureInstance = false;

        for (int i = 0; i < 7; i++) {
          if (repeatDays[i] == '1') {
            int targetWeekday = (i + 1) % 7;
            if (targetWeekday == 0) targetWeekday = 7;
            int daysUntilNext = ((targetWeekday - now.weekday + 7) % 7);
            DateTime nextOccurrence =
            DateTime(now.year, now.month, now.day + daysUntilNext, dueTime.hour, dueTime.minute);

            // Check if this is today's instance
            if (nextOccurrence.day == today.day &&
                nextOccurrence.month == today.month &&
                nextOccurrence.year == today.year) {
              final instance = instances.firstWhere(
                    (inst) =>
                inst['taskId'] == task['id'] &&
                    DateTime.parse(inst['dueDate']).day == today.day &&
                    DateTime.parse(inst['dueDate']).month == today.month &&
                    DateTime.parse(inst['dueDate']).year == today.year &&
                    inst['isDeleted'] != 1,
                orElse: () => <String, dynamic>{},
              );
              hasTodayInstance = instance.isNotEmpty || nextOccurrence.isAfter(now);
            }

            // Check for future instances (after today)
            if (nextOccurrence.isAfter(today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)))) {
              hasFutureInstance = true;
            }
          }
        }

        print('[DEBUG] Task ${task['id']} future check:');
        print('[DEBUG] - Has today instance: $hasTodayInstance');
        print('[DEBUG] - Has future instance: $hasFutureInstance');

        if (hasFutureInstance && _matchesCategory(task, categories, selectedCategory)) {
          filteredTasks.add(task);
        }
      }
    }
    return filteredTasks;
  }

  static bool _matchesCategory(
      Map<String, dynamic> task,
      List<Map<String, dynamic>> categories,
      String selectedCategory) {
    if (selectedCategory == 'All') return true;

    Map<String, dynamic>? category;
    if (categories.isNotEmpty) {
      category = categories.firstWhere(
            (c) => c['id'] == task['categoryId'],
        orElse: () => <String, dynamic>{},
      );
      if (category.isEmpty) {
        category = {'id': null, 'name': 'Uncategorized'};
      }
    } else {
      category = {'id': null, 'name': 'Uncategorized'};
    }

    final categoryName = category['name'] as String;
    return categoryName == selectedCategory;
  }

  Future<void> _loadTasks({String? searchQuery}) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    setState(() {
      _isLoading = true;
    });
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        print('[DEBUG] Starting task load - Today view: $_isTodayView');
        final List<Map<String, dynamic>> tasks = await _dbHelper.getTasks();
        final List<Map<String, dynamic>> allInstances = await _dbHelper.getTaskInstances();
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        print('[DEBUG] Raw tasks from DB: ${tasks.length}');
        print('[DEBUG] Raw instances from DB: ${allInstances.length}');

        final filteredTasks = await compute(_filterTasksIsolate, {
          'tasks': tasks,
          'categories': _categories,
          'selectedCategory': _selectedCategory,
          'isTodayView': _isTodayView,
          'today': today.toIso8601String(),
          'searchQuery': searchQuery,
          'instances': allInstances,
        });

        print('[DEBUG] Filtered tasks count: ${filteredTasks.length}');
        filteredTasks.forEach((task) {
          print('[DEBUG] Filtered task: ${task['id']} - ${task['title']}');
        });

        filteredTasks.sort((a, b) {
          if (_sortBy == 'dueDate') {
            final aDue = _getEarliestNextOccurrence(a);
            final bDue = _getEarliestNextOccurrence(b);
            print('[DEBUG] Sorting by date - ${a['id']}: $aDue vs ${b['id']}: $bDue');
            return aDue.compareTo(bDue);
          } else {
            print('[DEBUG] Sorting by title - ${a['title']} vs ${b['title']}');
            return (a['title'] as String).compareTo(b['title'] as String);
          }
        });

        if (mounted) {
          setState(() {
            _tasks = filteredTasks;
            _isLoading = false;
          });
          print('[DEBUG] Task list updated in UI');
        }
      } catch (e) {
        print('[ERROR] Error loading tasks: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar('Failed to load tasks');
        }
      }
    });
  }

  void refresh() async {
    await _loadCategories();
    await _loadTasks();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: widget.isDarkMode ? Colors.grey[800] : Colors.grey[300],
      ),
    );
  }

  void _showCategoriesForAdd() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDarkMode
                ? [widget.darkModeColor.withAlpha(230), Colors.grey[900]!]
                : [widget.lightModeColor.withAlpha(230), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _categories.isEmpty
            ? Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No categories yet! Add some in the menu.',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        )
            : ListView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          children: _categories.map((category) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AddRepeatedTaskPage(
                          isDarkMode: widget.isDarkMode,
                          lightModeColor: widget.lightModeColor,
                          darkModeColor: widget.darkModeColor,
                          categoryId: category['id'],
                          notificationsEnabled: widget.notificationsEnabled,
                          onTaskAdded: (task) async {
                            final int? id = await _dbHelper.insertTask(task);
                            if (id != null && id > 0) {
                              final Map<String, dynamic> scheduledTask =
                              Map<String, dynamic>.from(task);
                              scheduledTask['id'] = id;
                              if (widget.notificationsEnabled) {
                                await _scheduleAllNotifications(scheduledTask);
                              }
                              _loadTasks();
                              return id;
                            }
                            return null;
                          },
                        ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                          position: offsetAnimation, child: child);
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isDarkMode
                    ? Colors.grey[800]!.withAlpha(230)
                    : Colors.grey[200]!.withAlpha(230),
                foregroundColor: widget.isDarkMode ? Colors.white : Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: Text(
                category['name'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _editTask(Map<String, dynamic> task, {bool fromDetail = false}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => EditRepeatedTasksPage(
          task: task,
          isDarkMode: widget.isDarkMode,
          lightModeColor: widget.lightModeColor,
          darkModeColor: widget.darkModeColor,
          notificationsEnabled: widget.notificationsEnabled,
          onTaskUpdated: (updatedTask) async {
            await _dbHelper.updateTask(updatedTask);
            await _removeAllScheduledNotifications(updatedTask['id']);
            if (updatedTask['isCompleted'] == 0 && widget.notificationsEnabled) {
              await _scheduleAllNotifications(updatedTask);
            }
            _loadTasks();
            if (fromDetail) Navigator.pop(context);
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _markInstanceAsCompleted(int id, {bool fromDetail = false}) async {
    final now = DateTime.now();
    final task = await _dbHelper.getTaskById(id);
    if (task == null) {
      _showSnackBar('Task not found');
      return;
    }

    final repeatDays = task['repeatDays'].split(',').asMap();
    final dueTime = DateTime.parse(task['dueDate']);
    DateTime? currentDueDate;

    for (int i = 0; i < 7; i++) {
      if (repeatDays[i] == '1') {
        final candidate = _getNextOccurrence(now, i, dueTime.hour, dueTime.minute);
        if (candidate.weekday == now.weekday &&
            candidate.hour == dueTime.hour &&
            candidate.minute == dueTime.minute) {
          currentDueDate = DateTime(now.year, now.month, now.day, dueTime.hour, dueTime.minute);
          break;
        }
      }
    }

    if (currentDueDate == null) {
      DateTime? nextDueDate;
      for (int i = 0; i < 7; i++) {
        if (repeatDays[i] == '1') {
          final candidate = _getNextOccurrence(now, i, dueTime.hour, dueTime.minute);
          if (nextDueDate == null || candidate.isBefore(nextDueDate)) {
            nextDueDate = candidate;
          }
        }
      }
      _showSnackBar(
        'Cannot mark as completed yet. Wait until ${DateFormat('EEE, MMM dd, HH:mm').format(nextDueDate!)}.',
      );
      return;
    }

    if (now.isBefore(currentDueDate)) {
      _showSnackBar(
        'Cannot mark as completed yet. Wait until ${DateFormat('HH:mm').format(currentDueDate)} today.',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm Completion',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Mark this instance as completed? It will recur on the next scheduled day.',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Perform database operations
              await _dbHelper.markTaskInstanceCompleted(id, currentDueDate!);
              final task = await _dbHelper.getTaskById(id);
              if (task != null && task['isCompleted'] == 0) {
                await _scheduleNextInstance(task, currentDueDate);
              }
              // Close the dialog first
              Navigator.pop(dialogContext);
              // Show snackbar and refresh tasks after dialog is closed
              if (mounted) {
                _showSnackBar('Instance marked as completed successfully!');
                await _loadTasks();
              }
            },
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteTask(int id, {bool fromDetail = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm Delete',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this task and all its instances?',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteTask(id);
              await _removeAllScheduledNotifications(id);
              _showSnackBar('Task deleted successfully');
              _loadTasks();
              Navigator.pop(context);
              if (fromDetail) Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportTasks() async {
    final tasks = await _dbHelper.getTasks();
    List<List<dynamic>> csvData = [
      ['ID', 'Title', 'Description', 'Time', 'Repeat Days', 'Completed', 'Category'],
      ...tasks.where((task) => task['isRepeated'] == 1).map((task) {
        final repeatDaysString = task['repeatDays']?.toString() ?? '0,0,0,0,0,0,0';
        final repeatDays = repeatDaysString
            .split(',')
            .asMap()
            .map((i, value) => MapEntry(
            i,
            value == '1' ? DateFormat.E().format(DateTime(2023, 1, i + 2)) : ''))
            .values
            .where((day) => day.isNotEmpty)
            .join(', ');

        String categoryName = 'Uncategorized';
        if (task['categoryId'] != null && _categories.isNotEmpty) {
          final category = _categories.firstWhere(
                (c) => c['id'] == task['categoryId'],
            orElse: () => <String, dynamic>{},
          );
          if (category.isNotEmpty) {
            categoryName = category['name'] as String;
          }
        }

        return [
          task['id'],
          task['title'],
          task['description'],
          DateFormat('HH:mm').format(DateTime.parse(task['dueDate'])),
          repeatDays,
          task['isCompleted'],
          categoryName,
        ];
      }),
    ];

    String csv = const ListToCsvConverter().convert(csvData);
    final path = await getTemporaryDirectory();
    final file = File('${path.path}/repeated_tasks.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'My Repeated Tasks');
    _showSnackBar('Tasks exported successfully');
  }

  void _navigateToDetail(Map<String, dynamic> task) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => DetailRepeatedTasksPage(
          task: task,
          isDarkMode: widget.isDarkMode,
          lightModeColor: widget.lightModeColor,
          darkModeColor: widget.darkModeColor,
          onEdit: _editTask,
          onDelete: _deleteTask,
          onComplete: _markInstanceAsCompleted,
          isTodayView: _isTodayView,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1500),
        pageBuilder: (context, animation, secondaryAnimation) => NotificationsRepeatedPage(
          isDarkMode: widget.isDarkMode,
          lightModeColor: widget.lightModeColor,
          darkModeColor: widget.darkModeColor,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.1);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  String _getNextDueDate(Map<String, dynamic> task) {
    final repeatDays = task['repeatDays'].split(',').asMap();
    final dueTime = DateTime.parse(task['dueDate']);
    final now = DateTime.now();
    DateTime? nextDate;
    for (int i = 0; i < 7; i++) {
      if (repeatDays[i] == '1') {
        final candidate = _getNextOccurrence(now, i, dueTime.hour, dueTime.minute);
        if (nextDate == null || candidate.isBefore(nextDate)) {
          nextDate = candidate;
        }
      }
    }
    return nextDate != null ? DateFormat('EEE, MMM dd, HH:mm').format(nextDate) : 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.isDarkMode
        ? [widget.darkModeColor, Colors.grey[100]!.withAlpha(78)]
        : [widget.lightModeColor, Colors.white.withAlpha(179)];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Tooltip(
                message: 'Show today\'s repeated task instances',
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isTodayView = true;
                      _loadTasks(searchQuery: _searchController.text);
                    });
                  },
                  icon: Icon(
                    Icons.today,
                    color: _isTodayView
                        ? (widget.isDarkMode ? Colors.white : Colors.black87)
                        : (widget.isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                  label: Text(
                    'Today',
                    style: TextStyle(
                      color: _isTodayView
                          ? (widget.isDarkMode ? Colors.white : Colors.black87)
                          : (widget.isDarkMode ? Colors.white70 : Colors.black54),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTodayView
                        ? (widget.isDarkMode ? widget.darkModeColor : widget.lightModeColor)
                        : (widget.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: _isTodayView
                            ? (widget.isDarkMode ? Colors.white70 : Colors.black54)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    elevation: _isTodayView ? 6 : 2,
                    shadowColor: widget.isDarkMode ? Colors.black54 : Colors.grey[400],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SearchBar(
                    controller: _searchController,
                    hintText: _isTodayView ? 'Search today...' : 'Search future...',
                    hintStyle: WidgetStateProperty.resolveWith<TextStyle?>(
                          (states) => TextStyle(
                        color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    textStyle: WidgetStateProperty.resolveWith<TextStyle?>(
                          (states) => TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    onChanged: (query) {
                      setState(() => _isSearching = query.isNotEmpty);
                      _loadTasks(searchQuery: query);
                    },
                    trailing: _isSearching
                        ? [
                      IconButton(
                        icon: Icon(Icons.close,
                            color: widget.isDarkMode ? Colors.white70 : Colors.black54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _isSearching = false);
                          _loadTasks();
                        },
                      )
                    ]
                        : null,
                    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (states) => widget.isDarkMode
                          ? Colors.grey[850]!.withAlpha(128)
                          : Colors.grey[200]!,
                    ),
                    surfaceTintColor: WidgetStateProperty.resolveWith<Color?>(
                          (states) => Colors.transparent,
                    ),
                    elevation: WidgetStateProperty.all(0),
                    side: WidgetStateProperty.resolveWith<BorderSide?>(
                          (states) => BorderSide(
                        color: widget.isDarkMode ? Colors.grey[700]! : Colors.grey[400]!,
                        width: 1,
                      ),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              Tooltip(
                message: 'Show upcoming repeated task instances',
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isTodayView = false;
                      _loadTasks(searchQuery: _searchController.text);
                    });
                  },
                  icon: Icon(
                    Icons.upcoming,
                    color: !_isTodayView
                        ? (widget.isDarkMode ? Colors.white : Colors.black87)
                        : (widget.isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                  label: Text(
                    'Future',
                    style: TextStyle(
                      color: !_isTodayView
                          ? (widget.isDarkMode ? Colors.white : Colors.black87)
                          : (widget.isDarkMode ? Colors.white70 : Colors.black54),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isTodayView
                        ? (widget.isDarkMode ? widget.darkModeColor : widget.lightModeColor)
                        : (widget.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: !_isTodayView
                            ? (widget.isDarkMode ? Colors.white70 : Colors.black54)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    elevation: !_isTodayView ? 6 : 2,
                    shadowColor: widget.isDarkMode ? Colors.black54 : Colors.grey[400],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryButton('All'),
                  ..._categories.map((cat) => _buildCategoryButton(cat['name'])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButton<String>(
                      value: _sortBy,
                      items: [
                        DropdownMenuItem(value: 'dueDate', child: Text('Sort by Date')),
                        DropdownMenuItem(value: 'title', child: Text('Sort by Title')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                          _loadTasks(searchQuery: _searchController.text);
                        });
                      },
                      style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
                      dropdownColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 3),
          Expanded(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.isDarkMode ? Colors.white70 : widget.lightModeColor,
                ),
              ),
            )
                : _tasks.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.repeat,
                    size: 80,
                    color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isTodayView ? 'No repeated tasks for today!' : 'No repeated tasks!',
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _tasks.length,
              cacheExtent: 9999,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final repeatDaysString =
                    task['repeatDays']?.toString() ?? '0,0,0,0,0,0,0';
                final repeatDays = repeatDaysString
                    .split(',')
                    .asMap()
                    .map((i, value) => MapEntry(
                    i,
                    value == '1'
                        ? DateFormat.E().format(DateTime(2023, 1, i + 2))
                        : ''))
                    .values
                    .where((day) => day.isNotEmpty)
                    .join(', ');
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    title: Text(
                      task['title'] ?? '',
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      _isTodayView
                          ? 'Time: ${DateFormat('HH:mm').format(DateTime.parse(task['dueDate']))}\nRepeat: $repeatDays'
                          : 'Time: ${DateFormat('HH:mm').format(DateTime.parse(task['dueDate']))}\nRepeat: $repeatDays\nNext: ${_getNextDueDate(task)}',
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    onTap: () => _navigateToDetail(task),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: 'Edit task',
                          child: IconButton(
                            icon: Icon(Icons.edit,
                                color: widget.isDarkMode
                                    ? Colors.blueGrey
                                    : Colors.blueAccent),
                            onPressed: () => _editTask(task),
                          ),
                        ),
                        if (_isTodayView) // Show only in Today view
                          Tooltip(
                            message: 'Mark today\'s instance as completed',
                            child: IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () => _markInstanceAsCompleted(task['id']),
                            ),
                          ),
                        Tooltip(
                          message: 'Delete task and all instances',
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteTask(task['id']),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Tooltip(
                  message: 'Add task in category',
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.add,
                        color: widget.isDarkMode ? Colors.white : Colors.black87),
                    label: Text(
                      'Add',
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _showCategoriesForAdd,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                      backgroundColor:
                      widget.isDarkMode ? widget.darkModeColor : widget.lightModeColor,
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Export tasks',
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.share,
                        color: widget.isDarkMode ? Colors.white : Colors.black),
                    label: Text(
                      'Export',
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    onPressed: _exportTasks,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      widget.isDarkMode ? widget.darkModeColor : widget.lightModeColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                Tooltip(
                  message: 'upcoming notifications',
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.notifications,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                    label: Text(
                      '',
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    onPressed: _navigateToNotifications,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      widget.isDarkMode ? widget.darkModeColor : widget.lightModeColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String categoryName) {
    final isSelected = _selectedCategory == categoryName;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedCategory = categoryName;
            _loadTasks(searchQuery: _searchController.text);
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? (widget.isDarkMode ? widget.darkModeColor : widget.lightModeColor)
              : (widget.isDarkMode ? Colors.grey[700] : Colors.grey[300]),
          foregroundColor: widget.isDarkMode ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: isSelected ? 4 : 2,
        ),
        child: Text(
          categoryName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}