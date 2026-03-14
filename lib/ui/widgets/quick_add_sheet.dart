import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/database_providers.dart';
import '../../data/database.dart';
import 'package:drift/drift.dart' as drift;

class QuickAddBottomSheet extends ConsumerStatefulWidget {
  const QuickAddBottomSheet({super.key});

  @override
  ConsumerState<QuickAddBottomSheet> createState() => _QuickAddBottomSheetState();
}

class _QuickAddBottomSheetState extends ConsumerState<QuickAddBottomSheet> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  String _type = 'task';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = 'Work';

  late AnimationController _animationController;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Work', 'color': Colors.blue},
    {'name': 'Personal', 'color': Colors.purple},
    {'name': 'Urgent', 'color': Colors.orange},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick Add',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Task or event name',
                  hintText: 'e.g., Design Sync with Team',
                ),
              ),
              const SizedBox(height: 20),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'task',
                    label: Text('Task'),
                    icon: Icon(Icons.check_circle_outline),
                  ),
                  ButtonSegment(
                    value: 'event',
                    label: Text('Event'),
                    icon: Icon(Icons.calendar_month_outlined),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (newSelection) {
                  setState(() => _type = newSelection.first);
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date'),
                        child: Text(DateFormat('EEE, MMM d, yyyy').format(_selectedDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Time'),
                        child: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildCategoryChips(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Add to Calendar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(56, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      children: List.generate(_categories.length, (index) {
        final cat = _categories[index];
        final delay = index * 0.1;
        return FadeTransition(
          opacity: _animationController.drive(
            CurveTween(curve: Interval(delay, delay + 0.5, curve: Curves.easeOut)),
          ),
          child: ScaleTransition(
            scale: _animationController.drive(
              CurveTween(curve: Interval(delay, delay + 0.5, curve: Curves.easeOutBack)),
            ),
            child: ChoiceChip(
              label: Text(cat['name']),
              selected: _selectedCategory == cat['name'],
              onSelected: (_) => setState(() => _selectedCategory = cat['name']),
              avatar: CircleAvatar(backgroundColor: cat['color'], radius: 6),
            ),
          ),
        );
      })..add(
        IconButton.filledTonal(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 20),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  void _handleSubmit() async {
    if (_nameController.text.isEmpty) return;

    if (_type == 'task') {
      await ref.read(taskRepositoryProvider).addTask(TasksCompanion.insert(
        title: _nameController.text,
        type: 'task',
        category: drift.Value(_selectedCategory),
        dueDate: drift.Value(_selectedDate.millisecondsSinceEpoch),
        dueTime: drift.Value(_selectedTime.format(context)),
      ));
    } else {
      await ref.read(scheduleRepositoryProvider).addEvent(ScheduleEventsCompanion.insert(
        title: _nameController.text,
        date: _selectedDate.millisecondsSinceEpoch,
        startTime: _selectedTime.format(context),
        endTime: TimeOfDay(hour: _selectedTime.hour + 1, minute: _selectedTime.minute).format(context),
        type: 'meeting',
      ));
    }

    if (mounted) Navigator.pop(context);
  }
}
