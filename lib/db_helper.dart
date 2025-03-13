// the DBHelper class provides a way to interact with the database stored in
// the internal storage of the device on which the application runs

// the database is used to persist data across app restarts

// this particular snipet of code will not work on web applications

import './models.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

enum Type {
  note,
  todo,
}

class DBHelper {
  // to open the database
  static Future<Database> _database(Type type) async {
    final dbPath = await sql.getDatabasesPath();
    return await sql.openDatabase(
      path.join(dbPath, type == Type.note ? 'notes.db' : 'todos.db'),
      version: 1,
      onCreate: (db, version) {
        type == Type.note
            ? db.execute(
                'CREATE TABLE notes (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, lastEdited TEXT)')
            : db.execute(
                'CREATE TABLE todos (id INTEGER PRIMARY KEY AUTOINCREMENT, action TEXT, addedOn TEXT, isDone BOOL)');
      },
    );
  }

  // to fetch notes from the database when the app starts
  static Future<List<Map<String, dynamic>>> fetchNotes() async {
    final db = await _database(Type.note);
    return await db.query('notes', orderBy: 'lastEdited');
  }

  // to add notes to the database
  static Future<void> addNote(Note note) async {
    final db = await _database(Type.note);
    db.execute(
        'INSERT INTO notes (title, content, lastEdited) VALUES(\'${note.title}\', \'${note.content}\', \'${note.lastEdited.toIso8601String()}\')');
  }

  // to delete notes from the database
  static Future<void> deleteNote(int id) async {
    final db = await _database(Type.note);
    await db.execute('DELETE FROM notes WHERE id = $id');
  }

  // to update existing notes in the database
  static Future<void> updateNote(Note note) async {
    final db = await _database(Type.note);
    final id = int.parse(note.id);
    await db.execute(
      'UPDATE notes SET title = \'${note.title}\', '
      'content = \'${note.content}\', '
      'lastEdited = \'${note.lastEdited.toIso8601String()}\' '
      'WHERE id = $id',
    );
  }

  // to fetch to-dos from the database when the app starts
  static Future<List<Map<String, dynamic>>> fetchToDos() async {
    final db = await _database(Type.todo);
    final list = await db.query('todos', orderBy: 'addedOn');
    return list;
  }

  // to add to-dos to the database
  static Future<void> addToDo(ToDo todo) async {
    final db = await _database(Type.todo);
    db.execute(
      'INSERT INTO todos (action, addedOn, isDone) '
      'VALUES (\'${todo.action}\', \'${todo.addedOn.toIso8601String()}\','
      ' \'${todo.isDone}\')',
    );
  }

  // to toggle to-dos between completed and incomplete
  static Future<void> toggleToDoCompletion(ToDo todo) async {
    final db = await _database(Type.todo);
    await db.update(
      'todos',
      {'isDone': (!todo.isDone).toString()},
      where: 'id = ${todo.id}',
    );
  }

  // to delete completed to-dos from the database
  static Future<void> deleteCompletedToDos() async {
    final db = await _database(Type.todo);
    await db.delete('todos', where: 'isDone = \'true\'');
  }
}
