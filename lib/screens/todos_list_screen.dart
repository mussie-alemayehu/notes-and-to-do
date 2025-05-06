import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/to_dos.dart';
import '../widgets/todo_list_item.dart';

class ToDosListScreen extends StatefulWidget {
  static const routeName = '/todos_list';

  const ToDosListScreen({super.key});

  @override
  State<ToDosListScreen> createState() => _ToDosListScreenState();
}

class _ToDosListScreenState extends State<ToDosListScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<ToDos>(context, listen: false).fetchToDosData().then((_) {
        setState(() {
          _isLoading = false;
        });
      });

      _isInit = false;
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .primary, // Use primary color for headers
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todosData = Provider.of<ToDos>(context);
    final completedToDos = todosData.completedToDos;
    final incompleteToDos = todosData.incompleteToDos;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary),
      );
    }

    if (completedToDos.isEmpty && incompleteToDos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No tasks added yet, tap the + button to create one!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
        ),
      );
    }

    return ListView(
      children: [
        if (incompleteToDos.isNotEmpty) _buildSectionHeader(context, 'Tasks'),
        ...incompleteToDos.asMap().entries.map((entry) {
          final index = entry.key;
          final todo = entry.value;
          if (todo.syncStatus == 'pending_delete') {
            return const SizedBox.shrink();
          }
          return Animate(
            effects: [
              FadeEffect(duration: 300.ms, delay: (50 * index).ms),
              SlideEffect(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                  duration: 300.ms,
                  delay: (50 * index).ms),
            ],
            child: ToDoListItem(
              todo,
              key: ValueKey(todo.id),
            ),
          );
        }),
        if (completedToDos.isNotEmpty)
          _buildSectionHeader(context, 'Completed'),
        ...completedToDos.asMap().entries.map((entry) {
          final index = entry.key;
          final todo = entry.value;
          if (todo.syncStatus == 'pending_delete') {
            return const SizedBox.shrink();
          }
          return Animate(
            effects: [
              FadeEffect(duration: 300.ms, delay: (50 * index).ms),
              SlideEffect(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                  duration: 300.ms,
                  delay: (50 * index).ms),
            ],
            child: ToDoListItem(
              todo,
              isCompleted: true,
              key: ValueKey(todo.id),
            ),
          );
        }),
      ],
    );
  }
}
