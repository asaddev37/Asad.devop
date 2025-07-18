import 'package:flutter/material.dart';
import '../../controllers/admin_dashboard_controller.dart';
import 'complaint_list.dart';
import 'complaint_filters.dart';

class ComplaintManagementWidget extends StatefulWidget {
  final AdminDashboardController controller;

  const ComplaintManagementWidget({
    super.key,
    required this.controller,
  });

  @override
  State<ComplaintManagementWidget> createState() =>
      _ComplaintManagementWidgetState();
}

class _ComplaintManagementWidgetState extends State<ComplaintManagementWidget> {
  String _selectedStatus = 'all';
  String _selectedBatch = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header

        // Filters
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ComplaintFilters(
            selectedStatus: _selectedStatus,
            selectedBatch: _selectedBatch,
            searchQuery: _searchQuery,
            batches: widget.controller.batches,
            onStatusChanged: (status) =>
                setState(() => _selectedStatus = status),
            onBatchChanged: (batch) => setState(() => _selectedBatch = batch),
            onSearchChanged: (query) => setState(() => _searchQuery = query),
          ),
        ),

        const SizedBox(height: 24),

        // Complaints List
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ComplaintList(
            complaints: widget.controller.complaints,
            isLoading: widget.controller.isLoading,
            selectedStatus: _selectedStatus,
            selectedBatch: _selectedBatch,
            searchQuery: _searchQuery,
          ),
        ),
      ],
    );
  }
}
