import 'package:flutter/material.dart';

import '../db_helper.dart';
import '../models.dart';

class Notes with ChangeNotifier {
  // to keep track of the notes in the system
  List<Note> _notes = [];

  // Callback function to request a sync push
  VoidCallback? _requestSyncPush;

  // Method to set the sync request callback
  void setSyncRequestCallback(VoidCallback callback) {
    _requestSyncPush = callback;
  }

  List<Note> get notes {
    // Filter out items marked for pending delete so they don't show in the UI immediately
    return _notes.where((note) => note.syncStatus != 'pending_delete').toList()
      ..sort((a, b) => b.lastEdited.compareTo(a.lastEdited));
  }

  // to initialize the _notes array when the app starts or needs refreshing
  Future<void> fetchNotesData() async {
    // DBHelper.fetchNotes now returns List<Note> directly
    _notes = await DBHelper.fetchNotes();
    notifyListeners(); // Notify listeners after fetching data
  }

  // to add notes to the database and mark for sync
  Future<void> addNote(Note note) async {
    final newNote = Note(
      // id will be set by SQLite AUTOINCREMENT after insertion
      // firebaseId will be null initially
      title: note.title,
      content: note.content,
      lastEdited: DateTime.now(), // Set the current time as last edited
      syncStatus: 'pending_create', // Mark as pending creation for sync
      clientTimestamp:
          DateTime.now().millisecondsSinceEpoch, // Record local timestamp
    );

    try {
      // DBHelper.addNote now handles inserting the map and returns the local ID
      final localId = await DBHelper.addNote(newNote);
      newNote.id = localId.toString();
      _notes.add(newNote);
      notifyListeners();

      if (_requestSyncPush != null) _requestSyncPush!();
    } catch (error) {
      return;
    }
  }

  // to delete a note from the database (soft delete for syncing)
  Future<void> deleteNoteWithId(String id) async {
    // Find the note in the local list to update its status immediately in the UI
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      // Update the local model's sync status and timestamp
      _notes[index].syncStatus = 'pending_delete';
      _notes[index].clientTimestamp = DateTime.now().millisecondsSinceEpoch;

      // Call the DBHelper method to mark for deletion (soft delete)
      await DBHelper.deleteNote(id); // DBHelper.deleteNote now takes String id

      notifyListeners(); // Notify listeners to update the UI (item will disappear due to getter filtering)

      // Request a sync push after marking for deletion locally
      if (_requestSyncPush != null) _requestSyncPush!();
    }
  }

  // to update an existing note in the database and mark for sync
  Future<void> updateNote(Note note) async {
    // Find the note in the local list to update its status immediately in the UI
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      // Update the local model with the new data and sync metadata
      final updatedNote = Note(
        id: note.id, // Keep the local ID
        firebaseId: note.firebaseId, // Keep the Firebase ID if it exists
        title: note.title,
        content: note.content,
        lastEdited: DateTime.now(), // Update last edited time
        syncStatus: 'pending_update', // Mark as pending update
        clientTimestamp:
            DateTime.now().millisecondsSinceEpoch, // Record local timestamp
      );

      // Update the local list immediately
      _notes[index] = updatedNote;
      notifyListeners(); // Notify listeners to update the UI

      // Call the DBHelper method to update the record
      await DBHelper.updateNote(updatedNote);

      // Request a sync push after updating the note locally
      if (_requestSyncPush != null) _requestSyncPush!();
    }
  }

  // Method to update the provider's list when data is synced from Firebase
  // This method will be called by the SyncService
  void updateNotesFromSync(List<Note> syncedNotes) {
    // This is a simplified approach. A more robust method would merge changes.
    // For now, we'll just replace the local list with the synced data.
    // This assumes the SyncService has already merged/resolved conflicts in the DB.
    _notes = syncedNotes;
    notifyListeners();
  }
}
