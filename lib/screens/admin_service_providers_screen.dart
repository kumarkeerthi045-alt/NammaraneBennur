import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminServiceProvidersScreen extends StatefulWidget {
  const AdminServiceProvidersScreen({super.key});

  @override
  State<AdminServiceProvidersScreen> createState() =>
      _AdminServiceProvidersScreenState();
}

class _AdminServiceProvidersScreenState
    extends State<AdminServiceProvidersScreen> {
  static const Color purple = Color(0xff7C3AED);
  static const Color orange = Color(0xffF97316);
  static const Color background = Color(0xffF7F8FC);

  // ==============================================================
  // SEARCH CONTROLLER
  // ==============================================================

  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
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
      // PROVIDERS
      // ============================================================

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('serviceProviders')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),

        builder: (context, snapshot) {
          // ========================================================
          // LOADING
          // ========================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
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
            return _errorView(
              snapshot.error.toString(),
            );
          }

          // ========================================================
          // DATA
          // ========================================================

          final providers = snapshot.data?.docs ?? [];

          // ========================================================
          // EMPTY DATABASE
          // ========================================================

          if (providers.isEmpty) {
            return _emptyView();
          }

          // ========================================================
          // FILTER PROVIDERS BY SERVICE
          // ========================================================

          final filteredProviders = providers.where((document) {
            final data = document.data();

            final serviceType =
                data['serviceType']
                        ?.toString()
                        .trim()
                        .toLowerCase() ??
                    "";

            final search =
                _searchText.trim().toLowerCase();

            if (search.isEmpty) {
              return true;
            }

            return serviceType.contains(search);
          }).toList();

          // ========================================================
          // MAIN PAGE
          // ========================================================

          return Column(
            children: [

              // ======================================================
              // SEARCH BAR
              // ======================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  8,
                ),
                child: TextField(
                  controller: _searchController,

                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },

                  decoration: InputDecoration(
                    hintText: "Search by service...",
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),

                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: purple,
                    ),

                    suffixIcon: _searchText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              _searchController.clear();

                              setState(() {
                                _searchText = "";
                              });
                            },
                          )
                        : null,

                    filled: true,
                    fillColor: Colors.white,

                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: purple,
                        width: 1.3,
                      ),
                    ),
                  ),
                ),
              ),

              // ======================================================
              // SEARCH RESULT COUNT
              // ======================================================

              if (_searchText.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    4,
                    18,
                    4,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${filteredProviders.length} provider${filteredProviders.length == 1 ? '' : 's'} found",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              // ======================================================
              // FILTERED LIST
              // ======================================================

              Expanded(
                child: filteredProviders.isEmpty
                    ? _noSearchResults()
                    : ListView.builder(
                        physics:
                            const BouncingScrollPhysics(),

                        padding:
                            const EdgeInsets.all(16),

                        itemCount:
                            filteredProviders.length,

                        itemBuilder:
                            (context, index) {
                          final document =
                              filteredProviders[index];

                          return _providerCard(
                            context,
                            document.id,
                            document.data(),
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

  // ==============================================================
  // NO SEARCH RESULTS
  // ==============================================================

  Widget _noSearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: purple.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: purple,
                size: 42,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              "No Providers Found",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              "No service provider matches\n"
              "\"$_searchText\"",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // PROVIDER CARD
  // ==============================================================

  Widget _providerCard(
    BuildContext context,
    String documentId,
    Map<String, dynamic> data,
  ) {
    final String name =
        data['name']?.toString().trim().isNotEmpty == true
            ? data['name'].toString()
            : "No Name";

    final String email =
        data['email']?.toString().trim().isNotEmpty == true
            ? data['email'].toString()
            : "No email";

    final String phone =
        data['phone']?.toString().trim().isNotEmpty == true
            ? data['phone'].toString()
            : "No phone";

    final String serviceType =
        data['serviceType']?.toString().trim().isNotEmpty == true
            ? data['serviceType'].toString()
            : "Service not specified";

    final String status =
        data['status']?.toString().toLowerCase() ?? "pending";

    final String address =
        data['address']?.toString() ?? "";

    final String experience =
        data['experience']?.toString() ?? "";

    final String description =
        data['description']?.toString() ?? "";

    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ======================================================
            // HEADER
            // ======================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Container(
                  width: 58,
                  height: 58,

                  decoration: BoxDecoration(
                    color: purple.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(17),
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
                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        serviceType,

                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            GoogleFonts.poppins(
                          fontSize: 12,
                          color:
                              Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        phone,

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

                const SizedBox(width: 8),

                _statusBadge(status),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 14),

            // ======================================================
            // BASIC DETAILS
            // ======================================================

            _infoRow(
              Icons.phone_outlined,
              "Mobile",
              phone,
            ),

            const SizedBox(height: 11),

            _infoRow(
              Icons.email_outlined,
              "Email",
              email,
            ),

            const SizedBox(height: 11),

            _infoRow(
              Icons.handyman_outlined,
              "Service",
              serviceType,
            ),

            if (address.isNotEmpty) ...[
              const SizedBox(height: 11),

              _infoRow(
                Icons.location_on_outlined,
                "Address",
                address,
              ),
            ],

            if (experience.isNotEmpty) ...[
              const SizedBox(height: 11),

              _infoRow(
                Icons.work_history_outlined,
                "Experience",
                experience,
              ),
            ],

            if (description.isNotEmpty) ...[
              const SizedBox(height: 11),

              _infoRow(
                Icons.description_outlined,
                "Description",
                description,
              ),
            ],

            const SizedBox(height: 18),

            // ======================================================
            // VIEW DETAILS
            // ======================================================

            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: () {
                  _showProviderDetails(
                    context,
                    documentId,
                    data,
                  );
                },

                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 19,
                ),

                label: Text(
                  "View Full Details",
                  style: GoogleFonts.poppins(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                style:
                    OutlinedButton.styleFrom(
                  foregroundColor: purple,

                  side: const BorderSide(
                    color: purple,
                  ),

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 13,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ======================================================
            // ACTION BUTTONS
            // ======================================================

            if (status == "pending")
              Row(
                children: [
                  Expanded(
                    child:
                        OutlinedButton.icon(
                      onPressed: () {
                        _deleteProvider(
                          context,
                          documentId,
                          name,
                        );
                      },

                      icon: const Icon(
                        Icons
                            .delete_outline_rounded,
                        size: 19,
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
                        foregroundColor:
                            Colors.red,

                        side:
                            const BorderSide(
                          color:
                              Colors.redAccent,
                        ),

                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 13,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child:
                        ElevatedButton.icon(
                      onPressed: () {
                        _approveProvider(
                          context,
                          documentId,
                          data,
                        );
                      },

                      icon: const Icon(
                        Icons
                            .check_circle_outline_rounded,
                        size: 19,
                      ),

                      label: Text(
                        "Accept",
                        style:
                            GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green,

                        foregroundColor:
                            Colors.white,

                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 13,
                        ),

                        elevation: 0,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,

                child: OutlinedButton.icon(
                  onPressed: () {
                    _deleteProvider(
                      context,
                      documentId,
                      name,
                    );
                  },

                  icon: const Icon(
                    Icons
                        .delete_outline_rounded,
                  ),

                  label: Text(
                    "Delete Provider",
                    style: GoogleFonts.poppins(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.red,

                    side:
                        const BorderSide(
                      color: Colors.redAccent,
                    ),

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 13,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // STATUS BADGE
  // ==============================================================

  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case "approved":
        color = Colors.green;
        break;

      case "rejected":
        color = Colors.red;
        break;

      default:
        color = orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.12,
        ),
        borderRadius:
            BorderRadius.circular(30),
      ),

      child: Text(
        status.toUpperCase(),

        style: GoogleFonts.poppins(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ==============================================================
  // INFORMATION ROW
  // ==============================================================

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
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value.isEmpty
                    ? "Not provided"
                    : value,

                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // FULL DETAILS
  // ==============================================================

  void _showProviderDetails(
    BuildContext context,
    String documentId,
    Map<String, dynamic> data,
  ) {
    final String name =
        data['name']?.toString() ?? "Not provided";

    final String email =
        data['email']?.toString() ?? "Not provided";

    final String phone =
        data['phone']?.toString() ?? "Not provided";

    final String serviceType =
        data['serviceType']?.toString() ??
            "Not provided";

    final String address =
        data['address']?.toString() ??
            "Not provided";

    final String experience =
        data['experience']?.toString() ??
            "Not provided";

    final String description =
        data['description']?.toString() ??
            "Not provided";

    final String userId =
        data['userId']?.toString() ??
            "Not available";

    final String status =
        data['status']?.toString() ??
            "pending";

    final String approvedBy =
        data['approvedBy']?.toString() ?? "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.50,
          maxChildSize: 0.95,

          builder: (
            context,
            scrollController,
          ) {
            return Container(
              decoration:
                  const BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),

              child: SafeArea(
                child: ListView(
                  controller:
                      scrollController,

                  padding:
                      const EdgeInsets.all(22),

                  children: [

                    // =================================================
                    // HANDLE
                    // =================================================

                    Center(
                      child: Container(
                        width: 45,
                        height: 5,

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.grey.shade300,
                          borderRadius:
                              BorderRadius
                                  .circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // TITLE
                    // =================================================

                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,

                          decoration:
                              BoxDecoration(
                            color:
                                purple.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(15),
                          ),

                          child: const Icon(
                            Icons
                                .engineering_rounded,
                            color: purple,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 13),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                name,

                                style:
                                    GoogleFonts
                                        .poppins(
                                  fontSize: 19,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              Text(
                                "Service Provider Application",

                                style:
                                    GoogleFonts
                                        .poppins(
                                  fontSize: 11,
                                  color: Colors
                                      .grey
                                      .shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        _statusBadge(status),
                      ],
                    ),

                    const SizedBox(height: 25),

                    _detailSection(
                      "Personal Information",
                      [
                        _detailItem(
                          Icons.person_outline,
                          "Full Name",
                          name,
                        ),

                        _detailItem(
                          Icons.phone_outlined,
                          "Mobile Number",
                          phone,
                        ),

                        _detailItem(
                          Icons.email_outlined,
                          "Email Address",
                          email,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _detailSection(
                      "Service Information",
                      [
                        _detailItem(
                          Icons.handyman_outlined,
                          "Service Type",
                          serviceType,
                        ),

                        _detailItem(
                          Icons.work_history_outlined,
                          "Experience",
                          experience,
                        ),

                        _detailItem(
                          Icons.location_on_outlined,
                          "Address",
                          address,
                        ),

                        _detailItem(
                          Icons.description_outlined,
                          "Description",
                          description,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _detailSection(
                      "Account Information",
                      [
                        _detailItem(
                          Icons.fingerprint,
                          "User ID",
                          userId,
                        ),

                        _detailItem(
                          Icons.badge_outlined,
                          "Document ID",
                          documentId,
                        ),
                      ],
                    ),

                    if (approvedBy.isNotEmpty) ...[
                      const SizedBox(height: 18),

                      Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(
                          14,
                        ),

                        decoration:
                            BoxDecoration(
                          color: Colors.green
                              .withValues(
                            alpha: 0.08,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(14),
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                "Approved by: $approvedBy",

                                style:
                                    GoogleFonts
                                        .poppins(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                  color: Colors
                                      .green
                                      .shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 25),

                    // =================================================
                    // ACTIONS
                    // =================================================

                    if (status.toLowerCase() ==
                        "pending")
                      Row(
                        children: [
                          Expanded(
                            child:
                                OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(
                                  sheetContext,
                                );

                                _deleteProvider(
                                  context,
                                  documentId,
                                  name,
                                );
                              },

                              icon: const Icon(
                                Icons
                                    .delete_outline,
                              ),

                              label: const Text(
                                "Delete",
                              ),

                              style:
                                  OutlinedButton
                                      .styleFrom(
                                foregroundColor:
                                    Colors.red,

                                side:
                                    const BorderSide(
                                  color:
                                      Colors.redAccent,
                                ),

                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical: 14,
                                ),

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child:
                                ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(
                                  sheetContext,
                                );

                                _approveProvider(
                                  context,
                                  documentId,
                                  data,
                                );
                              },

                              icon: const Icon(
                                Icons.check,
                              ),

                              label: const Text(
                                "Accept",
                              ),

                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    Colors.green,

                                foregroundColor:
                                    Colors.white,

                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical: 14,
                                ),

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,

                        child:
                            OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(
                              sheetContext,
                            );

                            _deleteProvider(
                              context,
                              documentId,
                              name,
                            );
                          },

                          icon: const Icon(
                            Icons
                                .delete_outline,
                          ),

                          label: const Text(
                            "Delete Provider",
                          ),

                          style:
                              OutlinedButton
                                  .styleFrom(
                            foregroundColor:
                                Colors.red,

                            side:
                                const BorderSide(
                              color:
                                  Colors.redAccent,
                            ),

                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 14,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(12),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==============================================================
  // DETAIL SECTION
  // ==============================================================

  Widget _detailSection(
    String title,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),

        borderRadius:
            BorderRadius.circular(17),

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
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 13),

          ...children,
        ],
      ),
    );
  }

  // ==============================================================
  // DETAIL ITEM
  // ==============================================================

  Widget _detailItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 13),

      child: Row(
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

                  style:
                      GoogleFonts.poppins(
                    fontSize: 10,
                    color:
                        Colors.grey.shade500,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value.isEmpty
                      ? "Not provided"
                      : value,

                  style:
                      GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // APPROVE PROVIDER
  // ==============================================================

  Future<void> _approveProvider(
    BuildContext context,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    final String name =
        data['name']?.toString() ??
            "Service Provider";

    final String email =
        data['email']?.toString() ?? "";

    final String phone =
        data['phone']?.toString() ?? "";

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
            "Accept Service Provider?",
            style: GoogleFonts.poppins(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          content: Text(
            "Are you sure you want to accept "
            "$name as a service provider?",

            style: GoogleFonts.poppins(
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
                backgroundColor:
                    Colors.green,
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

    if (confirm != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('serviceProviders')
          .doc(documentId)
          .update({
        'status': 'approved',

        'approvedBy': 'admin',

        'approvedAt':
            FieldValue.serverTimestamp(),

        'notification': {
          'type':
              'provider_approved',

          'message':
              'Congratulations! Your application has been accepted as a service provider on Namma Ranebennur.',

          'email': email,

          'phone': phone,

          'sent': false,

          'createdAt':
              FieldValue.serverTimestamp(),
        },
      });

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.green,

          content: Text(
            "$name has been approved successfully.",

            style:
                GoogleFonts.poppins(
              color: Colors.white,
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          duration:
              const Duration(seconds: 4),
        ),
      );

      await Future.delayed(
        const Duration(
          milliseconds: 300,
        ),
      );

      if (!context.mounted) {
        return;
      }

      _showApprovalNotificationInfo(
        context,
        name,
        email,
        phone,
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.red,

          content: Text(
            "Failed to approve provider: $e",
          ),
        ),
      );
    }
  }

  // ==============================================================
  // APPROVAL NOTIFICATION INFO
  // ==============================================================

  void _showApprovalNotificationInfo(
    BuildContext context,
    String name,
    String email,
    String phone,
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

          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,

                decoration:
                    BoxDecoration(
                  color: Colors.green
                      .withValues(
                    alpha: 0.12,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child: const Icon(
                  Icons
                      .mark_email_read_outlined,
                  color: Colors.green,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  "Provider Accepted",

                  style:
                      GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                "The provider has been successfully accepted.",

                style:
                    GoogleFonts.poppins(
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                "Confirmation will be sent to:",

                style:
                    GoogleFonts.poppins(
                  fontWeight:
                      FontWeight.w600,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 8),

              if (email.isNotEmpty)
                _notificationContact(
                  Icons.email_outlined,
                  email,
                ),

              if (phone.isNotEmpty) ...[
                const SizedBox(height: 6),

                _notificationContact(
                  Icons.phone_outlined,
                  phone,
                ),
              ],

              const SizedBox(height: 15),

              Container(
                padding:
                    const EdgeInsets.all(12),

                decoration:
                    BoxDecoration(
                  color: Colors.blue
                      .withValues(
                    alpha: 0.07,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child: Text(
                  "The notification request has been "
                  "saved in Firestore. Connect Firebase "
                  "Cloud Functions to automatically send "
                  "the email/SMS.",

                  style:
                      GoogleFonts.poppins(
                    fontSize: 10,
                    color:
                        Colors.blue.shade700,
                    height: 1.5,
                  ),
                ),
              ),
            ],
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

  // ==============================================================
  // NOTIFICATION CONTACT
  // ==============================================================

  Widget _notificationContact(
    IconData icon,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: Colors.grey.shade600,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            value,

            style:
                GoogleFonts.poppins(
              fontSize: 11,
              color:
                  Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // DELETE PROVIDER
  // ==============================================================

  Future<void> _deleteProvider(
    BuildContext context,
    String documentId,
    String providerName,
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
            style: GoogleFonts.poppins(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          content: Text(
            "Are you sure you want to permanently "
            "delete the application of $providerName?",

            style: GoogleFonts.poppins(
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
                backgroundColor:
                    Colors.red,
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

    if (confirm != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('serviceProviders')
          .doc(documentId)
          .delete();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Service provider deleted successfully.",
          ),

          backgroundColor:
              Colors.red,
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Failed to delete provider: $e",
          ),

          backgroundColor:
              Colors.red,
        ),
      );
    }
  }

  // ==============================================================
  // EMPTY VIEW
  // ==============================================================

  Widget _emptyView() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 95,
              height: 95,

              decoration:
                  BoxDecoration(
                color: purple.withValues(
                  alpha: 0.10,
                ),

                shape:
                    BoxShape.circle,
              ),

              child: const Icon(
                Icons.engineering_rounded,
                color: purple,
                size: 48,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "No Service Providers",

              textAlign:
                  TextAlign.center,

              style:
                  GoogleFonts.poppins(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Service provider applications will "
              "appear here when users register.",

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

  // ==============================================================
  // ERROR VIEW
  // ==============================================================

  Widget _errorView(String error) {
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
              size: 60,
            ),

            const SizedBox(height: 15),

            Text(
              "Unable to load service providers",

              textAlign:
                  TextAlign.center,

              style:
                  GoogleFonts.poppins(
                fontSize: 17,
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
                color: Colors.red,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}