import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './notes_list_screen.dart';
import './todos_list_screen.dart';
import './note_details_screen.dart';
import '../models.dart';
import '../providers/to_dos.dart';
import '../widgets/custom_drawer.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs';

  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabsScreen> {
  int _selectedIndex = 0;

  void showMessageSnackBar(String message, [bool success = true]) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    scaffoldMessenger.removeCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        backgroundColor: success ? colorScheme.primary : colorScheme.secondary,
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:
                    success ? colorScheme.onPrimary : colorScheme.onSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<bool> confirmCompletedTodosClear() async {
    final confirm = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm Clear'),
            content: const Text(
                'Are you sure you want to clear all completed tasks?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Clear'),
              ),
            ],
          ),
        ) ??
        false;

    return confirm;
  }

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
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
            right: 16,
            left: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Task',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Enter your task here...',
                      ),
                      onChanged: (value) {
                        newAction = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(newAction);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    return newAction;
  }

  int get selectedIndex => _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final todosData = Provider.of<ToDos>(context);
    List<ToDo> completedToDos = todosData.completedToDos;

    return Scaffold(
      drawer: CustomDrawer(
        selectedIndex: selectedIndex,
        selectIndex: (newValue) {
          setState(() {
            _selectedIndex = newValue;
          });
        },
      ),
      appBar: AppBar(
        title: Text(
          (_selectedIndex == 0) ? 'Notes' : 'To-Dos',
        ),
        actions: [
          if (_selectedIndex == 1)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: const Icon(Icons.clear_all),
                tooltip: 'Clean completed tasks.',
                onPressed: () async {
                  if (completedToDos.isNotEmpty) {
                    final confirm = await confirmCompletedTodosClear();
                    if (!confirm) return;

                    await todosData.deleteCompletedToDos();
                    showMessageSnackBar('Completed tasks cleared!');
                  } else {
                    showMessageSnackBar(
                      'There are no completed tasks yet.',
                      false,
                    );
                  }
                },
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: (_selectedIndex == 0)
          ? const NotesListScreen()
          : const ToDosListScreen(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        currentIndex: _selectedIndex,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notes),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'To-Dos',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: (_selectedIndex == 0) ? 'Add a note' : 'Add new task',
        onPressed: (_selectedIndex == 0)
            ? () {
                Navigator.of(context).pushNamed(
                  NoteDetailsScreen.routeName,
                  arguments: true,
                );
              }
            : () async {
                final newAction = await _showModalBottomSheet(context);

                if (newAction.isEmpty) return;
                await todosData.addToDo(
                  ToDo(
                    id: DateTime.now().toString(),
                    action: newAction,
                    addedOn: DateTime.now(),
                    clientTimestamp: DateTime.now().millisecondsSinceEpoch,
                  ),
                );
              },
        child: const Icon(
          Icons.add,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
