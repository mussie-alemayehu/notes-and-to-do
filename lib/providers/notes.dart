import 'package:flutter/material.dart';

import '../db_helper.dart';
import '../models.dart';

class Notes with ChangeNotifier {
  // to keep track of the notes in the system
  List<Note> _notes = [];

  List<Note> get notes {
    // Filter out items marked for pending delete so they don't show in the UI immediately
    return _notes
        .where((note) => note.syncStatus != 'pending_delete')
        .toList()
        .reversed
        .toList();
  }

  /// to initialize the _notes array when the app starts or needs refreshing
  Future<void> fetchNotesData() async {
    // DBHelper.fetchNotes now returns List<Note> directly
    _notes = await DBHelper.fetchNotes();
    notifyListeners(); // Notify listeners after fetching data
  }

  /// to add notes to the database and mark for sync
  Future<void> addNote(Note note) async {
    final newNote = Note(
      title: note.title,
      content: note.content,
      lastEdited: DateTime.now(),
      syncStatus: 'pending_create',
      clientTimestamp: DateTime.now().millisecondsSinceEpoch,
    );

    try {
      // DBHelper.addNote now handles inserting the map and returns the local ID
      final localId = await DBHelper.addNote(newNote);
      newNote.id = localId.toString();

      _notes.add(newNote);
    } catch (error) {
      return;
    }

    notifyListeners();
  }

  /// to delete a note from the database (soft delete for syncing)
  Future<void> deleteNoteWithId(String id) async {
    // Find the note in the local list to update its status immediately in the UI
    final index = _notes.indexWhere((note) => note.id == id);

    if (index != -1) {
      // Update the local model's sync status and timestamp
      _notes[index].syncStatus = 'pending_delete';
      _notes[index].clientTimestamp = DateTime.now().millisecondsSinceEpoch;

      // Call the DBHelper method to mark for deletion (soft delete)
      await DBHelper.deleteNote(id); // DBHelper.deleteNote now takes String id

      notifyListeners();
    }
  }

  /// to update an existing note in the database and mark for sync
  Future<void> updateNote(Note note) async {
    // Find the note in the local list to update its status immediately in the UI
    final index = _notes.indexWhere((n) => n.id == note.id);

    if (index != -1) {
      // Update the local model with the new data and sync metadata
      final updatedNote = Note(
        id: note.id,
        firebaseId: note.firebaseId,
        title: note.title,
        content: note.content,
        lastEdited: DateTime.now(),
        syncStatus: 'pending_update',
        clientTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      _notes[index] = updatedNote;

      await DBHelper.updateNote(updatedNote);

      notifyListeners();
    }
  }

  /// Method to update the provider's list when data is synced from Firebase
  /// This method will be called by the SyncService
  void updateNotesFromSync(List<Note> syncedNotes) {
    // This is a simplified approach. A more robust method would merge changes.
    // For now, we'll just replace the local list with the synced data.
    // This assumes the SyncService has already merged/resolved conflicts in the DB.
    _notes = syncedNotes;
    notifyListeners();
  }
}
