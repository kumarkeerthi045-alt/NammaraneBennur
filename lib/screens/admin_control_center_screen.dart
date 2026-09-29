import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/admin_access_service.dart';

class AdminControlCenterScreen extends StatelessWidget {
  final AdminAccess access;

  const AdminControlCenterScreen({
    super.key,
    required this.access,
  });

  // ================================================================
  // ROLE NAME
  // ================================================================

  String get roleName {
    switch (access.role) {
      case AdminRole.superAdmin:
        return 'Super Admin';

      case AdminRole.marketTravelAdmin:
        return 'Market & Travel Admin';

      case AdminRole.bookingAdmin:
        return 'Booking Admin';
    }
  }

  // ================================================================
  // ROLE DESCRIPTION
  // ================================================================

  String get roleDescription {
    switch (access.role) {
      case AdminRole.superAdmin:
        return 'Full application control';

      case AdminRole.marketTravelAdmin:
        return 'Marketplace and travel management';

      case AdminRole.bookingAdmin:
        return 'Bookings and service provider management';
    }
  }

  // ================================================================
  // ROLE CHECKS
  // ================================================================

  bool get isSuperAdmin =>
      access.role == AdminRole.superAdmin;

  bool get isMarketTravelAdmin =>
      access.role == AdminRole.marketTravelAdmin;

  bool get isBookingAdmin =>
      access.role == AdminRole.bookingAdmin;

  // ================================================================
  // LOGOUT
  // ================================================================

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  // ================================================================
  // OPEN FEATURE
  // ================================================================

  void openFeature(
    BuildContext context,
    String title,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminFeaturePlaceholder(
          title: title,
          access: access,
        ),
      ),
    );
  }

  // ================================================================
  // FEATURE CARD
  // ================================================================

  Widget featureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xffffeee2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xffF97316),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: Text(
          'Admin Control Center',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => logout(context),
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.black87,
            ),
          ),
        ],
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ====================================================
              // ADMIN INFORMATION
              // ====================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset:
                          const Offset(0, 5),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,

                      decoration: BoxDecoration(
                        color:
                            const Color(0xffffeee2),
                        borderRadius:
                            BorderRadius.circular(18),
                      ),

                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color:
                            Color(0xffF97316),
                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            roleName,
                            style:
                                GoogleFonts.poppins(
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            roleDescription,
                            style:
                                GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            access.user.email ??
                                'Administrator',
                            style:
                                GoogleFonts.poppins(
                              fontSize: 11,
                              color:
                                  Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Text(
                'Administration',
                style: GoogleFonts.poppins(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // ====================================================
              // SUPER ADMIN
              // ====================================================

              if (isSuperAdmin) ...[
                featureCard(
                  context: context,
                  icon: Icons.people_alt_rounded,
                  title: 'Users',
                  subtitle:
                      'Manage application users',
                  onTap: () => openFeature(
                    context,
                    'Users',
                  ),
                ),

                featureCard(
                  context: context,
                  icon:
                      Icons.admin_panel_settings_rounded,
                  title: 'Admin Management',
                  subtitle:
                      'Manage administrators and roles',
                  onTap: () => openFeature(
                    context,
                    'Admin Management',
                  ),
                ),

                featureCard(
                  context: context,
                  icon:
                      Icons.storefront_rounded,
                  title: 'Marketplace',
                  subtitle:
                      'Manage marketplace products, prices and orders',
                  onTap: () => openFeature(
                    context,
                    'Marketplace',
                  ),
                ),

                featureCard(
                  context: context,
                  icon:
                      Icons.business_center_rounded,
                  title: 'Service Providers',
                  subtitle:
                      'Manage Do Business With Us applications',
                  onTap: () => openFeature(
                    context,
                    'Service Providers',
                  ),
                ),

                featureCard(
                  context: context,
                  icon:
                      Icons.book_online_rounded,
                  title: 'Bookings',
                  subtitle:
                      'Manage bookings and requests',
                  onTap: () => openFeature(
                    context,
                    'Bookings',
                  ),
                ),

                featureCard(
                  context: context,
                  icon:
                      Icons.campaign_rounded,
                  title: 'Announcements',
                  subtitle:
                      'Create and manage announcements',
                  onTap: () => openFeature(
                    context,
                    'Announcements',
                  ),
                ),

                featureCard(
                  context: context,
                  icon:
                      Icons.settings_rounded,
                  title: 'Application Settings',
                  subtitle:
                      'Manage global application settings',
                  onTap: () => openFeature(
                    context,
                    'Application Settings',
                  ),
                ),
              ]

              // ====================================================
              // MARKETPLACE ADMIN
              // ====================================================

              else if (isMarketTravelAdmin) ...[
                featureCard(
                  context: context,
                  icon:
                      Icons.storefront_rounded,
                  title: 'Marketplace',
                  subtitle:
                      'Manage marketplace products',
                  onTap: () => openFeature(
                    context,
                    'Marketplace',
                  ),
                ),

                featureCard(
                  context: context,
                  icon:
                      Icons.inventory_2_rounded,
                  title: 'Products',
                  subtitle:
                      'Add, edit and remove products',
                  onTap: () => openFeature(
                    context,
                    'Products',
                  ),
                ),

                featureCard(
                  context: context,
                  icon:
                      Icons.currency_rupee_rounded,
                  title: 'Prices',
                  subtitle:
                      'Update marketplace prices',
                  onTap: () => openFeature(
                    context,
                    'Prices',
                  ),
                ),

                featureCard(
                  context: context,
                  icon:
                      Icons.shopping_cart_rounded,
                  title: 'Orders',
                  subtitle:
                      'View and manage marketplace orders',
                  onTap: () => openFeature(
                    context,
                    'Marketplace Orders',
                  ),
                ),

                featureCard(
                  context: context,
                  icon:
                      Icons.category_rounded,
                  title: 'Categories',
                  subtitle:
                      'Manage marketplace categories',
                  onTap: () => openFeature(
                    context,
                    'Categories',
                  ),
                ),
              ]

              // ====================================================
              // SERVICE PROVIDER ADMIN
              // ====================================================

              else if (isBookingAdmin) ...[
                featureCard(
                  context: context,
                  icon:
                      Icons.business_center_rounded,
                  title: 'Do Business With Us',
                  subtitle:
                      'Review service provider applications',
                  onTap: () => openFeature(
                    context,
                    'Do Business With Us',
                  ),
                ),

                featureCard(
                  context: context,
                  icon:
                      Icons.pending_actions_rounded,
                  title: 'Pending Applications',
                  subtitle:
                      'Review new provider applications',
                  onTap: () => openFeature(
                    context,
                    'Pending Applications',
                  ),
                ),

                featureCard(
                  context: context,
                  icon:
                      Icons.verified_user_rounded,
                  title: 'Approved Providers',
                  subtitle:
                      'Manage approved service providers',
                  onTap: () => openFeature(
                    context,
                    'Approved Providers',
                  ),
                ),

                featureCard(
                  context: context,
                  icon:
                      Icons.cancel_rounded,
                  title: 'Rejected Applications',
                  subtitle:
                      'View rejected applications',
                  onTap: () => openFeature(
                    context,
                    'Rejected Applications',
                  ),
                ),

                featureCard(
                  context: context,
                  icon:
                      Icons.miscellaneous_services_rounded,
                  title: 'Provider Services',
                  subtitle:
                      'Manage services offered by providers',
                  onTap: () => openFeature(
                    context,
                    'Provider Services',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// TEMPORARY FEATURE SCREEN
// ==================================================================

class AdminFeaturePlaceholder extends StatelessWidget {
  final String title;
  final AdminAccess access;

  const AdminFeaturePlaceholder({
    super.key,
    required this.title,
    required this.access,
  });

  String get roleText {
    switch (access.role) {
      case AdminRole.superAdmin:
        return 'Super Admin';

      case AdminRole.marketTravelAdmin:
        return 'Market & Travel Admin';

      case AdminRole.bookingAdmin:
        return 'Booking Admin';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              const Icon(
                Icons.construction_rounded,
                size: 70,
                color: Color(0xffF97316),
              ),

              const SizedBox(height: 20),

              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '$roleText has access to this section.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'This section is ready to be connected to the actual admin functionality.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xffF97316),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 13,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),

                child: const Text(
                  'Go Back',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
