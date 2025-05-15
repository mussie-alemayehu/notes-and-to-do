import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../db_helper.dart';
import '../providers/notes.dart';
import '../providers/to_dos.dart';
import './firestore_services.dart';
import './sync_service_helpers.dart';

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

  void updateIsPushingChanges(bool value) {
    _isPushingChanges = value;
  }

  bool get isPushingChanges => _isPushingChanges;

  // Private constructor for singleton pattern
  SyncService._privateConstructor();

  static final SyncService _instance = SyncService._privateConstructor();

  factory SyncService() {
    return _instance;
  }

  // Method to set the provider references and pass the push request callback
  void setProviders(Notes notesProvider, ToDos todosProvider) {
    _notesProvider = notesProvider;
    _todosProvider = todosProvider;

    // Pass the requestPush method to the providers
    _notesProvider!.setSyncRequestCallback(requestPush);
    _todosProvider!.setSyncRequestCallback(requestPush);

    // If user is already logged in when providers are set, start sync
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
        // Start sync only if providers are already set
        if (_notesProvider != null && _todosProvider != null) {
          _startSync();
        }
      } else {
        _stopSync();

        DBHelper.clearAllData(Type.note);
        DBHelper.clearAllData(Type.todo);
      }
    });
  }

  // Start the synchronization process
  void _startSync() {
    if (_currentUser == null ||
        _notesProvider == null ||
        _todosProvider == null) {
      return;
    }

    // Ensure previous subscriptions are cancelled before starting new ones
    _stopSync(); // This will cancel existing streams but keep provider refs

    // 1. Perform initial pull of data from Firestore
    // This should happen first to populate the local DB before listening to changes
    SyncServiceHelpers.initialPull(
      user: _currentUser,
      notesProvider: _notesProvider,
      todosProvider: _todosProvider,
    ).then((_) {
      // After initial pull is complete, start listening to streams
      _startFirestoreListeners();
      // And then attempt to push any changes that might have occurred
      // during the initial pull or before connectivity was established.
      // This call is also triggered by requestPush, but we call it here
      // to handle any pending changes that existed before the app started
      // or before connectivity was available after startup.
      requestPush(); // Use the public method
    });

    // 3. Set up connectivity listener to trigger push when online
    _startConnectivityListener();
  }

  // Stop the synchronization process (e.g., on logout)
  void _stopSync() {
    _connectivitySubscription?.cancel();
    _notesStreamSubscription?.cancel();
    _todosStreamSubscription?.cancel();
    _connectivitySubscription = null;
    _notesStreamSubscription = null;
    _todosStreamSubscription = null;
  }

  // Check connectivity and trigger sync push if online
  Future<void> _checkConnectivityAndSync() async {
    final connectivityResult = await _connectivity.checkConnectivity();

    // Check if any result indicates connectivity (not just 'none')
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      // Only push if user is logged in and providers are set
      if (_currentUser != null &&
          _notesProvider != null &&
          _todosProvider != null) {
        requestPush(); // Use the public method
      }
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
      (firebaseNotes) async {
        // Use the helper method to handle incoming notes and update the local DB
        await SyncServiceHelpers.handleIncomingNotes(firebaseNotes);

        // After handling incoming notes and updating DB, notify the provider
        // Fetch from local DB after updates
        final updatedLocalNotes = await DBHelper.fetchNotes();
        // Update the provider's state
        _notesProvider!.updateNotesFromSync(updatedLocalNotes);
      },
      onError: (error) {},
    );

    // Listen to todos changes
    _todosStreamSubscription = _firestoreService.streamToDos().listen(
      (todos) async {
        // Use the helper method to handle incoming todos and update the local DB
        await SyncServiceHelpers.handleIncomingToDos(todos);

        // After handling incoming todos and updating DB, notify the provider
        // Fetch from local DB after updates
        final updatedLocalToDos = await DBHelper.fetchToDos();
        // Update the provider's state
        _todosProvider!.updateToDosFromSync(updatedLocalToDos);
      },
      onError: (error) {},
    );
  }

  // Public method for providers to request a push of pending changes
  void requestPush() {
    // Call the internal push logic, which handles the _isPushingChanges flag
    SyncServiceHelpers.pushPendingChanges(
      user: _currentUser,
      notesProvider: _notesProvider,
      todosProvider: _todosProvider,
      isPushingChanges: _isPushingChanges,
      updateIsPushingChanges: updateIsPushingChanges,
    );
  }

  // Dispose of streams and resources when the service is no longer needed
  void dispose() {
    _stopSync();
  }
}
