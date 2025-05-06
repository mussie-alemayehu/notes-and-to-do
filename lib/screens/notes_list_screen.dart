import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

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

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
            color: Theme.of(context)
                .colorScheme
                .primary), // Use theme primary color
      );
    }

    if (notes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No notes added yet, tap the + button to create one!',
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

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (ctx, index) {
        final note = notes[index];
        if (note.syncStatus == 'pending_delete') {
          return const SizedBox.shrink();
        }

        return Animate(
          effects: [
            FadeEffect(
              duration: 300.ms,
              delay: (50 * index).ms,
            ),
            SlideEffect(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
              duration: 300.ms,
              delay: (50 * index).ms,
            ),
          ],
          child: GestureDetector(
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
            ),
          ),
        );
      },
    );
  }
}
