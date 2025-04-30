import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../db_helper.dart';
import '../models.dart';
import '../providers/notes.dart';
import '../providers/to_dos.dart';
import './firestore_services.dart';

class SyncService {
  final FirestoreService _firestoreService = FirestoreService();
  final Connectivity _connectivity = Connectivity();

  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _notesStreamSubscription;
  StreamSubscription? _todosStreamSubscription;
  User? _currentUser;

  // References to the providers
  Notes? _notesProvider;
  ToDos? _todosProvider;

  // Flag to prevent concurrent executions of _pushPendingChanges
  bool _isPushingChanges = false;

  // Private constructor for singleton pattern (optional but common for services)
  SyncService._privateConstructor();

  static final SyncService _instance = SyncService._privateConstructor();

  factory SyncService() {
    return _instance;
  }

  // Method to set the provider references
  void setProviders(Notes notesProvider, ToDos todosProvider) {
    _notesProvider = notesProvider;
    _todosProvider = todosProvider;
    // If a user is already logged in when providers are set, start sync

    if (_currentUser != null) {
      print('SyncService providers set, starting sync.');
      _startSync();
    }
  }

  // Initialize the sync service
  void initialize() {
    // Listen for authentication state changes
    FirebaseAuth.instance.userChanges().listen((user) {
      _currentUser = user;
      if (_currentUser == null) {
        _startSync(); // Start sync when user logs in
      } else {
        _stopSync(); // Stop sync when user logs out
      }
    });

    // Initially check connectivity
    _checkConnectivityAndSync();
  }

  // Start the synchronization process
  void _startSync() {
    if (_notesProvider == null || _todosProvider == null) {
      print('Cannot start sync: Providers not set.');
      return;
    }

    // Ensure previous subscriptions are cancelled before starting new ones
    _stopSync();

    // 1. Perform initial pull of data from Firestore
    _initialPull();

    // 2. Set up listeners for incoming changes from Firestore
    _startFirestoreListeners();

    // 3. Set up connectivity listener to trigger push when online
    _startConnectivityListener();

    // 4. Immediately attempt to push any pending local changes
    _pushPendingChanges();
  }

  // Stop the synchronization process (e.g., on logout)
  void _stopSync() {
    _connectivitySubscription?.cancel();
    _notesStreamSubscription?.cancel();
    _todosStreamSubscription?.cancel();
    _connectivitySubscription = null;
    _notesStreamSubscription = null;
    _todosStreamSubscription = null;
    print('Sync services stopped.');
  }

  // Check connectivity and trigger sync push if online
  Future<void> _checkConnectivityAndSync() async {
    final connectivityResult = await _connectivity.checkConnectivity();

    if (!connectivityResult.contains(ConnectivityResult.none)) {
      print('Device is online. Attempting to push pending changes.');
      _pushPendingChanges();
    } else {
      print('Device is offline.');
    }
  }

  // Start listening for connectivity changes
  void _startConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      _checkConnectivityAndSync();
    });
  }

  // Start listening for real-time changes from Firestore
  void _startFirestoreListeners() {
    if (_currentUser == null ||
        _notesProvider == null ||
        _todosProvider == null) {
      return;
    }

    // Listen to notes changes
    _notesStreamSubscription = _firestoreService.streamNotes().listen(
      (notes) async {
        print('Received ${notes.length} notes from Firestore stream.');
        await _handleIncomingNotes(notes);

        // After handling incoming notes and updating DB, notify the provider
        // Fetch from local DB after updates
        final updatedLocalNotes = await DBHelper.fetchNotes();

        // Update the provider's state
        _notesProvider!.updateNotesFromSync(updatedLocalNotes);
      },
      onError: (error) {
        print('Error in Firestore notes stream: $error');
        // Handle stream errors (e.g., permission denied, network issues)
      },
    );

    // Listen to todos changes
    _todosStreamSubscription = _firestoreService.streamToDos().listen(
      (todos) async {
        print('Received ${todos.length} todos from Firestore stream.');
        await _handleIncomingToDos(todos);

        // After handling incoming todos and updating DB, notify the provider
        // Fetch from local DB after updates
        final updatedLocalToDos = await DBHelper.fetchToDos();

        // Update the provider's state
        _todosProvider!.updateToDosFromSync(updatedLocalToDos);
      },
      onError: (error) {
        print('Error in Firestore todos stream: $error');
        // Handle stream errors
      },
    );
  }

  // Handle incoming notes from the Firestore stream
  Future<void> _handleIncomingNotes(List<Note> firebaseNotes) async {
    // Fetch local notes once before processing incoming notes
    final localNotes = await DBHelper.fetchNotes();

    for (final firebaseNote in firebaseNotes) {
      // Try to find a local item matching by firebaseId first
      final existingLocalNoteByFirebaseId = localNotes.firstWhere(
        (note) => note.firebaseId == firebaseNote.firebaseId,
        orElse: () => Note(
          // Dummy Note if not found
          title: '',
          content: '',
          lastEdited: DateTime.now(),
          clientTimestamp: 0,
          syncStatus: 'synced',
        ),
      );

      if (existingLocalNoteByFirebaseId.id != null) {
        // Found a local item with the same firebaseId
        // Now, apply conflict resolution
        if (existingLocalNoteByFirebaseId.syncStatus != 'synced' &&
            existingLocalNoteByFirebaseId.clientTimestamp >
                firebaseNote.clientTimestamp) {
          print(
              'Conflict detected for note ${existingLocalNoteByFirebaseId.id}. Local version wins.');
          // Local version has pending changes and is newer, do nothing.
          // The local pending change will be pushed later.
        } else {
          // Firestore version wins (newer or local is synced), update the local item
          print(
              'Updating local note ${existingLocalNoteByFirebaseId.id} from Firebase: ${firebaseNote.firebaseId}');

          await DBHelper.updateItemFromFirebase(
            Type.note,
            firebaseNote.toMap(),
          );
        }
      } else {
        // No local item found with this firebaseId.
        // Check if there's a local item pending creation with the same clientTimestamp
        // This handles the case where the item was created offline on this device.
        final pendingCreateLocalNote = localNotes.firstWhere(
          (note) =>
              note.syncStatus == 'pending_create' &&
              note.clientTimestamp == firebaseNote.clientTimestamp,
          orElse: () => Note(
            // Dummy Note if not found
            title: '',
            content: '',
            lastEdited: DateTime.now(),
            clientTimestamp: 0,
            syncStatus: 'synced',
          ),
        );

        if (pendingCreateLocalNote.id != null) {
          // Found a local item pending creation with matching timestamp.
          // This is the same item created offline on this device.
          // Update it with the firebaseId received from Firestore.
          print(
              'Updating local pending_create note ${pendingCreateLocalNote.id} with firebaseId: ${firebaseNote.firebaseId}');
          await DBHelper.updateItemFirebaseIdAndStatus(
            Type.note,
            pendingCreateLocalNote.id!,
            firebaseNote.firebaseId!,
          );
        } else {
          // Item is new from Firebase and doesn't exist locally, insert it.
          print('Inserting new note from Firebase: ${firebaseNote.firebaseId}');
          await DBHelper.insertItemFromFirebase(
              Type.note, firebaseNote.toMap());
        }
      }
    }

    // --- Handle Deletions from Firebase ---
    // This requires comparing the current local items with firebaseIds
    // against the list of items received from Firebase.
    final localNotesWithFirebaseId =
        localNotes.where((note) => note.firebaseId != null).toList();
    final firebaseNoteIds =
        firebaseNotes.map((note) => note.firebaseId).toSet();

    for (final localNote in localNotesWithFirebaseId) {
      // If a local item has a firebaseId but is NOT in the incoming firebase list,
      // it means it was deleted in Firebase by another client.
      // We should permanently delete it locally, UNLESS it has pending local changes.
      if (!firebaseNoteIds.contains(localNote.firebaseId) &&
          localNote.syncStatus == 'synced') {
        print(
            'Deleting local note ${localNote.id} (firebaseId: ${localNote.firebaseId}) deleted in Firebase.');
        await DBHelper.permanentDeleteItem(Type.note, localNote.id!);
      }
      // Note: If a local item has pending changes (update/delete) and is not in the firebase list,
      // we assume the local change should take precedence. The pending delete will be pushed later,
      // and the pending update might result in a re-creation in Firebase depending on logic.
    }
  }

  // Handle incoming todos from the Firestore stream
  Future<void> _handleIncomingToDos(List<ToDo> firebaseToDos) async {
    // Fetch local todos once before processing incoming todos
    final localToDos = await DBHelper.fetchToDos();

    for (final firebaseToDo in firebaseToDos) {
      // Try to find a local item matching by firebaseId first
      final existingLocalToDoByFirebaseId = localToDos.firstWhere(
        (todo) => todo.firebaseId == firebaseToDo.firebaseId,
        orElse: () => ToDo(
          // Dummy ToDo if not found
          action: '',
          addedOn: DateTime.now(),
          clientTimestamp: 0,
          syncStatus: 'synced',
        ),
      );

      if (existingLocalToDoByFirebaseId.id != null) {
        // Found a local item with the same firebaseId
        // Apply conflict resolution
        if (existingLocalToDoByFirebaseId.syncStatus != 'synced' &&
            existingLocalToDoByFirebaseId.clientTimestamp >
                firebaseToDo.clientTimestamp) {
          print(
              'Conflict detected for todo ${existingLocalToDoByFirebaseId.id}. Local version wins.');
          // Local version wins
        } else {
          // Firestore version wins, update the local item
          print(
              'Updating local todo ${existingLocalToDoByFirebaseId.id} from Firebase: ${firebaseToDo.firebaseId}');
          await DBHelper.updateItemFromFirebase(
              Type.todo, firebaseToDo.toMap());
        }
      } else {
        // No local item found with this firebaseId.
        // Check if there's a local item pending creation with the same clientTimestamp
        final pendingCreateLocalToDo = localToDos.firstWhere(
          (todo) =>
              todo.syncStatus == 'pending_create' &&
              todo.clientTimestamp == firebaseToDo.clientTimestamp,
          orElse: () => ToDo(
            // Dummy ToDo if not found
            action: '',
            addedOn: DateTime.now(),
            clientTimestamp: 0,
            syncStatus: 'synced',
          ),
        );

        if (pendingCreateLocalToDo.id != null) {
          // Found a local item pending creation with matching timestamp.
          // Update it with the firebaseId received from Firestore.
          print(
              'Updating local pending_create todo ${pendingCreateLocalToDo.id} with firebaseId: ${firebaseToDo.firebaseId}');
          await DBHelper.updateItemFirebaseIdAndStatus(
              Type.todo, pendingCreateLocalToDo.id!, firebaseToDo.firebaseId!);
        } else {
          // Item is new from Firebase and doesn't exist locally, insert it.
          print('Inserting new todo from Firebase: ${firebaseToDo.firebaseId}');
          await DBHelper.insertItemFromFirebase(
            Type.todo,
            firebaseToDo.toMap(),
          );
        }
      }
    }

    // --- Handle Deletions from Firebase ---
    final localToDosWithFirebaseId =
        localToDos.where((todo) => todo.firebaseId != null).toList();
    final firebaseToDoIds =
        firebaseToDos.map((todo) => todo.firebaseId).toSet();

    for (final localToDo in localToDosWithFirebaseId) {
      if (!firebaseToDoIds.contains(localToDo.firebaseId) &&
          localToDo.syncStatus == 'synced') {
        print(
            'Deleting local todo ${localToDo.id} (firebaseId: ${localToDo.firebaseId}) deleted in Firebase.');
        await DBHelper.permanentDeleteItem(Type.todo, localToDo.id!);
      }
    }
  }

  // Perform an initial pull of all data from Firestore
  Future<void> _initialPull() async {
    if (_currentUser == null ||
        _notesProvider == null ||
        _todosProvider == null) {
      return;
    }
    print('Performing initial data pull from Firestore...');
    try {
      final firebaseNotes = await _firestoreService.getAllNotes();
      final firebaseToDos = await _firestoreService.getAllToDos();

      // For initial pull, iterate through Firebase data and merge with local
      // This logic is similar to handling stream updates but for the full dataset.
      // We need to fetch local data first to compare.
      final localNotes = await DBHelper.fetchNotes();
      final localToDos = await DBHelper.fetchToDos();

      // Process notes from Firebase
      for (final note in firebaseNotes) {
        final existingNote = localNotes.firstWhere(
          (localNote) => localNote.firebaseId == note.firebaseId,
          orElse: () => Note(
            title: '',
            content: '',
            lastEdited: DateTime.now(),
            clientTimestamp: 0,
            syncStatus: 'synced',
          ),
        );

        if (existingNote.id == null ||
            existingNote.syncStatus == 'pending_delete') {
          // Item doesn't exist locally or was marked for delete, insert it
          print('Initial pull: Inserting note ${note.firebaseId}');
          await DBHelper.insertItemFromFirebase(Type.note, note.toMap());
        } else {
          // Item exists, update it if Firebase version is newer or local is synced
          if (existingNote.syncStatus == 'synced' ||
              existingNote.clientTimestamp <= note.clientTimestamp) {
            print(
                'Initial pull: Updating existing note ${existingNote.id} from Firebase ${note.firebaseId}');
            await DBHelper.updateItemFromFirebase(Type.note, note.toMap());
          } else {
            print(
                'Initial pull: Local note ${existingNote.id} has pending changes, skipping update from Firebase.');
          }
        }
      }

      // Process todos from Firebase
      for (final todo in firebaseToDos) {
        final existingToDo = localToDos.firstWhere(
          (localToDo) => localToDo.firebaseId == todo.firebaseId,
          orElse: () => ToDo(
            action: '',
            addedOn: DateTime.now(),
            clientTimestamp: 0,
            syncStatus: 'synced',
          ),
        );

        if (existingToDo.id == null ||
            existingToDo.syncStatus == 'pending_delete') {
          print('Initial pull: Inserting todo ${todo.firebaseId}');
          await DBHelper.insertItemFromFirebase(Type.todo, todo.toMap());
        } else {
          if (existingToDo.syncStatus == 'synced' ||
              existingToDo.clientTimestamp <= todo.clientTimestamp) {
            print(
                'Initial pull: Updating existing todo ${existingToDo.id} from Firebase ${todo.firebaseId}');
            await DBHelper.updateItemFromFirebase(Type.todo, todo.toMap());
          } else {
            print(
                'Initial pull: Local todo ${existingToDo.id} has pending changes, skipping update from Firebase.');
          }
        }
      }

      // TODO: Handle deletions during initial pull. Compare fetched firebaseIds with local firebaseIds.
      // Any local item with a firebaseId that is NOT in the firebase lists should be permanently deleted
      // UNLESS it has a pending change (create, update, delete). If it has a pending delete,
      // and is not in Firebase, it means the delete didn't sync, or it was already deleted.
      // This requires careful logic.

      print('Initial data pull complete. Updating providers.');
      // After initial pull and DB updates, update the providers
      final updatedLocalNotes = await DBHelper.fetchNotes();
      _notesProvider!.updateNotesFromSync(updatedLocalNotes);

      final updatedLocalToDos = await DBHelper.fetchToDos();
      _todosProvider!.updateToDosFromSync(updatedLocalToDos);
    } catch (e) {
      print('Error during initial data pull: $e');
    }
  }

  // Push pending local changes to Firestore
  Future<void> _pushPendingChanges() async {
    // Check if already pushing changes
    if (_isPushingChanges) {
      print('Already pushing changes, skipping duplicate call.');
      return;
    }

    // Set flag to prevent concurrent executions
    _isPushingChanges = true;

    if (_currentUser == null ||
        _notesProvider == null ||
        _todosProvider == null) {
      _isPushingChanges = false;
      print('Cannot push changes: User not logged in or providers not set.');
      return;
    }

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _isPushingChanges = false;
      print('Device is offline, cannot push changes.');
      return;
    }

    print('Attempting to push pending changes to Firestore...');

    try {
      final pendingNotesMaps = await DBHelper.fetchPendingItems(Type.note);
      final pendingTodosMaps = await DBHelper.fetchPendingItems(Type.todo);

      final pendingItemsMaps = [...pendingNotesMaps, ...pendingTodosMaps];

      if (pendingItemsMaps.isEmpty) {
        print('No pending changes to push.');
        _isPushingChanges = false;
        return;
      }

      for (final itemMap in pendingItemsMaps) {
        final syncStatus = itemMap['syncStatus'];
        final localId = itemMap['id']?.toString();
        final firebaseId = itemMap['firebaseId']?.toString();
        final itemType = itemMap.containsKey('title') ? Type.note : Type.todo;

        if (localId == null) {
          print('Skipping pending item with null local ID: $itemMap');
          continue;
        }

        try {
          if (syncStatus == 'pending_create') {
            print('Pushing new item (create): $itemMap');
            // Convert map back to model
            final dynamic item = itemType == Type.note
                ? Note.fromMap(itemMap)
                : ToDo.fromMap(itemMap);
            final newFirebaseId = itemType == Type.note
                ? await _firestoreService.addNote(item as Note)
                : await _firestoreService.addToDo(item as ToDo);

            print('New Firebase ID: $newFirebaseId');

            if (newFirebaseId != null) {
              // Update local item with the new firebaseId and set status to synced
              final rows = await DBHelper.updateItemFirebaseIdAndStatus(
                itemType,
                localId,
                newFirebaseId,
              );

              print(rows);

              print(
                  'Successfully pushed and updated local item with firebaseId: $newFirebaseId');
              // } else {
              //   // Handle failure to add to Firestore
              //   print('Failed to push new item (create) to Firestore.');
              //   await DBHelper.updateItemSyncStatus(
              //       itemType, localId, 'sync_error');
              //   // Optionally update provider state to reflect error
            }

            // After updating the DB, refresh the provider's state
            final updatedLocalItems = itemType == Type.note
                ? await DBHelper.fetchNotes()
                : await DBHelper.fetchToDos();

            if (itemType == Type.note) {
              _notesProvider!.updateNotesFromSync(
                updatedLocalItems as List<Note>,
              );
            } else {
              _todosProvider!.updateToDosFromSync(
                updatedLocalItems as List<ToDo>,
              );
            }
          } else if (syncStatus == 'pending_update') {
            if (firebaseId == null) {
              print(
                  'Skipping pending update for item with no firebaseId: $itemMap');
              // await DBHelper.updateItemSyncStatus(
              //     itemType, localId, 'sync_error');
              continue;
            }
            print('Pushing updated item: $itemMap');
            // Convert map back to model
            final dynamic item = itemType == Type.note
                ? Note.fromMap(itemMap)
                : ToDo.fromMap(itemMap);
            final success = itemType == Type.note
                ? await _firestoreService.updateNote(item as Note)
                : await _firestoreService.updateToDo(item as ToDo);

            if (success) {
              // Set status to synced
              await DBHelper.updateItemSyncStatus(itemType, localId, 'synced');
              print('Successfully pushed update for item: $firebaseId');
              // } else {
              //   // Handle failure to update in Firestore
              //   print('Failed to push update for item: $firebaseId');
              //   await DBHelper.updateItemSyncStatus(
              //     itemType,
              //     localId,
              //     'sync_error',
              //   );
            }

            // After updating the DB, refresh the provider's state
            final updatedLocalItems = itemType == Type.note
                ? await DBHelper.fetchNotes()
                : await DBHelper.fetchToDos();
            if (itemType == Type.note) {
              _notesProvider!
                  .updateNotesFromSync(updatedLocalItems as List<Note>);
            } else {
              _todosProvider!
                  .updateToDosFromSync(updatedLocalItems as List<ToDo>);
            }
          } else if (syncStatus == 'pending_delete') {
            if (firebaseId == null) {
              print(
                  'Item marked for deletion has no firebaseId, permanently deleting locally: $itemMap');
              // If it was created offline and marked for delete before syncing, just delete locally
              await DBHelper.permanentDeleteItem(itemType, localId);
              print(
                  'Permanently deleted local item with no firebaseId: $localId');

              // After deleting from DB, refresh the provider's state
              final updatedLocalItems = itemType == Type.note
                  ? await DBHelper.fetchNotes()
                  : await DBHelper.fetchToDos();
              if (itemType == Type.note) {
                _notesProvider!
                    .updateNotesFromSync(updatedLocalItems as List<Note>);
              } else {
                _todosProvider!
                    .updateToDosFromSync(updatedLocalItems as List<ToDo>);
              }

              continue;
            }
            print('Pushing deleted item: $itemMap');
            final success = itemType == Type.note
                ? await _firestoreService.deleteNote(firebaseId)
                : await _firestoreService.deleteToDo(firebaseId);

            if (success) {
              // Permanently delete local item after successful cloud deletion
              await DBHelper.permanentDeleteItem(itemType, localId);
              print(
                  'Successfully pushed deletion for item and deleted locally: $firebaseId');
              // After deleting from DB, refresh the provider's state
              final updatedLocalItems = itemType == Type.note
                  ? await DBHelper.fetchNotes()
                  : await DBHelper.fetchToDos();
              if (itemType == Type.note) {
                _notesProvider!
                    .updateNotesFromSync(updatedLocalItems as List<Note>);
              } else {
                _todosProvider!
                    .updateToDosFromSync(updatedLocalItems as List<ToDo>);
              }
              // }
              //  else {
              //   // Handle failure to delete in Firestore
              //   print('Failed to push deletion for item: $firebaseId');
              //   await DBHelper.updateItemSyncStatus(
              //       itemType, localId, 'sync_error');
            }
          }
        } catch (e) {
          print(
              'Error processing pending item $localId (firebaseId: $firebaseId): $e');
          // await DBHelper.updateItemSyncStatus(itemType, localId, 'sync_error');
        }
      }
      print('Finished attempting to push pending changes.');
    } catch (e) {
      print('Error fetching pending items from local DB: $e');
    } finally {
      // Reset flag when done, regardless of success or failure
      _isPushingChanges = false;
    }
  }

  // Dispose of streams and resources when the service is no longer needed
  void dispose() {
    _stopSync();
  }
}
