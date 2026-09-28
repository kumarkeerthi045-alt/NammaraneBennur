import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialKannada = false});
  final bool initialKannada;
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool loading = false;
  late bool kannada;
  String t(String en, String kn) => kannada ? kn : en;
  @override
  void initState() { super.initState(); kannada = widget.initialKannada; }
  @override
  void dispose() { emailController.dispose(); super.dispose(); }

  Future<void> reset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    final error = await AuthService().resetPassword(email: emailController.text.trim());
    if (!mounted) return;
    setState(() => loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? t('Password reset email sent. Check Inbox and Spam.', 'ಪಾಸ್‌ವರ್ಡ್ ಮರುಹೊಂದಿಸುವ ಇಮೇಲ್ ಕಳುಹಿಸಲಾಗಿದೆ. ಇನ್‌ಬಾಕ್ಸ್ ಮತ್ತು ಸ್ಪ್ಯಾಮ್ ಪರಿಶೀಲಿಸಿ.'))));
    if (error == null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xfff8fafc),
    appBar: AppBar(backgroundColor: Colors.transparent, actions: [TextButton(onPressed: () => setState(() => kannada = !kannada), child: Text(kannada ? 'English' : 'ಕನ್ನಡ'))]),
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(25), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 30),
      Text(t('Forgot Password', 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿರಾ?'), style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
      Text(t('Enter your registered email address.', 'ನೋಂದಾಯಿತ ಇಮೇಲ್ ವಿಳಾಸ ನಮೂದಿಸಿ.'), style: GoogleFonts.poppins(color: Colors.grey)), const SizedBox(height: 40),
      TextFormField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: t('Email', 'ಇಮೇಲ್'), prefixIcon: const Icon(Icons.email), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)), validator: (value) => value == null || !value.contains('@') ? t('Enter a valid email', 'ಸರಿಯಾದ ಇಮೇಲ್ ನಮೂದಿಸಿ') : null), const SizedBox(height: 35),
      SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: loading ? null : reset, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xfff45b22), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: loading ? const CircularProgressIndicator(color: Colors.white) : Text(t('Send Reset Link', 'ಮರುಹೊಂದಿಸುವ ಲಿಂಕ್ ಕಳುಹಿಸಿ'), style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)))),
    ])))),
  );
}
