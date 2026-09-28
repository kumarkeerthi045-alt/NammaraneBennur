import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceProvidersScreen extends StatelessWidget {
  const ServiceProvidersScreen({super.key});

  static const Color orange = Color(0xffF97316);
  static const Color purple = Color(0xff7C3AED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

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
          "Service Providers",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      // ============================================================
      // FIRESTORE STREAM
      // ============================================================

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('serviceProviders')
            .where('status', isEqualTo: 'approved')
            .snapshots(),

        builder: (context, snapshot) {
          // ========================================================
          // LOADING
          // ========================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: purple,
              ),
            );
          }

          // ========================================================
          // ERROR
          // ========================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,

                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red,
                        size: 45,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Unable to load service providers",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ServiceProvidersScreen(),
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: Text(
                        "Try Again",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ========================================================
          // NO DATA
          // ========================================================

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return _emptyProvidersPage();
          }

          // ========================================================
          // PROVIDERS FOUND
          // ========================================================

          final providers = snapshot.data!.docs;

          return RefreshIndicator(
            color: purple,

            onRefresh: () async {
              await Future.delayed(
                const Duration(milliseconds: 500),
              );
            },

            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.all(16),

              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        purple,
                        Color(0xff6D28D9),
                      ],

                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

                    borderRadius: BorderRadius.circular(22),
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,

                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.18,
                          ),
                          borderRadius:
                              BorderRadius.circular(16),
                        ),

                        child: const Icon(
                          Icons.engineering_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Local Service Providers",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              "Trusted professionals available in Ranebennur",
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

                const SizedBox(height: 20),

                // ==================================================
                // RESULT COUNT
                // ==================================================

                Text(
                  "${providers.length} Service Provider${providers.length == 1 ? '' : 's'} Available",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // PROVIDER CARDS
                // ==================================================

                ...providers.map((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>;

                  return providerCard(
                    context: context,
                    documentId: doc.id,
                    data: data,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==============================================================
  // PROVIDER CARD
  // ==============================================================

  Widget providerCard({
    required BuildContext context,
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    final String name =
        data['name']?.toString() ?? 'Service Provider';

    final String phone =
        data['phone']?.toString() ?? '';

    final String serviceType =
        data['serviceType']?.toString() ??
            'Service not specified';

    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ========================================================
          // HEADER
          // ========================================================

          Row(
            children: [
              Container(
                width: 58,
                height: 58,

                decoration: BoxDecoration(
                  color: purple.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),

                child: const Icon(
                  Icons.engineering_rounded,
                  color: purple,
                  size: 31,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      serviceType,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // APPROVED BADGE

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: Colors.green.withValues(
                    alpha: 0.10,
                  ),

                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Text(
                  "VERIFIED",
                  style: GoogleFonts.poppins(
                    color: Colors.green.shade700,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ========================================================
          // SERVICE
          // ========================================================

          providerInfoRow(
            icon: Icons.handyman_outlined,
            title: "Service",
            value: serviceType,
          ),

          const SizedBox(height: 10),

          // ========================================================
          // PHONE
          // ========================================================

          if (phone.isNotEmpty)
            providerInfoRow(
              icon: Icons.phone_outlined,
              title: "Contact",
              value: phone,
            ),

          const SizedBox(height: 18),

          // ========================================================
          // VIEW DETAILS BUTTON
          // ========================================================

          SizedBox(
            width: double.infinity,
            height: 48,

            child: ElevatedButton.icon(
              onPressed: () {
                showProviderDetails(
                  context,
                  documentId,
                  data,
                );
              },

              icon: const Icon(
                Icons.visibility_outlined,
                color: Colors.white,
                size: 20,
              ),

              label: Text(
                "View Provider",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: purple,

                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // INFORMATION ROW
  // ==============================================================

  Widget providerInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Icon(
          icon,
          size: 19,
          color: purple,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // PROVIDER DETAILS
  // ==============================================================

  void showProviderDetails(
    BuildContext context,
    String documentId,
    Map<String, dynamic> data,
  ) {
    final String name =
        data['name']?.toString() ??
            'Service Provider';

    final String phone =
        data['phone']?.toString() ?? '';

    final String serviceType =
        data['serviceType']?.toString() ??
            'Not specified';

    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.transparent,

      isScrollControlled: true,

      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            25,
          ),

          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),

          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // HANDLE

                Center(
                  child: Container(
                    width: 45,
                    height: 5,

                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // PROFILE

                Row(
                  children: [
                    Container(
                      width: 65,
                      height: 65,

                      decoration: BoxDecoration(
                        color: purple.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),

                      child: const Icon(
                        Icons.engineering_rounded,
                        color: purple,
                        size: 35,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            serviceType,
                            style: GoogleFonts.poppins(
                              color:
                                  Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // SERVICE

                detailRow(
                  Icons.handyman_outlined,
                  "Service",
                  serviceType,
                ),

                const SizedBox(height: 15),

                // PHONE

                if (phone.isNotEmpty)
                  detailRow(
                    Icons.phone_outlined,
                    "Phone",
                    phone,
                  ),

                const SizedBox(height: 25),

                // BOOK SERVICE BUTTON

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Booking feature will be added next.",
                          ),
                        ),
                      );
                    },

                    icon: const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                    ),

                    label: Text(
                      "Request / Book Service",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: orange,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
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
  }

  // ==============================================================
  // DETAIL ROW
  // ==============================================================

  Widget detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: purple.withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(12),
          ),

          child: Icon(
            icon,
            color: purple,
            size: 21,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // EMPTY PAGE
  // ==============================================================

  Widget _emptyProvidersPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 100,
              height: 100,

              decoration: BoxDecoration(
                color: purple.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.engineering_rounded,
                color: purple,
                size: 50,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "No Service Providers Yet",
              textAlign: TextAlign.center,

              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Approved service providers will appear here when they become available.",
              textAlign: TextAlign.center,

              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}