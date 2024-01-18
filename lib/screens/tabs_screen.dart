import 'package:flutter/material.dart';

import '../screens/notes_list_screen.dart';
import '../screens/todos_list_screen.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs';

  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabsScreen> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        selectedItemColor: Theme.of(context).colorScheme.tertiary,
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
    );
  }
}
