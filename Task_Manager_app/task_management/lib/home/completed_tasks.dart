import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';
import '../repeated_tasks/detail_repeated_task.dart';
import '../today_tasks/detail_tasks.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class CompletedTasksPage extends StatefulWidget {
  final bool isDarkMode;
  final Color lightModeColor;
  final Color darkModeColor;

  const CompletedTasksPage({
    Key? key,
    required this.isDarkMode,
    required this.lightModeColor,
    required this.darkModeColor,
  }) : super(key: key);

  @override
  _CompletedTasksPageState createState() => _CompletedTasksPageState();
}

class _CompletedTasksPageState extends State<CompletedTasksPage> with SingleTickerProviderStateMixin {
  final _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _todayTasks = [];
  Map<int, List<Map<String, dynamic>>> _repeatedTasksWithInstances = {};
  List<Map<String, dynamic>> _categories = [];
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTasksAndCategories();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadTasksAndCategories() async {
    final tasks = await _dbHelper.getTasks();
    final instances = await _dbHelper.getTaskInstances();
    final categories = await _dbHelper.getCategories();

    setState(() {
      _categories = categories;

      final today = DateTime.now();
      _todayTasks = tasks.where((task) {
        try {
          final dueDate = DateTime.parse(task['dueDate']);
          return task['isCompleted'] == 1 &&
              task['isRepeated'] == 0 &&
              dueDate.day == today.day &&
              dueDate.month == today.month &&
              dueDate.year == today.year;
        } catch (e) {
          debugPrint('Error parsing dueDate for task ${task['id']}: $e');
          return false;
        }
      }).toList();

      _repeatedTasksWithInstances = {};
      final repeatedTasks = tasks.where((task) => task['isRepeated'] == 1).toList();
      for (var task in repeatedTasks) {
        final taskInstances = instances
            .where((instance) =>
        instance['taskId'] == task['id'] && instance['isCompleted'] == 1)
            .toList();
        if (task['isCompleted'] == 1 || taskInstances.isNotEmpty) {
          _repeatedTasksWithInstances[task['id']] = taskInstances.map((instance) {
            String categoryName = 'Uncategorized';
            if (task['categoryId'] != null) {
              final category = _categories.firstWhere(
                    (c) => c['id'] == task['categoryId'],
                orElse: () => {'name': 'Uncategorized'},
              );
              categoryName = category['name'] as String;
            }
            return {
              'taskId': instance['taskId'],
              'dueDate': instance['dueDate'],
              'isCompleted': instance['isCompleted'],
              'title': task['title'],
              'description': task['description'],
              'category': categoryName,
              'repeatDays': task['repeatDays'],
              'subtasks': task['subtasks'],
            };
          }).toList();
          if (_repeatedTasksWithInstances[task['id']]!.isEmpty && task['isCompleted'] == 1) {
            String categoryName = 'Uncategorized';
            if (task['categoryId'] != null) {
              final category = _categories.firstWhere(
                    (c) => c['id'] == task['categoryId'],
                orElse: () => {'name': 'Uncategorized'},
              );
              categoryName = category['name'] as String;
            }
            _repeatedTasksWithInstances[task['id']]!.add({
              'taskId': task['id'],
              'dueDate': task['dueDate'],
              'isCompleted': 1,
              'title': task['title'],
              'description': task['description'],
              'category': categoryName,
              'repeatDays': task['repeatDays'],
              'subtasks': task['subtasks'],
            });
          }
        }
      }
    });
  }

  Future<void> _uncompleteTodayTask(int id, {bool fromDetail = false}) async {
    final task = _todayTasks.firstWhere((t) => t['id'] == id, orElse: () => {'title': 'Task'});
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Mark as Uncompleted?',
            style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
          ),
          content: Text(
            'Are you sure you want to mark "${task['title']}" as uncompleted?',
            style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
          ),
          backgroundColor: widget.isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Yes', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _dbHelper.updateTask({'id': id, 'isCompleted': 0});
                _showSnackBar('Task marked as uncompleted');
                await _loadTasksAndCategories();
                if (fromDetail) Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTodayTask(int id, {bool fromDetail = false}) async {
    final task = _todayTasks.firstWhere((t) => t['id'] == id, orElse: () => {'title': 'Task'});
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Task?',
            style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
          ),
          content: Text(
            'Are you sure you want to delete "${task['title']}"?',
            style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
          ),
          backgroundColor: widget.isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Yes', style: TextStyle(color: Colors.redAccent)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _dbHelper.deleteTask(id);
                _showSnackBar('Task deleted');
                await _loadTasksAndCategories();
                if (fromDetail) Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uncompleteRepeatedInstance(int taskId, String dueDate, {bool fromDetail = false}) async {
    final instance = _repeatedTasksWithInstances[taskId]!
        .firstWhere((i) => i['dueDate'] == dueDate, orElse: () => {'title': 'Task'});
    final instanceDate = DateTime.parse(dueDate);
    final currentDate = DateTime.now();

    if (instanceDate.day == currentDate.day &&
        instanceDate.month == currentDate.month &&
        instanceDate.year == currentDate.year) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Mark Instance as Uncompleted?',
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
            ),
            content: Text(
              'Are you sure you want to mark the instance of "${instance['title']}" on ${DateFormat('EEE, MMM dd, HH:mm').format(instanceDate)} as uncompleted?',
              style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
            ),
            backgroundColor: widget.isDarkMode ? Colors.grey[850] : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'No',
                  style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Yes', style: TextStyle(color: Colors.blueAccent)),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _dbHelper.markTaskInstanceUncompleted(taskId, DateTime.parse(dueDate));
                  _showSnackBar('Instance marked as uncompleted');
                  await _loadTasksAndCategories();
                  if (fromDetail) Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      _showSnackBar('Oops! You can only undo tasks from today.');
    }
  }

  Future<void> _deleteRepeatedTask(int taskId, String dueDate, {bool fromDetail = false}) async {
    final instances = _repeatedTasksWithInstances[taskId]!;
    final taskTitle = instances.isNotEmpty ? instances.first['title'] : 'Task';
    final instanceDate = DateTime.parse(dueDate);
    final now = DateTime.now();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Completed Instance?',
            style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
          ),
          content: Text(
            'Are you sure you want to delete the completed instance of "$taskTitle" on ${DateFormat('EEE, MMM dd, HH:mm').format(instanceDate)}?',
            style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
          ),
          backgroundColor: widget.isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Yes', style: TextStyle(color: Colors.redAccent)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _dbHelper.deleteTaskInstance(taskId, dueDate);
                if (instanceDate.day == now.day &&
                    instanceDate.month == now.month &&
                    instanceDate.year == now.year) {
                  await _dbHelper.insertTaskInstance({
                    'taskId': taskId,
                    'dueDate': dueDate,
                    'isCompleted': 0,
                    'isDeleted': 1,
                  });
                }
                _showSnackBar('Completed instance deleted');
                await _loadTasksAndCategories();
                if (fromDetail) Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: widget.isDarkMode ? Colors.grey[800] : Colors.grey[300],
      ),
    );
  }

  Future<void> _showDownloadConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Download Tasks?',
          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
        ),
        content: Text(
          'Are you sure you want to download today’s completed tasks as a PDF?',
          style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
        ),
        backgroundColor: widget.isDarkMode ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Yes', style: TextStyle(color: Colors.blueAccent)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _generateAndDownloadPDF();
    }
  }

  Future<void> _generateAndDownloadPDF() async {
    final pdf = pw.Document();
    final today = DateTime.now();

    // Define color scheme
    final primaryColor = PdfColor.fromInt(Colors.blue[700]!.value);
    final accentColor = PdfColor.fromInt(Colors.teal[600]!.value);
    final neutralColor = PdfColor.fromInt(Colors.grey[700]!.value);
    final backgroundColor = PdfColor.fromInt(Colors.grey[100]!.value);
    final gradientStart = PdfColor.fromInt(widget.isDarkMode ? widget.darkModeColor.value : widget.lightModeColor.value);
    final gradientEnd = PdfColor.fromInt(widget.isDarkMode ? Colors.grey[800]!.value : Colors.white.value);

    // Collect tasks
    final tasks = [..._todayTasks];
    _repeatedTasksWithInstances.forEach((taskId, instances) {
      tasks.addAll(instances.where((instance) {
        final dueDate = DateTime.parse(instance['dueDate']);
        return dueDate.day == today.day &&
            dueDate.month == today.month &&
            dueDate.year == today.year;
      }));
    });
    tasks.sort((a, b) => DateTime.parse(a['dueDate']).compareTo(DateTime.parse(b['dueDate'])));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Container(
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [gradientStart, gradientEnd],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
            ),
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Title
                pw.Text(
                  'Today’s Completed Tasks',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 10),
                // App Description
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: backgroundColor,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'Our Task Manager App helps you stay organized, prioritize tasks, and track your progress with ease. Whether managing daily chores or long-term projects, our app ensures you never miss a deadline.',
                    style: pw.TextStyle(fontSize: 14, color: neutralColor),
                  ),
                ),
                pw.SizedBox(height: 10),
                // Completed Tasks Benefits
                pw.Text(
                  'Reviewing today’s completed tasks boosts your productivity and keeps you motivated to achieve more!',
                  style: pw.TextStyle(fontSize: 14, color: neutralColor, fontStyle: pw.FontStyle.italic),
                ),
                pw.SizedBox(height: 20),
                // Timestamp
                pw.Text(
                  'Generated on ${DateFormat('MMM dd, yyyy').format(today)}',
                  style: pw.TextStyle(fontSize: 12, color: neutralColor),
                ),
                pw.SizedBox(height: 20),
                // Tasks or Empty Message
                if (tasks.isEmpty)
                  pw.Container(
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(10),
                      border: pw.Border.all(color: neutralColor),
                      color: backgroundColor,
                    ),
                    child: pw.Text(
                      'No tasks completed today.',
                      style: pw.TextStyle(fontSize: 14, color: neutralColor),
                    ),
                  ),
                ...tasks.asMap().entries.map((entry) {
                  final task = entry.value;
                  return pw.Column(
                    children: [
                      pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 10),
                        padding: const pw.EdgeInsets.all(15),
                        decoration: pw.BoxDecoration(
                          borderRadius: pw.BorderRadius.circular(10),
                          border: pw.Border.all(color: primaryColor),
                          color: backgroundColor,
                          boxShadow: [
                            pw.BoxShadow(
                              color: PdfColor.fromInt(Colors.grey[400]!.value),
                              offset: const PdfPoint(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              task['title'] ?? 'Task',
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            if (task['description'] != null && task['description'].toString().isNotEmpty)
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(top: 5),
                                child: pw.Text(
                                  'Description: ${task['description']}',
                                  style: pw.TextStyle(fontSize: 12, color: neutralColor),
                                  softWrap: true,
                                ),
                              ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 5),
                              child: pw.Text(
                                'Due: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(task['dueDate']))}',
                                style: pw.TextStyle(fontSize: 12, color: accentColor),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 5),
                              child: pw.Text(
                                'Category: ${task['categoryId'] != null ? _categories.firstWhere((c) => c['id'] == task['categoryId'], orElse: () => {'name': 'Uncategorized'})['name'] : task['category'] ?? 'Uncategorized'}',
                                style: pw.TextStyle(fontSize: 12, color: neutralColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (entry.key < tasks.length - 1)
                        pw.Divider(color: neutralColor, height: 10),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );

    final path = await getTemporaryDirectory();
    final file = File('${path.path}/completed_tasks_${DateFormat('yyyyMMdd').format(today)}.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'Today’s Completed Tasks');
    _showSnackBar('PDF downloaded successfully');
  }

  void _navigateToDetail(Map<String, dynamic> task) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => DetailTasksPage(
          task: task,
          isDarkMode: widget.isDarkMode,
          lightModeColor: widget.lightModeColor,
          darkModeColor: widget.darkModeColor,
          onEdit: (task, {bool fromDetail = false}) {},
          onDelete: _deleteTodayTask,
          onUndo: _uncompleteTodayTask,
          onComplete: null,
          isCompletedNonRepeated: true,
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

  void _navigateToRepeatedDetail(Map<String, dynamic> instance) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => DetailRepeatedTasksPage(
          task: instance,
          isDarkMode: widget.isDarkMode,
          lightModeColor: widget.lightModeColor,
          darkModeColor: widget.darkModeColor,
          onEdit: (task, {bool fromDetail = false}) {},
          onDelete: (id, {bool fromDetail = false}) => _deleteRepeatedTask(id, instance['dueDate'], fromDetail: fromDetail),
          onComplete: (id, {bool fromDetail = false}) {},
          onUndo: (id, {bool fromDetail = false}) => _uncompleteRepeatedInstance(id, instance['dueDate'], fromDetail: fromDetail),
          isTodayView: false,
          isCompletedInstance: true,
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

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.isDarkMode
        ? [widget.darkModeColor, Colors.grey[100]!.withAlpha(51)]
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
          const SizedBox(height: 16),
          Text(
            'Completed Tasks',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: widget.isDarkMode ? Colors.white : Colors.black87,
            unselectedLabelColor: widget.isDarkMode ? Colors.white70 : Colors.black54,
            indicatorColor: widget.isDarkMode ? widget.darkModeColor : widget.lightModeColor,
            tabs: const [
              Tab(text: 'Non-Repeated'),
              Tab(text: 'Repeated'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _todayTasks.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No completed tasks for today!',
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
                  itemCount: _todayTasks.length,
                  itemBuilder: (context, index) {
                    final task = _todayTasks[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        title: Text(
                          task['title'] ?? '',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Due: ${DateFormat('HH:mm').format(DateTime.parse(task['dueDate']))}',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        onTap: () => _navigateToDetail(task),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.undo,
                                color: widget.isDarkMode ? Colors.blueGrey : Colors.blueAccent,
                              ),
                              onPressed: () => _uncompleteTodayTask(task['id']),
                              tooltip: 'Mark as Uncompleted',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deleteTodayTask(task['id']),
                              tooltip: 'Delete Task',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                _repeatedTasksWithInstances.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No completed repeated tasks!',
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
                  itemCount: _repeatedTasksWithInstances.length,
                  itemBuilder: (context, index) {
                    final taskId = _repeatedTasksWithInstances.keys.elementAt(index);
                    final instances = _repeatedTasksWithInstances[taskId]!;
                    final taskTitle = instances.first['title'] ?? 'Task';
                    final taskCategory = instances.first['category'] ?? 'Uncategorized';
                    return ExpansionTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            taskTitle,
                            style: TextStyle(
                              color: widget.isDarkMode ? Colors.white : Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Category: $taskCategory',
                            style: TextStyle(
                              color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      children: instances.map((instance) {
                        final dueDate = DateTime.parse(instance['dueDate']);
                        return ListTile(
                          title: Text(
                            DateFormat('EEE, MMM dd, HH:mm').format(dueDate),
                            style: TextStyle(
                              color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          onTap: () => _navigateToRepeatedDetail(instance),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.undo,
                                  color: widget.isDarkMode ? Colors.blueGrey : Colors.blueAccent,
                                ),
                                onPressed: () => _uncompleteRepeatedInstance(taskId, instance['dueDate']),
                                tooltip: 'Mark Instance as Uncompleted',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _deleteRepeatedTask(taskId, instance['dueDate']),
                                tooltip: 'Delete Completed Instance',
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tooltip(
                  message: 'Download today’s completed tasks',
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.picture_as_pdf_sharp,
                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                    ),
                    label: Text(
                      'Download',
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _showDownloadConfirmationDialog,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                      shadowColor: widget.isDarkMode ? Colors.black54 : Colors.grey[400],
                      backgroundColor: widget.isDarkMode ? widget.darkModeColor : widget.lightModeColor,
                      foregroundColor: widget.isDarkMode ? Colors.white.withAlpha(51) : Colors.black.withAlpha(51),
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
}