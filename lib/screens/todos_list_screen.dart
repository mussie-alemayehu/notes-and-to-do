import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../providers/to_dos.dart';
import '../widgets/todo_list_item.dart';

class ToDosListScreen extends StatelessWidget {
  static const routeName = '/todos_list';

  const ToDosListScreen({super.key});

  Widget _divider(TextStyle? style) {
    return Column(
      children: [
        const Divider(),
        Text(
          'Completed',
          style: style!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final todosData = Provider.of<ToDos>(context);
    List<ToDo> completedToDos = [];
    List<ToDo> incompleteToDos = [];

    return FutureBuilder(
      future: todosData.fetchToDosData(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }
        completedToDos = todosData.completedToDos;
        incompleteToDos = todosData.incompleteToDos;

        if (completedToDos.isEmpty && incompleteToDos.isEmpty) {
          return Center(
            child: Text(
              'No tasks added yet.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...incompleteToDos.map(
                        (todo) => ToDoListItem(todo),
                      ),
                    ],
                  ),
                ),
              ),
              if (completedToDos.isNotEmpty)
                _divider(Theme.of(context).textTheme.bodySmall),
              if (completedToDos.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...completedToDos.map(
                          (todo) => ToDoListItem(todo, isCompleted: true),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
