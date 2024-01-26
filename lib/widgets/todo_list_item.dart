// this widget will be displayed representing a single note in the ToDosListScreen screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/to_dos.dart';
import '../models.dart';

class ToDoListItem extends StatelessWidget {
  final ToDo todo;
  final bool isCompleted;

  const ToDoListItem(
    this.todo, {
    this.isCompleted = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.secondary,
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isCompleted ? 0 : 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // a check-box to represent the state of the to-do item
          Checkbox(
            value: todo.isDone,
            shape: const CircleBorder(),
            onChanged: (newValue) {
              Provider.of<ToDos>(context, listen: false).toggleCompletion(todo);
            },
          ),
          const SizedBox(width: 10),
          // using a gesture detector to allow toggling when the text part is tapped
          GestureDetector(
            onTap: () {
              Provider.of<ToDos>(context, listen: false).toggleCompletion(todo);
            },
            child: Text(
              todo.action,
              style: todo.isDone
                  ? Theme.of(context).textTheme.labelMedium
                  : Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
