import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/state_providers.dart';
import '../../providers/database_providers.dart';
import '../widgets/task_item.dart';
import '../widgets/quick_add_sheet.dart';
import 'task_detail_screen.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String _selectedFilter = 'All';
  String? _selectedTaskId;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(allTasksProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final isTwoPane = width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: isTwoPane ? 1 : 2,
              child: Column(
                children: [
                  _buildFilterChips(),
                  Expanded(
                    child: tasksAsync.when(
                      data: (tasks) {
                        final filteredTasks = _filterTasks(tasks);
                        if (filteredTasks.isEmpty) {
                          return _buildEmptyState();
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            final isSelected = _selectedTaskId == task.id;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Container(
                                decoration: isTwoPane && isSelected
                                    ? BoxDecoration(
                                        color: colorScheme.primaryContainer.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      )
                                    : null,
                                child: TaskItem(
                                  task: task,
                                  onToggle: () {
                                    final newStatus = task.status == 'completed' ? 'not_started' : 'completed';
                                    ref.read(taskRepositoryProvider).updateTask(task.copyWith(status: newStatus));
                                  },
                                  onTap: () {
                                    if (isTwoPane) {
                                      setState(() => _selectedTaskId = task.id);
                                    } else {
                                      context.push('/task-detail/${task.id}');
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),
                  ),
                ],
              ),
            ),
            if (isTwoPane) ...[
              const VerticalDivider(width: 1),
              Expanded(
                flex: 2,
                child: _selectedTaskId == null
                    ? Center(
                        child: Text(
                          'Select a task to view details',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : TaskDetailScreen(taskId: _selectedTaskId!, key: ValueKey(_selectedTaskId)),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const QuickAddBottomSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Active', 'Completed', 'High Priority'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist_rtl, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No tasks yet. Tap + to add one.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterTasks(List<dynamic> tasks) {
    switch (_selectedFilter) {
      case 'Active':
        return tasks.where((t) => t.status != 'completed').toList();
      case 'Completed':
        return tasks.where((t) => t.status == 'completed').toList();
      case 'High Priority':
        return tasks.where((t) => t.priority == 'high').toList();
      default:
        return tasks;
    }
  }
}
