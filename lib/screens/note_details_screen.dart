import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../providers/notes.dart';

class NoteDetailsScreen extends StatefulWidget {
  static const routeName = '/note_details';

  const NoteDetailsScreen({
    super.key,
  });

  @override
  State<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
  late Notes notesData;
  late bool isNew;
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  bool isChanged = false;
  Note? existingNote;
  bool isInit = true;

  // Focus node for the content TextField
  final FocusNode _contentFocusNode = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      notesData = Provider.of<Notes>(context, listen: false);

      final arg = ModalRoute.of(context)!.settings.arguments;
      if (arg is bool) {
        isNew = arg;
        existingNote = null;
      } else if (arg is Note) {
        existingNote = arg;
        isNew = false;
      } else {
        isNew = true;
        existingNote = null;
      }

      titleController.text = isNew ? '' : existingNote!.title;
      contentController.text = isNew ? '' : existingNote!.content;

      titleController.addListener(_onTextChanged);
      contentController.addListener(_onTextChanged);

      isInit = false;
    }
  }

  @override
  void dispose() {
    titleController.removeListener(_onTextChanged);
    contentController.removeListener(_onTextChanged);
    titleController.dispose();
    contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final currentTitle = titleController.text;
    final currentContent = contentController.text;

    final initialTitle = isNew ? '' : existingNote!.title;
    final initialContent = isNew ? '' : existingNote!.content;

    final hasChanged =
        currentTitle != initialTitle || currentContent != initialContent;

    if (hasChanged != isChanged) {
      setState(() {
        isChanged = hasChanged;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (titleController.text.trim().isEmpty &&
        contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note is empty, not saving.')),
      );
      Navigator.of(context).pop();
      return;
    }

    final noteToSave = Note(
      id: isNew ? DateTime.now().toString() : existingNote!.id,
      firebaseId: isNew ? null : existingNote!.firebaseId,
      content: contentController.text.trim(),
      title: titleController.text.trim(),
      clientTimestamp: DateTime.now().millisecondsSinceEpoch,
      lastEdited: DateTime.now(),
    );

    if (isNew) {
      await notesData.addNote(noteToSave);
    } else {
      await notesData.updateNote(noteToSave);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isNew ? 'Note saved!' : 'Note updated!')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmAndDelete() async {
    final bool confirm = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Note'),
            content: const Text('Are you sure you want to delete this note?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('Delete',
                    style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm && existingNote != null) {
      await notesData.deleteNoteWithId(existingNote!.id ?? '');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted!')),
        );

        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Changes',
            onPressed: isChanged ? _saveChanges : null,
          ),
          if (!isNew)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Note',
              onPressed: _confirmAndDelete,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title TextField
            TextField(
              decoration: _buildInputDecoration('Title'),
              textCapitalization: TextCapitalization.sentences,
              controller: titleController,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              autofocus: isNew,
              maxLines: null,
            ),
            const SizedBox(height: 16),

            // Content TextField (Expanded to fill remaining space)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Request focus for the content TextField when the body is tapped

                  FocusScope.of(context).requestFocus(_contentFocusNode);
                },
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: SingleChildScrollView(
                    // Allows scrolling if content exceeds screen height
                    child: TextField(
                      focusNode: _contentFocusNode,
                      decoration: _buildInputDecoration('Start writing...'),
                      textCapitalization: TextCapitalization.sentences,
                      controller: contentController,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.9),
                          ),
                      maxLines: null,
                      minLines: null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: InputBorder.none,
      hoverColor: Colors.transparent,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
      filled: true,
      fillColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
