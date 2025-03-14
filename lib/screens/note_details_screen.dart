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
  bool isFirstChange = true;
  Note? existingNote;
  bool isInit = true;

  late final Function popScreen;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      popScreen = () {
        Navigator.of(context).pop();
      };
      notesData = Provider.of<Notes>(context, listen: false);
      try {
        isNew = (ModalRoute.of(context)!.settings.arguments as bool?) ?? false;
      } catch (error) {
        existingNote = ModalRoute.of(context)!.settings.arguments as Note;
        isNew = false;
      }
      titleController.text = isNew ? '' : existingNote!.title;
      contentController.text = isNew ? '' : existingNote!.content;
    }
  }

  Future<void> _saveChanges() async {
    final newNote = Note(
      id: isNew ? DateTime.now().toString() : existingNote!.id,
      content: contentController.text,
      title: titleController.text,
      lastEdited: DateTime.now(),
    );

    if (isNew) {
      await notesData.addNote(newNote);
    } else {
      await notesData.updateNote(newNote);
    }
    // Navigator.of(context).pop();
    popScreen();
  }

  InputDecoration inputDecoration(String hintText) {
    return InputDecoration.collapsed(
      hintText: hintText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save Changes',
              onPressed: isChanged ? _saveChanges : null,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextField(
              decoration: inputDecoration('Title'),
              textCapitalization: TextCapitalization.sentences,
              controller: titleController,
              cursorColor: Theme.of(context).colorScheme.tertiary,
              style: Theme.of(context).textTheme.headlineMedium,
              autofocus: isNew,
              onChanged: (value) {
                if (isFirstChange) {
                  setState(() {
                    isChanged = true;
                  });
                  isFirstChange = false;
                }
              },
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  decoration: inputDecoration('Note something.'),
                  textCapitalization: TextCapitalization.sentences,
                  controller: contentController,
                  cursorColor: Theme.of(context).colorScheme.tertiary,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLength: 65535,
                  minLines: 50,
                  maxLines: 999,
                  onChanged: (value) {
                    if (isFirstChange) {
                      setState(() {
                        isChanged = true;
                      });
                      isFirstChange = false;
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (!isNew)
              Card(
                color: Theme.of(context).colorScheme.secondary,
                margin: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await notesData.deleteNoteWithId(existingNote!.id);
                        popScreen();
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: 'Delete Note',
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
