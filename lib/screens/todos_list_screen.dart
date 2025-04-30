// lib/screens/todos_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/to_dos.dart';
import '../widgets/todo_list_item.dart';

class ToDosListScreen extends StatefulWidget {
  // Changed to StatefulWidget to manage loading state
  static const routeName = '/todos_list';

  const ToDosListScreen({super.key});

  @override
  State<ToDosListScreen> createState() => _ToDosListScreenState();
}

class _ToDosListScreenState extends State<ToDosListScreen> {
  // Add a flag to ensure data fetching only happens once
  var _isInit = true;
  var _isLoading = false; // Add a loading indicator state

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true; // Set loading to true before fetching
      });

      // Fetch todos data when the screen is first initialized
      Provider.of<ToDos>(context, listen: false).fetchToDosData().then((_) {
        setState(() {
          _isLoading = false; // Set loading to false after fetching
        });
      });

      _isInit = false;
    }
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
    final completedToDos = todosData.completedToDos;
    final incompleteToDos = todosData.incompleteToDos;

    print(
      'Complete: ${completedToDos.length}, Incomplete: ${incompleteToDos.length}',
    );

    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          )
        : (completedToDos.isEmpty && incompleteToDos.isEmpty)
            ? Center(
                child: Text(
                  'No tasks added yet.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2, // Adjust flex as needed
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...incompleteToDos.map(
                              (todo) => ToDoListItem(
                                todo,
                                key: ValueKey(todo.id),
                                // Optional: Add a visual indicator for sync status
                                // syncStatus: todo.syncStatus,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (completedToDos.isNotEmpty)
                      _divider(Theme.of(context).textTheme.bodySmall),
                    if (completedToDos.isNotEmpty)
                      Expanded(
                        flex: 1, // Adjust flex as needed
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ...completedToDos.map(
                                (todo) => ToDoListItem(
                                  todo,
                                  isCompleted: true,
                                  key: ValueKey(todo.id),
                                  // Optional: Add a visual indicator for sync status
                                  // syncStatus: todo.syncStatus,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
  }
}
