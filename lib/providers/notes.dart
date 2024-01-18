import 'package:flutter/material.dart';

import '../db_helper.dart';
import '../models.dart';

class Notes with ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes {
    return _notes.reversed.toList();
  }

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

  Future<void> addNote(Note note) async {
    try {
      await DBHelper.addNote(note);
    } catch (error) {
      print(error);
      return;
    }
    notifyListeners();
  }

  Future<void> deleteNoteWithId(String id) async {
    await DBHelper.deleteNote(int.parse(id));
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    await DBHelper.updateNote(note);
    notifyListeners();
  }
}
