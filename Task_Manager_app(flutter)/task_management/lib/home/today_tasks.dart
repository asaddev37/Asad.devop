import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import '../today_tasks/add_tasks.dart';
import '../today_tasks/edit_tasks.dart';
import '../today_tasks/detail_tasks.dart';
import '../today_tasks/notifications.dart';
import '../database_helper.dart';

class TodayTasksPage extends StatefulWidget {
  final bool isDarkMode;
  final Color lightModeColor;
  final Color darkModeColor;
  final bool notificationsEnabled;
  final String? initialNotificationPayload;
  final VoidCallback? onRefreshNeeded;

  TodayTasksPage({
    Key? key,
    required this.isDarkMode,
    required this.lightModeColor,
    required this.darkModeColor,
    required this.notificationsEnabled,
    this.initialNotificationPayload,
    this.onRefreshNeeded,
  }) : super(key: key);

  @override
  TodayTasksPageState createState() => TodayTasksPageState();
}

class TodayTasksPageState extends State<TodayTasksPage> {
  final _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategory = 'All';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _hasHandledInitialNotification = false;
  bool _isTodayView = true; // Toggle between Today (true) and Future (false)
  String _sortBy = 'dueDate'; // Sorting option for both views (dueDate or title)
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasHandledInitialNotification && mounted) {
        _handleInitialNotification();
        _hasHandledInitialNotification = true;
      }
    });
  }

  Future<void> _handleInitialNotification() async {
    if (widget.initialNotificationPayload != null &&
        widget.initialNotificationPayload!.isNotEmpty && mounted) {
      final taskId = int.tryParse(widget.initialNotificationPayload!);
      if (taskId != null && taskId > 0) {
        await _navigateToTaskDetail(taskId);
      } else {
        _showSnackBar('Invalid notification payload received');
      }
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          final taskId = int.tryParse(response.payload!);
          if (taskId != null) {
            await _navigateToTaskDetail(taskId);
          }
        }
      },
    );

    if (widget.notificationsEnabled) {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        if (granted != true) {
          _showSnackBar(
              'Notification permission denied. Please enable it in settings.');
        }

        final exactAlarmGranted = await androidPlugin
            .requestExactAlarmsPermission();
        if (exactAlarmGranted != true) {
          _showSnackBar(
              'Exact alarm permission denied. Notifications may not work.');
        }
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
          pageBuilder: (context, animation, secondaryAnimation) =>
              DetailTasksPage(
                task: task,
                isDarkMode: widget.isDarkMode,
                lightModeColor: widget.lightModeColor,
                darkModeColor: widget.darkModeColor,
                onEdit: _editTask,
                onDelete: _deleteTask,
                onComplete: _isTodayView
                    ? _markAsCompleted
                    : null, // Disable completion in Future view
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    } else if (mounted) {
      _showSnackBar('Task not found');
    }
  }

  Future<void> _saveScheduledNotification(Map<String, dynamic> task) async {
    if (!widget.notificationsEnabled) return;
    final prefs = await SharedPreferences.getInstance();
    List<String> scheduledNotifications = prefs.getStringList(
        'scheduled_notifications') ?? [];
    scheduledNotifications.removeWhere((taskJson) {
      final existingTask = jsonDecode(taskJson);
      return existingTask['id'] == task['id'];
    });
    scheduledNotifications.add(jsonEncode(task));
    await prefs.setStringList(
        'scheduled_notifications', scheduledNotifications);

    const androidDetails = AndroidNotificationDetails(
      'task_channel_id',
      'Task Reminders',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      playSound: true,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task['id'] as int,
      task['title'] as String? ?? 'Task',
      task['description'] as String? ?? '',
      tz.TZDateTime.from(DateTime.parse(task['dueDate'] as String), tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
          .absoluteTime,
      payload: task['id'].toString(),
    );
  }

  Future<void> _restoreScheduledNotifications() async {
    if (!widget.notificationsEnabled) return;
    final prefs = await SharedPreferences.getInstance();
    List<String>? scheduledNotifications = prefs.getStringList(
        'scheduled_notifications');
    if (scheduledNotifications != null) {
      for (String taskJson in scheduledNotifications) {
        Map<String, dynamic> task = jsonDecode(taskJson);
        final dueDate = DateTime.parse(task['dueDate'] as String);
        if (dueDate.isAfter(DateTime.now()) && task['isCompleted'] == 0) {
          const androidDetails = AndroidNotificationDetails(
            'task_channel_id',
            'Task Reminders',
            channelDescription: 'Notifications for task reminders',
            importance: Importance.max,
            priority: Priority.high,
            enableLights: true,
            playSound: true,
          );
          const notificationDetails = NotificationDetails(
              android: androidDetails);
          await flutterLocalNotificationsPlugin.zonedSchedule(
            task['id'] as int,
            task['title'] as String? ?? 'Task',
            task['description'] as String? ?? '',
            tz.TZDateTime.from(dueDate, tz.local),
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
                .absoluteTime,
            payload: task['id'].toString(),
          );
        }
      }
    }
  }

  Future<void> _removeScheduledNotification(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> scheduledNotifications = prefs.getStringList(
        'scheduled_notifications') ?? [];
    scheduledNotifications.removeWhere((taskJson) {
      final task = jsonDecode(taskJson);
      return task['id'] == id;
    });
    await prefs.setStringList(
        'scheduled_notifications', scheduledNotifications);
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> _loadCategories() async {
    final categories = await _dbHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _loadTasks({String? searchQuery}) async {
    final tasks = await _dbHelper.getTasks();
    final today = DateTime.now();

    setState(() {
      _tasks = tasks.where((task) {
        // Search filter
        final matchesSearch = searchQuery == null || searchQuery.isEmpty ||
            task['title'].toString().toLowerCase().contains(
                searchQuery.toLowerCase()) ||
            task['description'].toString().toLowerCase().contains(
                searchQuery.toLowerCase());

        // Date filter
        final dueDate = DateTime.parse(task['dueDate']);
        bool dateCondition = _isTodayView
            ? (dueDate.day == today.day && dueDate.month == today.month &&
            dueDate.year == today.year)
            : dueDate.isAfter(today);

        return task['isCompleted'] == 0 &&
            task['isRepeated'] == 0 &&
            dateCondition &&
            matchesSearch &&
            (_selectedCategory == 'All' ||
                (_categories.any((c) => c['id'] == task['categoryId']) &&
                    _categories.firstWhere((c) =>
                    c['id'] == task['categoryId'])['name'] ==
                        _selectedCategory));
      }).toList();

      // Sort tasks for both Today and Future views
      _tasks.sort((a, b) {
        if (_sortBy == 'dueDate') {
          return DateTime.parse(a['dueDate']).compareTo(
              DateTime.parse(b['dueDate']));
        } else {
          return (a['title'] as String).compareTo(b['title'] as String);
        }
      });
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
              color: widget.isDarkMode ? Colors.white : Colors.black87),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: widget.isDarkMode ? Colors.grey[800] : Colors
            .grey[300],
      ),
    );
  }

  void _showCategoriesForAdd() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDarkMode
                    ? [widget.darkModeColor.withAlpha(230), Colors.grey[900]!]
                    : [widget.lightModeColor.withAlpha(230), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20)),
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
              children: _categories.map((category) =>
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                                milliseconds: 400),
                            pageBuilder: (context, animation,
                                secondaryAnimation) =>
                                AddTasksPage(
                                  isDarkMode: widget.isDarkMode,
                                  lightModeColor: widget.lightModeColor,
                                  darkModeColor: widget.darkModeColor,
                                  categoryId: category['id'],
                                  notificationsEnabled: widget
                                      .notificationsEnabled,
                                  onTaskAdded: (task) async {
                                    try {
                                      final int? id = await _dbHelper
                                          .insertTask(task);
                                      if (id != null && id > 0) {
                                        final Map<String,
                                            dynamic> scheduledTask = Map.from(
                                            task);
                                        scheduledTask['id'] = id;
                                        if (widget.notificationsEnabled) {
                                          await _saveScheduledNotification(
                                              scheduledTask);
                                        }
                                        await _loadTasks();
                                        return id;
                                      } else {
                                        throw Exception(
                                            'Invalid ID returned: $id');
                                      }
                                    } catch (e) {
                                      print('Error in onTaskAdded: $e');
                                      rethrow;
                                    }
                                  },
                                ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end).chain(
                                  CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(
                                  position: offsetAnimation, child: child);
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isDarkMode ? Colors.grey[800]!
                            .withAlpha(230) : Colors.grey[200]!.withAlpha(230),
                        foregroundColor: widget.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        shadowColor: widget.isDarkMode ? Colors.black54 : Colors
                            .grey[400],
                      ),
                      child: Text(
                        category['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode ? Colors.white : Colors
                              .black87,
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
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditTasksPage(
              task: task,
              isDarkMode: widget.isDarkMode,
              lightModeColor: widget.lightModeColor,
              darkModeColor: widget.darkModeColor,
              notificationsEnabled: widget.notificationsEnabled,
              onTaskUpdated: (updatedTask) async {
                await _dbHelper.updateTask(updatedTask);
                if (updatedTask['isCompleted'] == 0 &&
                    widget.notificationsEnabled) {
                  await _saveScheduledNotification(updatedTask);
                } else {
                  await _removeScheduledNotification(updatedTask['id']);
                }
                await _loadTasks();
                if (fromDetail) Navigator.pop(context);
              },
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _markAsCompleted(int id, {bool fromDetail = false}) async {
    if (!_isTodayView) return; // Disabled in Future view

    // Fetch the task to get its dueDate
    final task = await _dbHelper.getTaskById(id);
    if (task == null) {
      _showSnackBar('Task not found');
      return;
    }

    // Parse the task's due date and current time
    final dueDateTime = DateTime.parse(task['dueDate']);
    final currentTime = DateTime.now();

    // Check if current time is before the task's due time
    if (currentTime.isBefore(dueDateTime)) {
      // Format the due time for display
      final formattedDueTime = DateFormat('HH:mm').format(dueDateTime);
      _showSnackBar('Cannot mark as completed yet, wait until $formattedDueTime today');
      return;
    }

    // If time is equal or past due, show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          'Are you sure you want to mark this task as completed?',
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
              await _dbHelper.updateTask({'id': id, 'isCompleted': 1});
              await _removeScheduledNotification(id);
              _showSnackBar('Task marked as completed');
              await _loadTasks();
              Navigator.pop(context);
              if (fromDetail) Navigator.pop(context);
            },
            child: const Text('Yes', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _deleteTask(int id, {bool fromDetail = false}) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors
                .white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Confirm Delete',
              style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Are you sure you want to delete this task?',
              style: TextStyle(
                  color: widget.isDarkMode ? Colors.white70 : Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(
                    color: widget.isDarkMode ? Colors.white70 : Colors
                        .black87)),
              ),
              TextButton(
                onPressed: () async {
                  await _dbHelper.deleteTask(id);
                  await _removeScheduledNotification(id);
                  _showSnackBar('Task deleted successfully');
                  await _loadTasks();
                  Navigator.pop(context);
                  if (fromDetail) Navigator.pop(context);
                },
                child: const Text(
                    'Delete', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
    );
  }

  Future<void> _exportTasks() async {
    List<List<dynamic>> csvData = [
      ['ID', 'Title', 'Description', 'Due Date', 'Completed', 'Category'],
      ..._tasks.map((task) =>
      [
        task['id'],
        task['title'],
        task['description'],
        task['dueDate'],
        task['isCompleted'],
        task['categoryId'] != null
            ? _categories.firstWhere((c) => c['id'] == task['categoryId'],
            orElse: () => {'name': 'Uncategorized'})['name']
            : 'Uncategorized',
      ]),
    ];

    String csv = const ListToCsvConverter().convert(csvData);
    final path = await getTemporaryDirectory();
    final file = File(
        '${path.path}/${_isTodayView ? 'today' : 'future'}_tasks.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)],
        text: _isTodayView ? "Today's Tasks" : "Future Tasks");
    _showSnackBar(
        '${_isTodayView ? 'Today\'s' : 'Future'} tasks exported successfully');
  }

  void _navigateToDetail(Map<String, dynamic> task) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            DetailTasksPage(
              task: task,
              isDarkMode: widget.isDarkMode,
              lightModeColor: widget.lightModeColor,
              darkModeColor: widget.darkModeColor,
              onEdit: _editTask,
              onDelete: _deleteTask,
              onComplete: _isTodayView
                  ? _markAsCompleted
                  : null, // Disable completion in Future view
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve));
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
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            NotificationsPage(
              isDarkMode: widget.isDarkMode,
              lightModeColor: widget.lightModeColor,
              darkModeColor: widget.darkModeColor,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isDarkMode
              ? [widget.darkModeColor, Colors.grey[100]!.withAlpha(78)]
              : [widget.lightModeColor, Colors.white.withAlpha(179)],
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
              // Today Button
              Tooltip(
                message: 'Show today\'s tasks',
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isTodayView = true;
                      _loadTasks();
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
                          : (widget.isDarkMode ? Colors.white70 : Colors
                          .black54),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTodayView
                        ? (widget.isDarkMode ? widget.darkModeColor : widget
                        .lightModeColor)
                        : (widget.isDarkMode ? Colors.grey[800]! : Colors
                        .grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: _isTodayView
                            ? (widget.isDarkMode ? Colors.white70 : Colors
                            .black54)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    elevation: _isTodayView ? 6 : 2,
                    shadowColor: widget.isDarkMode ? Colors.black54 : Colors
                        .grey[400],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              // Search Bar
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
                            color: widget.isDarkMode
                                ? Colors.white70
                                : Colors.black54),
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
                        color: widget.isDarkMode
                            ? Colors.grey[700]!
                            : Colors.grey[400]!,
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
              // Future Button
              Tooltip(
                message: 'Show upcoming tasks',
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isTodayView = false;
                      _loadTasks();
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
                          : (widget.isDarkMode ? Colors.white70 : Colors
                          .black54),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isTodayView
                        ? (widget.isDarkMode ? widget.darkModeColor : widget
                        .lightModeColor)
                        : (widget.isDarkMode ? Colors.grey[800]! : Colors
                        .grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: !_isTodayView
                            ? (widget.isDarkMode ? Colors.white70 : Colors
                            .black54)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    elevation: !_isTodayView ? 6 : 2,
                    shadowColor: widget.isDarkMode ? Colors.black54 : Colors
                        .grey[400],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                  ..._categories.map((cat) =>
                      _buildCategoryButton(cat['name'])),
                  // Sorting dropdown for both Today and Future views
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButton<String>(
                      value: _sortBy,
                      items: [
                        DropdownMenuItem(
                            value: 'dueDate',
                            child: Text(_isTodayView ? 'Sort by Time' : 'Sort by Date')),
                        DropdownMenuItem(
                            value: 'title',
                            child: Text('Sort by Title')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                          _loadTasks();
                        });
                      },
                      style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : Colors
                              .black87),
                      dropdownColor: widget.isDarkMode
                          ? Colors.grey[800]
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3),
          Expanded(
            child: _tasks.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isTodayView ? Icons.today : Icons.upcoming,
                    size: 80,
                    color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isTodayView ? 'No today tasks!' : 'No future tasks!',
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white70 : Colors
                          .black87,
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
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    title: Text(
                      task['title']?.toString() ?? '',
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors
                            .black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(
                          DateTime.parse(task['dueDate'])) +
                          (task['categoryId'] != null
                              ? ' (${_categories.firstWhere((c) =>
                          c['id'] == task['categoryId'], orElse: () =>
                          {
                            'name': 'Uncategorized'
                          })['name']})'
                              : ''),
                      style: TextStyle(
                          color: widget.isDarkMode ? Colors.white70 : Colors
                              .black54),
                    ),
                    onTap: () => _navigateToDetail(task),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: 'Edit task',
                          child: IconButton(
                            icon: Icon(Icons.edit, color: widget.isDarkMode
                                ? Colors.blueGrey
                                : Colors.blueAccent),
                            onPressed: () => _editTask(task),
                          ),
                        ),
                        if (_isTodayView) // Only show in Today view
                          Tooltip(
                            message: 'Mark as completed',
                            child: IconButton(
                              icon: const Icon(
                                  Icons.check_circle, color: Colors.green),
                              onPressed: () => _markAsCompleted(task['id']),
                            ),
                          ),
                        Tooltip(
                          message: 'Delete task',
                          child: IconButton(
                            icon: const Icon(
                                Icons.delete, color: Colors.redAccent),
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
                        color: widget.isDarkMode ? Colors.white : Colors
                            .black87),
                    label: Text(
                      'Add',
                      style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : Colors
                              .black87, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _showCategoriesForAdd,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                      shadowColor: widget.isDarkMode ? Colors.black54 : Colors
                          .grey[400],
                      backgroundColor: widget.isDarkMode
                          ? widget.darkModeColor
                          : widget.lightModeColor,
                      foregroundColor: widget.isDarkMode ? Colors.white
                          .withAlpha(51) : Colors.black.withAlpha(51),
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
                          color: widget.isDarkMode ? Colors.white : Colors
                              .black),
                    ),
                    onPressed: _exportTasks,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isDarkMode
                          ? widget.darkModeColor
                          : widget.lightModeColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                Tooltip(
                  message: 'upcoming notifications',
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.notifications,
                        color: widget.isDarkMode ? Colors.white : Colors.black),
                    label: Text('', style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors
                            .black)),
                    onPressed: _navigateToNotifications,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isDarkMode
                          ? widget.darkModeColor
                          : widget.lightModeColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
            _loadTasks();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? (widget.isDarkMode ? widget.darkModeColor : widget
              .lightModeColor)
              : (widget.isDarkMode ? Colors.grey[700] : Colors.grey[300]),
          foregroundColor: widget.isDarkMode ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          elevation: isSelected ? 4 : 2,
          shadowColor: widget.isDarkMode ? Colors.black54 : Colors.grey[400],
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