import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'email_verification_screen.dart';
import 'production_home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.authService});

  // Overridable only so widget tests can inject a fake AuthService instead
  // of hitting the real Firebase platform channel.
  final AuthService? authService;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final AuthService auth = widget.authService ?? AuthService();

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    // Keep splash screen visible for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // ============================================================
    // USER NOT LOGGED IN
    // ============================================================

    if (auth.currentUser == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );

      return;
    }

    // ============================================================
    // RELOAD FIREBASE USER
    // ============================================================

    await auth.reloadUser();

    if (!mounted) return;

    // ============================================================
    // EMAIL NOT VERIFIED
    // ============================================================

    if (!auth.isEmailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(
            fullName: "",
            email: auth.currentUser?.email ?? "",
            phone: "",
            city: "",
            area: "",
            pincode: "",
            role: "",
          ),
        ),
      );

      return;
    }

    // ============================================================
    // USER VERIFIED → HOME SCREEN
    // ============================================================

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ProductionHomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==========================================================
      // ORANGE SPLASH BACKGROUND
      // ==========================================================

      backgroundColor: const Color(0xFFF97316),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ======================================================
            // LOGO
            // ======================================================

            Container(
              width: 150,
              height: 150,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              padding: const EdgeInsets.all(8),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),

                child: Image.asset(
                  'assets/images/namma_ranebennur_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ======================================================
            // APP NAME
            // ======================================================

            const Text(
              "Namma Ranebennur",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Your City. Your Services.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 35),

            // ======================================================
            // LOADING INDICATOR
            // ======================================================

            const SizedBox(
              width: 28,
              height: 28,

              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
