import 'package:drift/drift.dart';
import '../database.dart';

class SubTaskRepository {
  final SubTasksDao _subTasksDao;
  SubTaskRepository(this._subTasksDao);

  Future<int> addSubTask(SubTasksCompanion subTask) => _subTasksDao.insertSubTask(subTask);
  Future<bool> updateSubTask(SubTask subTask) => _subTasksDao.updateSubTask(subTask);
  Future toggleSubTaskCompletion(String id, bool completed) => _subTasksDao.toggleSubTaskCompletion(id, completed);
  Stream<List<SubTask>> watchSubTasksByParentId(String parentId) => _subTasksDao.watchSubTasksByParentId(parentId);
}
