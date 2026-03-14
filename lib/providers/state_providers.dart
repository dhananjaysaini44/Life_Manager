import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_providers.dart';
import '../data/database.dart';

final activeProjectsProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).watchAllProjects();
});

final priorityTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAllTasks().map(
        (tasks) => tasks
            .where((t) => t.priority == 'high' && t.status != 'completed')
            .toList(),
      );
});

final todayScheduleProvider = StreamProvider<List<ScheduleEvent>>((ref) {
  return ref.watch(scheduleRepositoryProvider).watchEventsByDate(DateTime.now());
});

final allTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAllTasks();
});

final taskDetailProvider = StreamProviderFamily<Task, String>((ref, taskId) {
  return ref.watch(taskRepositoryProvider).watchTaskById(taskId);
});

final subTasksByTaskProvider = StreamProviderFamily<List<SubTask>, String>((ref, taskId) {
  return ref.watch(subTaskRepositoryProvider).watchSubTasksByParentId(taskId);
});

final scheduleByDateProvider = StreamProviderFamily<List<ScheduleEvent>, DateTime>((ref, date) {
  return ref.watch(scheduleRepositoryProvider).watchEventsByDate(date);
});

final notesProvider = StreamProvider<List<Note>>((ref) {
  return ref.watch(noteRepositoryProvider).watchAllNotes();
});

class HomeStats {
  final int tasksDone;
  final int focusHours;
  final int upcomingEvents;
  final int productivityScore;

  HomeStats({
    required this.tasksDone,
    required this.focusHours,
    required this.upcomingEvents,
    required this.productivityScore,
  });
}

final homeStatsProvider = Provider<AsyncValue<HomeStats>>((ref) {
  final tasksAsync = ref.watch(allTasksProvider);
  final eventsAsync = ref.watch(todayScheduleProvider);

  return tasksAsync.when(
    data: (tasks) => eventsAsync.when(
      data: (events) {
        final done = tasks.where((t) => t.status == 'completed').length;
        return AsyncValue.data(HomeStats(
          tasksDone: done,
          focusHours: 5, // Mocked
          upcomingEvents: events.length,
          productivityScore: 85, // Mocked
        ));
      },
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
