class Note {
  String id;
  String title;
  String content;
  DateTime lastEdited;

  // the model for notes used in the entire app
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.lastEdited,
  });
}

// the model for to-dos used in the entire app
class ToDo {
  String id;
  String action;
  DateTime addedOn;
  bool isDone;

  ToDo({
    required this.id,
    required this.action,
    required this.addedOn,
    this.isDone = false,
  });
}
