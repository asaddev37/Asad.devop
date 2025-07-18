import 'package:flutter/material.dart';
import '../models/complaint.dart';

class ComplaintTile extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onResolve;
  final VoidCallback onEscalate;
  final VoidCallback onComment;

  const ComplaintTile({
    super.key,
    required this.complaint,
    required this.onResolve,
    required this.onEscalate,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Complaint #${complaint.id}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              complaint.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(complaint.description),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onComment,
                  icon: const Icon(Icons.comment),
                  label: const Text('Comment'),
                ),
                const SizedBox(width: 8),
                if (complaint.status != 'Resolved')
                  ElevatedButton.icon(
                    onPressed: onResolve,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Resolve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                const SizedBox(width: 8),
                if (complaint.status != 'Escalated')
                  ElevatedButton.icon(
                    onPressed: onEscalate,
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('Escalate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    switch (complaint.status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'resolved':
        color = Colors.green;
        break;
      case 'escalated':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        complaint.status,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}
