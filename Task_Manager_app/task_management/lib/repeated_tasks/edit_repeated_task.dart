import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class EditRepeatedTasksPage extends StatefulWidget {
  final Map<String, dynamic> task;
  final bool isDarkMode;
  final Color lightModeColor;
  final Color darkModeColor;
  final bool notificationsEnabled;
  final Function(Map<String, dynamic>) onTaskUpdated;

  const EditRepeatedTasksPage({
    Key? key,
    required this.task,
    required this.isDarkMode,
    required this.lightModeColor,
    required this.darkModeColor,
    required this.notificationsEnabled,
    required this.onTaskUpdated,
  }) : super(key: key);

  @override
  _EditRepeatedTasksPageState createState() => _EditRepeatedTasksPageState();
}

class _EditRepeatedTasksPageState extends State<EditRepeatedTasksPage> {
  late String title;
  late String description;
  late TimeOfDay dueTime;
  late List<bool> repeatDays;
  late List<String> subtasks;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  OverlayEntry? _overlayEntry;
  static const Color _lightModeErrorBg = Colors.black45;
  static const Color _lightModeErrorText = Colors.white;
  static const Color _darkModeErrorBg = Colors.white30;
  static const Color _darkModeErrorText = Colors.black;

  @override
  void initState() {
    super.initState();
    title = widget.task['title']?.toString() ?? '';
    description = widget.task['description']?.toString() ?? '';
    try {
      dueTime = TimeOfDay.fromDateTime(DateTime.parse(widget.task['dueDate'].toString()));
    } catch (e) {
      dueTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 5)));
    }
    repeatDays = (widget.task['repeatDays']?.toString() ?? '0,0,0,0,0,0,0')
        .split(',')
        .map((e) => e == '1')
        .toList();
    subtasks = (widget.task['subtasks']?.toString() ?? '')
        .split(',')
        .where((s) => s.isNotEmpty)
        .toList();
    _titleController = TextEditingController(text: title);
    _descriptionController = TextEditingController(text: description);
    _loadDraftTask();
  }

  Future<void> _loadDraftTask() async {
    final prefs = await SharedPreferences.getInstance();
    final draftTaskJson = prefs.getString('edit_draft_repeated_task_${widget.task['id']}');
    if (draftTaskJson != null) {
      final draftTask = jsonDecode(draftTaskJson) as Map<String, dynamic>;
      setState(() {
        title = draftTask['title']?.toString() ?? title;
        description = draftTask['description']?.toString() ?? description;
        _titleController.text = title;
        _descriptionController.text = description;
        try {
          final timeParts = (draftTask['dueTime']?.toString() ?? '00:00').split(':');
          dueTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        } catch (e) {
          dueTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 5)));
        }
        repeatDays = (draftTask['repeatDays']?.toString() ?? '0,0,0,0,0,0,0')
            .split(',')
            .map((e) => e == '1')
            .toList();
        subtasks = (draftTask['subtasks']?.toString() ?? '')
            .split(',')
            .where((s) => s.isNotEmpty)
            .toList();
      });
    }
  }

  Future<void> _saveDraftTask() async {
    final prefs = await SharedPreferences.getInstance();
    final draftTask = {
      'id': widget.task['id'],
      'title': title,
      'description': description,
      'dueTime': '${dueTime.hour}:${dueTime.minute}',
      'repeatDays': repeatDays.map((e) => e ? '1' : '0').join(','),
      'subtasks': subtasks.join(','),
    };
    await prefs.setString('edit_draft_repeated_task_${widget.task['id']}', jsonEncode(draftTask));
  }

  Future<void> _clearDraftTask() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('edit_draft_repeated_task_${widget.task['id']}');
  }

  DateTime _getNextOccurrence(DateTime now, int dayIndex, int hour, int minute) {
    int targetWeekday = (dayIndex + 1) % 7;
    if (targetWeekday == 0) targetWeekday = 7;
    int daysUntilNext = ((targetWeekday - now.weekday + 7) % 7);
    if (daysUntilNext == 0 && (now.hour > hour || (now.hour == hour && now.minute >= minute))) {
      daysUntilNext = 7;
    }
    return DateTime(now.year, now.month, now.day + daysUntilNext, hour, minute);
  }

  List<String> _getScheduledDatesPreview() {
    final now = DateTime.now();
    List<String> dates = [];
    for (int i = 0; i < 7; i++) {
      if (repeatDays[i]) {
        final nextDate = _getNextOccurrence(now, i, dueTime.hour, dueTime.minute);
        dates.add(DateFormat('EEE, MMM dd, HH:mm').format(nextDate));
      }
    }
    return dates;
  }

  Future<TimeOfDay?> showTimePickerDialog({required BuildContext context}) async {
    return await showTimePicker(
      context: context,
      initialTime: dueTime,
      builder: (context, child) {
        return Theme(
          data: widget.isDarkMode
              ? ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.darkModeColor,
              onPrimary: Colors.white,
              onSurface: Colors.white,
            ),
          )
              : ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.lightModeColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  void _addSubtask() {
    String subtask = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add Subtask',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
            hintText: 'Enter subtask',
            hintStyle: TextStyle(
              color: widget.isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ),
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
          onChanged: (value) => subtask = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (subtask.trim().isNotEmpty) {
                setState(() {
                  subtasks.add(subtask.trim());
                  _saveDraftTask();
                });
                _showSnackBar('Subtask added');
              } else {
                _showSnackBar('Subtask cannot be empty', isError: true);
              }
              Navigator.pop(context);
            },
            child: Text(
              'Add',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.amber : widget.lightModeColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTitleErrorOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 40,
        right: 40,
        top: MediaQuery.of(context).size.height * 0.35,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? _darkModeErrorBg : _lightModeErrorBg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(widget.isDarkMode ? 78 : 51),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: widget.isDarkMode
                    ? Colors.redAccent.withAlpha(128)
                    : Colors.red.withAlpha(178),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: widget.isDarkMode ? Colors.redAccent : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Please enter a task title!',
                    style: TextStyle(
                      color: widget.isDarkMode ? _darkModeErrorText : _lightModeErrorText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    Future.delayed(const Duration(seconds: 2), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
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
        backgroundColor: isError
            ? Colors.redAccent
            : (widget.isDarkMode ? Colors.grey[800] : Colors.grey[300]),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.isDarkMode
        ? [widget.darkModeColor, Colors.grey[800]!.withAlpha(78)]
        : [widget.lightModeColor, Colors.white.withAlpha(178)];

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
          'Edit Repeated Task',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.repeat,
                        color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Edit Repeated Task',
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title Field
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(
                        color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 18,
                    ),
                    controller: _titleController,
                    onChanged: (value) {
                      title = value;
                      _saveDraftTask();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Description Field
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter task description here...',
                      hintStyle: TextStyle(
                        color: widget.isDarkMode ? Colors.white54 : Colors.black54,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    controller: _descriptionController,
                    onChanged: (value) {
                      description = value;
                      _saveDraftTask();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Time Picker
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                child: ListTile(
                  leading: Icon(
                    Icons.access_time,
                    color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  title: Text(
                    'Time: ${dueTime.format(context)}',
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () async {
                    final picked = await showTimePickerDialog(context: context);
                    if (picked != null) {
                      setState(() {
                        dueTime = picked;
                        _saveDraftTask();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Repeat Days
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repeat Days',
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(7, (index) {
                          final day = DateFormat.E().format(DateTime(2023, 1, index + 2));
                          return ChoiceChip(
                            label: Text(
                              day,
                              style: TextStyle(
                                fontSize: 16,
                                color: widget.isDarkMode
                                    ? (repeatDays[index] ? Colors.black : Colors.white70)
                                    : (repeatDays[index] ? Colors.white : Colors.black87),
                              ),
                            ),
                            selected: repeatDays[index],
                            onSelected: (selected) {
                              setState(() {
                                repeatDays[index] = selected;
                                _saveDraftTask();
                              });
                            },
                            selectedColor: widget.isDarkMode
                                ? widget.darkModeColor
                                : widget.lightModeColor,
                            backgroundColor: widget.isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey[300],
                          );
                        }),
                      ),
                      if (repeatDays.contains(true)) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Scheduled: ${_getScheduledDatesPreview().join(', ')}',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Subtasks Section
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtasks (${subtasks.length})',
                            style: TextStyle(
                              color: widget.isDarkMode ? Colors.white : Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: _addSubtask,
                            child: Text(
                              'Add Subtask',
                              style: TextStyle(
                                color: widget.isDarkMode ? Colors.amber : widget.lightModeColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (subtasks.isNotEmpty) const SizedBox(height: 8),
                      ...subtasks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final subtask = entry.value;
                        return Dismissible(
                          key: Key('$index-$subtask-${DateTime.now().millisecondsSinceEpoch}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            color: Colors.redAccent,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Text(
                                  'Delete Subtask',
                                  style: TextStyle(
                                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to delete "$subtask"?',
                                  style: TextStyle(
                                    color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ) ?? false;
                          },
                          onDismissed: (direction) {
                            setState(() {
                              subtasks.removeAt(index);
                              _saveDraftTask();
                            });
                            _showSnackBar('Subtask deleted');
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.check_circle_outline,
                                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                              title: Text(
                                subtask,
                                style: TextStyle(
                                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      title: Text(
                                        'Delete Subtask',
                                        style: TextStyle(
                                          color: widget.isDarkMode ? Colors.white : Colors.black87,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to delete "$subtask"?',
                                        style: TextStyle(
                                          color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                                          fontSize: 16,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    setState(() {
                                      subtasks.removeAt(index);
                                      _saveDraftTask();
                                    });
                                    _showSnackBar('Subtask deleted');
                                  }
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                      if (subtasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No subtasks added',
                            style: TextStyle(
                              color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: () {
                        _clearDraftTask();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isDarkMode ? widget.darkModeColor : widget.lightModeColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      onPressed: () async {
                        if (title.trim().isEmpty) {
                          _showTitleErrorOverlay();
                          return;
                        }
                        if (!repeatDays.contains(true)) {
                          _showSnackBar('Please select at least one repeat day!', isError: true);
                          return;
                        }

                        bool? confirmSave = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: Text(
                              'Confirm Update',
                              style: TextStyle(
                                color: widget.isDarkMode ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            content: Text(
                              'Update this task? Next occurrences: ${_getScheduledDatesPreview().join(', ')}',
                              style: TextStyle(
                                color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  'Update',
                                  style: TextStyle(
                                    color: widget.isDarkMode ? Colors.amber : widget.lightModeColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmSave == true) {
                          final updatedTask = {
                            'id': widget.task['id'],
                            'title': title,
                            'description': description,
                            'dueDate': DateTime.now()
                                .copyWith(hour: dueTime.hour, minute: dueTime.minute)
                                .toIso8601String(),
                            'repeatDays': repeatDays.map((e) => e ? '1' : '0').join(','),
                            'subtasks': subtasks.join(','),
                            'isCompleted': widget.task['isCompleted'] ?? 0,
                            'isRepeated': 1,
                            'categoryId': widget.task['categoryId'],
                          };
                          try {
                            await widget.onTaskUpdated(updatedTask);
                            await _clearDraftTask();
                            _showSnackBar('Task updated successfully');

                            bool? returnToPrevious = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Text(
                                  'Task Updated',
                                  style: TextStyle(
                                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                content: Text(
                                  'Task updated successfully. Return to previous page?',
                                  style: TextStyle(
                                    color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text(
                                      'Stay',
                                      style: TextStyle(
                                        color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text(
                                      'Return',
                                      style: TextStyle(
                                        color: widget.isDarkMode ? Colors.amber : widget.lightModeColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (returnToPrevious == true) {
                              Navigator.pop(context);
                            } else {
                              setState(() {
                                title = '';
                                description = '';
                                dueTime = TimeOfDay.fromDateTime(
                                    DateTime.now().add(const Duration(minutes: 5)));
                                repeatDays = List.filled(7, false);
                                subtasks = [];
                                _titleController.text = '';
                                _descriptionController.text = '';
                              });
                            }
                          } catch (e) {
                            debugPrint('Error updating task: $e');
                            _showSnackBar('Failed to update task: $e', isError: true);
                          }
                        }
                      },
                      child: Text(
                        'Update Task',
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.amber : Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}