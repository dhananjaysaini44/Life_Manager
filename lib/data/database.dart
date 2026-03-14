import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

part 'database.g.dart';

class Tasks extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get type => text()(); // 'task' | 'event'
  TextColumn get priority => text().withDefault(const Constant('medium'))(); // 'high' | 'medium' | 'low'
  TextColumn get status => text().withDefault(const Constant('not_started'))(); // 'not_started' | 'in_progress' | 'completed'
  IntColumn get dueDate => integer().nullable()(); // timestamp ms
  TextColumn get dueTime => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get projectId => text().nullable().references(Projects, #id)();
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  @override
  Set<Column> get primaryKey => {id};
}

class Projects extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get name => text()();
  IntColumn get deadline => integer().nullable()();
  IntColumn get progressPercent => integer().withDefault(const Constant(0))();
  TextColumn get colorTag => text()(); // hex string

  @override
  Set<Column> get primaryKey => {id};
}

class SubTasks extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get parentTaskId => text().references(Tasks, #id)();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get hasAttachment => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ScheduleEvents extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get title => text()();
  IntColumn get date => integer()(); // timestamp ms
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();
  TextColumn get location => text().nullable()();
  TextColumn get platform => text().nullable()();
  TextColumn get type => text()(); // 'meeting' | 'design' | 'personal' | 'review'
  TextColumn get attendees => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Notes extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get content => text()();
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Tasks, Projects, SubTasks, ScheduleEvents, Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'life_manager_db');
  }

  Future<void> clearAllData() {
    return transaction(() async {
      await delete(subTasks).go();
      await delete(tasks).go();
      await delete(projects).go();
      await delete(scheduleEvents).go();
      await delete(notes).go();
    });
  }
}

// DAOs
@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);
  Future<int> insertTask(TasksCompanion data) => into(tasks).insert(data);
  Future<bool> updateTask(Insertable<Task> data) => update(tasks).replace(data);
  Future<int> deleteTask(String id) => (delete(tasks)..where((t) => t.id.equals(id))).go();
  Stream<List<Task>> watchAllTasks() => select(tasks).watch();
  Stream<Task> watchTaskById(String id) => (select(tasks)..where((t) => t.id.equals(id))).watchSingle();
  Stream<List<Task>> watchTasksByStatus(String status) => (select(tasks)..where((t) => t.status.equals(status))).watch();
  Stream<List<Task>> watchTasksByCategory(String category) => (select(tasks)..where((t) => t.category.equals(category))).watch();
}

@DriftAccessor(tables: [Projects])
class ProjectsDao extends DatabaseAccessor<AppDatabase> with _$ProjectsDaoMixin {
  ProjectsDao(super.db);
  Future<int> insertProject(ProjectsCompanion data) => into(projects).insert(data);
  Future<bool> updateProject(Insertable<Project> data) => update(projects).replace(data);
  Future<int> deleteProject(String id) => (delete(projects)..where((p) => p.id.equals(id))).go();
  Stream<List<Project>> watchAllProjects() => select(projects).watch();
  Stream<Project> watchProjectById(String id) => (select(projects)..where((p) => p.id.equals(id))).watchSingle();
}

@DriftAccessor(tables: [SubTasks])
class SubTasksDao extends DatabaseAccessor<AppDatabase> with _$SubTasksDaoMixin {
  SubTasksDao(super.db);
  Future<int> insertSubTask(SubTasksCompanion data) => into(subTasks).insert(data);
  Future<bool> updateSubTask(Insertable<SubTask> data) => update(subTasks).replace(data);
  Future toggleSubTaskCompletion(String id, bool completed) => (update(subTasks)..where((st) => st.id.equals(id))).write(SubTasksCompanion(isCompleted: Value(completed)));
  Stream<List<SubTask>> watchSubTasksByParentId(String parentId) => (select(subTasks)..where((st) => st.parentTaskId.equals(parentId))).watch();
}

@DriftAccessor(tables: [ScheduleEvents])
class ScheduleEventsDao extends DatabaseAccessor<AppDatabase> with _$ScheduleEventsDaoMixin {
  ScheduleEventsDao(super.db);
  Future<int> insertEvent(ScheduleEventsCompanion data) => into(scheduleEvents).insert(data);
  Future<bool> updateEvent(Insertable<ScheduleEvent> data) => update(scheduleEvents).replace(data);
  Future<int> deleteEvent(String id) => (delete(scheduleEvents)..where((e) => e.id.equals(id))).go();
  Stream<List<ScheduleEvent>> watchEventsByDate(int dateTimestamp) => (select(scheduleEvents)..where((e) => e.date.equals(dateTimestamp))).watch();
  Stream<List<ScheduleEvent>> watchAllEvents() => select(scheduleEvents).watch();
}

@DriftAccessor(tables: [Notes])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);
  Future<int> insertNote(NotesCompanion data) => into(notes).insert(data);
  Future<int> deleteNote(String id) => (delete(notes)..where((n) => n.id.equals(id))).go();
  Stream<List<Note>> watchAllNotes() => select(notes).watch();
}
