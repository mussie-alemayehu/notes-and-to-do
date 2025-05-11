import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Animate(
      // Animation for state change (e.g., when marking as complete/incomplete)
      // This will run when the widget is rebuilt with a different `isCompleted` value
      target: 1, // Animate based on completion state
      effects: [
        if (isCompleted) // Apply effects only when completing
          FadeEffect(duration: 200.ms),
        ScaleEffect(
          begin: Offset(1, 1),
          end: Offset(0.95, 0.95),
          duration: 200.ms,
        ),
        if (!isCompleted) FadeEffect(duration: 200.ms),
        ScaleEffect(
          begin: Offset(0.95, 0.95),
          end: Offset(1, 1),
          duration: 200.ms,
        ),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isCompleted
              ? colorScheme.surface.withValues(alpha: 0.6)
              : colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isCompleted ? 0.05 : 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Provider.of<ToDos>(context, listen: false).toggleCompletion(todo);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: todo.isDone,
                  shape: const CircleBorder(),
                  activeColor: colorScheme.primary,
                  onChanged: (newValue) {
                    Provider.of<ToDos>(context, listen: false)
                        .toggleCompletion(todo);
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    todo.action,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isCompleted
                              ? colorScheme.onSurface.withValues(alpha: 0.5)
                              : colorScheme.onSurface,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          fontStyle:
                              isCompleted ? FontStyle.italic : FontStyle.normal,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
