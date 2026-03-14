import 'package:flutter/material.dart';
import '../../data/database.dart';
import 'package:intl/intl.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = task.status == 'completed';

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: IconButton(
        icon: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        onPressed: onToggle,
      ),
      title: Text(
        task.title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
            ),
      ),
      subtitle: task.dueDate != null
          ? Text(
              _formatDueDate(task.dueDate!, task.dueTime),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isCompleted ? colorScheme.onSurfaceVariant.withOpacity(0.5) : colorScheme.primary,
                  ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }

  String _formatDueDate(int dueDate, String? dueTime) {
    final date = DateTime.fromMillisecondsSinceEpoch(dueDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    String dateStr;
    if (taskDate == today) {
      dateStr = 'Today';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = DateFormat('MMM d').format(date);
    }

    if (dueTime != null) {
      return '$dateStr, $dueTime';
    }
    return dateStr;
  }
}
