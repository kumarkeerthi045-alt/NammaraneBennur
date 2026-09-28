import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'production_home_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String city;
  final String area;
  final String pincode;
  final String role;
  final bool initialKannada;

  const EmailVerificationScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
    required this.area,
    required this.pincode,
    required this.role,
    this.initialKannada = false,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends State<EmailVerificationScreen> {
  bool loading = false;
  bool resending = false;
  late bool kannada;

  String t(String english, String kn) => kannada ? kn : english;

  @override
  void initState() {
    super.initState();
    kannada = widget.initialKannada;
  }

  // ============================================================
  // CHECK EMAIL VERIFICATION
  // ============================================================

  Future<void> checkVerification() async {
    setState(() {
      loading = true;
    });

    try {
      // Reload Firebase user
      await AuthService().reloadUser();

      final User? user = FirebaseAuth.instance.currentUser;

      // ----------------------------------------------------------
      // USER NOT FOUND
      // ----------------------------------------------------------

      if (user == null) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t("User not found. Please login again.", "ಬಳಕೆದಾರರು ಕಂಡುಬಂದಿಲ್ಲ. ಮತ್ತೆ ಲಾಗಿನ್ ಮಾಡಿ."),
            ),
          ),
        );

        return;
      }

      // ----------------------------------------------------------
      // EMAIL NOT VERIFIED
      // ----------------------------------------------------------

      if (!user.emailVerified) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t("Please verify your email first.", "ಮೊದಲು ನಿಮ್ಮ ಇಮೇಲ್ ಪರಿಶೀಲಿಸಿ."),
            ),
          ),
        );

        return;
      }

      // ----------------------------------------------------------
      // CHECK WHETHER USER ALREADY EXISTS
      // ----------------------------------------------------------

      final bool exists =
          await FirestoreService().userExists(user.uid);

      // ----------------------------------------------------------
      // CREATE USER DOCUMENT
      // ----------------------------------------------------------

      if (!exists) {
        final UserModel newUser = UserModel(
          userId: user.uid,
          name: widget.fullName,
          email: widget.email,
          phone: widget.phone,
          city: widget.city,
          area: widget.area,
          pincode: widget.pincode,
          role: widget.role.isEmpty
              ? "user"
              : widget.role,
          serviceProviderId: null,
          createdAt: DateTime.now(),
        );

        await FirestoreService().saveUser(newUser);
      }
      await FirestoreService().updateUser(user.uid, {
        'emailVerified': true,
        'emailVerifiedAt': FieldValue.serverTimestamp(),
      });

      // ----------------------------------------------------------
      // GO TO HOME
      // ----------------------------------------------------------

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const ProductionHomeScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${t('Something went wrong', 'ಏನೋ ತಪ್ಪಾಗಿದೆ')}: $e",
          ),
        ),
      );
    }
  }

  // ============================================================
  // RESEND VERIFICATION EMAIL
  // ============================================================

  Future<void> resendEmail() async {
    if (resending) return;
    setState(() => resending = true);
    try {
      await AuthService().resendVerificationEmail();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t("Verification email sent. Check Inbox and Spam.", "ಪರಿಶೀಲನಾ ಇಮೇಲ್ ಕಳುಹಿಸಲಾಗಿದೆ. ಇನ್‌ಬಾಕ್ಸ್ ಮತ್ತು ಸ್ಪ್ಯಾಮ್ ಪರಿಶೀಲಿಸಿ."),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${t('Unable to send email', 'ಇಮೇಲ್ ಕಳುಹಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ')}: $e",
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => resending = false);
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => kannada = !kannada),
            icon: const Icon(Icons.translate_rounded),
            label: Text(kannada ? 'English' : 'ಕನ್ನಡ'),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              const SizedBox(height: 18),

              // Email icon
              const Icon(
                Icons.mark_email_read_rounded,
                size: 96,
                color: Color(0xfff45b22),
              ),

              const SizedBox(height: 30),

              // Title
              Text(
                t("Verify Your Email", "ನಿಮ್ಮ ಇಮೇಲ್ ಪರಿಶೀಲಿಸಿ"),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // Description
              Text(
                t("We've sent a verification link to", "ಪರಿಶೀಲನಾ ಲಿಂಕ್ ಅನ್ನು ಇಲ್ಲಿ ಕಳುಹಿಸಿದ್ದೇವೆ"),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              // Email
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 35),

              // ==================================================
              // VERIFIED BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed:
                      loading ? null : checkVerification,

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF1565C0),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),

                  child: loading
                      ? const SizedBox(
                          width: 25,
                          height: 25,
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          t("I've Verified", "ನಾನು ಪರಿಶೀಲಿಸಿದ್ದೇನೆ"),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // RESEND
              // ==================================================

              TextButton(
                onPressed: resending ? null : resendEmail,

                child: Text(
                  resending ? t("Sending…", "ಕಳುಹಿಸಲಾಗುತ್ತಿದೆ…") : t("Resend Verification Email", "ಪರಿಶೀಲನಾ ಇಮೇಲ್ ಮತ್ತೆ ಕಳುಹಿಸಿ"),
                  style: GoogleFonts.poppins(
                    color: const Color(0xfff45b22),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // INSTRUCTION
              // ==================================================

              Text(
                t(
                  'After clicking the verification link in your email, return here and tap "I\'ve Verified". If you do not see it, check Spam.',
                  'ಇಮೇಲ್‌ನ ಪರಿಶೀಲನಾ ಲಿಂಕ್ ಒತ್ತಿದ ನಂತರ ಇಲ್ಲಿ ಮರಳಿ “ನಾನು ಪರಿಶೀಲಿಸಿದ್ದೇನೆ” ಒತ್ತಿರಿ. ಇಮೇಲ್ ಕಾಣದಿದ್ದರೆ ಸ್ಪ್ಯಾಮ್ ಪರಿಶೀಲಿಸಿ.',
                ),

                textAlign: TextAlign.center,

                style: GoogleFonts.poppins(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
