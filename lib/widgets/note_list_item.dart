// this widget will be displayed representing a single note in NotesListScreen screen

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteListItem extends StatelessWidget {
  final String title;
  final String content;
  final DateTime lastEdited;

  const NoteListItem({
    super.key,
    required this.title,
    required this.content,
    required this.lastEdited,
  });

  // a getter that returns the date in a user readable format
  String get _readableDate {
    if (lastEdited.isAfter(
      DateTime.now().subtract(
        const Duration(hours: 24),
      ),
    )) {
      return DateFormat.Hm().format(lastEdited);
    }
    return DateFormat.MMMd().format(lastEdited);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      color: Theme.of(context).colorScheme.secondary,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // display the title of the note
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: primary,
                  ),
            ),
            const SizedBox(height: 10),
            // display a maximum of 3 lines of the content of the note
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: primary,
                  ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            // display a user-readable format of the date
            Text(
              'Last edited: $_readableDate',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
