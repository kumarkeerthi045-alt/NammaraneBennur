import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/firestore_service.dart';
import 'admin_service_providers_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const Color primaryBlue = Color(0xff1565C0);
  static const Color lightBackground = Color(0xffF7F8FC);
  static const Color purple = Color(0xff7C3AED);
  static const Color orange = Color(0xffF97316);
  static const Color green = Color(0xff16A34A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),

              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),

            const SizedBox(width: 12),

            Text(
              "Admin Panel",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 19,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.black87,
            ),

            tooltip: "Logout",

            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              // ======================================================
              // WELCOME CARD
              // ======================================================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff1565C0),
                      Color(0xff1976D2),
                    ],

                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withValues(alpha: 0.20),
                      blurRadius: 15,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),

                child: Row(
                  children: [

                    Container(
                      width: 55,
                      height: 55,

                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
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
                            "Welcome, Admin 👋",

                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "Control and manage Namma Ranebennur",

                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ======================================================
              // APPLICATION OVERVIEW
              // ======================================================

              Text(
                "Application Overview",

                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              // ======================================================
              // STATISTICS
              // ======================================================

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),

                builder: (context, userSnapshot) {

                  return StreamBuilder<
                      QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('serviceProviders')
                        .snapshots(),

                    builder: (context, providerSnapshot) {

                      return StreamBuilder<
                          QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection(
                                'serviceProviderRequests')
                            .where(
                              'status',
                              isEqualTo: 'pending',
                            )
                            .snapshots(),

                        builder: (
                          context,
                          requestSnapshot,
                        ) {

                          return StreamBuilder<
                              QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('orders')
                                .snapshots(),

                            builder: (
                              context,
                              bookingSnapshot,
                            ) {

                              if (userSnapshot.hasError ||
                                  providerSnapshot.hasError ||
                                  requestSnapshot.hasError ||
                                  bookingSnapshot.hasError) {
                                return _statsErrorCard();
                              }

                              if (userSnapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  providerSnapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  requestSnapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  bookingSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                return _statsLoading();
                              }

                              final int userCount =
                                  userSnapshot.data?.docs.length ?? 0;

                              final int providerCount =
                                  providerSnapshot.data?.docs.length ?? 0;

                              final int pendingCount =
                                  requestSnapshot.data?.docs.length ?? 0;

                              final int bookingCount =
                                  bookingSnapshot.data?.docs.length ?? 0;

                              return GridView.count(
                                shrinkWrap: true,

                                physics:
                                    const NeverScrollableScrollPhysics(),

                                crossAxisCount: 2,

                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,

                                childAspectRatio: 1.35,

                                children: [

                                  adminStat(
                                    title: "Users",
                                    value: userCount.toString(),
                                    icon: Icons.people_rounded,
                                    color: Colors.blue,
                                  ),

                                  adminStat(
                                    title: "Providers",
                                    value:
                                        providerCount.toString(),
                                    icon:
                                        Icons.engineering_rounded,
                                    color: purple,
                                  ),

                                  adminStat(
                                    title: "Pending Requests",
                                    value:
                                        pendingCount.toString(),
                                    icon:
                                        Icons.assignment_rounded,
                                    color: orange,
                                  ),

                                  adminStat(
                                    title: "Bookings",
                                    value:
                                        bookingCount.toString(),
                                    icon:
                                        Icons.calendar_month_rounded,
                                    color: Colors.teal,
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 30),

              // ======================================================
              // MANAGEMENT
              // ======================================================

              Text(
                "Management",

                style: GoogleFonts.poppins(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // ======================================================
              // USERS
              // ======================================================

              adminOption(
                context,

                icon: Icons.people_rounded,
                color: Colors.blue,

                title: "Users",

                subtitle:
                    "View and manage registered users",

                onTap: () {
                  _showComingSoon(
                    context,
                    "Users Management",
                  );
                },
              ),

              // ======================================================
              // SERVICE PROVIDERS
              // ======================================================

              adminOption(
                context,

                icon: Icons.engineering_rounded,
                color: purple,

                title: "Service Providers",

                subtitle:
                    "View and manage all service providers",

                onTap: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminServiceProvidersScreen(),
                    ),
                  );
                },
              ),

              // ======================================================
              // SERVICE REQUESTS
              // ======================================================

              adminOption(
                context,

                icon: Icons.assignment_rounded,
                color: orange,

                title: "Service Requests",

                subtitle:
                    "Review user requests and respond",

                onTap: () {

                  _showComingSoon(
                    context,
                    "Service Requests",
                  );
                },
              ),

              // ======================================================
              // ADVERTISEMENTS
              // ======================================================

              adminOption(
                context,

                icon: Icons.campaign_rounded,
                color: green,

                title: "Advertisements",

                subtitle:
                    "Approve and manage advertisements",

                onTap: () {

                  _showComingSoon(
                    context,
                    "Advertisements",
                  );
                },
              ),

              // ======================================================
              // REQUIREMENTS
              // ======================================================

              adminOption(
                context,

                icon: Icons.help_outline_rounded,
                color: Colors.red,

                title: "Requirements",

                subtitle:
                    "Manage user requirements and responses",

                onTap: () {

                  _showComingSoon(
                    context,
                    "Requirements",
                  );
                },
              ),

              // ======================================================
              // BOOKINGS
              // ======================================================

              adminOption(
                context,

                icon: Icons.calendar_month_rounded,
                color: Colors.teal,

                title: "Bookings",

                subtitle:
                    "Manage service bookings and customer requests",

                onTap: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminBookingsScreen(),
                    ),
                  );
                },
              ),

              // ======================================================
              // ANNOUNCEMENTS
              // ======================================================

              adminOption(
                context,

                icon:
                    Icons.notifications_active_rounded,

                color: Colors.deepOrange,

                title: "Announcements",

                subtitle:
                    "Manage power cuts, news, alerts and city updates",

                onTap: () {

                  _showComingSoon(
                    context,
                    "Announcements",
                  );
                },
              ),

              // ======================================================
              // PLANS & PAYMENTS
              // ======================================================

              adminOption(
                context,

                icon: Icons.payment_rounded,
                color: Colors.indigo,

                title: "Plans & Payments",

                subtitle:
                    "Manage advertising plans and payments",

                onTap: () {

                  _showComingSoon(
                    context,
                    "Plans & Payments",
                  );
                },
              ),

              // ======================================================
              // CITY CONTENT
              // ======================================================

              adminOption(
                context,

                icon: Icons.location_city_rounded,
                color: Colors.brown,

                title: "City Content",

                subtitle:
                    "Manage city information, events and promotions",

                onTap: () {

                  _showComingSoon(
                    context,
                    "City Content",
                  );
                },
              ),

              const SizedBox(height: 20),

              // ======================================================
              // ADMIN CONTROL
              // ======================================================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(20),

                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(
                        alpha: 0.025,
                      ),

                      blurRadius: 8,

                      offset:
                          const Offset(0, 3),
                    ),
                  ],
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Container(
                      width: 45,
                      height: 45,

                      decoration: BoxDecoration(
                        color:
                            Colors.blue.withValues(
                          alpha: 0.10,
                        ),

                        borderRadius:
                            BorderRadius.circular(14),
                      ),

                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            "Admin Control",

                            style:
                                GoogleFonts.poppins(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "All important user requests, service "
                            "provider approvals, advertisements, "
                            "bookings and requirements will be "
                            "controlled through this panel.",

                            style:
                                GoogleFonts.poppins(
                              color:
                                  Colors.grey.shade600,
                              fontSize: 11,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATISTICS LOADING
  // ============================================================

  Widget _statsLoading() {
    return GridView.count(
      shrinkWrap: true,

      physics:
          const NeverScrollableScrollPhysics(),

      crossAxisCount: 2,

      crossAxisSpacing: 12,
      mainAxisSpacing: 12,

      childAspectRatio: 1.35,

      children: [
        _loadingStatCard(),
        _loadingStatCard(),
        _loadingStatCard(),
        _loadingStatCard(),
      ],
    );
  }

  Widget _loadingStatCard() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,

          child:
              CircularProgressIndicator(
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATISTICS ERROR
  // ============================================================

  Widget _statsErrorCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color:
            Colors.red.withValues(alpha: 0.06),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color:
              Colors.red.withValues(alpha: 0.15),
        ),
      ),

      child: Row(
        children: [

          const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              "Unable to load dashboard statistics. "
              "Check your Firestore permissions.",

              style: GoogleFonts.poppins(
                color: Colors.red.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget adminStat({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.03),

            blurRadius: 10,

            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color:
                  color.withValues(alpha: 0.12),

              borderRadius:
                  BorderRadius.circular(13),
            ),

            child: Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),

          const Spacer(),

          Text(
            value,

            style:
                GoogleFonts.poppins(
              fontSize: 23,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Text(
            title,

            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,

            style:
                GoogleFonts.poppins(
              color:
                  Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADMIN OPTION
  // ============================================================

  Widget adminOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),

      child: Material(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        child: InkWell(
          onTap: onTap,

          borderRadius:
              BorderRadius.circular(20),

          child: Padding(
            padding:
                const EdgeInsets.all(17),

            child: Row(
              children: [

                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    color:
                        color.withValues(alpha: 0.12),

                    borderRadius:
                        BorderRadius.circular(15),
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

                        style:
                            GoogleFonts.poppins(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        subtitle,

                        maxLines: 2,

                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            GoogleFonts.poppins(
                          color:
                              Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color:
                      Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COMING SOON
  // ============================================================

  void _showComingSoon(
    BuildContext context,
    String section,
  ) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          title: Text(
            section,

            style:
                GoogleFonts.poppins(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          content: Text(
            "The $section module will be connected "
            "to Firebase next.",

            style:
                GoogleFonts.poppins(
              fontSize: 13,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child:
                  const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void _showLogoutDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          title: Text(
            "Logout",

            style:
                GoogleFonts.poppins(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          content: Text(
            "Are you sure you want to logout "
            "from the admin panel?",

            style:
                GoogleFonts.poppins(
              fontSize: 13,
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child:
                  const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {

                Navigator.pop(context);

                Navigator.pop(context);
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),

              child:
                  const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


// ============================================================================
// ADMIN BOOKINGS SCREEN
// ============================================================================

class AdminBookingsScreen
    extends StatelessWidget {

  const AdminBookingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final FirestoreService
        firestoreService =
        FirestoreService();

    return Scaffold(
      backgroundColor:
          const Color(0xffF7F8FA),

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        title: Text(
          "Bookings",

          style:
              GoogleFonts.poppins(
            fontWeight:
                FontWeight.w600,
          ),
        ),

        backgroundColor:
            const Color(0xff1E293B),

        foregroundColor:
            Colors.white,

        elevation: 0,
      ),

      // ==========================================================
      // BOOKINGS
      // ==========================================================

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream:
            firestoreService.streamOrders(),

        builder:
            (context, snapshot) {

          // ========================================================
          // LOADING
          // ========================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          // ========================================================
          // ERROR
          // ========================================================

          if (snapshot.hasError) {

            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    const Icon(
                      Icons.error_outline,
                      size: 55,
                      color: Colors.red,
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Text(
                      "Unable to load bookings",

                      style:
                          GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      snapshot.error.toString(),

                      textAlign:
                          TextAlign.center,

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
            );
          }

          // ========================================================
          // NO BOOKINGS
          // ========================================================

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Icon(
                    Icons
                        .calendar_month_outlined,

                    size: 70,

                    color:
                        Colors.grey[400],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  Text(
                    "No Bookings Yet",

                    style:
                        GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Colors.grey[700],
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    "Customer bookings will appear here.",

                    style:
                        GoogleFonts.poppins(
                      fontSize: 13,
                      color:
                          Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          // ========================================================
          // BOOKINGS
          // ========================================================

          final bookings =
              snapshot.data!.docs;

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),

            itemCount:
                bookings.length,

            itemBuilder:
                (context, index) {

              final booking =
                  bookings[index];

              final data =
                  booking.data();

              // ====================================================
              // DATA
              // ====================================================

              final String orderId =
                  data['orderId']
                          ?.toString() ??
                      booking.id;

              final String userName =
                  data['userName']
                          ?.toString() ??
                      "Unknown User";

              final String userPhone =
                  data['userPhone']
                          ?.toString() ??
                      "";

              final String userEmail =
                  data['userEmail']
                          ?.toString() ??
                      "";

              final String serviceType =
                  data['serviceType']
                          ?.toString() ??
                      "Service";

              final String urgency =
                  data['urgency']
                          ?.toString() ??
                      "normal";

              final String status =
                  data['status']
                          ?.toString() ??
                      "pending";

              final String address =
                  data['address']
                          ?.toString() ??
                      "";

              final String description =
                  data['description']
                          ?.toString() ??
                      "";

              final String preferredTime =
                  data['preferredTime']
                          ?.toString() ??
                      "";

              // ====================================================
              // DATE
              // ====================================================

              String preferredDate =
                  "Not selected";

              final dynamic dateValue =
                  data['preferredDate'];

              if (dateValue is Timestamp) {

                final DateTime date =
                    dateValue.toDate();

                preferredDate =
                    "${date.day}/"
                    "${date.month}/"
                    "${date.year}";
              }

              // ====================================================
              // COLORS
              // ====================================================

              Color urgencyColor;

              switch (
                  urgency.toLowerCase()) {

                case "emergency":
                  urgencyColor =
                      Colors.red;
                  break;

                case "priority":
                  urgencyColor =
                      Colors.orange;
                  break;

                default:
                  urgencyColor =
                      Colors.green;
              }

              Color statusColor;

              switch (
                  status.toLowerCase()) {

                case "approved":
                  statusColor =
                      Colors.green;
                  break;

                case "rejected":
                  statusColor =
                      Colors.red;
                  break;

                case "assigned":
                  statusColor =
                      Colors.blue;
                  break;

                case "completed":
                  statusColor =
                      Colors.teal;
                  break;

                default:
                  statusColor =
                      Colors.orange;
              }

              // ====================================================
              // BOOKING CARD
              // ====================================================

              return Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 16,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(18),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(
                        alpha: 0.05,
                      ),

                      blurRadius: 10,

                      offset:
                          const Offset(0, 3),
                    ),
                  ],
                ),

                child: Padding(
                  padding:
                      const EdgeInsets.all(18),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // ============================================
                      // HEADER
                      // ============================================

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Container(
                            padding:
                                const EdgeInsets.all(12),

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.teal.withValues(
                                alpha: 0.10,
                              ),

                              shape:
                                  BoxShape.circle,
                            ),

                            child:
                                const Icon(
                              Icons
                                  .calendar_month,

                              color:
                                  Colors.teal,

                              size: 28,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  serviceType,

                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(
                                  height: 3,
                                ),

                                Text(
                                  "Order ID: $orderId",

                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 10,
                                    color:
                                        Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  statusColor.withValues(
                                alpha: 0.10,
                              ),

                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),
                            ),

                            child: Text(
                              status.toUpperCase(),

                              style:
                                  GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.w700,
                                color:
                                    statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      const Divider(),

                      const SizedBox(
                        height: 12,
                      ),

                      // ============================================
                      // CUSTOMER
                      // ============================================

                      Text(
                        "Customer Details",

                        style:
                            GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      buildBookingDetail(
                        Icons.person,
                        "Name",
                        userName,
                      ),

                      buildBookingDetail(
                        Icons.phone,
                        "Phone",
                        userPhone,
                      ),

                      buildBookingDetail(
                        Icons.email,
                        "Email",
                        userEmail,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // ============================================
                      // BOOKING DETAILS
                      // ============================================

                      Text(
                        "Booking Details",

                        style:
                            GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      buildBookingDetail(
                        Icons.calendar_today,
                        "Preferred Date",
                        preferredDate,
                      ),

                      buildBookingDetail(
                        Icons.access_time,
                        "Preferred Time",
                        preferredTime,
                      ),

                      buildBookingDetail(
                        Icons.location_on,
                        "Address",
                        address,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // ============================================
                      // URGENCY
                      // ============================================

                      Row(
                        children: [

                          const Icon(
                            Icons.priority_high,
                            size: 20,
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Text(
                            "Urgency",

                            style:
                                GoogleFonts.poppins(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  urgencyColor.withValues(
                                alpha: 0.10,
                              ),

                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),
                            ),

                            child:
                                Text(
                              urgency.toUpperCase(),

                              style:
                                  GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.w700,
                                color:
                                    urgencyColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // ============================================
                      // DESCRIPTION
                      // ============================================

                      Text(
                        "Service Description",

                        style:
                            GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Container(
                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets.all(
                          12,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xffF8FAFC,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),

                        child: Text(
                          description.isEmpty
                              ? "No description provided"
                              : description,

                          style:
                              GoogleFonts.poppins(
                            fontSize: 13,
                            color:
                                Colors.grey[700],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ============================================
                      // MANAGE BUTTON
                      // ============================================

                      SizedBox(
                        width:
                            double.infinity,

                        child:
                            ElevatedButton.icon(
                          onPressed: () {

                            _showBookingDetails(
                              context,
                              booking.id,
                              data,
                            );
                          },

                          icon:
                              const Icon(
                            Icons
                                .settings_rounded,
                          ),

                          label:
                              const Text(
                            "Manage Booking",
                          ),

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.teal,

                            foregroundColor:
                                Colors.white,

                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 13,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ================================================================
  // BOOKING DETAIL
  // ================================================================

  static Widget buildBookingDetail(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 9,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(
            icon,
            size: 19,
            color:
                Colors.grey[600],
          ),

          const SizedBox(
            width: 10,
          ),

          Text(
            "$title: ",

            style:
                GoogleFonts.poppins(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty
                  ? "Not provided"
                  : value,

              style:
                  GoogleFonts.poppins(
                fontSize: 12,
                color:
                    Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // MANAGE BOOKING DIALOG
  // ================================================================

  static void _showBookingDetails(
    BuildContext context,
    String bookingId,
    Map<String, dynamic> data,
  ) {
    final String status =
        data['status']?.toString() ??
            "pending";

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor:
          Colors.transparent,

      builder: (context) {

        return Container(
          padding:
              const EdgeInsets.all(20),

          decoration:
              const BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),

          child: SafeArea(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Center(
                  child: Container(
                    width: 45,
                    height: 5,

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.grey.shade300,

                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  "Manage Booking",

                  style:
                      GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  "Booking ID: $bookingId",

                  style:
                      GoogleFonts.poppins(
                    fontSize: 11,
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // CURRENT STATUS

                Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets.all(
                    15,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.teal.withValues(
                      alpha: 0.08,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),

                  child: Row(
                    children: [

                      const Icon(
                        Icons.info_outline,
                        color:
                            Colors.teal,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Text(
                        "Current Status: ",

                        style:
                            GoogleFonts.poppins(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      Text(
                        status.toUpperCase(),

                        style:
                            GoogleFonts.poppins(
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // CLOSE

                SizedBox(
                  width:
                      double.infinity,

                  child:
                      OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },

                    child:
                        const Text(
                      "Close",
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}