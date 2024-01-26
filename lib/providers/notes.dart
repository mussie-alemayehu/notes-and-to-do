// provides notes to the whole app during runtime

import 'package:flutter/material.dart';

import '../db_helper.dart';
import '../models.dart';

class Notes with ChangeNotifier {
  // to keep track of the notes in the system
  List<Note> _notes = [];

  List<Note> get notes {
    return _notes.reversed.toList();
  }

  // to initiliaze the _notes array when the app starts
  Future<void> fetchNotesData() async {
    final list = await DBHelper.fetchNotes();
    _notes = list.map((item) {
      return Note(
        id: item['id'].toString(),
        title: item['title'],
        content: item['content'],
        lastEdited: DateTime.parse(item['lastEdited']),
      );
    }).toList();
  }

  // to add notes to the database by accessing the addNote() method in DBHelper class
  Future<void> addNote(Note note) async {
    try {
      await DBHelper.addNote(note);
    } catch (error) {
      return;
    }
    notifyListeners();
  }

  // to delete a note from the database by accessing the deleteNode() method in DBHelper class
  Future<void> deleteNoteWithId(String id) async {
    await DBHelper.deleteNote(int.parse(id));
    notifyListeners();
  }

  // to update an existing note in the database by accessing the updateNote() method in DBHelper class
  Future<void> updateNote(Note note) async {
    await DBHelper.updateNote(note);
    notifyListeners();
  }
}
