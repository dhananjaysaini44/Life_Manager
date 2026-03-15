import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_providers.dart';
import '../data/database.dart';

final allEventsProvider = StreamProvider<List<ScheduleEvent>>((ref) {
  return ref.watch(scheduleRepositoryProvider).watchAllEvents();
});

final urgentItemsProvider = Provider<AsyncValue<List<dynamic>>>((ref) {
  final tasksAsync = ref.watch(allTasksProvider);
  final eventsAsync = ref.watch(allEventsProvider);

  return tasksAsync.when(
    data: (tasks) => eventsAsync.when(
      data: (events) {
        final urgentTasks = tasks.where((t) => t.priority == 'high' && t.status != 'completed').toList();
        final urgentEvents = events.where((e) {
          try {
            return !(e as dynamic).isCompleted;
          } catch (_) {
            return true; 
          }
        }).toList();
        
        return AsyncValue.data([...urgentTasks, ...urgentEvents]);
      },
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

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
  final int pendingCount;
  final int upcomingEvents;
  final int productivityScore;

  HomeStats({
    required this.tasksDone,
    required this.pendingCount,
    required this.upcomingEvents,
    required this.productivityScore,
  });
}

final homeStatsProvider = Provider<AsyncValue<HomeStats>>((ref) {
  final tasksAsync = ref.watch(allTasksProvider);
  final eventsAsync = ref.watch(allEventsProvider);

  return tasksAsync.when(
    data: (tasks) => eventsAsync.when(
      data: (events) {
        final doneTasks = tasks.where((t) => t.status == 'completed').length;
        final pendingTasks = tasks.where((t) => t.status != 'completed').length;
        
        final doneEvents = events.where((e) {
          try {
            return (e as dynamic).isCompleted;
          } catch (_) {
            return false;
          }
        }).length;

        final pendingEvents = events.where((e) {
          try {
            return !(e as dynamic).isCompleted;
          } catch (_) {
            return true;
          }
        }).length;
        
        final totalDone = doneTasks + doneEvents;
        final totalItems = tasks.length + events.length;
        
        final productivity = totalItems == 0 ? 0 : ((totalDone / totalItems) * 100).toInt();
        
        // Today's upcoming events
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
        final upcomingToday = events.where((e) {
          final isToday = e.date == startOfDay;
          try {
            return isToday && !(e as dynamic).isCompleted;
          } catch (_) {
            return isToday;
          }
        }).length;

        return AsyncValue.data(HomeStats(
          tasksDone: doneTasks,
          pendingCount: pendingTasks + pendingEvents,
          upcomingEvents: upcomingToday,
          productivityScore: productivity,
        ));
      },
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
