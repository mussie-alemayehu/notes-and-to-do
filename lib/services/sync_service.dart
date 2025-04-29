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
    print('SyncService providers set.');
    // If a user is already logged in when providers are set, start sync

    if (_currentUser != null) {
      _startSync();
    }
  }

  // Initialize the sync service
  void initialize() {
    // Listen for authentication state changes
    FirebaseAuth.instance.userChanges().listen((user) {
      _currentUser = user;
      if (_currentUser != null) {
        print('User logged in: ${_currentUser!.uid}. Starting sync setup.');
        _startSync(); // Start sync when user logs in
      } else {
        print('User logged out. Stopping sync.');
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
    _currentUser = null;
    print('Sync service stopped.');
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
        final updatedLocalNotes =
            await DBHelper.fetchNotes(); // Fetch from local DB after updates
        _notesProvider!.updateNotesFromSync(
            updatedLocalNotes); // Update the provider's state
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
        final updatedLocalToDos =
            await DBHelper.fetchToDos(); // Fetch from local DB after updates
        _todosProvider!.updateToDosFromSync(
            updatedLocalToDos); // Update the provider's state
      },
      onError: (error) {
        print('Error in Firestore todos stream: $error');
        // Handle stream errors
      },
    );
  }

  // Handle incoming notes from the Firestore stream
  Future<void> _handleIncomingNotes(List<Note> firebaseNotes) async {
    final localNotes = await DBHelper.fetchNotes();

    for (final firebaseNote in firebaseNotes) {
      // Find the corresponding local note by firebaseId
      final localNote = localNotes.firstWhere(
        (note) => note.firebaseId == firebaseNote.firebaseId,
        orElse: () => Note(
            // Create a dummy note if not found locally to simplify logic
            // This dummy note will have a null id and syncStatus 'synced'
            title: '',
            content: '',
            lastEdited: DateTime.now(),
            clientTimestamp: 0,
            syncStatus: 'synced'),
      );

      // Conflict Resolution (Last Write Wins based on clientTimestamp)
      // If local item exists AND has pending changes AND local timestamp is newer
      if (localNote.id != null &&
          localNote.syncStatus != 'synced' &&
          localNote.clientTimestamp > firebaseNote.clientTimestamp) {
        print(
            'Conflict detected for note ${localNote.id}. Local version wins.');
        // Local version wins, do nothing. The local pending change will be pushed later.
      } else {
        // No conflict, or Firestore version wins, or item is new from Firebase
        if (localNote.id == null) {
          // Item is new from Firebase, insert it locally
          print('Inserting new note from Firebase: ${firebaseNote.firebaseId}');
          await DBHelper.insertItemFromFirebase(
            Type.note,
            firebaseNote.toMap(),
          );
        } else {
          // Item exists locally, update it with Firebase data
          print(
              'Updating local note ${localNote.id} from Firebase: ${firebaseNote.firebaseId}');
          await DBHelper.updateItemFromFirebase(
            Type.note,
            firebaseNote.toMap(),
          );
        }
      }
    }

    // TODO: Handle deletions from Firebase - The stream doesn't directly tell you what was deleted.
    // You might need a separate mechanism or compare the full list from Firebase
    // with the local list to find items that exist locally but are missing in Firebase.
    // This is a more advanced sync pattern. For now, we only handle additions/updates.
  }

  // Handle incoming todos from the Firestore stream
  Future<void> _handleIncomingToDos(List<ToDo> firebaseToDos) async {
    final localToDos = await DBHelper.fetchToDos();

    // Similar logic as _handleIncomingNotes
    for (final firebaseToDo in firebaseToDos) {
      final localToDo = localToDos.firstWhere(
        (todo) => todo.firebaseId == firebaseToDo.firebaseId,
        orElse: () => ToDo(
            action: '',
            addedOn: DateTime.now(),
            clientTimestamp: 0,
            syncStatus: 'synced'),
      );

      // Conflict Resolution (Last Write Wins)
      if (localToDo.id != null &&
          localToDo.syncStatus != 'synced' &&
          localToDo.clientTimestamp > firebaseToDo.clientTimestamp) {
        print(
            'Conflict detected for todo ${localToDo.id}. Local version wins.');
        // Local version wins
      } else {
        // No conflict, or Firebase version wins, or item is new
        if (localToDo.id == null) {
          print('Inserting new todo from Firebase: ${firebaseToDo.firebaseId}');
          await DBHelper.insertItemFromFirebase(
              Type.todo, firebaseToDo.toMap());
        } else {
          print(
              'Updating local todo ${localToDo.id} from Firebase: ${firebaseToDo.firebaseId}');
          await DBHelper.updateItemFromFirebase(
              Type.todo, firebaseToDo.toMap());
        }
      }
    }
    // TODO: Handle deletions from Firebase
  }

  // Perform an initial pull of all data from Firestore
  Future<void> _initialPull() async {
    if (_currentUser == null ||
        _notesProvider == null ||
        _todosProvider == null) return;
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
                syncStatus: 'synced') // Dummy
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
                syncStatus: 'synced') // Dummy
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
    if (_currentUser == null ||
        _notesProvider == null ||
        _todosProvider == null) {
      print('Cannot push changes: User not logged in or providers not set.');
      return;
    }
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('Device is offline, cannot push changes.');
      return;
    }

    print('Attempting to push pending changes to Firestore...');

    try {
      final pendingItemsMaps = await DBHelper.fetchPendingItems(Type.note);
      pendingItemsMaps.addAll(await DBHelper.fetchPendingItems(Type.todo));

      if (pendingItemsMaps.isEmpty) {
        print('No pending changes to push.');
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

            if (newFirebaseId != null) {
              // Update local item with the new firebaseId and set status to synced
              await DBHelper.updateItemFirebaseIdAndStatus(
                  itemType, localId, newFirebaseId);
              print(
                  'Successfully pushed and updated local item with firebaseId: $newFirebaseId');
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
            } else {
              // Handle failure to add to Firestore
              print('Failed to push new item (create) to Firestore.');
              await DBHelper.updateItemSyncStatus(
                  itemType, localId, 'sync_error');
              // Optionally update provider state to reflect error
            }
          } else if (syncStatus == 'pending_update') {
            if (firebaseId == null) {
              print(
                  'Skipping pending update for item with no firebaseId: $itemMap');
              await DBHelper.updateItemSyncStatus(
                  itemType, localId, 'sync_error');
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
            } else {
              // Handle failure to update in Firestore
              print('Failed to push update for item: $firebaseId');
              await DBHelper.updateItemSyncStatus(
                itemType,
                localId,
                'sync_error',
              );
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
              continue; // Move to next item
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
            } else {
              // Handle failure to delete in Firestore
              print('Failed to push deletion for item: $firebaseId');
              await DBHelper.updateItemSyncStatus(
                  itemType, localId, 'sync_error');
            }
          }
        } catch (e) {
          print(
              'Error processing pending item $localId (firebaseId: $firebaseId): $e');
          await DBHelper.updateItemSyncStatus(itemType, localId, 'sync_error');
        }
      }
      print('Finished attempting to push pending changes.');
    } catch (e) {
      print('Error fetching pending items from local DB: $e');
    }
  }

  // Dispose of streams and resources when the service is no longer needed
  void dispose() {
    _stopSync();
    print('Sync service disposed.');
  }
}
