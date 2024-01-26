// provides to-dos to the whole app during runtime

import 'package:flutter/material.dart';

import '../db_helper.dart';
import '../models.dart';

class ToDos with ChangeNotifier {
  // to keep track of all to-dos in the app
  List<ToDo> _todos = [];

  // returns the list of completed to-dos
  List<ToDo> get completedToDos {
    final list = _todos.reversed.where((todo) => todo.isDone == true).toList();
    return list;
  }

  // returns the list of incomplete to-dos
  List<ToDo> get incompleteToDos {
    final list = _todos.reversed.where((todo) => todo.isDone == false).toList();
    return list;
  }

  // to initialize the _todos array when the app starts
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

  // to toggle to-dos between completed and incomplete
  void toggleCompletion(ToDo todo) {
    DBHelper.toggleToDoCompletion(todo);
    notifyListeners();
  }

  // to add to-dos to the database by accessing the addToDo() method in DBHelper class
  Future<void> addToDo(ToDo todo) async {
    await DBHelper.addToDo(todo);
    notifyListeners();
  }

  // to delete completed to-dos from the database by accessing the deleteCompletedToDos() method in DBHelper class
  Future<void> deleteCompletedToDos() async {
    DBHelper.deleteCompletedToDos();
    notifyListeners();
  }
}
