// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:namma_ranebennur/screens/splash_screen.dart';
import 'package:namma_ranebennur/services/auth_service.dart';

void main() {
  testWidgets('application starts with the splash screen', (tester) async {
    // A real AuthService talks to the Firebase platform channel, which is
    // unavailable in a widget test. Inject one backed by MockFirebaseAuth
    // (no signed-in user) so the splash screen's post-delay login check
    // resolves without touching the network or requiring Firebase.initializeApp().
    final authService = AuthService(auth: MockFirebaseAuth());

    await tester.pumpWidget(MaterialApp(
      home: SplashScreen(authService: authService),
    ));
    expect(find.text('Namma Ranebennur'), findsOneWidget);

    // Drain the splash screen's 2-second timer so no timer is left pending
    // when the test ends.
    await tester.pump(const Duration(seconds: 3));
  });
}
