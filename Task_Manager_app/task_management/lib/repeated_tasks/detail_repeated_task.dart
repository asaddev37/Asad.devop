import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../database_helper.dart';

class DetailRepeatedTasksPage extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function(Map<String, dynamic>, {bool fromDetail}) onEdit;
  final Function(int, {bool fromDetail}) onDelete;
  final Function(int, {bool fromDetail}) onComplete;
  final Function(int, {bool fromDetail})? onUndo;
  final bool isDarkMode;
  final Color lightModeColor;
  final Color darkModeColor;
  final bool isTodayView;
  final bool isCompletedInstance;
  final DateTime? instanceDate;

  const DetailRepeatedTasksPage({
    Key? key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onComplete,
    this.onUndo,
    required this.isDarkMode,
    required this.lightModeColor,
    required this.darkModeColor,
    required this.isTodayView,
    this.isCompletedInstance = false,
    this.instanceDate,
  }) : super(key: key);

  @override
  _DetailRepeatedTasksPageState createState() => _DetailRepeatedTasksPageState();
}

class _DetailRepeatedTasksPageState extends State<DetailRepeatedTasksPage> {
  final _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _taskInstances = [];
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadTaskInstances();
    if (widget.instanceDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {}); // Refresh UI for instanceDate
      });
    }
  }

  Future<void> _loadTaskInstances() async {
    try {
      final instances = await _dbHelper.getTaskInstances(widget.task['taskId'] ?? widget.task['id']);
      final now = DateTime.now();
      final currentInstanceDueDate = widget.instanceDate ?? (widget.isCompletedInstance ? DateTime.parse(widget.task['dueDate']) : null);

      List<Map<String, dynamic>> filteredInstances = instances
          .where((instance) {
        try {
          final dueDate = DateTime.parse(instance['dueDate']);
          return instance['isDeleted'] != 1 &&
              (dueDate.isAfter(now) ||
                  (widget.instanceDate != null &&
                      dueDate.day == widget.instanceDate!.day &&
                      dueDate.month == widget.instanceDate!.month &&
                      dueDate.year == widget.instanceDate!.year) ||
                  (dueDate.day == now.day &&
                      dueDate.month == now.month &&
                      dueDate.year == now.year &&
                      instance['isCompleted'] == 0));
        } catch (e) {
          debugPrint('Error parsing dueDate in instance: $e');
          return false;
        }
      })
          .toList()
        ..sort((a, b) {
          try {
            return DateTime.parse(a['dueDate']).compareTo(DateTime.parse(b['dueDate']));
          } catch (e) {
            debugPrint('Error sorting instances: $e');
            return 0;
          }
        });

      // Deduplicate instances by dueDate
      Map<String, Map<String, dynamic>> uniqueInstances = {};
      for (var instance in filteredInstances) {
        final dueDateStr = instance['dueDate'] as String;
        if (!uniqueInstances.containsKey(dueDateStr)) {
          uniqueInstances[dueDateStr] = instance;
        }
      }

      setState(() {
        _taskInstances = uniqueInstances.values.toList().take(5).toList();
        _completedCount = instances.where((instance) => instance['isCompleted'] == 1 && instance['isDeleted'] != 1).length;
      });
    } catch (e) {
      debugPrint('Error loading task instances: $e');
      setState(() {
        _taskInstances = [];
        _completedCount = 0;
      });
    }
  }

  Future<Widget> _buildUpcomingNotifications(int taskId) async {
    final instances = await _dbHelper.getTaskInstances(taskId);
    final now = DateTime.now();
    final upcomingInstances = instances
        .where((instance) {
      try {
        final dueDate = DateTime.parse(instance['dueDate']);
        return instance['isDeleted'] != 1 &&
            (dueDate.isAfter(now) ||
                (widget.instanceDate != null &&
                    dueDate.day == widget.instanceDate!.day &&
                    dueDate.month == widget.instanceDate!.month &&
                    dueDate.year == widget.instanceDate!.year) ||
                (dueDate.day == now.day &&
                    dueDate.month == now.month &&
                    dueDate.year == now.year &&
                    instance['isCompleted'] == 0));
      } catch (e) {
        debugPrint('Error parsing dueDate in instance: $e');
        return false;
      }
    })
        .toList()
      ..sort((a, b) => DateTime.parse(a['dueDate']).compareTo(DateTime.parse(b['dueDate'])));

    if (upcomingInstances.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(left: 32),
        child: Text(
          'No upcoming instances',
          style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87),
        ),
      );
    }

    return Column(
      children: upcomingInstances.take(5).map((instance) {
        final dueDate = DateTime.parse(instance['dueDate']);
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(width: 32),
              Icon(
                Icons.schedule,
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
              ),
              SizedBox(width: 8),
              Text(
                DateFormat('EEE, MMM dd, HH:mm').format(dueDate),
                style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87),
              ),
              if (instance['isCompleted'] == 1)
                Text(
                  ' (Completed)',
                  style: TextStyle(color: Colors.green),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<bool> _isInstanceCompleted() async {
    if (widget.instanceDate != null) {
      final instances = await _dbHelper.getTaskInstances(widget.task['taskId'] ?? widget.task['id']);
      final instance = instances.firstWhere(
            (inst) => inst['dueDate'] == widget.instanceDate!.toIso8601String() && inst['isDeleted'] != 1,
        orElse: () => {'isCompleted': 0},
      );
      return instance['isCompleted'] == 1;
    }
    return widget.isCompletedInstance;
  }

  Future<void> _shareTask(BuildContext context) async {
    try {
      final dueTime = DateTime.parse(widget.task['dueDate'] as String);
      String repeatDaysString;
      try {
        repeatDaysString = (widget.task['repeatDays'] as String?) ?? '0,0,0,0,0,0,0';
        final repeatDaysList = repeatDaysString.split(',').asMap().entries.map((entry) {
          try {
            return entry.value == '1'
                ? DateFormat.E().format(DateTime(2023, 1, entry.key + 2))
                : '';
          } catch (e) {
            debugPrint('Error formatting repeat day at index ${entry.key}: $e');
            return '';
          }
        }).where((day) => day.isNotEmpty).join(', ');
        repeatDaysString = repeatDaysList;
      } catch (e) {
        debugPrint('Error processing repeatDays for share: $e');
        repeatDaysString = 'N/A';
      }

      final subtasks = (widget.task['subtasks'] as String? ?? '').split(',').where((s) => s.isNotEmpty).toList();

      List<List<dynamic>> csvData = [
        ['ID', 'Title', 'Description', widget.isCompletedInstance ? 'Instance Date' : 'Time', 'Repeat Days', 'Completed', 'Subtasks', 'Next Instances'],
        [
          widget.task['taskId'] ?? widget.task['id'],
          widget.task['title'] ?? 'No title',
          widget.task['description'] ?? 'No description',
          widget.isCompletedInstance
              ? DateFormat('yyyy-MM-dd HH:mm').format(dueTime)
              : DateFormat('HH:mm').format(dueTime),
          repeatDaysString,
          widget.isCompletedInstance && widget.task['isCompleted'] == 1 ? 'Yes' : 'No',
          subtasks.isNotEmpty ? subtasks.join('; ') : 'None',
          _taskInstances.take(3).map((instance) {
            try {
              return DateFormat('EEE, MMM dd, HH:mm').format(DateTime.parse(instance['dueDate']));
            } catch (e) {
              debugPrint('Error formatting instance date: $e');
              return 'N/A';
            }
          }).join('; '),
        ],
      ];

      String csv = const ListToCsvConverter().convert(csvData);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/repeated_task_${widget.task['taskId'] ?? widget.task['id']}_${widget.task['dueDate']}.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: widget.isCompletedInstance
            ? 'Repeated Task Instance: ${widget.task['title'] ?? 'No title'}'
            : 'Repeated Task Details: ${widget.task['title'] ?? 'No title'}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isCompletedInstance ? 'Task instance exported as CSV' : 'Task exported as CSV',
            style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: widget.isDarkMode ? Colors.grey[800] : Colors.grey[300],
        ),
      );
    } catch (e) {
      debugPrint('Error sharing task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to export task: $e',
            style: TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _getNextDueDate() {
    try {
      final repeatDaysString = (widget.task['repeatDays'] as String?) ?? '0,0,0,0,0,0,0';
      final repeatDaysMap = repeatDaysString.split(',').asMap();
      final dueTime = DateTime.parse(widget.task['dueDate'] as String);
      final now = DateTime.now();
      DateTime? nextDate;
      for (int i = 0; i < 7; i++) {
        if (repeatDaysMap[i] == '1') {
          final candidate = _getNextOccurrence(now, i, dueTime.hour, dueTime.minute);
          if (nextDate == null || candidate.isBefore(nextDate)) {
            nextDate = candidate;
          }
        }
      }
      return nextDate != null
          ? DateFormat('EEE, MMM dd, HH:mm').format(nextDate)
          : 'N/A';
    } catch (e) {
      debugPrint('Error calculating next due date: $e');
      return 'N/A';
    }
  }

  DateTime _getNextOccurrence(DateTime now, int dayIndex, int hour, int minute) {
    try {
      int targetWeekday = (dayIndex + 1) % 7;
      if (targetWeekday == 0) targetWeekday = 7;
      int daysUntilNext = ((targetWeekday - now.weekday + 7) % 7);
      if (daysUntilNext == 0 && (now.hour > hour || (now.hour == hour && now.minute >= minute))) {
        daysUntilNext = 7;
      }
      return DateTime(now.year, now.month, now.day + daysUntilNext, hour, minute);
    } catch (e) {
      debugPrint('Error in _getNextOccurrence: $e');
      return now;
    }
  }

  bool _hasTodayInstance() {
    try {
      final now = DateTime.now();
      final repeatDays = (widget.task['repeatDays'] as String?)?.split(',')?.asMap() ?? {};
      final dueTime = DateTime.parse(widget.task['dueDate'] as String);
      final today = DateTime(now.year, now.month, now.day);

      for (int i = 0; i < 7; i++) {
        if (repeatDays[i] == '1') {
          int targetWeekday = (i + 1) % 7;
          if (targetWeekday == 0) targetWeekday = 7;
          int daysUntilNext = ((targetWeekday - now.weekday + 7) % 7);
          final nextOccurrence = DateTime(now.year, now.month, now.day + daysUntilNext, dueTime.hour, dueTime.minute);
          if (nextOccurrence.day == today.day &&
              nextOccurrence.month == today.month &&
              nextOccurrence.year == today.year) {
            return now.isAfter(dueTime) ||
                (now.hour == dueTime.hour && now.minute >= dueTime.minute);
          }
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error checking today instance: $e');
      return false;
    }
  }

  String _getTaskStatus(Map<String, dynamic> task) {
    try {
      if (widget.isCompletedInstance) {
        return 'Completed';
      }

      final now = DateTime.now();
      final dueTime = DateTime.parse(task['dueDate'] as String);
      final repeatDays = (task['repeatDays'] as String?)?.split(',')?.asMap() ?? {};
      final today = DateTime(now.year, now.month, now.day);

      bool hasTodayInstance = false;
      DateTime? todayDueDate;
      for (int i = 0; i < 7; i++) {
        if (repeatDays[i] == '1') {
          int targetWeekday = (i + 1) % 7;
          if (targetWeekday == 0) targetWeekday = 7;
          int daysUntilNext = ((targetWeekday - now.weekday + 7) % 7);
          final nextOccurrence = DateTime(now.year, now.month, now.day + daysUntilNext, dueTime.hour, dueTime.minute);
          if (nextOccurrence.day == today.day &&
              nextOccurrence.month == today.month &&
              nextOccurrence.year == today.year) {
            hasTodayInstance = true;
            todayDueDate = nextOccurrence;
            break;
          }
        }
      }

      if (hasTodayInstance && todayDueDate != null && widget.isTodayView) {
        final instance = _taskInstances.firstWhere(
              (inst) =>
          DateTime.parse(inst['dueDate']).day == today.day &&
              DateTime.parse(inst['dueDate']).month == today.month &&
              DateTime.parse(inst['dueDate']).year == today.year &&
              inst['isDeleted'] != 1,
          orElse: () => <String, dynamic>{},
        );
        if (instance.isNotEmpty && instance['isCompleted'] == 1) {
          return 'Completed';
        }
        if (now.isAfter(todayDueDate)) {
          return 'Pending';
        }
        return 'Uncompleted';
      }
      return 'Uncompleted';
    } catch (e) {
      debugPrint('Error determining task status: $e');
      return 'Uncompleted';
    }
  }

  Color _getStatusColor(String status, bool isDarkMode) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Uncompleted':
        return Colors.blue;
      default:
        return isDarkMode ? Colors.white70 : Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime dueTime;
    try {
      dueTime = DateTime.parse(widget.task['dueDate'] as String);
    } catch (e) {
      debugPrint('Error parsing dueDate: $e');
      dueTime = DateTime.now();
    }

    String repeatDaysString;
    try {
      repeatDaysString = (widget.task['repeatDays'] as String?) ?? '0,0,0,0,0,0,0';
      repeatDaysString = repeatDaysString
          .split(',')
          .asMap()
          .entries
          .map((entry) {
        try {
          return entry.value == '1'
              ? DateFormat.E().format(DateTime(2023, 1, entry.key + 2))
              : '';
        } catch (e) {
          debugPrint('Error formatting repeat day in build: $e');
          return '';
        }
      })
          .where((day) => day.isNotEmpty)
          .join(', ');
    } catch (e) {
      debugPrint('Error processing repeatDays in build: $e');
      repeatDaysString = 'N/A';
    }

    List<String> subtasks;
    try {
      subtasks = (widget.task['subtasks'] as String? ?? '').split(',').where((s) => s.isNotEmpty).toList();
    } catch (e) {
      debugPrint('Error processing subtasks: $e');
      subtasks = [];
    }

    final taskStatus = _getTaskStatus(widget.task);
    final statusColor = _getStatusColor(taskStatus, widget.isDarkMode);
    final hasTodayInstance = _hasTodayInstance();

    final gradientColors = widget.isDarkMode
        ? [widget.darkModeColor, Colors.grey[800]!.withAlpha(78)]
        : [widget.lightModeColor, Colors.white.withAlpha(178)];

    return FutureBuilder<bool>(
      future: _isInstanceCompleted(),
      builder: (context, snapshot) {
        final isCompleted = snapshot.data ?? widget.isCompletedInstance;
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
              widget.isCompletedInstance ? 'Instance Details' : 'Task Details',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                ),
                onPressed: () => _shareTask(context),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                ),
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      widget.onEdit(widget.task, fromDetail: true);
                      break;
                    case 'complete':
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text('Mark as Complete?',
                            style: TextStyle(
                              color: widget.isDarkMode ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text('Are you sure you want to mark this instance as complete?',
                            style: TextStyle(
                              color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel',
                                style: TextStyle(
                                  color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Complete',style: TextStyle(color: Colors.green),),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        final taskId = widget.task['taskId'] ?? widget.task['id'];
                        final instanceDate = widget.instanceDate ?? DateTime.now();
                        await _dbHelper.markTaskInstanceCompleted(taskId, instanceDate);
                        widget.onComplete(taskId, fromDetail: true);
                        setState(() {
                          _loadTaskInstances();
                        });
                        Navigator.pop(context);
                      }
                      break;
                    case 'delete':
                      widget.onDelete(widget.task['taskId'] ?? widget.task['id'], fromDetail: true);
                      break;
                    case 'undo':
                      if (widget.onUndo != null) {
                        widget.onUndo!(widget.task['taskId'] ?? widget.task['id'], fromDetail: true);
                      }
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  if (widget.isCompletedInstance) {
                    return [
                      PopupMenuItem<String>(
                        value: 'undo',
                        child: Row(
                          children: [
                            Icon(Icons.undo, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Undo'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ];
                  } else {
                    final canMarkComplete = widget.isTodayView && hasTodayInstance && !isCompleted;
                    return [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'complete',
                        enabled: canMarkComplete,
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: canMarkComplete ? Colors.green : Colors.grey,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Mark Instance Complete',
                              style: TextStyle(
                                color: canMarkComplete ? null : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ];
                  }
                },
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.title, color: widget.isDarkMode ? Colors.blueGrey : Colors.blue),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                widget.task['title'] ?? 'No title',
                                style: TextStyle(
                                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.description, color: widget.isDarkMode ? Colors.blueGrey : Colors.blue),
                                SizedBox(width: 16),
                                Text(
                                  'Description',
                                  style: TextStyle(
                                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              widget.task['description'] ?? 'No description',
                              style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time, color: widget.isDarkMode ? Colors.blueGrey : Colors.blue),
                                SizedBox(width: 16),
                                Text(
                                  widget.isCompletedInstance ? 'Instance Date' : 'Time',
                                  style: TextStyle(
                                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              widget.isCompletedInstance
                                  ? DateFormat('EEE, MMM dd, HH:mm').format(dueTime)
                                  : DateFormat('HH:mm').format(dueTime),
                              style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.repeat, color: widget.isDarkMode ? Colors.blueGrey : Colors.blue),
                                SizedBox(width: 16),
                                Text(
                                  'Repeat Days',
                                  style: TextStyle(
                                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              repeatDaysString,
                              style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color: widget.isDarkMode ? Colors.blueGrey : Colors.blue),
                                SizedBox(width: 16),
                                Text(
                                  'Next Due',
                                  style: TextStyle(
                                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              _getNextDueDate(),
                              style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.list, color: widget.isDarkMode ? Colors.blueGrey : Colors.blue),
                                SizedBox(width: 16),
                                Text(
                                  'Subtasks',
                                  style: TextStyle(
                                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            if (subtasks.isEmpty)
                              Padding(
                                padding: EdgeInsets.only(left: 32),
                                child: Text(
                                  'No subtasks',
                                  style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87),
                                ),
                              )
                            else
                              ...subtasks.map(
                                    (subtask) => Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 32),
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          subtask,
                                          style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.flag, color: widget.isDarkMode ? Colors.blueGrey : Colors.blue),
                            SizedBox(width: 16),
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    margin: EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Text(
                                    'Status: $taskStatus',
                                    style: TextStyle(
                                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.isCompletedInstance) ...[
                      SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: widget.isDarkMode ? Colors.blueGrey : Colors.blue),
                              SizedBox(width: 16),
                              Text(
                                'Completed Instances: $_completedCount',
                                style: TextStyle(
                                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.event, color: widget.isDarkMode ? Colors.blueGrey : Colors.blue),
                                SizedBox(width: 16),
                                Text(
                                  'Upcoming Notifications',
                                  style: TextStyle(
                                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            FutureBuilder<Widget>(
                              future: _buildUpcomingNotifications(widget.task['taskId'] ?? widget.task['id']),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!;
                                }
                                return Padding(
                                  padding: EdgeInsets.only(left: 32),
                                  child: Text(
                                    'Loading...',
                                    style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: !isCompleted && widget.isTodayView && hasTodayInstance
              ? FloatingActionButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text('Mark as Complete?',
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text('Are you sure you want to mark this instance as complete?',
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel',
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Complete',style: TextStyle(color: Colors.green),),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                final taskId = widget.task['taskId'] ?? widget.task['id'];
                final instanceDate = widget.instanceDate ?? DateTime.now();
                await _dbHelper.markTaskInstanceCompleted(taskId, instanceDate);
                widget.onComplete(taskId, fromDetail: true);
                setState(() {
                  _loadTaskInstances();
                });
              }
            },
            child: Icon(Icons.check),
            backgroundColor: Colors.green,
          )
              : null,
        );
      },
    );
  }
}