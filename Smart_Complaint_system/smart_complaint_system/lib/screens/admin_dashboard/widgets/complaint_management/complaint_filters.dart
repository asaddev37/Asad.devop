import 'package:flutter/material.dart';

class ComplaintFilters extends StatelessWidget {
  final String selectedStatus;
  final String selectedBatch;
  final String searchQuery;
  final List<Map<String, dynamic>> batches;
  final Function(String) onStatusChanged;
  final Function(String) onBatchChanged;
  final Function(String) onSearchChanged;

  const ComplaintFilters({
    super.key,
    required this.selectedStatus,
    required this.selectedBatch,
    required this.searchQuery,
    required this.batches,
    required this.onStatusChanged,
    required this.onBatchChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: theme.colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Filters',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Search complaints...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 18,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 400;
              if (isWideScreen) {
                return Row(
                  children: [
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedStatus,
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            items: const [
                              DropdownMenuItem(
                                  value: 'all', child: Text('All Statuses')),
                              DropdownMenuItem(
                                  value: 'Submitted', child: Text('Submitted')),
                              DropdownMenuItem(
                                  value: 'In Progress',
                                  child: Text('In Progress')),
                              DropdownMenuItem(
                                  value: 'Resolved', child: Text('Resolved')),
                              DropdownMenuItem(
                                  value: 'Rejected', child: Text('Rejected')),
                            ],
                            onChanged: (value) => onStatusChanged(value!),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface,
                            ),
                            dropdownColor: theme.colorScheme.surface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedBatch,
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            items: [
                              const DropdownMenuItem(
                                  value: 'all', child: Text('All Batches')),
                              ...batches
                                  .map((batch) => DropdownMenuItem<String>(
                                        value: batch['batch_name'] as String,
                                        child: Text(
                                          batch['batch_name'] as String,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      )),
                            ],
                            onChanged: (value) => onBatchChanged(value!),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface,
                            ),
                            dropdownColor: theme.colorScheme.surface,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedStatus,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          items: const [
                            DropdownMenuItem(
                                value: 'all', child: Text('All Statuses')),
                            DropdownMenuItem(
                                value: 'Submitted', child: Text('Submitted')),
                            DropdownMenuItem(
                                value: 'In Progress',
                                child: Text('In Progress')),
                            DropdownMenuItem(
                                value: 'Resolved', child: Text('Resolved')),
                            DropdownMenuItem(
                                value: 'Rejected', child: Text('Rejected')),
                          ],
                          onChanged: (value) => onStatusChanged(value!),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface,
                          ),
                          dropdownColor: theme.colorScheme.surface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedBatch,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          items: [
                            const DropdownMenuItem(
                                value: 'all', child: Text('All Batches')),
                            ...batches.map((batch) => DropdownMenuItem<String>(
                                  value: batch['batch_name'] as String,
                                  child: Text(
                                    batch['batch_name'] as String,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                )),
                          ],
                          onChanged: (value) => onBatchChanged(value!),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface,
                          ),
                          dropdownColor: theme.colorScheme.surface,
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
