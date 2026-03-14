import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database.dart';
import 'package:uuid/uuid.dart';

class SeedDataService {
  final AppDatabase db;
  SeedDataService(this.db);

  Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final seeded = prefs.getBool('seeded') ?? false;

    if (!seeded) {
      await _seedData();
      await prefs.setBool('seeded', true);
    }
  }

  Future<void> _seedData() async {
    const uuid = Uuid();
    
    // Projects
    final project1Id = uuid.v4();
    final project2Id = uuid.v4();
    
    await db.into(db.projects).insert(ProjectsCompanion.insert(
      id: Value(project1Id),
      name: 'Mobile App UI Redesign',
      progressPercent: const Value(65),
      deadline: Value(DateTime.now().add(const Duration(days: 14)).millisecondsSinceEpoch),
      colorTag: '#22C55E',
    ));

    await db.into(db.projects).insert(ProjectsCompanion.insert(
      id: Value(project2Id),
      name: 'Brand Identity Design',
      progressPercent: const Value(32),
      deadline: Value(DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch),
      colorTag: '#A78BFA',
    ));

    // Task with sub-tasks
    final taskId = uuid.v4();
    await db.into(db.tasks).insert(TasksCompanion.insert(
      id: Value(taskId),
      title: 'Finalize Project Proposal',
      type: 'task',
      priority: const Value('high'),
      status: const Value('in_progress'),
      dueDate: Value(DateTime.now().millisecondsSinceEpoch),
      projectId: Value(project1Id),
    ));

    await db.into(db.subTasks).insert(SubTasksCompanion.insert(
      parentTaskId: taskId,
      title: 'Verify budget calculations',
      isCompleted: const Value(true),
    ));
    await db.into(db.subTasks).insert(SubTasksCompanion.insert(
      parentTaskId: taskId,
      title: 'Export PDF from design tool',
      isCompleted: const Value(true),
    ));
    await db.into(db.subTasks).insert(SubTasksCompanion.insert(
      parentTaskId: taskId,
      title: 'Coordinate with legal on section 4',
      hasAttachment: const Value(true),
    ));
    await db.into(db.subTasks).insert(SubTasksCompanion.insert(
      parentTaskId: taskId,
      title: 'Email proposal to stakeholders',
    ));

    // Priority Tasks
    await db.into(db.tasks).insert(TasksCompanion.insert(
      title: 'Review API documentation',
      type: 'task',
      priority: const Value('high'),
      dueDate: Value(DateTime.now().millisecondsSinceEpoch),
      dueTime: const Value('05:00 PM'),
    ));

    await db.into(db.tasks).insert(TasksCompanion.insert(
      title: 'Client feedback meeting',
      type: 'task',
      priority: const Value('high'),
      dueDate: Value(DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch),
      dueTime: const Value('10:00 AM'),
    ));

    // Schedule Events
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).millisecondsSinceEpoch;
    
    await db.into(db.scheduleEvents).insert(ScheduleEventsCompanion.insert(
      title: 'Standup Meeting',
      date: today,
      startTime: '09:00',
      endTime: '09:30',
      platform: const Value('Zoom Call'),
      type: 'meeting',
    ));

    await db.into(db.scheduleEvents).insert(ScheduleEventsCompanion.insert(
      title: 'Deep Work Session',
      date: today,
      startTime: '11:30',
      endTime: '13:30',
      platform: const Value('Project Alpha'),
      type: 'design',
    ));

    await db.into(db.scheduleEvents).insert(ScheduleEventsCompanion.insert(
      title: 'UI Review',
      date: today,
      startTime: '14:00',
      endTime: '15:00',
      platform: const Value('Design Team'),
      type: 'review',
    ));
  }
}
