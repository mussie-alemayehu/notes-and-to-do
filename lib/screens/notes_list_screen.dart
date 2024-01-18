import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './note_details_screen.dart';
import '../widgets/note_list_item.dart';
import '../providers/notes.dart';
import '../models.dart';

class NotesListScreen extends StatefulWidget {
  static const routeName = '/notes_list';

  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListState();
}

class _NotesListState extends State<NotesListScreen> {
  List<Note>? notes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final notesData = Provider.of<Notes>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      body: FutureBuilder(
          future: notesData.fetchNotesData(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor),
              );
            } else {
              notes = notesData.notes;
              if (notes == null) {
                return const Center(
                  child: Text(
                      'No data found for your notes, please restart the app.'),
                );
              }
              return notes!.isEmpty
                  ? const Center(
                      child: Text('No notes added yet, start adding some.'),
                    )
                  : ListView.builder(
                      itemCount: notes!.length,
                      itemBuilder: (ctx, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              NoteDetailsScreen.routeName,
                              arguments: notes![index],
                            );
                          },
                          child: NoteListItem(
                            key: ValueKey(notes![index].id),
                            title: notes![index].title,
                            content: notes![index].content,
                            lastEdited: notes![index].lastEdited,
                          ),
                        );
                      },
                    );
            }
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        onPressed: () {
          Navigator.of(context).pushNamed(
            NoteDetailsScreen.routeName,
            arguments: true,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
