import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

/// The main dashboard screen showing active and completed tasks/events.
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the TaskProvider to get current items
    final taskProvider = Provider.of<TaskProvider>(context);
    final activeItems = taskProvider.activeItems;
    final completedItems = taskProvider.completedItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Manager'),
      ),
      body: activeItems.isEmpty && completedItems.isEmpty
          ? const Center(child: Text('Nothing to manage yet. Add tasks or events!'))
          : CustomScrollView(
              slivers: [
                // Section for Active items
                if (activeItems.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Active Tasks & Events',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _ItemTile(item: activeItems[index]);
                    },
                    childCount: activeItems.length,
                  ),
                ),
                // Section for Completed items
                if (completedItems.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Completed Tasks & Events',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                  ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _ItemTile(item: completedItems[index]);
                    },
                    childCount: completedItems.length,
                  ),
                ),
                // Padding for the FloatingActionButton
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Displays a dialog to either create a new item or edit an existing one.
  void _showItemDialog(BuildContext context, {LifeItem? item}) {
    final titleController = TextEditingController(text: item?.title ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    ItemType selectedType = item?.type ?? ItemType.task;
    DateTime? selectedDate = item?.dateTime;
    final isEditing = item != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit ${selectedType.name}' : 'Add New'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Toggle between Task and Event
                SegmentedButton<ItemType>(
                  segments: const [
                    ButtonSegment(value: ItemType.task, label: Text('Task'), icon: Icon(Icons.task)),
                    ButtonSegment(value: ItemType.event, label: Text('Event'), icon: Icon(Icons.event)),
                  ],
                  selected: {selectedType},
                  onSelectionChanged: (Set<ItemType> newSelection) {
                    setState(() => selectedType = newSelection.first);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                // Date picker specifically for events
                if (selectedType == ItemType.event) ...[
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(selectedDate == null 
                      ? 'Pick Date & Time' 
                      : DateFormat('MMM d, yyyy - HH:mm').format(selectedDate!)),
                    trailing: const Icon(Icons.calendar_today),
                    shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date == null) return;
                      
                      if (!context.mounted) return;
                      
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
                      );
                      
                      if (time != null) {
                        setState(() {
                          selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      }
                    },
                  ),
                  const Text(
                    'You will be alerted 15m before start',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final provider = Provider.of<TaskProvider>(context, listen: false);
                  if (isEditing) {
                    provider.updateItem(item.id, titleController.text, descController.text, selectedDate);
                  } else {
                    provider.addItem(
                      title: titleController.text,
                      description: descController.text,
                      type: selectedType,
                      dateTime: selectedDate,
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper widget to represent a single row (task or event) in the list.
class _ItemTile extends StatelessWidget {
  final LifeItem item;
  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final bool isEvent = item.type == ItemType.event;

    return Dismissible(
      key: Key(item.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => provider.deleteItem(item.id),
      child: ListTile(
        leading: Checkbox(
          value: item.isCompleted,
          onChanged: (_) => provider.toggleItemStatus(item.id),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: isEvent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description),
            if (isEvent && item.dateTime != null)
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.deepPurple),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, HH:mm').format(item.dateTime!),
                    style: const TextStyle(fontSize: 12, color: Colors.deepPurple, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
          ],
        ),
        trailing: Icon(
          isEvent ? Icons.event : Icons.task_alt,
          color: isEvent ? Colors.orange : Colors.green,
          size: 20,
        ),
        onTap: () => const TasksScreen()._showItemDialog(context, item: item),
      ),
    );
  }
}
