import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../providers/state_providers.dart';
import '../../providers/database_providers.dart';
import '../../data/database.dart';
import '../widgets/stat_card.dart';
import '../widgets/task_item.dart';
import '../widgets/schedule_event_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _entranceController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    final statsAsync = ref.watch(homeStatsProvider);
    final urgentItemsAsync = ref.watch(urgentItemsProvider);
    final priorityTasksAsync = ref.watch(priorityTasksProvider);
    final todayScheduleAsync = ref.watch(todayScheduleProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 700;
            
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  snap: true,
                  expandedHeight: 80,
                  backgroundColor: colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.green.withValues(alpha: 0.2),
                      child: const Icon(Icons.bolt, color: Colors.green),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Life Manager',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      Text(
                        'Manage your life here!',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.notifications_outlined, color: colorScheme.onSurfaceVariant),
                      onPressed: () {},
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 16.0, left: 8.0),
                      child: CircleAvatar(
                        radius: 16,
                        child: Text('D'),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : double.infinity),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _buildAnimatedSection(
                              index: 0,
                              child: _buildStatsSection(statsAsync, constraints.maxWidth),
                            ),
                            const SizedBox(height: 24),
                            _buildAnimatedSection(
                              index: 1,
                              child: Column(
                                children: [
                                  _buildSectionHeader('Urgent Tasks & Events', 'View All', () => context.go('/tasks')),
                                  _buildUrgentList(urgentItemsAsync),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildAnimatedSection(
                              index: 2,
                              child: Column(
                                children: [
                                  _buildSectionHeader('Priority Tasks', null, null, trailing: IconButton(
                                    icon: Icon(Icons.add, color: colorScheme.primary),
                                    onPressed: () {},
                                  )),
                                  _buildPriorityTasks(ref, priorityTasksAsync),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildAnimatedSection(
                              index: 3,
                              child: Column(
                                children: [
                                  _buildSectionHeader('Today\'s Schedule', DateFormat('EEE, MMM d').format(DateTime.now()), null),
                                  _buildScheduleTimeline(todayScheduleAsync),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildAnimatedSection(
                              index: 4,
                              child: _buildQuickNoteSection(ref),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({required int index, required Widget child}) {
    final start = (0.1 * index).clamp(0.0, 1.0);
    final end = (start + 0.4).clamp(0.0, 1.0);
    
    return FadeTransition(
      opacity: _entranceController.drive(
        CurveTween(curve: Interval(start, end, curve: Curves.easeOutCubic)),
      ),
      child: SlideTransition(
        position: _entranceController.drive(
          Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
              .chain(CurveTween(curve: Interval(start, end, curve: Curves.easeOutCubic))),
        ),
        child: child,
      ),
    );
  }

  Widget _buildStatsSection(AsyncValue<HomeStats> statsAsync, double width) {
    return statsAsync.when(
      data: (stats) {
        final isDesktop = width > 700;
        final crossAxisCount = isDesktop ? 4 : 2;
        // Use childAspectRatio to control height. Lower ratio = taller card.
        final aspectRatio = isDesktop ? 1.4 : 1.15; 
        
        return Column(
          children: [
            GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: aspectRatio,
              children: [
                StatCard(title: 'Tasks Done', value: stats.tasksDone.toDouble(), icon: Icons.check_circle_outline),
                StatCard(title: 'Pending', value: stats.pendingCount.toDouble(), icon: Icons.pending_actions_outlined),
                StatCard(title: 'Today Events', value: stats.upcomingEvents.toDouble(), icon: Icons.calendar_today_outlined),
                StatCard(title: 'Productivity', value: stats.productivityScore.toDouble(), unit: '%', icon: Icons.trending_up),
              ],
            ),
            const SizedBox(height: 12),
            StatCard(
              title: 'Productivity Score',
              value: stats.productivityScore.toDouble(),
              unit: '%',
              icon: Icons.auto_graph,
              isFullWidth: true,
              isHighlighted: true,
              progress: stats.productivityScore / 100,
            ),
          ],
        );
      },
      loading: () => _buildShimmerGrid(width),
      error: (e, st) => _buildErrorState(e, st, () => ref.refresh(homeStatsProvider)),
    );
  }

  Widget _buildShimmerGrid(double width) {
    final isDesktop = width > 700;
    final crossAxisCount = isDesktop ? 4 : 2;
    final aspectRatio = isDesktop ? 1.4 : 1.15;
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: aspectRatio,
      children: List.generate(4, (index) => const _ShimmerPlaceholder()),
    );
  }

  Widget _buildErrorState(Object error, StackTrace stack, VoidCallback onRetry) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Failed to load data', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? actionText, VoidCallback? onAction, {Widget? trailing}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              if (actionText != null && onAction == null)
                Text(actionText, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        if (actionText != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionText))
        else if (trailing != null)
          trailing,
      ],
    );
  }

  Widget _buildUrgentList(AsyncValue<List<dynamic>> itemsAsync) {
    return itemsAsync.when(
      data: (items) => items.isEmpty 
          ? _buildEmptyState('No urgent tasks or events.')
          : Column(
              children: items.map((item) {
                if (item is Task) {
                  return TaskItem(
                    task: item,
                    onToggle: () {
                      final newStatus = item.status == 'completed' ? 'not_started' : 'completed';
                      ref.read(taskRepositoryProvider).updateTask(item.copyWith(status: newStatus));
                    },
                    onTap: () => context.push('/task-detail/${item.id}'),
                  );
                } else if (item is ScheduleEvent) {
                  return ScheduleEventCard(event: item);
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
      loading: () => const _ShimmerPlaceholder(height: 100),
      error: (e, _) => Text('Error loading urgent items', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
    );
  }

  Widget _buildPriorityTasks(WidgetRef ref, AsyncValue<List<Task>> tasksAsync) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: tasksAsync.when(
          data: (tasks) => tasks.isEmpty 
              ? Padding(padding: const EdgeInsets.all(24.0), child: Center(child: Text('No high priority tasks', style: TextStyle(color: colorScheme.onSurfaceVariant))))
              : Column(
                  children: tasks.map((t) => TaskItem(
                    task: t,
                    onToggle: () {
                      final newStatus = t.status == 'completed' ? 'not_started' : 'completed';
                      ref.read(taskRepositoryProvider).updateTask(t.copyWith(status: newStatus));
                    },
                    onTap: () => context.push('/task-detail/${t.id}'),
                  )).toList(),
                ),
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Error loading tasks', style: TextStyle(color: colorScheme.onSurface)),
        ),
      ),
    );
  }

  Widget _buildScheduleTimeline(AsyncValue<List<ScheduleEvent>> scheduleAsync) {
    final colorScheme = Theme.of(context).colorScheme;
    return scheduleAsync.when(
      data: (events) => events.isEmpty
          ? _buildEmptyState('Nothing scheduled for today.')
          : Column(
              children: events.map((e) => IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 60,
                      child: Column(
                        children: [
                          Text(e.startTime, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.onSurface)),
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ScheduleEventCard(event: e),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading schedule', style: TextStyle(color: colorScheme.onSurface)),
    );
  }

  Widget _buildQuickNoteSection(WidgetRef ref) {
    final noteController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: noteController,
              maxLines: 3,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Type a quick thought...',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                border: InputBorder.none,
                filled: false,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (noteController.text.isNotEmpty) {
                    final note = NotesCompanion.insert(
                      content: noteController.text,
                    );
                    await ref.read(noteRepositoryProvider).addNote(note);
                    noteController.clear();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Note saved!')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Note'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  final double height;
  const _ShimmerPlaceholder({this.height = 80});

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(CurveTween(curve: Curves.easeInOut)),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
