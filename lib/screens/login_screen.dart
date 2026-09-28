import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import 'admin_login_screen.dart';
import 'email_verification_screen.dart';
import 'forgot_password_screen.dart';
import 'production_home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool hidePassword = true;
  bool kannada = false;
  String t(String english, String kn) => kannada ? kn : english;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    final result = await AuthService().login(email: emailController.text.trim(), password: passwordController.text);
    if (!mounted) return;
    setState(() => isLoading = false);
    if (result != null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result))); return; }
    await AuthService().reloadUser();
    if (!mounted) return;
    if (!AuthService().isEmailVerified) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => EmailVerificationScreen(fullName: '', email: emailController.text.trim(), phone: '', city: '', area: '', pincode: '', role: '', initialKannada: kannada)));
      return;
    }
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const ProductionHomeScreen()), (_) => false);
  }

  InputDecoration decoration(String english, String kn, IconData icon) => InputDecoration(labelText: t(english, kn), prefixIcon: Icon(icon), filled: true, fillColor: const Color(0xfff3f0ef), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none));
  @override
  void dispose() { emailController.dispose(); passwordController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xfff8fafc),
    appBar: AppBar(backgroundColor: Colors.transparent, actions: [TextButton.icon(onPressed: () => setState(() => kannada = !kannada), icon: const Icon(Icons.translate_rounded), label: Text(kannada ? 'English' : 'ಕನ್ನಡ'))]),
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(25), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 20),
      Text(t('Welcome Back 👋', 'ಮತ್ತೆ ಸ್ವಾಗತ 👋'), style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8), Text(t('Login to continue', 'ಮುಂದುವರಿಸಲು ಲಾಗಿನ್ ಮಾಡಿ'), style: GoogleFonts.poppins(color: Colors.grey)), const SizedBox(height: 35),
      TextFormField(controller: emailController, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email], decoration: decoration('Email', 'ಇಮೇಲ್', Icons.email), validator: (value) => value == null || !value.contains('@') ? t('Enter a valid email', 'ಸರಿಯಾದ ಇಮೇಲ್ ನಮೂದಿಸಿ') : null), const SizedBox(height: 20),
      TextFormField(controller: passwordController, obscureText: hidePassword, autofillHints: const [AutofillHints.password], decoration: decoration('Password', 'ಪಾಸ್‌ವರ್ಡ್', Icons.lock).copyWith(suffixIcon: IconButton(onPressed: () => setState(() => hidePassword = !hidePassword), icon: Icon(hidePassword ? Icons.visibility : Icons.visibility_off))), validator: (value) => value == null || value.length < 6 ? t('Password must be at least 6 characters', 'ಪಾಸ್‌ವರ್ಡ್ ಕನಿಷ್ಠ 6 ಅಕ್ಷರ ಇರಬೇಕು') : null, onFieldSubmitted: (_) { if (!isLoading) login(); }),
      Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen(initialKannada: kannada))), child: Text(t('Forgot Password?', 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿರಾ?'), style: const TextStyle(color: Color(0xfff15106), fontWeight: FontWeight.w600)))),
      SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: isLoading ? null : login, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xfff45b22), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(t('Login', 'ಲಾಗಿನ್'), style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)))), const SizedBox(height: 30),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(t("Don't have an account? ", 'ಖಾತೆ ಇಲ್ಲವೇ? '), style: GoogleFonts.poppins()), GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen(initialKannada: kannada))), child: Text(t('Create Account', 'ಖಾತೆ ತೆರೆಯಿರಿ'), style: GoogleFonts.poppins(color: const Color(0xfff45b22), fontWeight: FontWeight.bold)))]), const SizedBox(height: 20),
      Center(child: TextButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen())), icon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xfff97316)), label: Text(t('Admin Login', 'ನಿರ್ವಾಹಕ ಲಾಗಿನ್'), style: GoogleFonts.poppins(color: const Color(0xfff97316), fontWeight: FontWeight.w600)))),
    ])))),
  );
}
