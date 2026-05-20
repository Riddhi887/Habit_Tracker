import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //get firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //emit current user whenever state changes redirect to home screen
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //get currently logged in user
  User? get currentUser => _auth.currentUser;

  //helper method to get error message
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect Password, try again.';
      case 'email-already-in-use':
        return 'This email already exist.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  //sign up
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      //create user auth account in firebase
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //update display name
      await cred.user?.updateDisplayName(name);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    }
  }

  //sign in
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    }
  }

  //sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
