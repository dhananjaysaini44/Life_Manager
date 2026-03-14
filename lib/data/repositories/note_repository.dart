import 'package:drift/drift.dart';
import '../database.dart';

class NoteRepository {
  final NotesDao _notesDao;
  NoteRepository(this._notesDao);

  Future<int> addNote(NotesCompanion note) => _notesDao.insertNote(note);
  Future<int> deleteNote(String id) => _notesDao.deleteNote(id);
  Stream<List<Note>> watchAllNotes() => _notesDao.watchAllNotes();
}
