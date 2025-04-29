// the model for notes used in the entire app
class Note {
  // for SQLite primary key (AUTOINCREMENT)
  String? id;
  String? firebaseId; // nullable until synced
  String title;
  String content;
  DateTime lastEdited;
  String
      syncStatus; // (e.g., 'synced', 'pending_create', 'pending_update', 'pending_delete')
  int clientTimestamp; // (milliseconds since epoch)

  Note({
    this.id,
    this.firebaseId,
    required this.title,
    required this.content,
    required this.lastEdited,
    this.syncStatus = 'synced',
    required this.clientTimestamp,
  });

  // Helper to create a Note from a database Map (from SQLite)
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id']?.toString(), // SQLite id is INTEGER, map to String
      firebaseId: map['firebaseId'],
      title: map['title'],
      content: map['content'],
      lastEdited: DateTime.parse(
          map['lastEdited']), // Parse ISO8601 string back to DateTime
      syncStatus: map['syncStatus'],
      clientTimestamp: map['clientTimestamp'],
    );
  }

  // Helper to convert a Note to a database Map (for SQLite insertion/update)
  Map<String, dynamic> toMap() {
    return {
      // 'id' is typically excluded for inserts (AUTOINCREMENT handles it)
      'firebaseId': firebaseId,
      'title': title,
      'content': content,
      'lastEdited': lastEdited.toIso8601String(),
      'syncStatus': syncStatus,
      'clientTimestamp': clientTimestamp,
    };
  }

  // Helper to convert a Note to a Map suitable for Firestore
  Map<String, dynamic> toFirestoreMap() {
    return {
      'title': title,
      'content': content,
      'lastEdited': lastEdited, // Firestore can handle DateTime directly
      // Add a server timestamp here during actual upload in the sync service
      // 'updatedAt': FieldValue.serverTimestamp(),
      'clientTimestamp':
          clientTimestamp, // Keep client timestamp for conflict resolution logic
      // syncStatus is local state, not needed in Firestore document
    };
  }
}

// the model for to-dos used in the entire app
class ToDo {
  String? id; // for SQLite primary key (AUTOINCREMENT)
  String? firebaseId; // nullable until synced
  String action;
  DateTime addedOn;
  bool isDone;
  String syncStatus;
  int clientTimestamp;

  ToDo({
    this.id,
    this.firebaseId,
    required this.action,
    required this.addedOn,
    this.isDone = false,
    this.syncStatus = 'synced',
    required this.clientTimestamp,
  });

  // Helper to create a ToDo from a database Map (from SQLite)
  factory ToDo.fromMap(Map<String, dynamic> map) {
    return ToDo(
      id: map['id']?.toString(), // SQLite id is INTEGER, map to String
      firebaseId: map['firebaseId'],
      action: map['action'],
      addedOn: DateTime.parse(
          map['addedOn']), // Parse ISO8601 string back to DateTime
      isDone: map['isDone'] == 1, // SQLite stores boolean as INTEGER (0 or 1)
      syncStatus: map['syncStatus'],
      clientTimestamp: map['clientTimestamp'],
    );
  }

  // Helper to convert a ToDo to a database Map (for SQLite insertion/update)
  Map<String, dynamic> toMap() {
    return {
      // 'id' is typically excluded for inserts (AUTOINCREMENT handles it)
      'firebaseId': firebaseId,
      'action': action,
      'addedOn': addedOn.toIso8601String(), // Store DateTime as ISO8601 string
      'isDone':
          isDone ? 1 : 0, // Store boolean as INTEGER (1 for true, 0 for false)
      'syncStatus': syncStatus,
      'clientTimestamp': clientTimestamp,
    };
  }

  // Helper to convert a ToDo to a Map suitable for Firestore
  Map<String, dynamic> toFirestoreMap() {
    return {
      'action': action,
      'addedOn': addedOn, // Firestore can handle DateTime directly
      'isDone': isDone, // Firestore can handle boolean directly
      // Add a server timestamp here during actual upload in the sync service
      // 'updatedAt': FieldValue.serverTimestamp(),
      'clientTimestamp':
          clientTimestamp, // Keep client timestamp for conflict resolution logic
      // syncStatus is local state, not needed in Firestore document
    };
  }
}
