import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication Service
/// Handles Firebase Authentication with Google Sign-In
class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static User? _safeCurrentUser() {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Get current user
  static User? get currentUser => _safeCurrentUser();

  /// Check if user is logged in
  static bool get isLoggedIn => _safeCurrentUser() != null;

  /// Get user ID
  static String? get userId => _safeCurrentUser()?.uid;

  /// Get user display name
  static String? get displayName => _safeCurrentUser()?.displayName;

  /// Get user email
  static String? get email => _safeCurrentUser()?.email;

  /// Get user photo URL
  static String? get photoUrl => _safeCurrentUser()?.photoURL;

  /// Stream of auth state changes
  static Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (_) {
      return const Stream<User?>.empty();
    }
  }

  /// Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Delete account
  static Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _googleSignIn.signOut();
      await user.delete();
    }
  }
}
