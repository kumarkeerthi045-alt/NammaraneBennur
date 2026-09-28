import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/admin_access_service.dart';
import 'admin_control_center_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() =>
      _AdminLoginScreenState();
}

class _AdminLoginScreenState
    extends State<AdminLoginScreen> {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool obscurePassword = true;
  bool loading = false;

  // ------------------------------------------------------------
  // ADMIN LOGIN
  // ------------------------------------------------------------

  Future<void> loginAdmin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter admin email and password",
          ),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final access = await AdminAccessService().signIn(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminControlCenterScreen(access: access)),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Admin sign-in failed.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to verify administrator access.')),
      );
    } finally {
      if (mounted) setState(() { loading = false; });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),

            child: Column(
              children: [
                // ADMIN ICON
                Container(
                  width: 95,
                  height: 95,

                  decoration: BoxDecoration(
                    color: const Color(0xffffeee2),
                    borderRadius:
                        BorderRadius.circular(28),
                  ),

                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 55,
                    color: Color(0xffF97316),
                  ),
                ),

                const SizedBox(height: 25),

                // TITLE
                Text(
                  "Admin Panel",
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Namma Ranebennur",
                  style: GoogleFonts.poppins(
                    color: const Color(0xffF97316),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 35),

                // EMAIL
                TextField(
                  controller: emailController,

                  keyboardType:
                      TextInputType.emailAddress,

                  decoration: InputDecoration(
                    labelText: "Admin Email",
                    hintText: "Enter admin email",

                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xffF97316),
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // PASSWORD
                TextField(
                  controller: passwordController,

                  obscureText: obscurePassword,

                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter password",

                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xffF97316),
                    ),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword =
                              !obscurePassword;
                        });
                      },

                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed:
                        loading ? null : loginAdmin,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xffF97316),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),

                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            "Login to Admin Panel",
                            style:
                                GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Authorized administrators only",
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
