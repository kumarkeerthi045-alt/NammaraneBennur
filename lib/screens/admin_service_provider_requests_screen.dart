import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/firestore_service.dart';

class AdminServiceProviderRequestsScreen extends StatelessWidget {
  const AdminServiceProviderRequestsScreen({super.key});

  static const Color purple = Color(0xff7C3AED);
  static const Color orange = Color(0xffF97316);
  static const Color green = Color(0xff16A34A);
  static const Color red = Color(0xffDC2626);
  static const Color background = Color(0xffF7F8FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          "Provider Requests",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('serviceProviderRequests')
            .where('status', isEqualTo: 'pending')
            .snapshots(),

        builder: (context, snapshot) {
          // ==========================================================
          // LOADING
          // ==========================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: purple,
              ),
            );
          }

          // ==========================================================
          // ERROR
          // ==========================================================

          if (snapshot.hasError) {
            return _errorWidget(
              context,
              snapshot.error.toString(),
            );
          }

          // ==========================================================
          // EMPTY
          // ==========================================================

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty) {
            return _emptyWidget();
          }

          // ==========================================================
          // REQUEST LIST
          // ==========================================================

          return Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  10,
                ),
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff7C3AED),
                      Color(0xff9333EA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,

                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.18,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: const Icon(
                        Icons.pending_actions_rounded,
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
                            "Pending Applications",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            "${requests.length} provider request(s) waiting for approval",
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

              // LIST
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    5,
                    16,
                    30,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: requests.length,

                  itemBuilder: (context, index) {
                    final doc = requests[index];

                    return _requestCard(
                      context,
                      doc.id,
                      doc.data(),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==================================================================
  // REQUEST CARD
  // ==================================================================

  Widget _requestCard(
    BuildContext context,
    String requestId,
    Map<String, dynamic> data,
  ) {
    final String name =
        data['name']?.toString().trim().isNotEmpty == true
            ? data['name'].toString()
            : 'Unknown Provider';

    final String phone =
        data['phone']?.toString() ?? '';

    final String serviceType =
        data['serviceType']?.toString() ??
            'Service not specified';

    final String city =
        data['city']?.toString() ?? '';

    final String area =
        data['area']?.toString() ?? '';

    final String uid =
        data['uid']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(17),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ========================================================
            // HEADER
            // ========================================================

            Row(
              children: [
                Container(
                  width: 55,
                  height: 55,

                  decoration: BoxDecoration(
                    color: purple.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(16),
                  ),

                  child: const Icon(
                    Icons.engineering_rounded,
                    color: purple,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        serviceType,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            GoogleFonts.poppins(
                          color:
                              Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                _pendingBadge(),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 12),

            // ========================================================
            // BASIC INFORMATION
            // ========================================================

            _infoRow(
              Icons.phone_outlined,
              "Phone",
              phone.isEmpty
                  ? "Not provided"
                  : phone,
            ),

            const SizedBox(height: 9),

            _infoRow(
              Icons.handyman_outlined,
              "Service",
              serviceType,
            ),

            const SizedBox(height: 9),

            _infoRow(
              Icons.location_city_outlined,
              "City",
              city.isEmpty
                  ? "Not provided"
                  : city,
            ),

            const SizedBox(height: 9),

            _infoRow(
              Icons.location_on_outlined,
              "Area",
              area.isEmpty
                  ? "Not provided"
                  : area,
            ),

            const SizedBox(height: 18),

            // ========================================================
            // THREE BUTTONS
            // ========================================================

            Row(
              children: [
                // VIEW
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showProviderDetails(
                        context,
                        requestId,
                        data,
                      );
                    },

                    icon: const Icon(
                      Icons.visibility_outlined,
                      size: 18,
                    ),

                    label: Text(
                      "View",
                      style:
                          GoogleFonts.poppins(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          Colors.blue,
                      side: const BorderSide(
                        color: Colors.blue,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          11,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // ACCEPT
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: uid.isEmpty
                        ? null
                        : () {
                            _approveProvider(
                              context,
                              requestId,
                              uid,
                              name,
                            );
                          },

                    icon: const Icon(
                      Icons.check_circle_outline,
                      size: 18,
                    ),

                    label: Text(
                      "Accept",
                      style:
                          GoogleFonts.poppins(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor:
                          Colors.white,
                      disabledBackgroundColor:
                          Colors.grey.shade300,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          11,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // DELETE
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _deleteRequest(
                        context,
                        requestId,
                        uid,
                        name,
                      );
                    },

                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                    ),

                    label: Text(
                      "Delete",
                      style:
                          GoogleFonts.poppins(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor: red,
                      side: const BorderSide(
                        color: red,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          11,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================================
  // PENDING BADGE
  // ==================================================================

  Widget _pendingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: orange.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Text(
        "PENDING",
        style: GoogleFonts.poppins(
          color: orange,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ==================================================================
  // INFORMATION ROW
  // ==================================================================

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Icon(
          icon,
          size: 19,
          color: Colors.grey.shade600,
        ),

        const SizedBox(width: 9),

        Text(
          "$title: ",
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  // ==================================================================
  // VIEW ALL DETAILS
  // ==================================================================

  void _showProviderDetails(
    BuildContext context,
    String requestId,
    Map<String, dynamic> data,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height *
                  0.82,

          decoration:
              const BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),

          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                Container(
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

                const SizedBox(height: 18),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,

                        decoration:
                            BoxDecoration(
                          color:
                              purple.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            15,
                          ),
                        ),

                        child: const Icon(
                          Icons.person_rounded,
                          color: purple,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 13),

                      Expanded(
                        child: Text(
                          "Provider Details",
                          style:
                              GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  height: 30,
                ),

                Expanded(
                  child: ListView(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      30,
                    ),

                    children: [
                      _detailBox(
                        "Request ID",
                        requestId,
                      ),

                      ...data.entries.map(
                        (entry) {
                          String value;

                          if (entry.value ==
                              null) {
                            value = "-";
                          } else if (entry.value
                              is Timestamp) {
                            value =
                                (entry.value
                                        as Timestamp)
                                    .toDate()
                                    .toString();
                          } else {
                            value =
                                entry.value
                                    .toString();
                          }

                          return _detailBox(
                            entry.key,
                            value,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================================================================
  // DETAIL BOX
  // ==================================================================

  Widget _detailBox(
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,

      margin:
          const EdgeInsets.only(bottom: 10),

      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.grey.shade50,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black87,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================================
  // APPROVE PROVIDER
  // ==================================================================

  Future<void> _approveProvider(
    BuildContext context,
    String requestId,
    String uid,
    String name,
  ) async {
    final bool? confirm =
        await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          title: Text(
            "Accept Provider?",
            style:
                GoogleFonts.poppins(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          content: Text(
            "Accept $name as a service provider?",
            style:
                GoogleFonts.poppins(
              fontSize: 13,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor: green,
              ),

              child: const Text(
                "Accept",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      // ============================================================
      // 1. APPROVE REQUEST
      //
      // This creates the service provider,
      // updates the user role and updates
      // the request.
      // ============================================================

      final FirestoreService service =
          FirestoreService();

      final String serviceProviderId =
          await service
              .approveServiceProviderRequest(
        requestId: requestId,
      );

      // ============================================================
      // 2. CREATE NOTIFICATION FOR USER
      // ============================================================

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .add({
        'title':
            'Service Provider Application Approved',
        'message':
            'Congratulations! Your service provider application has been approved by the admin.',
        'type':
            'service_provider_approved',
        'serviceProviderId':
            serviceProviderId,
        'requestId':
            requestId,
        'read': false,
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Provider accepted. User has been notified.",
          ),
          backgroundColor: green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Failed to accept provider: $e",
          ),
          backgroundColor: red,
        ),
      );
    }
  }

  // ==================================================================
  // DELETE REQUEST
  // ==================================================================

  Future<void> _deleteRequest(
    BuildContext context,
    String requestId,
    String uid,
    String name,
  ) async {
    final bool? confirm =
        await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          title: Text(
            "Delete Provider?",
            style:
                GoogleFonts.poppins(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          content: Text(
            "This will permanently delete $name's service provider request. Continue?",
            style:
                GoogleFonts.poppins(
              fontSize: 13,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor: red,
              ),

              child: const Text(
                "Delete",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      // ============================================================
      // DELETE REQUEST
      // ============================================================

      await FirebaseFirestore.instance
          .collection('serviceProviderRequests')
          .doc(requestId)
          .delete();

      // ============================================================
      // IF THIS USER ALREADY HAS A PROVIDER RECORD,
      // REMOVE IT TOO.
      // ============================================================

      if (uid.isNotEmpty) {
        final providerQuery =
            await FirebaseFirestore.instance
                .collection('serviceProviders')
                .where(
                  'uid',
                  isEqualTo: uid,
                )
                .get();

        for (final provider
            in providerQuery.docs) {
          await provider.reference.delete();
        }

        // Reset user's role if necessary.
        final userRef =
            FirebaseFirestore.instance
                .collection('users')
                .doc(uid);

        final userDoc =
            await userRef.get();

        if (userDoc.exists) {
          final userData =
              userDoc.data();

          if (userData?[
                  'role'] ==
              'serviceProvider') {
            await userRef.update({
              'role': 'user',
              'serviceProviderId':
                  FieldValue.delete(),
              'updatedAt':
                  FieldValue
                      .serverTimestamp(),
            });
          }
        }
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Provider deleted successfully.",
          ),
          backgroundColor: red,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Failed to delete provider: $e",
          ),
          backgroundColor: red,
        ),
      );
    }
  }

  // ==================================================================
  // EMPTY
  // ==================================================================

  Widget _emptyWidget() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

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
                    purple.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(
                  28,
                ),
              ),

              child: const Icon(
                Icons
                    .engineering_outlined,
                color: purple,
                size: 45,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "No Pending Requests",
              style:
                  GoogleFonts.poppins(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              "There are currently no service provider applications waiting for approval.",
              textAlign:
                  TextAlign.center,

              style:
                  GoogleFonts.poppins(
                color:
                    Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================================
  // ERROR
  // ==================================================================

  Widget _errorWidget(
    BuildContext context,
    String error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 55,
            ),

            const SizedBox(height: 15),

            Text(
              "Unable to load requests",
              textAlign:
                  TextAlign.center,

              style:
                  GoogleFonts.poppins(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              error,
              textAlign:
                  TextAlign.center,

              style:
                  GoogleFonts.poppins(
                color:
                    Colors.red.shade600,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              "Make sure your Firestore rules allow the admin account to read serviceProviderRequests.",
              textAlign:
                  TextAlign.center,

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
    );
  }
}