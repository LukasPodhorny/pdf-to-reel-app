import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = _initializeGoogleSignIn();

  static GoogleSignIn _initializeGoogleSignIn() {
    if (kIsWeb) {
      // Web: requires explicit clientId (OAuth 2.0 Web Client ID from Google Cloud Console)
      // TODO: Replace 'YOUR_WEB_CLIENT_ID' with your actual Web Client ID
      // Found at: Google Cloud Console > APIs & Services > Credentials > OAuth 2.0 Client IDs
      return GoogleSignIn(
        clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
    } else {
      // Mobile (iOS/Android): use default initialization
      // The client IDs are configured in native files (google-services.json, GoogleService-Info.plist)
      return GoogleSignIn(scopes: ['email', 'profile']);
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Checks if a user with this email exists.
  /// NOTE: fetchSignInMethodsForEmail was removed in newer Firebase versions.
  /// We use a workaround by attempting a login with a dummy password.
  Future<bool> checkIfUserExists(String email) async {
    try {
      // Attempt login with a dummy password.
      // If email enumeration protection is OFF in Firebase Console,
      // this will return 'user-not-found' if the user doesn't exist.
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: "dummy_password_for_existence_check_123!",
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return false;
      }
      // 'wrong-password' or 'invalid-credential' (if protection is ON)
      // usually means we can proceed to the next step.
      return true;
    } catch (e) {
      return true;
    }
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with Google.
  /// On web, make sure YOUR_WEB_CLIENT_ID is set in _initializeGoogleSignIn().
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      print("Google Sign-In Error: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
        await _googleSignIn.signOut();
      }
    } catch (e) {
      print("Google Sign-Out Error: $e");
    }
    await _auth.signOut();
  }

  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken(true);
    }
    return null;
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}
