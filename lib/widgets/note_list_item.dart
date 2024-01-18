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
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            Text(
              'Last edited: $_readableDate',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
