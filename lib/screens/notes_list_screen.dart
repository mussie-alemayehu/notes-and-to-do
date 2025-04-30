import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './note_details_screen.dart';
import '../widgets/note_list_item.dart';
import '../providers/notes.dart';

class NotesListScreen extends StatefulWidget {
  static const routeName = '/notes_list';

  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListState();
}

class _NotesListState extends State<NotesListScreen> {
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

      // Fetch notes data when the screen is first initialized
      Provider.of<Notes>(context, listen: false).fetchNotesData().then((_) {
        setState(() {
          _isLoading = false;
        });
      });

      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesData = Provider.of<Notes>(context);
    final notes = notesData.notes;

    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          )
        : notes.isEmpty
            ? const Center(
                child: Text('No notes added yet, start adding some.'),
              )
            : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (ctx, index) {
                  final note = notes[index];
                  if (note.syncStatus == 'pending_delete') {
                    // Hide items marked for deletion
                    return const SizedBox.shrink();
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        NoteDetailsScreen.routeName,
                        arguments: note,
                      );
                    },
                    child: NoteListItem(
                      key: ValueKey(note.id),
                      title: note.title,
                      content: note.content,
                      lastEdited: note.lastEdited,
                      // Optional: Add a visual indicator for sync status
                      // syncStatus: note.syncStatus,
                    ),
                  );
                },
              );
  }
}
