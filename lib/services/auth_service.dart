import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //get firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //emit current user whenever state changes redirect to home screen
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //get currently logged in user
  User? get currentUser => _auth.currentUser;

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
      return e.message;
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
      return e.message;
    }
  }

  //sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
