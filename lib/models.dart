class Note {
  String id;
  String title;
  String content;
  DateTime lastEdited;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.lastEdited,
  });
}

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
