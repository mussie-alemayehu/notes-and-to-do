import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models.dart';

class FirestoreService {
  // Get the current authenticated user's ID
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  /// Get a reference to the user's notes collection in Firestore
  CollectionReference? get _userNotesCollection {
    if (userId == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes');
  }

  /// Get a reference to the user's todos collection in Firestore
  CollectionReference? get _userTodosCollection {
    if (userId == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('todos');
  }

  // --- Methods for Notes ---

  /// Add a new note to Firestore
  /// Returns the Firebase Document ID on success
  Future<String?> addNote(Note note) async {
    if (_userNotesCollection == null) return null;

    try {
      // Use the toFirestoreMap helper from the Note model
      final docRef = await _userNotesCollection!.add(note.toFirestoreMap());

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  /// Update an existing note in Firestore
  Future<bool> updateNote(Note note) async {
    if (_userNotesCollection == null || note.firebaseId == null) return false;

    try {
      // Use the toFirestoreMap helper
      await _userNotesCollection!
          .doc(note.firebaseId)
          .update(note.toFirestoreMap());

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a note from Firestore
  Future<bool> deleteNote(String firebaseId) async {
    if (_userNotesCollection == null) return false;

    try {
      await _userNotesCollection!.doc(firebaseId).delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all notes from Firestore for the current user
  /// This is primarily used for the initial sync or full refresh
  Future<List<Note>> getAllNotes() async {
    if (_userNotesCollection == null) return [];

    try {
      final querySnapshot = await _userNotesCollection!.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Add the firebaseId to the map before converting
        data['firebaseId'] = doc.id;

        // Note: Firestore timestamps need conversion to DateTime
        if (data['lastEdited'] is Timestamp) {
          data['lastEdited'] =
              (data['lastEdited'] as Timestamp).toDate().toIso8601String();
        }

        if (data['addedOn'] is Timestamp) {
          // For todos, though this is notes method
          data['addedOn'] =
              (data['addedOn'] as Timestamp).toDate().toIso8601String();
        }

        // Assume clientTimestamp is stored as INTEGER (milliseconds) in Firestore
        // If stored as Timestamp in Firestore, convert similarly
        if (data['clientTimestamp'] is Timestamp) {
          data['clientTimestamp'] =
              (data['clientTimestamp'] as Timestamp).millisecondsSinceEpoch;
        } else if (data['clientTimestamp'] is! int) {
          // Handle cases where clientTimestamp might be missing or wrong type
          data['clientTimestamp'] = 0; // Default or handle error
        }

        // Set syncStatus to 'synced' for items pulled from Firestore
        data['syncStatus'] = 'synced';

        return Note.fromMap(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Listen for real-time changes to notes in Firestore
  // This is crucial for pulling changes initiated on other devices
  Stream<List<Note>> streamNotes() {
    if (_userNotesCollection == null) {
      // Return an empty stream if no user is logged in
      return Stream.value([]);
    }

    return _userNotesCollection!.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['firebaseId'] = doc.id;
        // Convert Firestore timestamps
        if (data['lastEdited'] is Timestamp) {
          data['lastEdited'] =
              (data['lastEdited'] as Timestamp).toDate().toIso8601String();
        }
        if (data['clientTimestamp'] is Timestamp) {
          data['clientTimestamp'] =
              (data['clientTimestamp'] as Timestamp).millisecondsSinceEpoch;
        } else if (data['clientTimestamp'] is! int) {
          data['clientTimestamp'] = 0;
        }
        data['syncStatus'] =
            'synced'; // Items from stream are considered synced
        return Note.fromMap(data);
      }).toList();
    });
  }

  // --- Methods for ToDos ---

  /// Add a new todo to Firestore
  /// Returns the Firebase Document ID on success
  Future<String?> addToDo(ToDo todo) async {
    if (_userTodosCollection == null) return null;

    try {
      // Use the toFirestoreMap helper from the ToDo model
      final docRef = await _userTodosCollection!.add(todo.toFirestoreMap());

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  /// Update an existing todo in Firestore
  Future<bool> updateToDo(ToDo todo) async {
    if (_userTodosCollection == null || todo.firebaseId == null) return false;

    try {
      // Use the toFirestoreMap helper
      await _userTodosCollection!
          .doc(todo.firebaseId)
          .update(todo.toFirestoreMap());

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a todo from Firestore
  Future<bool> deleteToDo(String firebaseId) async {
    if (_userTodosCollection == null) return false;

    try {
      await _userTodosCollection!.doc(firebaseId).delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get all todos from Firestore for the current user
  Future<List<ToDo>> getAllToDos() async {
    if (_userTodosCollection == null) return [];

    try {
      final querySnapshot = await _userTodosCollection!.get();

      return querySnapshot.docs.map((doc) {
        // Convert Firestore document to ToDo model
        final data = doc.data() as Map<String, dynamic>;
        // Add the firebaseId to the map before converting
        data['firebaseId'] = doc.id;

        // Convert Firestore timestamps
        if (data['addedOn'] is Timestamp) {
          data['addedOn'] =
              (data['addedOn'] as Timestamp).toDate().toIso8601String();
        }
        if (data['lastEdited'] is Timestamp) {
          // For notes, though this is todos method
          data['lastEdited'] =
              (data['lastEdited'] as Timestamp).toDate().toIso8601String();
        }
        if (data['clientTimestamp'] is Timestamp) {
          data['clientTimestamp'] =
              (data['clientTimestamp'] as Timestamp).millisecondsSinceEpoch;
        } else if (data['clientTimestamp'] is! int) {
          data['clientTimestamp'] = 0;
        }

        // Firestore stores boolean directly, but our ToDo.fromMap expects int (0/1) from SQLite map
        // Ensure 'isDone' is handled correctly if it comes as bool from Firestore
        if (data['isDone'] is bool) {
          data['isDone'] = data['isDone'] ? 1 : 0;
        } else if (data['isDone'] is! int) {
          data['isDone'] = 0; // Default or handle error
        }

        // Set syncStatus to 'synced' for items pulled from Firestore
        data['syncStatus'] = 'synced';

        return ToDo.fromMap(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Listen for real-time changes to todos in Firestore
  Stream<List<ToDo>> streamToDos() {
    if (_userTodosCollection == null) {
      // Return an empty stream if no user is logged in
      return Stream.value([]);
    }

    return _userTodosCollection!.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['firebaseId'] = doc.id;

        // Convert Firestore timestamps
        if (data['addedOn'] is Timestamp) {
          data['addedOn'] =
              (data['addedOn'] as Timestamp).toDate().toIso8601String();
        }
        if (data['clientTimestamp'] is Timestamp) {
          data['clientTimestamp'] =
              (data['clientTimestamp'] as Timestamp).millisecondsSinceEpoch;
        } else if (data['clientTimestamp'] is! int) {
          data['clientTimestamp'] = 0;
        }

        // Handle boolean from Firestore
        if (data['isDone'] is bool) {
          data['isDone'] = data['isDone'] ? 1 : 0;
        } else if (data['isDone'] is! int) {
          data['isDone'] = 0;
        }

        data['syncStatus'] =
            'synced'; // Items from stream are considered synced

        return ToDo.fromMap(data);
      }).toList();
    });
  }
}
