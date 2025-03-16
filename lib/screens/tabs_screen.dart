import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/notes_list_screen.dart';
import '../screens/todos_list_screen.dart';
import '../providers/to_dos.dart';
import '../services/auth.dart';
import '../models.dart';
import './note_details_screen.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs';

  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabsScreen> {
  int _selectedIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final todosData = Provider.of<ToDos>(context);
    List<ToDo> completedToDos = [];

    final userEmail = FirebaseAuth.instance.currentUser!.email;

    return Scaffold(
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                  if (userEmail != null)
                    Text(
                      userEmail,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.notes,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Notes'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            ListTile(
              leading: Icon(
                Icons.task_alt,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('To-Dos'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.of(context).pop();
                final showSnackBar = ScaffoldMessenger.of(context).showSnackBar;
                final colorScheme = Theme.of(context).colorScheme;

                await AuthServices().signOut();
                showSnackBar(
                  SnackBar(
                    content: const Text('Logged out!'),
                    backgroundColor: colorScheme.primary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          (_selectedIndex == 0) ? 'Notes' : 'To-Dos',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        actions: [
          if (_selectedIndex == 1)
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
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
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
        unselectedItemColor: Theme.of(context).colorScheme.tertiary,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.notes),
            label: 'Notes',
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.task_alt),
            label: 'To-Dos',
            backgroundColor: Theme.of(context).primaryColor,
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
                  ),
                );
              },
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}
