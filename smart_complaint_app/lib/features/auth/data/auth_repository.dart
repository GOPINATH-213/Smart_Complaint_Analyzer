import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      debugPrint('Send verification email error: $e');
      rethrow;
    }
  }

  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Password reset email error: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        try {
          return await _auth.signInWithPopup(googleProvider);
        } on FirebaseAuthException catch (e) {
          debugPrint('signInWithPopup failed code [${e.code}]: ${e.message}');
          // If FedCM mode or network popup fails, fall back to redirect mode on Web
          if (e.code == 'network-request-failed' ||
              e.code == 'popup-blocked' ||
              e.code == 'popup-closed-by-user' ||
              e.code == 'cancelled') {
            await _auth.signInWithRedirect(googleProvider);
            return null;
          }
          rethrow;
        }
      } else {
        final googleUser = await GoogleSignIn.instance.authenticate();
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during Google Sign In: [${e.code}] ${e.message}');
      if (e.code == 'network-request-failed') {
        throw FirebaseAuthException(
          code: 'network-request-failed',
          message: 'Network connection failed while reaching authentication servers. Please check your internet connection or verify authorized domains in Firebase Console.',
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('Google Sign In error: $e');
      rethrow;
    }
  }

  /// Check for any pending Google redirect sign-in result (Web)
  Future<UserCredential?> checkRedirectResult() async {
    if (kIsWeb) {
      try {
        return await _auth.getRedirectResult();
      } catch (e) {
        debugPrint('Error getting redirect result: $e');
      }
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (e) {
        debugPrint('Google Sign Out error: $e');
      }
    }
  }
}
