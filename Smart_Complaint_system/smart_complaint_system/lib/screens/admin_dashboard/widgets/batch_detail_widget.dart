import 'package:flutter/material.dart';
import '../controllers/admin_dashboard_controller.dart';

class BatchDetailWidget extends StatefulWidget {
  final AdminDashboardController controller;
  final Map<String, dynamic> batch;
  final ThemeData theme;

  const BatchDetailWidget({
    super.key,
    required this.controller,
    required this.batch,
    required this.theme,
  });

  @override
  State<BatchDetailWidget> createState() => _BatchDetailWidgetState();
}

class _BatchDetailWidgetState extends State<BatchDetailWidget> {
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  bool _showAllStudents = false;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final batchId = widget.batch['id'];
    if (batchId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final students = await widget.controller.getStudentsForBatch(batchId);
      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error, maybe show a snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    final advisor = widget.batch['advisor'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: widget.theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.batch['batch_name'] ?? 'Batch Details',
          style: TextStyle(color: widget.theme.colorScheme.onSurface),
        ),
        backgroundColor: widget.theme.colorScheme.surface,
        iconTheme: IconThemeData(color: widget.theme.colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Advisor', widget.theme),
            const SizedBox(height: 16),
            advisor != null
                ? _buildAdvisorCard(advisor, widget.theme)
                : _buildNoDataCard('No Advisor Assigned', widget.theme),
            const SizedBox(height: 24),
            _buildSectionHeader('Students (${_students.length})', widget.theme),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isNotEmpty
                    ? _buildStudentList(_students, widget.theme)
                    : _buildNoDataCard(
                        'No Students in this Batch', widget.theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildAdvisorCard(Map<String, dynamic> advisor, ThemeData theme) {
    final String name = advisor['name'] ?? 'N/A';
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          advisor['email'] ?? 'No email',
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
      ),
    );
  }

  Widget _buildStudentList(
      List<Map<String, dynamic>> students, ThemeData theme) {
    final int shownCount =
        _showAllStudents ? students.length : (students.isNotEmpty ? 1 : 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(shownCount, (index) {
          final student = students[index];
          final String name = student['name'] ?? 'N/A';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: theme.colorScheme.surface,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.secondary.withOpacity(0.15),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              title: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                student['email'] ?? 'No email',
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
            ),
          );
        }),
        if (students.length > 1)
          Center(
            child: IconButton(
              icon: Icon(
                _showAllStudents
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              onPressed: () {
                setState(() {
                  _showAllStudents = !_showAllStudents;
                });
              },
              tooltip: _showAllStudents ? 'Show less' : 'Show all students',
            ),
          ),
      ],
    );
  }

  Widget _buildNoDataCard(String message, ThemeData theme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Text(
          message,
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
      ),
    );
  }
}
