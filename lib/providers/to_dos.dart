import 'package:flutter/material.dart';

import '../db_helper.dart';
import '../models.dart';

class ToDos with ChangeNotifier {
  List<ToDo> _todos = [];

  List<ToDo> get completedToDos {
    final list = _todos.reversed.where((todo) => todo.isDone == true).toList();
    return list;
  }

  List<ToDo> get incompleteToDos {
    final list = _todos.reversed.where((todo) => todo.isDone == false).toList();
    return list;
  }

  Future<void> fetchToDosData() async {
    final list = await DBHelper.fetchToDos();
    _todos = list.map((todo) {
      return ToDo(
        id: todo['id'].toString(),
        action: todo['action'],
        addedOn: DateTime.parse(todo['addedOn']),
        isDone: todo['isDone'] == 'true' ? true : false,
      );
    }).toList();
  }

  void toggleCompletion(ToDo todo) {
    DBHelper.toggleToDoCompletion(todo);
    notifyListeners();
  }

  Future<void> addToDo(ToDo todo) async {
    await DBHelper.addToDo(todo);
    notifyListeners();
  }

  void deleteToDoWithId(String id) {
    _todos.removeWhere((existingToDo) => existingToDo.id == id);
    notifyListeners();
  }

  Future<void> deleteCompletedToDos() async {
    DBHelper.deleteCompletedToDos();
    notifyListeners();
  }

  void updateToDo(ToDo todo) {
    _todos.removeWhere((existingToDo) => existingToDo.id == todo.id);
    _todos.add(todo);
    notifyListeners();
  }
}
