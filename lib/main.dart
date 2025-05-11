import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './firebase_options.dart';

// themes
import './themes/light_theme.dart';
import './themes/dark_theme.dart';

// services
import './services/sync_service.dart';

// providers
import './providers/notes.dart';
import './providers/to_dos.dart';
import './providers/theme_notifier.dart';

// screens
import './screens/auth_screen.dart';
import './screens/tabs_screen.dart';
import './screens/note_details_screen.dart';
import './screens/notes_list_screen.dart';
import './screens/todos_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SyncService().initialize();

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
          create: (_) => ThemeNotifier(),
        ),
      ],
      child: Builder(builder: (context) {
        final notesProvider = Provider.of<Notes>(context, listen: false);
        final todosProvider = Provider.of<ToDos>(context, listen: false);

        SyncService().setProviders(notesProvider, todosProvider);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Notes',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: Provider.of<ThemeNotifier>(context).themeMode,
          home: StreamBuilder(
            stream: FirebaseAuth.instance.userChanges(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.data != null) {
                return TabsScreen();
              } else {
                return AuthScreen();
              }
            },
          ),
          routes: {
            AuthScreen.routeName: (_) => const AuthScreen(),
            TabsScreen.routeName: (_) => const TabsScreen(),
            NotesListScreen.routeName: (_) => const NotesListScreen(),
            NoteDetailsScreen.routeName: (_) => const NoteDetailsScreen(),
            ToDosListScreen.routeName: (_) => const ToDosListScreen(),
          },
        );
      }),
    );
  }
}
