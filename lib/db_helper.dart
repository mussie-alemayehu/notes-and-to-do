import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

import './models.dart';

enum Type {
  note,
  todo,
}

class DBHelper {
  // to open the database
  static Future<Database> _database(Type type) async {
    final dbPath = await sql.getDatabasesPath();
    final dbName = type == Type.note ? 'notes.db' : 'todos.db';
    final fullPath = path.join(dbPath, dbName);

    // Check if database exists before opening, useful for migrations
    // This is a simple onCreate, migrations would be more complex
    return await sql.openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, version) {
        if (type == Type.note) {
          return db.execute(
            'CREATE TABLE notes ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'firebaseId TEXT UNIQUE, '
            'title TEXT, '
            'content TEXT, '
            'lastEdited TEXT, '
            'syncStatus TEXT DEFAULT \'synced\', '
            'clientTimestamp INTEGER'
            ')',
          );
        } else {
          // Type.todo
          return db.execute(
            'CREATE TABLE todos ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'firebaseId TEXT UNIQUE, '
            'action TEXT, '
            'addedOn TEXT, '
            'isDone INTEGER, '
            'syncStatus TEXT DEFAULT \'synced\', '
            'clientTimestamp INTEGER'
            ')',
          );
        }
      },
    );
  }

  static Future<void> closeDatabase(Type type) async {
    final db = await _database(type);
    await db.close();
  }

  // --- Fetch methods (returning List of Models) ---

  /// to fetch notes from the database when the app starts or needs refreshing
  static Future<List<Note>> fetchNotes() async {
    final db = await _database(Type.note);
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy:
          'lastEdited DESC', // Usually order by last edited descending for notes
    );

    // Convert the List<Map<String, dynamic>> into a List<Note>.
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  /// to fetch to-dos from the database when the app starts or needs refreshing
  static Future<List<ToDo>> fetchToDos() async {
    final db = await _database(Type.todo);
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      orderBy: 'addedOn ASC', // Order by added date ascending for todos
    );

    // Convert the List<Map<String, dynamic>> into a List<ToDo>.
    return List.generate(maps.length, (i) {
      return ToDo.fromMap(maps[i]);
    });
  }

  // --- CRUD methods (refactored and including sync metadata) ---
  /// to add notes to the database
  static Future<int> addNote(Note note) async {
    final db = await _database(Type.note);
    // Use the toMap helper from the Note model
    // Note: We do NOT set 'id' here; SQLite AUTOINCREMENT handles it
    final Map<String, dynamic> data = note.toMap();

    // Ensure syncStatus and clientTimestamp are set for a new item
    data['syncStatus'] = 'pending_create';
    data['clientTimestamp'] = DateTime.now().millisecondsSinceEpoch;

    // Using db.insert is safe and returns the new row's id
    return await db.insert(
      'notes',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// to delete notes from the database (soft delete for syncing)
  /// We mark as 'pending_delete' instead of immediate deletion
  static Future<void> deleteNote(String id) async {
    final db = await _database(Type.note);
    // We don't actually delete yet. Mark for deletion and update timestamp.
    // The sync service will perform the actual deletion after syncing with Firebase.
    await db.update(
      'notes',
      {
        'syncStatus': 'pending_delete',
        'clientTimestamp': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// to update existing notes in the database
  static Future<int> updateNote(Note note) async {
    final db = await _database(Type.note);
    final Map<String, dynamic> data = note.toMap();
    // Always mark as pending update and update timestamp on local edit
    data['syncStatus'] = 'pending_update';
    data['clientTimestamp'] = DateTime.now().millisecondsSinceEpoch;

    // Using db.update is safe and returns the number of rows affected
    return await db.update(
      'notes',
      data,
      where: 'id = ?',
      whereArgs: [note.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// to add to-dos to the database
  static Future<int> addToDo(ToDo todo) async {
    final db = await _database(Type.todo);
    final Map<String, dynamic> data = todo.toMap();
    // Ensure syncStatus and clientTimestamp are set for a new item
    data['syncStatus'] = 'pending_create';
    data['clientTimestamp'] = DateTime.now().millisecondsSinceEpoch;

    // Using db.insert is safe and returns the new row's id
    return await db.insert(
      'todos',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// to toggle to-dos between completed and incomplete (update)
  static Future<int> toggleToDoCompletion(ToDo todo) async {
    final db = await _database(Type.todo);

    // Use the toMap helper
    final Map<String, dynamic> data = todo.toMap();

    return await db.update(
      'todos',
      data,
      where: 'id = ?',
      whereArgs: [todo.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// to delete completed to-dos from the database (soft delete for syncing)
  /// We mark as 'pending_delete' instead of immediate deletion
  /// This method will now mark *all* completed todos for deletion
  static Future<void> deleteCompletedToDos() async {
    final db = await _database(Type.todo);
    // Mark all todos where isDone is 1 (true) for deletion
    await db.update(
      'todos',
      {
        'syncStatus': 'pending_delete',
        'clientTimestamp': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'isDone = ?', // isDone is stored as INTEGER
      whereArgs: [1], // 1 represents true
    );
  }

  // --- Sync Service ---

  /// Method to permanently delete a record after it's synced (used by sync service)
  static Future<void> permanentDeleteItem(Type type, String localId) async {
    final db = await _database(type);
    final table = type == Type.note ? 'notes' : 'todos';

    await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  /// Method to update an item's Firebase ID and set status to synced (used by sync service)
  static Future<int> updateItemFirebaseIdAndStatus(
    Type type,
    String localId,
    String firebaseId,
  ) async {
    final db = await _database(type);
    final table = type == Type.note ? 'notes' : 'todos';

    return await db.update(
      table,
      {
        'firebaseId': firebaseId,
        'syncStatus': 'synced',
        // clientTimestamp is not updated here, only on local edits
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  /// Method to update a local item with changes pulled from Firebase (used by sync service)
  static Future<int> updateItemFromFirebase(
    Type type,
    Map<String, dynamic> firebaseData,
  ) async {
    final db = await _database(type);
    final table = type == Type.note ? 'notes' : 'todos';

    // Ensure the data map includes the firebaseId and sets syncStatus to synced
    firebaseData['syncStatus'] = 'synced';
    // Note: clientTimestamp in the local DB might differ from a timestamp in firebaseData.
    // The sync logic in the sync service decides which version wins based on timestamps *before* calling this.
    // We overwrite the local clientTimestamp when applying the synced version.
    firebaseData['clientTimestamp'] = DateTime.now()
        .millisecondsSinceEpoch; // Or use a timestamp from firebaseData if appropriate for the model

    return await db.update(
      table,
      firebaseData,
      where: 'firebaseId = ?', // Match using firebaseId
      whereArgs: [firebaseData['firebaseId']],
    );
  }

  /// Method to add an item pulled from Firebase that doesn't exist locally (used by sync service)
  static Future<int> insertItemFromFirebase(
      Type type, Map<String, dynamic> firebaseData) async {
    final db = await _database(type);
    final table = type == Type.note ? 'notes' : 'todos';
    // Ensure the data map includes the firebaseId and sets syncStatus to synced
    firebaseData['syncStatus'] = 'synced';
    firebaseData['clientTimestamp'] = DateTime.now()
        .millisecondsSinceEpoch; // Or use a timestamp from firebaseData

    return await db.insert(
      table,
      firebaseData,
      conflictAlgorithm: ConflictAlgorithm
          .ignore, // Ignore if an item with the same firebaseId somehow exists
    );
  }

  /// Method to fetch all items that are not synced (used by sync service to push)
  static Future<List<Map<String, dynamic>>> fetchPendingItems(Type type) async {
    final db = await _database(type);
    final table = type == Type.note ? 'notes' : 'todos';

    return await db.query(
      table,
      where: 'syncStatus != ?',
      whereArgs: ['synced'],
    );
  }

  /// Method to update the sync status of an item (e.g., from 'pending_create' to 'synced', or to 'sync_error')
  static Future<int> updateItemSyncStatus(
      Type type, String localId, String status) async {
    final db = await _database(type);
    final table = type == Type.note ? 'notes' : 'todos';

    return await db.update(
      table,
      {'syncStatus': status},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // --- Clear Methods ---

  /// clear all data [Type] in local storage
  static Future<void> clearAllData(Type type) async {
    final db = await _database(type);

    await db.delete(
      type == Type.note ? 'notes' : 'todos',
    );
  }
}
