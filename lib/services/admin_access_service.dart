import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ===============================================================
/// ADMIN ROLES
/// ===============================================================
///
/// superAdmin
///     -> Complete control over the application
///
/// marketplaceAdmin
///     -> Marketplace products, prices, orders and updates
///
/// serviceProviderAdmin
///     -> "Do Business With Us", service-provider applications
///        and provider management
///
enum AdminRole {
  superAdmin,
  marketplaceAdmin,
  serviceProviderAdmin,
}

/// ===============================================================
/// ADMIN ACCESS
/// ===============================================================

class AdminAccess {
  final User user;
  final AdminRole role;

  const AdminAccess({
    required this.user,
    required this.role,
  });

  /// Useful for checking the role from other screens.
  bool get isSuperAdmin =>
      role == AdminRole.superAdmin;

  bool get isMarketplaceAdmin =>
      role == AdminRole.marketplaceAdmin;

  bool get isServiceProviderAdmin =>
      role == AdminRole.serviceProviderAdmin;
}

/// ===============================================================
/// ADMIN ACCESS SERVICE
/// ===============================================================

class AdminAccessService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// =============================================================
  /// ADMIN SIGN IN
  /// =============================================================

  Future<AdminAccess> signIn({
    required String email,
    required String password,
  }) async {
    // -------------------------------------------------------------
    // 1. FIREBASE AUTHENTICATION
    // -------------------------------------------------------------

    final credential =
        await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Administrator account was not found.',
      );
    }

    // -------------------------------------------------------------
    // 2. GET ADMIN RECORD
    // -------------------------------------------------------------

    final document = await _firestore
        .collection('adminUsers')
        .doc(user.uid)
        .get();

    final data = document.data();

    // -------------------------------------------------------------
    // 3. VERIFY ADMIN ACCOUNT
    // -------------------------------------------------------------

    if (!document.exists ||
        data == null ||
        data['active'] != true) {
      await _auth.signOut();

      throw FirebaseAuthException(
        code: 'admin-access-denied',
        message:
            'This account is not an active Namma Ranebennur administrator.',
      );
    }

    // -------------------------------------------------------------
    // 4. READ ADMIN ROLE
    // -------------------------------------------------------------

    final role =
        _parseRole(data['role']?.toString());

    if (role == null) {
      await _auth.signOut();

      throw FirebaseAuthException(
        code: 'invalid-admin-role',
        message:
            'No valid administrator role is assigned to this account.',
      );
    }

    // -------------------------------------------------------------
    // 5. RECORD ADMIN LOGIN
    // -------------------------------------------------------------

    await _firestore
        .collection('adminActivity')
        .add({
      'adminUid': user.uid,
      'action': 'admin_login',
      'role': data['role'],
      'createdAt':
          FieldValue.serverTimestamp(),
    });

    // -------------------------------------------------------------
    // 6. RETURN ADMIN ACCESS
    // -------------------------------------------------------------

    return AdminAccess(
      user: user,
      role: role,
    );
  }

  /// =============================================================
  /// CONVERT FIRESTORE ROLE TO ENUM
  /// =============================================================

  AdminRole? _parseRole(String? value) {
    switch (value) {
      case 'super_admin':
        return AdminRole.superAdmin;

      case 'marketplace_admin':
        return AdminRole.marketplaceAdmin;

      case 'service_provider_admin':
        return AdminRole.serviceProviderAdmin;

      default:
        return null;
    }
  }
}
