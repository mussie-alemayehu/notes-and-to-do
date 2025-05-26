import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign In with Email & Password
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// Sign Up with Email & Password
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
