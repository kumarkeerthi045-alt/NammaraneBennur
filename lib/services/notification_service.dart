import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = await _messaging.getToken();
      await _saveToken(token);
      _messaging.onTokenRefresh.listen((token) async {
        try {
          await _saveToken(token);
        } catch (_) {
          // Notifications must never prevent the customer from using the app.
        }
      });
    } catch (_) {
      // Firebase Messaging may be unavailable on an unsupported device.
    }
  }

  Future<void> _saveToken(String? token) async {
    final user = _auth.currentUser;
    if (user == null || token == null || token.isEmpty) return;
    await _firestore.collection('users').doc(user.uid).set({
      'notificationTokens': FieldValue.arrayUnion([token]),
      'notificationTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
