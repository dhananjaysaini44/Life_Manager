import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/state_providers.dart';
import '../../providers/database_providers.dart';
import '../../data/database.dart';
import '../widgets/sub_task_item.dart';
import 'package:drift/drift.dart' as drift;

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _chipController;

  @override
  void initState() {
    super.initState();
    _chipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _chipController.forward();
  }

  @override
  void dispose() {
    _chipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));
    final subTasksAsync = ref.watch(subTasksByTaskProvider(widget.taskId));
    final colorScheme = Theme.of(context).colorScheme;

    return taskAsync.when(
      data: (task) {
        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text('Task Details', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'delete') {
                    ref.read(taskRepositoryProvider).deleteTask(task.id);
                    Navigator.pop(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.projectId != null)
                          Text(
                            'PROJECT: ${task.projectId!.substring(0, 8).toUpperCase()}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colorScheme.secondary,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildAnimatedChip(
                              0,
                              _buildStatusChip(
                                context,
                                Icons.flag_outlined,
                                task.priority.toUpperCase(),
                                colorScheme.errorContainer,
                                colorScheme.onErrorContainer,
                              ),
                            ),
                            _buildAnimatedChip(
                              1,
                              _buildStatusChip(
                                context,
                                Icons.schedule,
                                task.dueDate != null 
                                    ? DateFormat('MMM d').format(DateTime.fromMillisecondsSinceEpoch(task.dueDate!))
                                    : 'No date',
                                colorScheme.secondaryContainer,
                                colorScheme.onSecondaryContainer,
                              ),
                            ),
                            _buildAnimatedChip(
                              2,
                              _buildStatusChip(
                                context,
                                Icons.autorenew,
                                task.status.replaceAll('_', ' ').toUpperCase(),
                                colorScheme.primaryContainer,
                                colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildSectionLabel(context, 'DESCRIPTION'),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 0,
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              task.description ?? 'No description provided.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        subTasksAsync.when(
                          data: (subTasks) {
                            final completedCount = subTasks.where((st) => st.isCompleted).length;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildSectionLabel(context, 'SUB-TASKS ($completedCount/${subTasks.length})'),
                                    TextButton.icon(
                                      onPressed: () => _showAddSubTaskDialog(context, ref),
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Add Task'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: subTasks.length,
                                  itemBuilder: (context, index) {
                                    final st = subTasks[index];
                                    return SubTaskItem(
                                      subTask: st,
                                      onToggle: () => ref.read(subTaskRepositoryProvider).toggleSubTaskCompletion(st.id, !st.isCompleted),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Error: $e'),
                        ),
                        const SizedBox(height: 32),
                        _buildSectionLabel(context, 'ASSIGNEES'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const CircleAvatar(radius: 16, child: Text('JD')),
                            const SizedBox(width: 8),
                            const CircleAvatar(radius: 16, child: Text('AS')),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: colorScheme.surfaceVariant,
                              child: Text('+2', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(taskRepositoryProvider).updateTask(task.copyWith(status: 'completed'));
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Mark as Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.inverseSurface,
                      foregroundColor: colorScheme.onInverseSurface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildAnimatedChip(int index, Widget child) {
    final start = index * 0.1;
    final end = (start + 0.5).clamp(0.0, 1.0);
    return SlideTransition(
      position: _chipController.drive(
        Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero)
            .chain(CurveTween(curve: Interval(start, end, curve: Curves.easeOutCubic))),
      ),
      child: FadeTransition(
        opacity: _chipController.drive(
          CurveTween(curve: Interval(start, end, curve: Curves.easeIn)),
        ),
        child: child,
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
    );
  }

  Widget _buildStatusChip(BuildContext context, IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSubTaskDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Sub-task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Sub-task title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(subTaskRepositoryProvider).addSubTask(SubTasksCompanion.insert(
                  parentTaskId: widget.taskId,
                  title: controller.text,
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
