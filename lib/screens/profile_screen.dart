import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'my_posts_screen.dart';
import 'login_screen.dart';
import 'partner_portals_screen.dart';
import '../services/location_share_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color orange = Color(0xffF97316);
  static const Color lightOrange = Color(0xfffff7ed);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          "My Profile",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [

              // =====================================================
              // PROFILE HEADER
              // =====================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      orange,
                      Color(0xffEA580C),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(25),
                ),

                child: Column(
                  children: [

                    Container(
                      width: 90,
                      height: 90,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),

                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: orange,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "Hello User 👋",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Welcome to Namma Ranebennur",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =====================================================
              // MY ACTIVITY
              // =====================================================

              sectionTitle("My Activity"),

              const SizedBox(height: 12),

              profileOption(
                context: context,
                icon: Icons.calendar_month_rounded,
                title: "My Bookings",
                subtitle:
                    "View and manage your current bookings",
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const MyBookingsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              profileOption(
                context: context,
                icon: Icons.post_add_rounded,
                title: "My Posts",
                subtitle:
                    "Manage your property and service posts",
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const MyPostsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              profileOption(
                context: context,
                icon: Icons.campaign_rounded,
                title: "My Ads",
                subtitle:
                    "View your active, pending and expired ads",
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const MyAdsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // =====================================================
              // POST & REQUEST
              // =====================================================

              sectionTitle("Post & Request"),

              const SizedBox(height: 12),

              profileOption(
                context: context,
                icon: Icons.add_business_rounded,
                title: "Post an Ad",
                subtitle:
                    "Request to advertise your business or service",
                color: orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PostAdScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              profileOption(
                context: context,
                icon: Icons.post_add_rounded,
                title: "Post Requirement",
                subtitle:
                    "Tell us what service or product you need",
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PostRequirementScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              profileOption(
                context: context,
                icon: Icons.question_answer_rounded,
                title: "My Requirements & Responses",
                subtitle:
                    "View your requirements and admin responses",
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const MyRequirementsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // =====================================================
              // BUSINESS
              // =====================================================

              sectionTitle("Business"),

              const SizedBox(height: 12),

              profileOption(
                context: context,
                icon: Icons.local_taxi_rounded,
                title: "Partner Service",
                subtitle: "Booking Counter · Auto · Cab · Delivery Partner",
                color: Colors.deepPurple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PartnerServicesScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              profileOption(
                context: context,
                icon: Icons.handshake_rounded,
                title: "Do Business With Us",
                subtitle:
                    "Join Namma Ranebennur as a service provider",
                color: Colors.indigo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const BusinessWithUsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // =====================================================
              // PLANS & PAYMENTS
              // =====================================================

              profileOption(
                context: context,
                icon:
                    Icons.account_balance_wallet_rounded,
                title: "Plans & Payments",
                subtitle:
                    "Advertisement plans, charges and payment details",
                color: Colors.deepOrange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PlansPaymentScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // =====================================================
              // ACCOUNT
              // =====================================================

              sectionTitle("Account"),

              const SizedBox(height: 12),

              // EDIT PROFILE
              profileOption(
                context: context,
                icon: Icons.edit_outlined,
                title: "Edit Profile",
                subtitle:
                    "Update your personal information",
                color: Colors.blueGrey,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const EditProfileScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // SETTINGS
              profileOption(
                context: context,
                icon: Icons.settings_outlined,
                title: "Settings",
                subtitle:
                    "Manage your app preferences",
                color: Colors.grey,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SettingsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // HELP & SUPPORT
              profileOption(
                context: context,
                icon: Icons.help_outline_rounded,
                title: "Help & Support",
                subtitle:
                    "Emergency contacts and support",
                color: Colors.cyan,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const HelpSupportScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // =====================================================
              // LOGOUT
              // =====================================================

              SizedBox(
                width: double.infinity,
                height: 55,

                child: OutlinedButton.icon(
                  onPressed: () {
                    showLogoutDialog(context);
                  },

                  icon: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),

                  label: Text(
                    "Logout",
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,

                    side: const BorderSide(
                      color: Colors.redAccent,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // SECTION TITLE
  // ================================================================

  static Widget sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,

      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // ================================================================
  // PROFILE OPTION
  // ================================================================

  static Widget profileOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),

        child: Padding(
          padding: const EdgeInsets.all(17),

          child: Row(
            children: [

              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color:
                      color.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(16),
                ),

                child: Icon(
                  icon,
                  color: color,
                  size: 27,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color:
                            Colors.grey.shade600,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // LOGOUT DIALOG
  // ================================================================

  static void showLogoutDialog(
      BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          title: Text(
            "Logout",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            "Are you sure you want to logout?",
            style: GoogleFonts.poppins(),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await logoutUser(context);
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor: orange,
              ),

              child: Text(
                "Logout",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================================================================
  // FIREBASE LOGOUT
  // ================================================================

  static Future<void> logoutUser(
      BuildContext context) async {

    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(
            color: orange,
          ),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      Navigator.pop(context);

      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(
          builder: (_) =>
              const LoginScreen(),
        ),

        (route) => false,
      );

    } on FirebaseAuthException catch (e) {

      if (!context.mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Logout failed: ${e.message ?? 'Something went wrong'}",
          ),
          backgroundColor: Colors.red,
        ),
      );

    } catch (e) {

      if (!context.mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Something went wrong while logging out.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


// ==================================================================
// EDIT PROFILE SCREEN
// ==================================================================

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  final fullNameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final cityController =
      TextEditingController();

  final areaController =
      TextEditingController();

  final pincodeController =
      TextEditingController();

  String role = "Customer";

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    areaController.dispose();
    pincodeController.dispose();

    super.dispose();
  }

  // ================================================================
  // FETCH EXISTING PROFILE
  // ================================================================

  Future<void> loadProfile() async {

    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      return;
    }

    try {

      final DocumentSnapshot snapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .get();

      if (snapshot.exists) {

        final data =
            snapshot.data()
                as Map<String, dynamic>;

        fullNameController.text =
            data["fullName"]?.toString() ?? "";

        emailController.text =
            data["email"]?.toString() ??
                user.email ??
                "";

        phoneController.text =
            data["phone"]?.toString() ?? "";

        cityController.text =
            data["city"]?.toString() ?? "";

        areaController.text =
            data["area"]?.toString() ?? "";

        pincodeController.text =
            data["pincode"]?.toString() ?? "";

        final savedRole =
            data["role"]?.toString();

        if (savedRole != null &&
            savedRole.isNotEmpty) {
          role = savedRole;
        }
      }

      // Fallback from Firebase Authentication
      if (fullNameController.text.isEmpty) {
        fullNameController.text =
            user.displayName ?? "";
      }

      if (emailController.text.isEmpty) {
        emailController.text =
            user.email ?? "";
      }

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load profile: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ================================================================
  // SAVE PROFILE
  // ================================================================

  Future<void> saveProfile() async {

    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage(
        "Please login again to update your profile.",
      );
      return;
    }

    final fullName =
        fullNameController.text.trim();

    final email =
        emailController.text.trim();

    final phone =
        phoneController.text.trim();

    final city =
        cityController.text.trim();

    final area =
        areaController.text.trim();

    final pincode =
        pincodeController.text.trim();

    // --------------------------------------------------------------
    // VALIDATION
    // --------------------------------------------------------------

    if (fullName.isEmpty) {
      showMessage("Please enter your full name.");
      return;
    }

    if (email.isEmpty) {
      showMessage("Please enter your email.");
      return;
    }

    if (phone.isEmpty) {
      showMessage("Please enter your phone number.");
      return;
    }

    if (city.isEmpty) {
      showMessage("Please enter your city.");
      return;
    }

    if (area.isEmpty) {
      showMessage("Please enter your area.");
      return;
    }

    if (pincode.isEmpty) {
      showMessage("Please enter your pincode.");
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {

      // ------------------------------------------------------------
      // UPDATE EXISTING USER DOCUMENT
      // ------------------------------------------------------------

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "fullName": fullName,
        "email": email,
        "phone": phone,
        "city": city,
        "area": area,
        "pincode": pincode,
        "role": role,
      }, SetOptions(merge: true));

      // ------------------------------------------------------------
      // UPDATE AUTH DISPLAY NAME
      // ------------------------------------------------------------

      await user.updateDisplayName(fullName);

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      await showDialog(
        context: context,

        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(20),
            ),

            title: Text(
              "Profile Updated",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),

            content: Text(
              "Your profile information has been updated successfully.",
              style: GoogleFonts.poppins(
                fontSize: 13,
              ),
            ),

            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      ProfileScreen.orange,
                ),

                child: Text(
                  "OK",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context);

    } catch (e) {

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      showMessage(
        "Failed to update profile: $e",
        error: true,
      );
    }
  }

  // ================================================================
  // MESSAGE
  // ================================================================

  void showMessage(
    String message, {
    bool error = false,
  }) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            error ? Colors.red : null,
      ),
    );
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xffF7F8FC),

      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor:
            Colors.transparent,

        elevation: 0,
      ),

      body: isLoading

          ? const Center(
              child: CircularProgressIndicator(
                color: ProfileScreen.orange,
              ),
            )

          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // PROFILE ICON

                  Center(
                    child: Container(
                      width: 90,
                      height: 90,

                      decoration:
                          BoxDecoration(
                        color:
                            ProfileScreen.orange
                                .withValues(
                                    alpha: 0.12),
                        shape:
                            BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.person_rounded,
                        size: 50,
                        color:
                            ProfileScreen.orange,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Personal Information",
                    style:
                        GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  profileTextField(
                    controller:
                        fullNameController,
                    label:
                        "Full Name",
                    icon:
                        Icons.person_outline,
                  ),

                  const SizedBox(height: 15),

                  profileTextField(
                    controller:
                        emailController,
                    label:
                        "Email",
                    icon:
                        Icons.email_outlined,
                    keyboardType:
                        TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 15),

                  profileTextField(
                    controller:
                        phoneController,
                    label:
                        "Phone Number",
                    icon:
                        Icons.phone_outlined,
                    keyboardType:
                        TextInputType.phone,
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Location Information",
                    style:
                        GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  profileTextField(
                    controller:
                        cityController,
                    label:
                        "City",
                    icon:
                        Icons.location_city_outlined,
                  ),

                  const SizedBox(height: 15),

                  profileTextField(
                    controller:
                        areaController,
                    label:
                        "Area",
                    icon:
                        Icons.location_on_outlined,
                  ),

                  const SizedBox(height: 15),

                  profileTextField(
                    controller:
                        pincodeController,
                    label:
                        "Pincode",
                    icon:
                        Icons.pin_drop_outlined,
                    keyboardType:
                        TextInputType.number,
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Account Type",
                    style:
                        GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    initialValue: role,

                    decoration:
                        InputDecoration(
                      labelText:
                          "Role",

                      prefixIcon:
                          const Icon(
                        Icons
                            .account_circle_outlined,
                        color:
                            ProfileScreen.orange,
                      ),

                      filled: true,
                      fillColor:
                          Colors.white,

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                15),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),

                    items: const [

                      DropdownMenuItem(
                        value: "Customer",
                        child:
                            Text("Customer"),
                      ),

                      DropdownMenuItem(
                        value:
                            "Service Provider",
                        child: Text(
                            "Service Provider"),
                      ),
                    ],

                    onChanged:
                        (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        role = value;
                      });
                    },
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton.icon(
                      onPressed:
                          isSaving
                              ? null
                              : saveProfile,

                      icon: isSaving

                          ? const SizedBox(
                              width: 22,
                              height: 22,

                              child:
                                  CircularProgressIndicator(
                                color:
                                    Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )

                          : const Icon(
                              Icons.save_rounded,
                              color:
                                  Colors.white,
                            ),

                      label: Text(
                        isSaving
                            ? "Saving..."
                            : "Save Changes",

                        style:
                            GoogleFonts.poppins(
                          color:
                              Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            ProfileScreen.orange,

                        disabledBackgroundColor:
                            Colors.grey,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  15),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}


// ==================================================================
// SETTINGS SCREEN
// ==================================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {

  bool notifications = true;
  bool autoRefresh = true;
  bool logoutConfirmation = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xffF7F8FC),

      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor:
            Colors.transparent,

        elevation: 0,
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),

        children: [

          Text(
            "General",
            style: GoogleFonts.poppins(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // NOTIFICATIONS

          settingsSwitch(
            icon:
                Icons.notifications_outlined,

            title:
                "Notifications",

            subtitle:
                "Receive booking, request and service notifications",

            value:
                notifications,

            onChanged:
                (value) {
              setState(() {
                notifications = value;
              });
            },
          ),

          const SizedBox(height: 10),

          // AUTO REFRESH

          settingsSwitch(
            icon:
                Icons.refresh_rounded,

            title:
                "Auto Refresh",

            subtitle:
                "Automatically refresh available services and requests",

            value:
                autoRefresh,

            onChanged:
                (value) {
              setState(() {
                autoRefresh = value;
              });
            },
          ),

          const SizedBox(height: 10),

          // LOGOUT CONFIRMATION

          settingsSwitch(
            icon:
                Icons.logout_rounded,

            title:
                "Logout Confirmation",

            subtitle:
                "Ask for confirmation before logging out",

            value:
                logoutConfirmation,

            onChanged:
                (value) {
              setState(() {
                logoutConfirmation = value;
              });
            },
          ),

          const SizedBox(height: 25),

          Text(
            "Application",
            style: GoogleFonts.poppins(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          settingsTile(
            icon:
                Icons.info_outline_rounded,

            title:
                "About Namma Ranebennur",

            subtitle:
                "Learn more about the application",

            onTap: () {
              showAboutDialog(
                context: context,

                applicationName:
                    "Namma Ranebennur",

                applicationVersion:
                    "1.0.0",

                applicationIcon:
                    const Icon(
                  Icons.location_city_rounded,
                  color:
                      ProfileScreen.orange,
                  size: 40,
                ),

                children: [
                  Text(
                    "Namma Ranebennur is a hyperlocal platform designed to connect people with local services, businesses and requirements.",
                    style:
                        GoogleFonts.poppins(
                      fontSize: 13,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 10),

          settingsTile(
            icon:
                Icons.language_rounded,

            title:
                "Language",

            subtitle:
                "English",

            onTap: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    "More language options will be added soon.",
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 25),

          Container(
            padding:
                const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color:
                  Colors.white,

              borderRadius:
                  BorderRadius.circular(18),
            ),

            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Icon(
                  Icons.info_outline_rounded,
                  color:
                      ProfileScreen.orange,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    "Your application preferences are stored locally on this device.",
                    style:
                        GoogleFonts.poppins(
                      fontSize: 11.5,
                      color:
                          Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SETTINGS SWITCH
  // ================================================================

  Widget settingsSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {

    return Container(
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: SwitchListTile(
        value: value,

        onChanged: onChanged,

        activeThumbColor:
            ProfileScreen.orange,

        secondary: Container(
          width: 45,
          height: 45,

          decoration:
              BoxDecoration(
            color:
                ProfileScreen.orange
                    .withValues(alpha: 0.10),

            borderRadius:
                BorderRadius.circular(13),
          ),

          child: Icon(
            icon,
            color:
                ProfileScreen.orange,
          ),
        ),

        title: Text(
          title,
          style:
              GoogleFonts.poppins(
            fontSize: 14,
            fontWeight:
                FontWeight.w600,
          ),
        ),

        subtitle: Text(
          subtitle,
          style:
              GoogleFonts.poppins(
            fontSize: 10.5,
            color:
                Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // SETTINGS TILE
  // ================================================================

  Widget settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {

    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(18),

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(18),

        child: Padding(
          padding:
              const EdgeInsets.all(16),

          child: Row(
            children: [

              Container(
                width: 48,
                height: 48,

                decoration:
                    BoxDecoration(
                  color:
                      ProfileScreen.orange
                          .withValues(
                              alpha: 0.10),

                  borderRadius:
                      BorderRadius.circular(14),
                ),

                child: Icon(
                  icon,
                  color:
                      ProfileScreen.orange,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      title,
                      style:
                          GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style:
                          GoogleFonts.poppins(
                        fontSize: 11,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 15,
                color:
                    Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ==================================================================
// HELP & SUPPORT / EMERGENCY CONTACTS
// ==================================================================

class HelpSupportScreen
    extends StatelessWidget {

  const HelpSupportScreen({super.key});

  static const Color emergencyRed =
      Color(0xffDC2626);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xffF7F8FC),

      appBar: AppBar(
        title: Text(
          "Help & Support",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor:
            Colors.transparent,

        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ========================================================
            // EMERGENCY HEADER
            // ========================================================

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(20),

              decoration:
                  BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xffDC2626),
                    Color(0xffB91C1C),
                  ],

                  begin:
                      Alignment.topLeft,

                  end:
                      Alignment.bottomRight,
                ),

                borderRadius:
                    BorderRadius.circular(23),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Container(
                    width: 55,
                    height: 55,

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white
                              .withValues(
                                  alpha: 0.18),

                      shape:
                          BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons
                          .emergency_rounded,
                      color:
                          Colors.white,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Emergency Contacts",
                    style:
                        GoogleFonts.poppins(
                      color:
                          Colors.white,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Use these numbers when immediate assistance is required.",
                    style:
                        GoogleFonts.poppins(
                      color:
                          Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Text(
              "Emergency Numbers",
              style:
                  GoogleFonts.poppins(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            emergencyCard(
              context: context,
              icon:
                  Icons.emergency_rounded,
              title:
                  "Emergency",
              subtitle:
                  "National Emergency Number",
              number:
                  "112",
              color:
                  Colors.red,
            ),

            const SizedBox(height: 10),

            emergencyCard(
              context: context,
              icon:
                  Icons.local_police_rounded,
              title:
                  "Police",
              subtitle:
                  "Police Emergency",
              number:
                  "100",
              color:
                  Colors.blue,
            ),

            const SizedBox(height: 10),

            emergencyCard(
              context: context,
              icon:
                  Icons.local_hospital_rounded,
              title:
                  "Ambulance",
              subtitle:
                  "Medical Emergency",
              number:
                  "108",
              color:
                  Colors.green,
            ),

            const SizedBox(height: 10),

            emergencyCard(
              context: context,
              icon:
                  Icons.local_fire_department_rounded,
              title:
                  "Fire & Rescue",
              subtitle:
                  "Fire Emergency",
              number:
                  "101",
              color:
                  Colors.deepOrange,
            ),

            const SizedBox(height: 25),

            // ========================================================
            // APP SUPPORT
            // ========================================================

            Text(
              "Namma Ranebennur Support",
              style:
                  GoogleFonts.poppins(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(18),

              decoration:
                  BoxDecoration(
                color:
                    Colors.white,

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Column(
                children: [

                  const Icon(
                    Icons.support_agent_rounded,
                    size: 45,
                    color:
                        ProfileScreen.orange,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Need help with the application?",
                    textAlign:
                        TextAlign.center,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "For booking issues, account problems, service requests or other app-related support, contact the Namma Ranebennur support team.",
                    textAlign:
                        TextAlign.center,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 11.5,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width:
                        double.infinity,
                    height:
                        48,

                    child:
                        OutlinedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintScreen())),

                      icon:
                          const Icon(
                        Icons
                            .support_agent_rounded,
                        color:
                            ProfileScreen.orange,
                      ),

                      label:
                          Text(
                        "Create Support Ticket",
                        style:
                            GoogleFonts.poppins(
                          color:
                              ProfileScreen.orange,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      style:
                          OutlinedButton.styleFrom(
                        side:
                            const BorderSide(
                          color:
                              ProfileScreen.orange,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container(
              padding:
                  const EdgeInsets.all(15),

              decoration:
                  BoxDecoration(
                color:
                    Colors.red.withValues(
                        alpha: 0.06),

                borderRadius:
                    BorderRadius.circular(16),

                border:
                    Border.all(
                  color:
                      Colors.red.withValues(
                          alpha: 0.15),
                ),
              ),

              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Icon(
                    Icons.info_outline_rounded,
                    color:
                        Colors.red,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      "For life-threatening emergencies, contact the appropriate emergency service directly rather than relying on application support.",
                      style:
                          GoogleFonts.poppins(
                        fontSize: 10.5,
                        color:
                            Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // EMERGENCY CARD
  // ================================================================

  static Widget emergencyCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String number,
    required Color color,
  }) {

    return Material(
      color:
          Colors.white,

      borderRadius:
          BorderRadius.circular(18),

      child: Padding(
        padding:
            const EdgeInsets.all(15),

        child: Row(
          children: [

            Container(
              width: 50,
              height: 50,

              decoration:
                  BoxDecoration(
                color:
                    color.withValues(
                        alpha: 0.10),

                borderRadius:
                    BorderRadius.circular(14),
              ),

              child: Icon(
                icon,
                color:
                    color,
                size: 27,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    title,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 10.5,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),

              decoration:
                  BoxDecoration(
                color:
                    color.withValues(
                        alpha: 0.10),

                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: Text(
                number,
                style:
                    GoogleFonts.poppins(
                  color:
                      color,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});
  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final reference = TextEditingController();
  final details = TextEditingController();
  String category = 'booking';
  bool urgent = false;
  bool sending = false;
  @override
  void dispose() { reference.dispose(); details.dispose(); super.dispose(); }

  Future<void> submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || details.text.trim().length < 10) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in and describe the problem clearly.'))); return; }
    setState(() => sending = true);
    try {
      final ticket = FirebaseFirestore.instance.collection('complaints').doc();
      await ticket.set({'complaintId': ticket.id, 'userId': user.uid, 'userEmail': user.email ?? '', 'category': category, 'bookingReference': reference.text.trim(), 'details': details.text.trim(), 'priority': urgent ? 'urgent' : 'normal', 'status': 'open', 'contactProtected': true, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(icon: const Icon(Icons.verified_rounded, color: Colors.green, size: 42), title: const Text('Support ticket created'), content: Text('Ticket reference: ${ticket.id}\nOur admin team can now review it safely.'), actions: [FilledButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('OK'))]));
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not create ticket: $error')));
    } finally { if (mounted) setState(() => sending = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Namma Ranebennur Support')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Text('For immediate danger call 112. This form is for booking, payment, account, provider or safety complaints.', style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 18),
      DropdownButtonFormField<String>(initialValue: category, decoration: const InputDecoration(labelText: 'Issue category'), items: const [DropdownMenuItem(value: 'booking', child: Text('Booking')), DropdownMenuItem(value: 'payment', child: Text('Payment')), DropdownMenuItem(value: 'provider', child: Text('Provider / Driver')), DropdownMenuItem(value: 'account', child: Text('Account')), DropdownMenuItem(value: 'safety', child: Text('Safety'))], onChanged: (value) => setState(() => category = value!)),
      const SizedBox(height: 12),
      TextField(controller: reference, decoration: const InputDecoration(labelText: 'Booking/payment reference (optional)')),
      const SizedBox(height: 12),
      TextField(controller: details, maxLength: 1000, maxLines: 6, decoration: const InputDecoration(labelText: 'Describe the issue')),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Urgent safety concern'), subtitle: const Text('Do not use this instead of calling 112.'), value: urgent, onChanged: (value) => setState(() => urgent = value)),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: sending ? null : submit, icon: const Icon(Icons.support_agent_rounded), label: Text(sending ? 'Submitting…' : 'Submit safely')),
    ]),
  );
}

// ==================================================================
// MY BOOKINGS
// ==================================================================

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings'), actions: [IconButton(tooltip: 'Track shared trip', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TripLookupScreen())), icon: const Icon(Icons.travel_explore_rounded))]),
      body: user == null
          ? const Center(child: Text('Please sign in to view bookings.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: user.uid).snapshots(),
              builder: (context, ordersSnapshot) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('marketOrders').where('userId', isEqualTo: user.uid).snapshots(),
                builder: (context, marketSnapshot) {
                  if (ordersSnapshot.connectionState == ConnectionState.waiting || marketSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final records = <({String kind, QueryDocumentSnapshot<Map<String, dynamic>> doc})>[
                    for (final doc in ordersSnapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[]) (kind: 'Booking', doc: doc),
                    for (final doc in marketSnapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[]) (kind: 'Market Order', doc: doc),
                  ];
                  records.sort((a, b) {
                    final aTime = a.doc.data()['createdAt'] as Timestamp?;
                    final bTime = b.doc.data()['createdAt'] as Timestamp?;
                    return (bTime?.millisecondsSinceEpoch ?? 0).compareTo(aTime?.millisecondsSinceEpoch ?? 0);
                  });
                  if (records.isEmpty) return const Center(child: Text('No bookings yet. Your service and market requests will appear here.'));
                  return ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: records.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final record = records[index];
                      final data = record.doc.data();
                      final status = data['status']?.toString() ?? 'pending';
                      final title = data['serviceType'] ?? data['vehicleType'] ?? data['category'] ?? (record.kind == 'Market Order' ? 'Market order' : 'Service booking');
                      return Card(child: ListTile(
                        leading: CircleAvatar(backgroundColor: _statusColor(status).withValues(alpha: .14), child: Icon(record.kind == 'Market Order' ? Icons.shopping_bag_rounded : Icons.receipt_long, color: _statusColor(status))),
                        title: Text(title.toString().replaceAll('_', ' ')),
                        subtitle: Text('${record.kind} · Ref: ${record.doc.id.length > 8 ? record.doc.id.substring(0, 8) : record.doc.id}\n${status.replaceAll('_', ' ').toUpperCase()}'),
                        trailing: const Icon(Icons.chevron_right),
                        isThreeLine: true,
                        onTap: () => details(context, record.kind, record.doc.id, data),
                      ));
                    },
                  );
                },
              ),
            ),
    );
  }

  static Future<void> details(BuildContext context, String kind, String id, Map<String, dynamic> data) async {
    final status = (data['status'] ?? 'pending').toString().replaceAll('_', ' ');
    final quote = data['quotedFare'] ?? data['estimatedFare'] ?? data['totalAmount'];
    final advance = data['advancePaymentStatus'];
    final showTripOtp = ['assigned', 'arrived'].contains(data['status']) && data['tripStartOtp'] != null;
    final showPickupOtp = data['category'] == 'delivery' && data['status'] == 'assigned' && data['pickupOtp'] != null;
    final showDeliveryOtp = data['category'] == 'delivery' && data['status'] == 'picked_up' && data['deliveryOtp'] != null;
    final canAcceptQuote = kind == 'Booking' && data['quoteStatus'] == 'awaiting_customer';
    final canCancel = kind == 'Booking' && ['pending', 'awaiting_customer', 'awaiting_advance'].contains(data['status']);
    final shareCode = data['category'] == 'travel' ? data['tripShareCode']?.toString() : null;
    final action = await showDialog<String>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text('$kind details'),
      content: Text('Reference: $id\nStatus: $status${quote == null ? '' : '\nAmount / quote: ₹$quote'}${data['advanceAmount'] == null ? '' : '\nAdvance amount: ₹${data['advanceAmount']}'}${advance == null ? '' : '\nAdvance: ${advance.toString().replaceAll('_', ' ')}'}${showTripOtp ? '\nTrip-start OTP: ${data['tripStartOtp']}' : ''}${showPickupOtp ? '\nPickup OTP: ${data['pickupOtp']}' : ''}${showDeliveryOtp ? '\nDelivery OTP: ${data['deliveryOtp']}' : ''}${shareCode == null ? '' : '\nTrip share code: $shareCode'}\n\nProvider contact remains protected until the controlled confirmation stage.'),
      actions: [
        if (canCancel) TextButton(onPressed: () => Navigator.pop(dialogContext, 'cancel'), child: const Text('Cancel booking', style: TextStyle(color: Colors.red))),
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
        if (shareCode != null) TextButton(onPressed: () => Navigator.pop(dialogContext, 'share_trip'), child: const Text('Share trip')),
        if (canAcceptQuote) FilledButton(onPressed: () => Navigator.pop(dialogContext, 'accept_quote'), child: const Text('Accept quote')),
      ],
    ));
    if (action == null || !context.mounted) return;
    final booking = FirebaseFirestore.instance.collection('orders').doc(id);
    try {
      if (action == 'accept_quote') {
        await booking.update({'status': 'awaiting_advance', 'quoteStatus': 'accepted', 'quoteAccepted': true, 'updatedAt': FieldValue.serverTimestamp()});
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quote accepted. The owner will verify the advance before confirming.')));
      } else if (action == 'share_trip') {
        await LocationShareService.shareText(
          title: 'Namma Travel',
          text: 'My trip reference is $id',
        );
      } else if (action == 'cancel') {
        final batch = FirebaseFirestore.instance.batch();
        batch.update(booking, {'status': 'cancelled', 'updatedAt': FieldValue.serverTimestamp()});
        if (data['category'] == 'delivery' || (data['category'] == 'travel' && data['travelScope'] != 'outstation')) {
          batch.update(FirebaseFirestore.instance.collection('driverJobs').doc(id), {'status': 'cancelled', 'updatedAt': FieldValue.serverTimestamp()});
        }
        if (data['category'] == 'vibe_town') {
          final locks = await FirebaseFirestore.instance.collection('vibeTownSlotLocks').where('orderId', isEqualTo: id).get();
          for (final lock in locks.docs) {
            batch.update(lock.reference, {'active': false, 'releasedAt': FieldValue.serverTimestamp()});
          }
        }
        if (shareCode != null) batch.update(FirebaseFirestore.instance.collection('tripShares').doc(shareCode), {'status': 'cancelled', 'updatedAt': FieldValue.serverTimestamp()});
        await batch.commit();
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled.')));
      }
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update booking: $error')));
    }
  }

  static Color _statusColor(String status) => switch (status) {
    'confirmed' || 'completed' => Colors.green,
    'cancelled' || 'rejected' => Colors.red,
    _ => Colors.orange,
  };
}

class TripLookupScreen extends StatefulWidget {
  const TripLookupScreen({super.key});
  @override
  State<TripLookupScreen> createState() => _TripLookupScreenState();
}

class _TripLookupScreenState extends State<TripLookupScreen> {
  final controller = TextEditingController();
  Map<String, dynamic>? trip;
  String? error;
  bool loading = false;

  @override
  void dispose() { controller.dispose(); super.dispose(); }

  Future<void> lookup() async {
    final code = controller.text.trim().toUpperCase();
    if (!RegExp(r'^[A-Z2-9]{10}$').hasMatch(code)) { setState(() => error = 'Enter the complete 10-character trip code.'); return; }
    setState(() { loading = true; error = null; trip = null; });
    try {
      final snapshot = await FirebaseFirestore.instance.collection('tripShares').doc(code).get();
      if (!mounted) return;
      setState(() { trip = snapshot.data(); error = snapshot.exists ? null : 'Trip code not found.'; });
    } catch (_) {
      if (mounted) setState(() => error = 'Could not load this trip. Confirm the code and internet connection.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Track Shared Trip')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Icon(Icons.travel_explore_rounded, size: 70, color: Color(0xfff45b22)),
      const SizedBox(height: 10),
      const Text('Enter the trip code shared by the customer. Exact addresses and contact details are never shown here.', textAlign: TextAlign.center),
      const SizedBox(height: 18),
      TextField(controller: controller, textCapitalization: TextCapitalization.characters, maxLength: 10, decoration: InputDecoration(labelText: '10-character trip code', prefixIcon: const Icon(Icons.key_rounded), errorText: error), onSubmitted: (_) => lookup()),
      FilledButton.icon(onPressed: loading ? null : lookup, icon: const Icon(Icons.search), label: Text(loading ? 'Checking…' : 'Track trip')),
      if (trip != null) ...[
        const SizedBox(height: 20),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text((trip!['vehicleType'] ?? 'Travel').toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Status: ${(trip!['status'] ?? 'pending').toString().replaceAll('_', ' ').toUpperCase()}'),
          Text('Trip: ${(trip!['travelScope'] ?? '').toString().replaceAll('_', ' ')} · ${(trip!['tripType'] ?? '').toString().replaceAll('_', ' ')}'),
          const Divider(height: 24),
          Text((trip!['privacyNotice'] ?? 'Exact address and contact details are protected.').toString(), style: const TextStyle(color: Colors.black54)),
        ]))),
      ],
    ]),
  );
}


// ==================================================================
// MY ADS
// ==================================================================

class MyAdsScreen extends StatelessWidget {
  const MyAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('My Ads')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PostAdScreen())), icon: const Icon(Icons.add), label: const Text('Post New Ad')),
      body: user == null ? const Center(child: Text('Please sign in to view advertisements.')) : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('advertisements').where('userId', isEqualTo: user.uid).snapshots(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('You have not posted any advertisements yet.'));
          return ListView.separated(padding: const EdgeInsets.all(14), itemCount: docs.length, separatorBuilder: (_, _) => const SizedBox(height: 8), itemBuilder: (_, index) { final data = docs[index].data(); final status = (data['status'] ?? 'pending').toString(); return Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.campaign_rounded)), title: Text((data['title'] ?? 'Advertisement').toString()), subtitle: Text('${data['plan'] ?? 'free'} · ${status.replaceAll('_', ' ')}'), trailing: Text(status.toUpperCase(), style: TextStyle(color: MyBookingsScreen._statusColor(status), fontSize: 10, fontWeight: FontWeight.w800)))); });
        },
      ),
    );
  }
}


// ==================================================================
// POST AD
// ==================================================================

class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});

  @override
  State<PostAdScreen> createState() =>
      _PostAdScreenState();
}

class _PostAdScreenState
    extends State<PostAdScreen> {

  final titleController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  String adPlan = "Free";
  bool submitting = false;

  Future<void> submitAd() async {
    final user = FirebaseAuth.instance.currentUser;
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final phone = phoneController.text.trim();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in before posting an advertisement.')));
      return;
    }
    if (title.length < 3 || description.length < 5 || !RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a title, description and valid 10-digit mobile number.')));
      return;
    }
    setState(() => submitting = true);
    try {
      await FirebaseFirestore.instance.collection('advertisements').add({
        'userId': user.uid, 'title': title, 'body': description, 'advertiserPhone': phone,
        'plan': adPlan.toLowerCase(), 'status': 'pending', 'contactProtected': true,
        'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      titleController.clear(); descriptionController.clear(); phoneController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Advertisement submitted for admin approval.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not submit advertisement: $error')));
    } finally { if (mounted) setState(() => submitting = false); }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF7F8FC),

      appBar: AppBar(
        title:
            const Text("Post an Ad"),
        backgroundColor:
            Colors.transparent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              "Create Advertisement",
              style:
                  GoogleFonts.poppins(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Submit your advertisement for admin approval.",
              style:
                  GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 25),

            profileTextField(
              controller:
                  titleController,
              label:
                  "Advertisement Title",
              icon: Icons.title,
            ),

            const SizedBox(height: 15),

            profileTextField(
              controller:
                  descriptionController,
              label: "Description",
              icon:
                  Icons.description_outlined,
              maxLines: 4,
            ),

            const SizedBox(height: 15),

            profileTextField(
              controller:
                  phoneController,
              label:
                  "Contact Number",
              icon: Icons.phone,
              keyboardType:
                  TextInputType.phone,
            ),

            const SizedBox(height: 25),

            Text(
              "Advertisement Plan",
              style:
                  GoogleFonts.poppins(
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: adPlan,

              decoration:
                  InputDecoration(
                prefixIcon:
                    const Icon(
                  Icons
                      .workspace_premium_rounded,
                  color:
                      ProfileScreen.orange,
                ),

                filled: true,
                fillColor: Colors.white,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          15),
                  borderSide:
                      BorderSide.none,
                ),
              ),

              items: const [

                DropdownMenuItem(
                  value: "Free",
                  child: Text(
                    "Free - 24 Hours",
                  ),
                ),

                DropdownMenuItem(
                  value: "Premium",
                  child: Text(
                    "Premium - Paid / Longer Visibility",
                  ),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  adPlan = value!;
                });
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width:
                  double.infinity,
              height: 55,

              child:
                  ElevatedButton.icon(
                onPressed: submitting ? null : submitAd,

                icon:
                    const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),

                label: Text(
                  submitting ? "Submitting…" : "Submit Ad Request",
                  style:
                      GoogleFonts.poppins(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      ProfileScreen.orange,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ==================================================================
// POST REQUIREMENT
// ==================================================================

class PostRequirementScreen
    extends StatefulWidget {

  const PostRequirementScreen({
    super.key,
  });

  @override
  State<PostRequirementScreen> createState() =>
      _PostRequirementScreenState();
}

class _PostRequirementScreenState
    extends State<PostRequirementScreen> {

  final requirementController =
      TextEditingController();

  String category = "Property";
  bool submitting = false;

  Future<void> submitRequirement() async {
    final user = FirebaseAuth.instance.currentUser;
    final requirement = requirementController.text.trim();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in before posting a requirement.')));
      return;
    }
    if (requirement.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Describe your requirement clearly.')));
      return;
    }
    setState(() => submitting = true);
    try {
      final reference = FirebaseFirestore.instance.collection('requirements').doc();
      await reference.set({
        'userId': user.uid, 'reference': reference.id, 'category': category,
        'title': requirement.length > 120 ? requirement.substring(0, 120) : requirement,
        'details': requirement, 'area': 'Ranebennur', 'status': 'pending',
        'contactProtected': true, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      requirementController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Requirement submitted · ${reference.id.substring(0, 8)}')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not submit requirement: $error')));
    } finally { if (mounted) setState(() => submitting = false); }
  }

  @override
  void dispose() {
    requirementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF7F8FC),

      appBar: AppBar(
        title:
            const Text("Post Requirement"),
        backgroundColor:
            Colors.transparent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              "What are you looking for?",
              style:
                  GoogleFonts.poppins(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Post your requirement and our team can help you find suitable options.",
              style:
                  GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 25),

            DropdownButtonFormField<String>(
              initialValue: category,

              decoration:
                  InputDecoration(
                labelText:
                    "Requirement Category",

                prefixIcon:
                    const Icon(
                  Icons.category_rounded,
                  color:
                      ProfileScreen.orange,
                ),

                filled: true,
                fillColor: Colors.white,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          15),
                  borderSide:
                      BorderSide.none,
                ),
              ),

              items: const [

                DropdownMenuItem(
                  value: "Property",
                  child:
                      Text("Property"),
                ),

                DropdownMenuItem(
                  value: "Workers",
                  child:
                      Text("Workers"),
                ),

                DropdownMenuItem(
                  value: "Market",
                  child:
                      Text("Market"),
                ),

                DropdownMenuItem(
                  value: "Events",
                  child:
                      Text("Events"),
                ),

                DropdownMenuItem(
                  value: "Delivery",
                  child:
                      Text("Delivery"),
                ),

                DropdownMenuItem(
                  value: "Machinery",
                  child:
                      Text("Machinery"),
                ),

                DropdownMenuItem(
                  value: "Travel",
                  child:
                      Text("Travel"),
                ),

                DropdownMenuItem(
                  value: "Travel",
                  child:
                      Text("Travel"),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  category = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            profileTextField(
              controller:
                  requirementController,
              label:
                  "Describe Your Requirement",
              icon:
                  Icons.edit_note_rounded,
              maxLines: 6,
            ),

            const SizedBox(height: 25),

            SizedBox(
              width:
                  double.infinity,
              height: 55,

              child:
                  ElevatedButton.icon(
                onPressed: submitting ? null : submitRequirement,

                icon:
                    const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),

                label: Text(
                  submitting ? "Submitting…" : "Submit Requirement",
                  style:
                      GoogleFonts.poppins(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      ProfileScreen.orange,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ==================================================================
// MY REQUIREMENTS
// ==================================================================

class MyRequirementsScreen
    extends StatelessWidget {

  const MyRequirementsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('My Requirements & Responses')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PostRequirementScreen())), icon: const Icon(Icons.add), label: const Text('Post Requirement')),
      body: user == null ? const Center(child: Text('Please sign in to view requirements.')) : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('requirements').where('userId', isEqualTo: user.uid).snapshots(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('No requirements submitted yet.'));
          return ListView.separated(padding: const EdgeInsets.all(14), itemCount: docs.length, separatorBuilder: (_, _) => const SizedBox(height: 8), itemBuilder: (_, index) { final data = docs[index].data(); final status = (data['status'] ?? 'pending').toString(); return Card(child: ExpansionTile(leading: const CircleAvatar(child: Icon(Icons.question_answer_rounded)), title: Text((data['title'] ?? data['details'] ?? 'Requirement').toString(), maxLines: 2, overflow: TextOverflow.ellipsis), subtitle: Text('${data['category'] ?? ''} · ${status.replaceAll('_', ' ')}'), childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14), children: [Align(alignment: Alignment.centerLeft, child: Text((data['details'] ?? '').toString())), const SizedBox(height: 10), RequirementQuotes(requirementId: docs[index].id, requirementStatus: status)])); });
        },
      ),
    );
  }
}

class RequirementQuotes extends StatelessWidget {
  const RequirementQuotes({super.key, required this.requirementId, required this.requirementStatus});
  final String requirementId;
  final String requirementStatus;

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance.collection('providerQuotes').where('requirementId', isEqualTo: requirementId).snapshots(),
    builder: (_, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
      final quotes = snapshot.data?.docs ?? [];
      if (quotes.isEmpty) return const Align(alignment: Alignment.centerLeft, child: Text('No verified-provider quote yet. Your contact remains protected.'));
      return Column(children: quotes.map((quote) {
        final data = quote.data();
        final status = data['status']?.toString() ?? 'submitted';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: status == 'accepted' ? const Color(0xffdcfce7) : const Color(0xfffff4ed), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const CircleAvatar(child: Icon(Icons.handshake_rounded, size: 19)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${data['providerName'] ?? 'Verified provider'} · ₹${data['quoteAmount'] ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w800)),
              if ((data['message'] ?? '').toString().isNotEmpty) Text(data['message'].toString()),
              Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.black54)),
              if (status == 'accepted')
                Text('Service: ${(data['serviceStatus'] ?? 'awaiting_provider').toString().replaceAll('_', ' ')}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ])),
            if (status == 'submitted' && ['pending', 'approved', 'open'].contains(requirementStatus))
              FilledButton(onPressed: () => accept(context, quote.reference), child: const Text('Accept')),
          ]),
        );
      }).toList());
    },
  );

  Future<void> accept(BuildContext context, DocumentReference<Map<String, dynamic>> quote) async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Accept this quote?'),
      content: const Text('The selected provider and Admin can continue the controlled booking. Direct contact remains protected until confirmation.'),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Not now')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Accept quote'))],
    ));
    if (confirmed != true) return;
    final requirement = FirebaseFirestore.instance.collection('requirements').doc(requirementId);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final requirementSnapshot = await transaction.get(requirement);
        final quoteSnapshot = await transaction.get(quote);
        final requirementState = requirementSnapshot.data()?['status']?.toString() ?? '';
        final quoteState = quoteSnapshot.data()?['status']?.toString() ?? '';
        if (!['pending', 'approved', 'open'].contains(requirementState) || quoteState != 'submitted') {
          throw StateError('This requirement or quote has already changed. Refresh and try again.');
        }
        transaction.update(quote, {'status': 'accepted', 'serviceStatus': 'awaiting_provider', 'acceptedAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
        transaction.update(requirement, {'status': 'matched', 'acceptedQuoteId': quote.id, 'updatedAt': FieldValue.serverTimestamp()});
      });
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quote accepted. Admin and the verified provider can now continue.')));
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not accept quote: $error')));
    }
  }
}


// ==================================================================
// BUSINESS WITH US
// ==================================================================

// ==================================================================
// BUSINESS WITH US
// ==================================================================

class BusinessWithUsScreen extends StatefulWidget {
  const BusinessWithUsScreen({super.key});

  @override
  State<BusinessWithUsScreen> createState() => _BusinessWithUsScreenState();
}

class _BusinessWithUsScreenState extends State<BusinessWithUsScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    serviceController.dispose();
    super.dispose();
  }

  Future<void> submitApplication() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final serviceType = serviceController.text.trim();

    if (name.isEmpty || phone.isEmpty || serviceType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      // Use Firebase UID if logged in.
      // If not logged in, create a simple document ID.
      final String uid = user?.uid ?? '';

      final DocumentReference<Map<String, dynamic>> document =
          FirebaseFirestore.instance
              .collection('serviceProviderRequests')
              .doc(uid.isNotEmpty ? uid : null);

      await document.set({
        'requestId': document.id,
        'uid': uid,
        'name': name,
        'phone': phone,
        'serviceType': serviceType,
        'city': 'Ranebennur',
        'area': 'Ranebennur',
        'status': 'pending',
        'approvedByAdmin': false,
        'adminMessage': '',
        'rejectionReason': '',
        'serviceProviderId': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      nameController.clear();
      phoneController.clear();
      serviceController.clear();

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );

      debugPrint('DO BUSINESS WITH US ERROR: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Do Business With Us'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Become a Service Provider',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Fill in your details and submit your application.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name / Business Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: serviceController,
              decoration: const InputDecoration(
                labelText: 'Service You Provide',
                hintText: 'Example: Electrician, Plumber, Salon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.build),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitApplication,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Apply Now',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// PLANS & PAYMENTS
// ==================================================================

class PlansPaymentScreen
    extends StatelessWidget {

  const PlansPaymentScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xffF7F8FC),

      appBar: AppBar(
        title:
            const Text(
          "Plans & Payments",
        ),

        backgroundColor:
            Colors.transparent,

        elevation: 0,
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),

        children: [

          Text(
            "Advertisement Plans",
            style:
                GoogleFonts.poppins(
              fontSize: 21,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          planCard(
            title:
                "Free Advertisement",

            price:
                "₹0",

            description:
                "Display your advertisement for 24 hours.",

            icon:
                Icons.access_time_rounded,

            color:
                Colors.green,
          ),

          const SizedBox(height: 15),

          planCard(
            title:
                "Premium Advertisement",

            price:
                "Paid Plan",

            description:
                "Longer visibility and premium placement.",

            icon:
                Icons.workspace_premium_rounded,

            color:
                ProfileScreen.orange,
          ),

          const SizedBox(height: 25),

          Text(
            "Other Charges",
            style:
                GoogleFonts.poppins(
              fontSize: 21,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          chargeCard(
            title:
                "Minimum Service Charge",

            subtitle:
                "Charges may apply depending on the service requested.",
          ),

          chargeCard(
            title:
                "Booking Charges",

            subtitle:
                "Applicable charges will be displayed before confirmation.",
          ),

          chargeCard(
            title:
                "Premium Placement",

            subtitle:
                "Additional charges may apply for priority advertisement placement.",
          ),

          const SizedBox(height: 20),

          Container(
            padding:
                const EdgeInsets.all(18),

            decoration:
                BoxDecoration(
              color:
                  Colors.white,

              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: Row(
              children: [

                const Icon(
                  Icons.info_outline_rounded,
                  color:
                      ProfileScreen.orange,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    "Final pricing and payment options will be shown before any payment is made.",

                    style:
                        GoogleFonts.poppins(
                      fontSize: 12,
                      color:
                          Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget planCard({
    required String title,
    required String price,
    required String description,
    required IconData icon,
    required Color color,
  }) {

    return Container(
      padding:
          const EdgeInsets.all(20),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(22),

        border:
            Border.all(
          color:
              color.withValues(
                  alpha: 0.2),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 55,
            height: 55,

            decoration:
                BoxDecoration(
              color:
                  color.withValues(
                      alpha: 0.12),

              borderRadius:
                  BorderRadius.circular(16),
            ),

            child:
                Icon(
              icon,
              color:
                  color,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style:
                      GoogleFonts.poppins(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  description,
                  style:
                      GoogleFonts.poppins(
                    color:
                        Colors.grey,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  price,
                  style:
                      GoogleFonts.poppins(
                    color:
                        color,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget chargeCard({
    required String title,
    required String subtitle,
  }) {

    return Container(
      margin:
          const EdgeInsets.only(
              bottom: 10),

      padding:
          const EdgeInsets.all(16),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Row(
        children: [

          const Icon(
            Icons.currency_rupee_rounded,
            color:
                ProfileScreen.orange,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style:
                      GoogleFonts.poppins(
                    fontWeight:
                        FontWeight.w600,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style:
                      GoogleFonts.poppins(
                    color:
                        Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ==================================================================
// SIMPLE EMPTY / PLACEHOLDER PAGE
// ==================================================================

class SimpleProfilePage
    extends StatelessWidget {

  final String title;
  final IconData icon;
  final String description;
  final String emptyMessage;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const SimpleProfilePage({
    super.key,

    required this.title,
    required this.icon,
    required this.description,
    required this.emptyMessage,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xffF7F8FC),

      appBar: AppBar(
        title:
            Text(
          title,
          style:
              GoogleFonts.poppins(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        backgroundColor:
            Colors.transparent,

        elevation: 0,
      ),

      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(25),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Container(
                width: 90,
                height: 90,

                decoration:
                    BoxDecoration(
                  color:
                      ProfileScreen.orange
                          .withValues(
                              alpha: 0.12),

                  shape:
                      BoxShape.circle,
                ),

                child:
                    Icon(
                  icon,
                  size: 45,
                  color:
                      ProfileScreen.orange,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                emptyMessage,
                textAlign:
                    TextAlign.center,

                style:
                    GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                description,
                textAlign:
                    TextAlign.center,

                style:
                    GoogleFonts.poppins(
                  color:
                      Colors.grey,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                height: 50,

                child:
                    ElevatedButton(
                  onPressed:
                      onButtonPressed,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        ProfileScreen.orange,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              15),
                    ),
                  ),

                  child:
                      Text(
                    buttonText,

                    style:
                        GoogleFonts.poppins(
                      color:
                          Colors.white,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ==================================================================
// TEXT FIELD
// ==================================================================

Widget profileTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,

  TextInputType keyboardType =
      TextInputType.text,

  int maxLines = 1,
}) {

  return TextField(
    controller:
        controller,

    keyboardType:
        keyboardType,

    maxLines:
        maxLines,

    decoration:
        InputDecoration(
      labelText:
          label,

      prefixIcon:
          Icon(
        icon,
        color:
            ProfileScreen.orange,
      ),

      filled:
          true,

      fillColor:
          Colors.white,

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),

        borderSide:
            BorderSide.none,
      ),
    ),
  );
}

