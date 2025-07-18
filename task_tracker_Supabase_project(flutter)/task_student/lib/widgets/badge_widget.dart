import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';

class BadgeWidget extends StatelessWidget {
  final String badgeName;

  const BadgeWidget({super.key, required this.badgeName});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Row(
          children: [
            const Icon(Icons.star, color: AppColors.secondary, size: 24),
            const SizedBox(width: AppSizes.padding),
            Text(badgeName, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.easeInOut);
  }
}