import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  // ==========================
  // REGISTER USER
  // ==========================
  Future<String?> register({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint("Trying to register: $email");

      UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      debugPrint("UID: ${credential.user?.uid}");
      debugPrint("EMAIL: ${credential.user?.email}");
      debugPrint("EMAIL VERIFIED: ${credential.user?.emailVerified}");

      // Send Email Verification
      await credential.user!.sendEmailVerification();

      debugPrint("Verification email request completed.");

      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException");
      debugPrint("Code: ${e.code}");
      debugPrint("Message: ${e.message}");
      return e.message;
    } catch (e) {
      debugPrint("Unknown Error: $e");
      return e.toString();
    }
  }

  // ==========================
  // LOGIN USER
  // ==========================
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================
  // FORGOT PASSWORD
  // ==========================
  Future<String?> resetPassword({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================
  // CURRENT USER
  // ==========================
  User? get currentUser => _auth.currentUser;

  // ==========================
  // LOGOUT
  // ==========================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ==========================
  // RESEND EMAIL VERIFICATION
  // ==========================
  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // ==========================
  // RELOAD USER
  // ==========================
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // ==========================
  // CHECK EMAIL VERIFIED
  // ==========================
  bool get isEmailVerified =>
      _auth.currentUser?.emailVerified ?? false;
}