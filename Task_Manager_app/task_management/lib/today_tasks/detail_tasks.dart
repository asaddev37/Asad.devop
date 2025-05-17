import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart'; // For CSV conversion
import 'package:path_provider/path_provider.dart'; // For temporary file storage
import 'dart:io'; // For File operations
import 'package:share_plus/share_plus.dart'; // Updated to share_plus for consistency

class DetailTasksPage extends StatelessWidget {
  final Map<String, dynamic> task;
  final Function(Map<String, dynamic>, {bool fromDetail}) onEdit;
  final Function(int, {bool fromDetail}) onDelete;
  final Function(int, {bool fromDetail})? onComplete;
  final Function(int, {bool fromDetail})? onUndo; // New callback for undo
  final bool isDarkMode;
  final Color lightModeColor;
  final Color darkModeColor;
  final bool isCompletedNonRepeated;

  const DetailTasksPage({
    Key? key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    this.onComplete,
    this.onUndo, // Optional undo callback
    required this.isDarkMode,
    required this.lightModeColor,
    required this.darkModeColor,
    this.isCompletedNonRepeated = false,
  }) : super(key: key);

  String _getTaskStatus(Map<String, dynamic> task) {
    if (task['isCompleted'] == 1) {
      return 'Completed';
    }

    final dueDate = DateTime.parse(task['dueDate']);
    final now = DateTime.now();

    final isToday = dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;

    if (isToday) {
      final isTimeEqualOrAfter =
          now.hour > dueDate.hour ||
              (now.hour == dueDate.hour && now.minute >= dueDate.minute);

      return isTimeEqualOrAfter ? 'Pending' : 'Uncompleted';
    } else {
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

  Future<void> _shareTask(BuildContext context) async {
    final dueDate = DateTime.parse(task['dueDate'].toString());
    final subtasks = (task['subtasks']?.toString() ?? '')
        .split(',')
        .where((String s) => s.isNotEmpty)
        .toList();

    List<List<dynamic>> csvData = [
      ['ID', 'Title', 'Description', 'Due Date', 'Completed', 'Subtasks'],
      [
        task['id'],
        task['title'] ?? 'No title',
        task['description'] ?? 'No description',
        DateFormat('yyyy-MM-dd HH:mm').format(dueDate),
        task['isCompleted'] == 1 ? 'Yes' : 'No',
        subtasks.isNotEmpty ? subtasks.join('; ') : 'None',
      ],
    ];

    String csv = const ListToCsvConverter().convert(csvData);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/task_${task['id']}.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Task Details: ${task['title'] ?? 'No title'}',
      subject: 'Task Export',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Task exported as CSV',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskStatus = _getTaskStatus(task);
    final statusColor = _getStatusColor(taskStatus, isDarkMode);
    final dueDate = DateTime.parse(task['dueDate'].toString());
    final subtasks = (task['subtasks']?.toString() ?? '')
        .split(',')
        .where((String s) => s.isNotEmpty)
        .toList();
    final gradientColors = isDarkMode
        ? [darkModeColor, Colors.grey[800]!.withAlpha(78)]
        : [lightModeColor, Colors.white.withAlpha(178)];

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
          'Task Details',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () => _shareTask(context),
            tooltip: 'Share Task as CSV',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert,
                color: isDarkMode ? Colors.white : Colors.black87),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit(task, fromDetail: true);
                  break;
                case 'complete':
                  if (onComplete != null) {
                    onComplete!(task['id'], fromDetail: true);
                  }
                  break;
                case 'delete':
                  onDelete(task['id'], fromDetail: true);
                  break;
                case 'undo':
                  if (onUndo != null) {
                    onUndo!(task['id'], fromDetail: true);
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              if (isCompletedNonRepeated) {
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
                  if (onComplete != null)
                    PopupMenuItem<String>(
                      value: 'complete',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Mark as Complete'),
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
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.title, color: isDarkMode ? Colors.blueGrey : Colors.blue),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            task['title']?.toString() ?? 'No title',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
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
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description, color: isDarkMode ? Colors.blueGrey : Colors.blue),
                            SizedBox(width: 16),
                            Text(
                              'Description',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          task['description']?.toString() ?? 'No description',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black87,
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
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: isDarkMode ? Colors.blueGrey : Colors.blue),
                            SizedBox(width: 16),
                            Text(
                              'Due Date',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: isDarkMode ? Colors.blueGrey : Colors.blue),
                            SizedBox(width: 16),
                            Text(
                              DateFormat('yyyy-MM-dd').format(dueDate),
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: isDarkMode ? Colors.blueGrey : Colors.blue),
                            SizedBox(width: 16),
                            Text(
                              DateFormat('HH:mm').format(dueDate),
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.list, color: isDarkMode ? Colors.blueGrey : Colors.blue),
                            SizedBox(width: 16),
                            Text(
                              'Subtasks',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
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
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          )
                        else
                          ...subtasks.map(
                                (subtask) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  SizedBox(width: 32),
                                  Icon(Icons.check_circle_outline,
                                      color: isDarkMode ? Colors.white70 : Colors.black54),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      subtask,
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white70 : Colors.black87,
                                      ),
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
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag,
                          color: isDarkMode ? Colors.blueGrey : Colors.blue,
                        ),
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
                                  color: isDarkMode ? Colors.white : Colors.black87,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}