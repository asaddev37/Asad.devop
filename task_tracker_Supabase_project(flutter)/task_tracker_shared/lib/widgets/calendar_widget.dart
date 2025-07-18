import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';
import '../models/task.dart';

class CalendarWidget extends StatelessWidget {
  final List<Task> tasks;
  final Function(DateTime) onDaySelected;

  const CalendarWidget({
    super.key,
    required this.tasks,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final events = {
      for (var task in tasks)
        if (task.dueDate != null) task.dueDate!: [task]
    };

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: DateTime.now(),
          calendarFormat: CalendarFormat.month,
          eventLoader: (day) => events[day] ?? [],
          onDaySelected: (selectedDay, focusedDay) {
            onDaySelected(selectedDay);
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}