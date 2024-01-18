import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';

import './themes/light_theme.dart';
import './themes/dark_theme.dart';
import './providers/notes.dart';
import './providers/to_dos.dart';
import './screens/tabs_screen.dart';
import './screens/note_details_screen.dart';
import './screens/notes_list_screen.dart';
import './screens/todos_list_screen.dart';

void main() {
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
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
