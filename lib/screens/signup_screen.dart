import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import 'package:namma_ranebennur/services/auth_service.dart';
import '../services/firestore_service.dart';
import 'email_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, this.initialKannada = false});

  final bool initialKannada;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController cityController =
      TextEditingController();

  final TextEditingController areaController =
      TextEditingController();

  final TextEditingController pincodeController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;
  late bool kannada;

  String selectedRole = "Customer";

  String t(String english, String kn) => kannada ? kn : english;

  @override
  void initState() {
    super.initState();
    kannada = widget.initialKannada;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    areaController.dispose();
    pincodeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    String? result = await AuthService().register(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });

    if (result == null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account was created but the session could not be loaded. Please sign in.')));
        return;
      }
      await FirestoreService().saveUser(UserModel(
        userId: user.uid,
        name: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        city: cityController.text.trim(),
        area: areaController.text.trim(),
        pincode: pincodeController.text.trim(),
        role: selectedRole,
        serviceProviderId: null,
        createdAt: DateTime.now(),
      ));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerificationScreen(
            fullName: fullNameController.text.trim(),
            email: emailController.text.trim(),
            phone: phoneController.text.trim(),
            city: cityController.text.trim(),
            area: areaController.text.trim(),
            pincode: pincodeController.text.trim(),
            role: selectedRole,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
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

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  t("Create Account", "ಖಾತೆ ತೆರೆಯಿರಿ"),
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  t("Create an account to continue", "ಮುಂದುವರಿಸಲು ಖಾತೆ ತೆರೆಯಿರಿ"),
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: fullNameController,
                  decoration: inputDecoration(
                    label: t("Full Name", "ಪೂರ್ಣ ಹೆಸರು"),
                    icon: Icons.person,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t("Enter Full Name", "ಪೂರ್ಣ ಹೆಸರು ನಮೂದಿಸಿ");
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: inputDecoration(
                    label: t("Email", "ಇಮೇಲ್"),
                    icon: Icons.email,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t("Enter Email", "ಇಮೇಲ್ ನಮೂದಿಸಿ");
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: inputDecoration(
                    label: t("Phone Number", "ಮೊಬೈಲ್ ಸಂಖ್ಯೆ"),
                    icon: Icons.phone,
                  ).copyWith(prefixText: "+91 "),
                  validator: (value) {
                    if (value == null || value.length != 10) {
                      return t("Enter Valid Mobile Number", "ಸರಿಯಾದ ಮೊಬೈಲ್ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ");
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: cityController,
                  decoration: inputDecoration(
                    label: t("City", "ನಗರ"),
                    icon: Icons.location_city,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t("Enter City", "ನಗರ ನಮೂದಿಸಿ");
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: areaController,
                  decoration: inputDecoration(
                    label: t("Area / Locality", "ಪ್ರದೇಶ / ಬಡಾವಣೆ"),
                    icon: Icons.place,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t("Enter Area", "ಪ್ರದೇಶ ನಮೂದಿಸಿ");
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: pincodeController,
                  keyboardType: TextInputType.number,
                  decoration: inputDecoration(
                    label: t("Pincode", "ಪಿನ್ ಕೋಡ್"),
                    icon: Icons.pin_drop,
                  ),
                  validator: (value) {
                    if (value == null || value.length != 6) {
                      return t("Enter Valid Pincode", "ಸರಿಯಾದ ಪಿನ್ ಕೋಡ್ ನಮೂದಿಸಿ");
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: inputDecoration(
                    label: t("Password", "ಪಾಸ್‌ವರ್ಡ್"),
                    icon: Icons.lock,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return t("Password must be at least 6 characters", "ಪಾಸ್‌ವರ್ಡ್ ಕನಿಷ್ಠ 6 ಅಕ್ಷರ ಇರಬೇಕು");
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: hideConfirmPassword,
                  decoration: inputDecoration(
                    label: t("Confirm Password", "ಪಾಸ್‌ವರ್ಡ್ ಖಚಿತಪಡಿಸಿ"),
                    icon: Icons.lock_outline,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        hideConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          hideConfirmPassword =
                              !hideConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value != passwordController.text) {
                      return t("Passwords do not match", "ಪಾಸ್‌ವರ್ಡ್‌ಗಳು ಹೊಂದಿಕೆಯಾಗುತ್ತಿಲ್ಲ");
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                Text(
                  t("Register As", "ನೋಂದಣಿ ಪ್ರಕಾರ"),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                RadioListTile<String>(
                  value: "Customer",
                  groupValue: selectedRole,
                  title: Text(t("Customer", "ಗ್ರಾಹಕ")),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),

                RadioListTile<String>(
                  value: "Provider",
                  groupValue: selectedRole,
                  title: Text(t("Service Provider", "ಸೇವಾ ಪೂರೈಕೆದಾರ")),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            t("Create Account", "ಖಾತೆ ತೆರೆಯಿರಿ"),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t("Already have an account? ", "ಈಗಾಗಲೇ ಖಾತೆ ಇದೆಯೇ? "),
                      style: GoogleFonts.poppins(),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        t("Login", "ಲಾಗಿನ್"),
                        style: GoogleFonts.poppins(
                          color: const Color(0xfff45b22),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
