import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import '../data/repositories/task_repository.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/subtask_repository.dart';
import '../data/repositories/schedule_repository.dart';
import '../data/repositories/note_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TaskRepository(TasksDao(db));
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ProjectRepository(ProjectsDao(db));
});

final subTaskRepositoryProvider = Provider<SubTaskRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SubTaskRepository(SubTasksDao(db));
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ScheduleRepository(ScheduleEventsDao(db));
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return NoteRepository(NotesDao(db));
});
