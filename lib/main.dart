import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './firebase_options.dart';

// themes
import './themes/light_theme.dart';
import './themes/dark_theme.dart';

// providers
import './providers/notes.dart';
import './providers/auth.dart';
import './providers/to_dos.dart';

// screens
import './screens/tabs_screen.dart';
import './screens/note_details_screen.dart';
import './screens/notes_list_screen.dart';
import './screens/todos_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Notes(),
        ),
        ChangeNotifierProvider(
          create: (_) => ToDos(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Notes',
        theme: lightTheme,
        darkTheme: darkTheme,
        initialRoute: TabsScreen.routeName,
        routes: {
          TabsScreen.routeName: (_) => const TabsScreen(),
          NotesListScreen.routeName: (_) => const NotesListScreen(),
          NoteDetailsScreen.routeName: (_) => const NoteDetailsScreen(),
          ToDosListScreen.routeName: (_) => const ToDosListScreen(),
        },
      ),
    );
  }
}
