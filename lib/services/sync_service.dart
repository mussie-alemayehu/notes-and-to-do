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
      return;
    }

    // Ensure previous subscriptions are cancelled before starting new ones
    _stopSync();

    // 1. Perform initial pull of data from Firestore
    SyncServiceHelpers.initialPull(
      user: _currentUser,
      notesProvider: _notesProvider,
      todosProvider: _todosProvider,
    );

    // 2. Set up listeners for incoming changes from Firestore
    _startFirestoreListeners();

    // 3. Set up connectivity listener to trigger push when online
    _startConnectivityListener();

    // 4. Immediately attempt to push any pending local changes
    SyncServiceHelpers.pushPendingChanges(
      user: _currentUser,
      notesProvider: _notesProvider,
      todosProvider: _todosProvider,
      isPushingChanges: isPushingChanges,
      updateIsPushingChanges: updateIsPushingChanges,
    );
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

    if (!connectivityResult.contains(ConnectivityResult.none)) {
      SyncServiceHelpers.pushPendingChanges(
        user: _currentUser,
        notesProvider: _notesProvider,
        todosProvider: _todosProvider,
        isPushingChanges: isPushingChanges,
        updateIsPushingChanges: updateIsPushingChanges,
      );
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
        await SyncServiceHelpers.handleIncomingNotes(notes);

        // After handling incoming notes and updating DB, notify the provider
        // Fetch from local DB after updates
        final updatedLocalNotes = await DBHelper.fetchNotes();

        // Update the provider's state
        _notesProvider!.updateNotesFromSync(updatedLocalNotes);
      },
      onError: (error) {
        // Handle stream errors (e.g., permission denied, network issues)
      },
    );

    // Listen to todos changes
    _todosStreamSubscription = _firestoreService.streamToDos().listen(
      (todos) async {
        await SyncServiceHelpers.handleIncomingToDos(todos);

        // After handling incoming todos and updating DB, notify the provider
        // Fetch from local DB after updates
        final updatedLocalToDos = await DBHelper.fetchToDos();

        // Update the provider's state
        _todosProvider!.updateToDosFromSync(updatedLocalToDos);
      },
      onError: (error) {
        // Handle stream errors
      },
    );
  }

  // Dispose of streams and resources when the service is no longer needed
  void dispose() {
    _stopSync();
  }
}
