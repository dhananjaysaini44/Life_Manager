import 'package:drift/drift.dart';
import '../database.dart';

class ScheduleRepository {
  final ScheduleEventsDao _scheduleEventsDao;
  ScheduleRepository(this._scheduleEventsDao);

  Future<int> addEvent(ScheduleEventsCompanion event) => _scheduleEventsDao.insertEvent(event);
  Future<bool> updateEvent(ScheduleEvent event) => _scheduleEventsDao.updateEvent(event);
  Future<int> deleteEvent(String id) => _scheduleEventsDao.deleteEvent(id);
  Stream<List<ScheduleEvent>> watchEventsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    return _scheduleEventsDao.watchEventsByDate(startOfDay);
  }
  Stream<List<ScheduleEvent>> watchAllEvents() => _scheduleEventsDao.watchAllEvents();
}
