import 'package:drift/drift.dart';
import '../database.dart';

class ProjectRepository {
  final ProjectsDao _projectsDao;
  ProjectRepository(this._projectsDao);

  Future<int> addProject(ProjectsCompanion project) => _projectsDao.insertProject(project);
  Future<bool> updateProject(Project project) => _projectsDao.updateProject(project);
  Future<int> deleteProject(String id) => _projectsDao.deleteProject(id);
  Stream<List<Project>> watchAllProjects() => _projectsDao.watchAllProjects();
  Stream<Project> watchProjectById(String id) => _projectsDao.watchProjectById(id);
}
