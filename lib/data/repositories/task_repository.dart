import 'package:drift/drift.dart';
import '../database.dart';

class TaskRepository {
  final TasksDao _tasksDao;
  TaskRepository(this._tasksDao);

  Future<int> addTask(TasksCompanion task) => _tasksDao.insertTask(task);
  Future<bool> updateTask(Task task) => _tasksDao.updateTask(task);
  Future<int> deleteTask(String id) => _tasksDao.deleteTask(id);
  Stream<List<Task>> watchAllTasks() => _tasksDao.watchAllTasks();
  Stream<Task> watchTaskById(String id) => _tasksDao.watchTaskById(id);
  Stream<List<Task>> watchTasksByStatus(String status) => _tasksDao.watchTasksByStatus(status);
}
