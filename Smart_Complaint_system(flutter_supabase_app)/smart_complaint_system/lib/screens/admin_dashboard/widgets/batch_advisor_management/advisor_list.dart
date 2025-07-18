import 'package:flutter/material.dart';

class AdvisorList extends StatefulWidget {
  final List<Map<String, dynamic>> advisors;
  final List<Map<String, dynamic>> batches;
  final bool isLoading;
  final Function(Map<String, dynamic>) onEdit;
  final Function(String, String) onDelete;

  const AdvisorList({
    super.key,
    required this.advisors,
    required this.batches,
    required this.isLoading,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<AdvisorList> createState() => _AdvisorListState();
}

class _AdvisorListState extends State<AdvisorList> {
  String? _expandedAdvisorId;

  String _getBatchName(String advisorId) {
    try {
      final batch = widget.batches.firstWhere(
        (b) => b['advisor_id'] == advisorId,
      );
      return batch['batch_name'] as String? ?? 'Unassigned';
    } catch (e) {
      return 'Unassigned';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.advisors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.supervisor_account_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Batch Advisors Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first batch advisor to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Batch Advisors',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.advisors.length,
          itemBuilder: (context, index) {
            final advisor = widget.advisors[index];
            final advisorId = advisor['id'] as String;
            final batchName = _getBatchName(advisorId);
            final isExpanded = _expandedAdvisorId == advisorId;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _expandedAdvisorId = isExpanded ? null : advisorId;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Text(
                            (advisor['name'] as String)
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            advisor['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Container(
                        height: isExpanded ? null : 0,
                        width: double.infinity,
                        child: Opacity(
                          opacity: isExpanded ? 1.0 : 0.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 24),
                              _buildDetailRow(context, Icons.email_outlined,
                                  advisor['email'] as String),
                              const SizedBox(height: 8),
                              _buildDetailRow(context, Icons.school_outlined,
                                  _getBatchName(advisorId)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => widget.onEdit(advisor),
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 20),
                                    label: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => widget.onDelete(
                                      advisorId,
                                      batchName,
                                    ),
                                    icon: const Icon(Icons.delete_outline,
                                        size: 20),
                                    label: const Text('Delete'),
                                    style: TextButton.styleFrom(
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .error),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
