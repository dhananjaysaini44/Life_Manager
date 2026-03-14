import 'package:flutter/material.dart';
import '../../data/database.dart';

class ScheduleEventCard extends StatelessWidget {
  final ScheduleEvent event;

  const ScheduleEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Choose container color based on event type
    Color containerColor;
    Color onContainerColor;
    
    switch (event.type) {
      case 'meeting':
        containerColor = colorScheme.secondaryContainer;
        onContainerColor = colorScheme.onSecondaryContainer;
        break;
      case 'design':
        containerColor = colorScheme.tertiaryContainer;
        onContainerColor = colorScheme.onTertiaryContainer;
        break;
      case 'review':
        containerColor = colorScheme.errorContainer;
        onContainerColor = colorScheme.onErrorContainer;
        break;
      default:
        containerColor = colorScheme.surfaceVariant;
        onContainerColor = colorScheme.onSurfaceVariant;
    }

    return Card(
      elevation: 0,
      color: containerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onContainerColor,
                    ),
                  ),
                ),
                Text(
                  '${event.startTime} - ${event.endTime}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: onContainerColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              event.platform ?? event.location ?? 'No location',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: onContainerColor.withOpacity(0.7),
              ),
            ),
            if (event.attendees != null && event.attendees!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildAttendeesRow(event.attendees!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeesRow(String attendees) {
    final names = attendees.split(',');
    return Row(
      children: [
        for (int i = 0; i < names.length.clamp(0, 3); i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: CircleAvatar(
              radius: 12,
              child: Text(
                names[i].trim().substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        if (names.length > 3)
          Text(
            '+${names.length - 3}',
            style: const TextStyle(fontSize: 12),
          ),
      ],
    );
  }
}
