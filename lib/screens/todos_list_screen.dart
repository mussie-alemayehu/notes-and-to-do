import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../providers/to_dos.dart';
import '../widgets/todo_list_item.dart';

class ToDosListScreen extends StatelessWidget {
  static const routeName = '/todos_list';

  const ToDosListScreen({super.key});

  Future<String> _showModalBottomSheet(BuildContext context) async {
    String newAction = '';

    await showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      context: context,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
            top: 12,
            right: 12,
            left: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: TextField(
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: Theme.of(context).colorScheme.tertiary,
                  decoration: const InputDecoration(
                    hintText: 'Add task.',
                  ),
                  onChanged: (value) {
                    newAction = value;
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text(
                  'Save',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
            ],
          ),
        );
      },
    );

    return newAction;
  }

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
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'To-Dos',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clean completed tasks.',
              onPressed: () async {
                if (completedToDos.isEmpty) {
                  scaffoldMessenger.removeCurrentSnackBar();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      content: Text(
                        'There are no completed tasks yet.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else {
                  await todosData.deleteCompletedToDos();
                }
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder(
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
                        ...incompleteToDos
                            .map(
                              (todo) => ToDoListItem(todo),
                            )
                            .toList(),
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
                          ...completedToDos
                              .map(
                                (todo) => ToDoListItem(todo, isCompleted: true),
                              )
                              .toList(),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        tooltip: 'Add new task',
        onPressed: () async {
          final newAction = await _showModalBottomSheet(context);

          if (newAction.isEmpty) return;
          await todosData.addToDo(
            ToDo(
              id: DateTime.now().toString(),
              action: newAction,
              addedOn: DateTime.now(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
