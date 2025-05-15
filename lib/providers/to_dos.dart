// lib/providers/to_dos.dart

// provides to-dos to the whole app during runtime

import 'package:flutter/material.dart';

import '../db_helper.dart';
import '../models.dart';

class ToDos with ChangeNotifier {
  // to keep track of all to-dos in the app
  List<ToDo> _todos = [];

  // Callback function to request a sync push
  VoidCallback? _requestSyncPush;

  // Method to set the sync request callback
  void setSyncRequestCallback(VoidCallback callback) {
    _requestSyncPush = callback;
  }

  // returns the list of completed to-dos (filtering out pending deletes)
  List<ToDo> get completedToDos {
    final list = _todos
        .where((todo) =>
            todo.isDone == true && todo.syncStatus != 'pending_delete')
        .toList()
      ..sort((a, b) => b.addedOn.compareTo(a.addedOn));

    return list;
  }

  // returns the list of incomplete to-dos (filtering out pending deletes)
  List<ToDo> get incompleteToDos {
    final list = _todos
        .where((todo) =>
            todo.isDone == false && todo.syncStatus != 'pending_delete')
        .toList()
      ..sort((a, b) => b.addedOn.compareTo(a.addedOn));

    return list;
  }

  // to initialize the _todos array when the app starts or needs refreshing
  Future<void> fetchToDosData() async {
    // DBHelper.fetchToDos now returns List<ToDo> directly
    _todos = await DBHelper.fetchToDos();
    notifyListeners();
  }

  // to toggle to-dos between completed and incomplete and mark for sync
  void toggleCompletion(ToDo todo) {
    // Find the todo in the local list to update its status immediately in the UI
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      // Update the local model's isDone state, sync status, and timestamp
      _todos[index].isDone = !_todos[index].isDone;
      _todos[index].syncStatus = 'pending_update'; // Mark as pending update
      _todos[index].clientTimestamp =
          DateTime.now().millisecondsSinceEpoch; // Record local timestamp

      // Update the local list immediately (already done above)
      notifyListeners(); // Notify listeners to update the UI

      // Call the DBHelper method to update the record
      // DBHelper.toggleToDoCompletion now takes the updated ToDo object
      DBHelper.toggleToDoCompletion(_todos[index]);

      // Request a sync push after toggling completion locally
      if (_requestSyncPush != null) _requestSyncPush!();
    }
  }

  // to add to-dos to the database and mark for sync
  Future<void> addToDo(ToDo todo) async {
    final newToDo = ToDo(
      // id will be set by SQLite AUTOINCREMENT after insertion
      // firebaseId will be null initially
      action: todo.action,
      addedOn: DateTime.now(), // Set the current time as added on
      isDone: todo.isDone,
      syncStatus: 'pending_create', // Mark as pending creation for sync
      clientTimestamp: DateTime.now().millisecondsSinceEpoch,
    );

    try {
      // DBHelper.addToDo now handles inserting the map and returns the local ID
      final localId = await DBHelper.addToDo(newToDo);
      newToDo.id = localId.toString();
      _todos.add(newToDo); // Add the new todo to the local list immediately
      notifyListeners();

      if (_requestSyncPush != null) _requestSyncPush!();
    } catch (error) {
      return;
    }
  }

  // to delete completed to-dos from the database (soft delete for syncing)
  Future<void> deleteCompletedToDos() async {
    // Update the local list immediately to reflect the pending deletion in the UI
    // Mark all completed todos as pending_delete in the local list
    for (var todo in _todos.where((t) => t.isDone).toList()) {
      // Create a list copy to modify while iterating
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index].syncStatus = 'pending_delete';
        _todos[index].clientTimestamp = DateTime.now().millisecondsSinceEpoch;
      }
    }

    notifyListeners();

    // Call the DBHelper method to mark for deletion (soft delete)
    await DBHelper.deleteCompletedToDos();

    // Request a sync push after marking for deletion locally
    if (_requestSyncPush != null) _requestSyncPush!();
  }

  // Method to update the provider's list when data is synced from Firebase
  // This method will be called by the SyncService
  void updateToDosFromSync(List<ToDo> syncedToDos) {
    // This is a simplified approach. A more robust method would merge changes.
    // For now, we'll just replace the local list with the synced data.
    // This assumes the SyncService has already merged/resolved conflicts in the DB.
    _todos = syncedToDos;
    notifyListeners();
  }
}
