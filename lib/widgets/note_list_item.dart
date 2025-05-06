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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              'Last edited: $_readableDate',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
