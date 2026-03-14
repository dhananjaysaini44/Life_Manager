import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/state_providers.dart';
import '../widgets/schedule_event_card.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final scheduleAsync = ref.watch(scheduleByDateProvider(selectedDate));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.green),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Manage your time',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _entranceController,
          child: Column(
            children: [
              _CalendarWidget(
                selectedDate: selectedDate,
                onDateSelected: (date) => ref.read(selectedDateProvider.notifier).state = date,
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateUtils.isSameDay(selectedDate, DateTime.now())
                          ? 'Today, ${DateFormat('MMM d').format(selectedDate)}'
                          : DateFormat('EEEE, MMM d').format(selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Event'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: scheduleAsync.when(
                  data: (events) => events.isEmpty
                      ? _buildEmptyState(colorScheme)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      child: Column(
                                        children: [
                                          Text(
                                            event.startTime,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Expanded(
                                            child: Container(
                                              width: 2,
                                              color: colorScheme.outlineVariant,
                                              margin: const EdgeInsets.symmetric(vertical: 4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(child: ScheduleEventCard(event: event)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No events for this day.',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _CalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const _CalendarWidget({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(selectedDate),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => onDateSelected(DateTime(selectedDate.year, selectedDate.month - 1)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => onDateSelected(DateTime(selectedDate.year, selectedDate.month + 1)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) => 
              SizedBox(width: 40, child: Center(child: Text(day, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant.withOpacity(0.5)))))
            ).toList(),
          ),
        ),
        const SizedBox(height: 8),
        _buildCalendarGrid(context),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final startWeekday = firstDay.weekday % 7;
    final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final dayNum = index - startWeekday + 1;
        if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox.shrink();

        final date = DateTime(selectedDate.year, selectedDate.month, dayNum);
        final isToday = DateUtils.isSameDay(date, DateTime.now());
        final isSelected = DateUtils.isSameDay(date, selectedDate);

        return GestureDetector(
          onTap: () => onDateSelected(date),
          child: Container(
            decoration: BoxDecoration(
              color: isToday ? colorScheme.primary : (isSelected ? colorScheme.primaryContainer : null),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayNum',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isToday ? colorScheme.onPrimary : (isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface),
                    ),
                  ),
                  // Mock event indicator
                  if (dayNum % 5 == 0) 
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: isToday ? colorScheme.onPrimary : colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
