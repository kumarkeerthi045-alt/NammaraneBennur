import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/order_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  int currentAd = 0;

  final PageController adController = PageController();

  @override
  void dispose() {
    adController.dispose();
    super.dispose();
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  void changeBottomPage(int index) {
    setState(() {
      selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;

      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FindForMeScreen(),
          ),
        );
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AnnouncementsScreen(),
          ),
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NewInCityScreen(),
          ),
        );
        break;

      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SOSScreen(),
          ),
        );
        break;
    }
  }

  // ============================================================
  // PROFILE
  // ============================================================

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  // ============================================================
  // OPEN CATEGORY
  // ============================================================

  void openBookingCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryListScreen(
          category: category,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8F1),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffff6b16),
        automaticallyImplyLeading: false,

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_city_rounded,
                color: Color(0xffF97316),
                size: 24,
              ),
            ),

            const SizedBox(width: 10),

            Text(
              "Namma Ranebennur",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: "Notifications",
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("No new notifications"),
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              tooltip: "Profile",
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              onPressed: openProfile,
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // GREETING
              // ==================================================

              Text(
                "Hello User 👋",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff3A2418),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                "What's happening in Ranebennur today?",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // SEARCH
              // ==================================================

              Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: const Color(0xffffe1cc),
                  ),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText:
                        "Search businesses, services, posts...",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xffF97316),
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // FEATURED ADS
              // ==================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    "Featured Ads",
                    style: GoogleFonts.poppins(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff3A2418),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      showPostAdDialog(context);
                    },
                    child: Text(
                      "Advertise here →",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xffF97316),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 3),

              Text(
                "Sponsored Ads",
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // ADS SLIDER
              // ==================================================

              SizedBox(
                height: 205,
                child: PageView(
                  controller: adController,
                  onPageChanged: (index) {
                    setState(() {
                      currentAd = index;
                    });
                  },
                  children: [
                    advertisementCard(
                      title: "Grand Opening Offer 🎉",
                      business: "Sri Lakshmi Electronics",
                      description:
                          "Special discounts available this week.",
                      icon: Icons.store_rounded,
                      colors: const [
                        Color(0xffF97316),
                        Color(0xffEA580C),
                      ],
                      premium: true,
                    ),

                    advertisementCard(
                      title: "Best Food in Town 🍴",
                      business: "Ranebennur Food Fest",
                      description:
                          "Taste the best food from our city.",
                      icon: Icons.restaurant_rounded,
                      colors: const [
                        Color(0xff2563EB),
                        Color(0xff1D4ED8),
                      ],
                      premium: false,
                    ),

                    advertisementCard(
                      title: "New Collection",
                      business: "City Fashion Store",
                      description:
                          "Latest fashion arrivals available now.",
                      icon: Icons.shopping_bag_rounded,
                      colors: const [
                        Color(0xff7C3AED),
                        Color(0xff5B21B6),
                      ],
                      premium: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ==================================================
              // AD INDICATORS
              // ==================================================

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) {
                    return AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 250),
                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      height: 7,
                      width:
                          currentAd == index ? 22 : 7,
                      decoration: BoxDecoration(
                        color: currentAd == index
                            ? const Color(0xffF97316)
                            : Colors.grey.shade300,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // IMPORTANT IN RANEBENNUR
              // ==================================================

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AnnouncementsScreen(),
                    ),
                  );
                },

                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xffff7a18),
                        Color(0xffed4b00),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange
                            .withValues(alpha: 0.20),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,

                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(alpha: 0.20),
                          borderRadius:
                              BorderRadius.circular(17),
                        ),

                        child: const Icon(
                          Icons.campaign_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "IMPORTANT IN RANEBENNUR",
                              style:
                                  GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "City announcements & alerts",
                              style:
                                  GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              "Power cuts, emergency alerts, news & updates",
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // BOOKING
              // ==================================================

              Text(
                "What do you want to book?",
                style: GoogleFonts.poppins(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff3A2418),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "Choose a service and find available options.",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 15),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),

                children: [
                  bookingCard(
                    emoji: "🏨",
                    title: "Hotel",
                    onTap: () =>
                        openBookingCategory("Hotel"),
                  ),

                  bookingCard(
                    emoji: "✂️",
                    title: "Salon",
                    onTap: () =>
                        openBookingCategory("Salon"),
                  ),

                  bookingCard(
                    emoji: "🎊",
                    title: "Function Hall",
                    onTap: () =>
                        openBookingCategory(
                      "Function Hall",
                    ),
                  ),

                  bookingCard(
                    emoji: "🩺",
                    title: "Clinic",
                    onTap: () =>
                        openBookingCategory("Clinic"),
                  ),

                  bookingCard(
                    emoji: "🛺",
                    title: "Travel",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const TravelScreen(),
                        ),
                      );
                    },
                  ),

                  bookingCard(
                    emoji: "🔧",
                    title: "Home Services",
                    onTap: () =>
                        openBookingCategory(
                      "Workers",
                    ),
                  ),

                  bookingCard(
                    emoji: "🎉",
                    title: "Events",
                    onTap: () =>
                        openBookingCategory(
                      "Function Hall",
                    ),
                  ),

                  bookingCard(
                    emoji: "🚜",
                    title: "Machinery",
                    onTap: () =>
                        openBookingCategory(
                      "Machinery",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ==================================================
              // LOCAL POSTS
              // ==================================================

              Text(
                "Local Posts",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xffB45309),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                "Around Ranebennur",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff3A2418),
                ),
              ),

              const SizedBox(height: 15),

              localPostCard(
                icon: "🏠",
                category: "TO-LET",
                type: "Premium",
                title:
                    "2BHK house required / available",
                location: "Ranebennur",
              ),

              localPostCard(
                icon: "📱",
                category: "MARKET",
                type: "Standard",
                title:
                    "Used phones & gadgets",
                location: "Local sellers",
              ),

              localPostCard(
                icon: "🚜",
                category: "MACHINERY",
                type: "Featured",
                title:
                    "JCB, crane & tractor services",
                location: "Ranebennur",
              ),

              localPostCard(
                icon: "🔧",
                category: "SERVICE",
                type: "Standard",
                title:
                    "Electrician and plumbing services",
                location: "Available nearby",
              ),

              localPostCard(
                icon: "🚗",
                category: "TRAVEL",
                type: "Standard",
                title:
                    "Car and driver available for trips",
                location: "Ranebennur",
              ),

              const SizedBox(height: 5),

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "All local posts will appear here.",
                        ),
                      ),
                    );
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xffEF4F00),
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),

                  child: Text(
                    "View all local posts →",
                    style:
                        GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // ADVERTISE
              // ==================================================

              Text(
                "Advertise Your Business",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff3A2418),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "Reach customers across Ranebennur",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: advertisementOption(
                      title: "Premium",
                      subtitle: "Long visibility",
                      icon:
                          Icons.workspace_premium_rounded,
                      color:
                          const Color(0xffF97316),
                      onTap: () {
                        showPostAdDialog(context);
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: advertisementOption(
                      title: "Free Post",
                      subtitle:
                          "Visible for 24 hours",
                      icon:
                          Icons.access_time_rounded,
                      color:
                          const Color(0xff16A34A),
                      onTap: () {
                        showPostAdDialog(context);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        elevation: 8,
        selectedIndex: selectedIndex,
        indicatorColor:
            const Color(0xffffe2cc),
        onDestinationSelected:
            changeBottomPage,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: Color(0xffF97316),
            ),
            label: "Home",
          ),

          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(
              Icons.search_rounded,
              color: Color(0xffF97316),
            ),
            label: "Find For Me",
          ),

          NavigationDestination(
            icon:
                Icon(Icons.campaign_outlined),
            selectedIcon: Icon(
              Icons.campaign_rounded,
              color: Color(0xffF97316),
            ),
            label: "Announcements",
          ),

          NavigationDestination(
            icon: Icon(
              Icons.auto_awesome_outlined,
            ),
            selectedIcon: Icon(
              Icons.auto_awesome,
              color: Color(0xffF97316),
            ),
            label: "New in City",
          ),

          NavigationDestination(
            icon: Icon(
              Icons.sos_outlined,
              color: Colors.red,
            ),
            selectedIcon: Icon(
              Icons.sos_rounded,
              color: Colors.red,
            ),
            label: "SOS",
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// ADVERTISEMENT CARD
// ==================================================================

Widget advertisementCard({
  required String title,
  required String business,
  required String description,
  required IconData icon,
  required List<Color> colors,
  required bool premium,
}) {
  return Container(
    margin: const EdgeInsets.only(right: 6),
    padding: const EdgeInsets.all(20),

    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
    ),

    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              if (premium)
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white
                        .withValues(alpha: 0.20),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Text(
                    "⭐ PREMIUM",
                    style:
                        GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              Text(
                title,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                business,
                style:
                    GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 68,
          height: 68,

          decoration: BoxDecoration(
            color: Colors.white
                .withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),

          child: Icon(
            icon,
            size: 35,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

// ==================================================================
// BOOKING CARD
// ==================================================================

Widget bookingCard({
  required String emoji,
  required String title,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,

    child: Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xffffdfca),
          width: 1.3,
        ),
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Text(
            emoji,
            style: const TextStyle(
              fontSize: 31,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            title,
            textAlign: TextAlign.center,
            style:
                GoogleFonts.poppins(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color:
                  const Color(0xff3A2418),
            ),
          ),
        ],
      ),
    ),
  );
}

// ==================================================================
// LOCAL POST CARD
// ==================================================================

Widget localPostCard({
  required String icon,
  required String category,
  required String type,
  required String title,
  required String location,
}) {
  return Container(
    margin:
        const EdgeInsets.only(bottom: 13),

    padding:
        const EdgeInsets.all(15),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xffffdfca),
      ),
    ),

    child: Row(
      children: [
        Container(
          width: 65,
          height: 65,

          decoration: BoxDecoration(
            color: const Color(0xfffff3e8),
            borderRadius:
                BorderRadius.circular(16),
          ),

          child: Center(
            child: Text(
              icon,
              style: const TextStyle(
                fontSize: 35,
              ),
            ),
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                "$category · $type",
                style:
                    GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      const Color(0xffD9550A),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                title,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      const Color(0xff34251E),
                ),
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: Colors.red,
                  ),

                  const SizedBox(width: 3),

                  Expanded(
                    child: Text(
                      location,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          GoogleFonts.poppins(
                        fontSize: 10,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 11,
          ),

          decoration: BoxDecoration(
            color: const Color(0xfffff0e4),
            borderRadius:
                BorderRadius.circular(14),
          ),

          child: Text(
            "View",
            style:
                GoogleFonts.poppins(
              color:
                  const Color(0xffA9440A),
              fontWeight:
                  FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    ),
  );
}

// ==================================================================
// ADVERTISEMENT OPTION
// ==================================================================

Widget advertisementOption({
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.white,
    borderRadius:
        BorderRadius.circular(20),

    child: InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(20),

      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Container(
              width: 45,
              height: 45,

              decoration: BoxDecoration(
                color:
                    color.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(14),
              ),

              child: Icon(
                icon,
                color: color,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style:
                  GoogleFonts.poppins(
                fontSize: 15,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              subtitle,
              style:
                  GoogleFonts.poppins(
                color:
                    Colors.grey.shade600,
                fontSize: 10,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Post Now →",
              style:
                  GoogleFonts.poppins(
                color: color,
                fontSize: 11,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ==================================================================
// POST AD DIALOG
// ==================================================================

void showPostAdDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,

    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(22),

        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              "Advertise on Namma Ranebennur",
              style:
                  GoogleFonts.poppins(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Choose how you want your advertisement to be displayed.",
              style:
                  GoogleFonts.poppins(
                color:
                    Colors.grey.shade600,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xffF97316),
              ),

              title: const Text(
                "Premium Advertisement",
              ),

              subtitle: const Text(
                "Longer visibility with premium placement",
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
              ),

              onTap: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Premium ad request selected.",
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.access_time_rounded,
                color: Colors.green,
              ),

              title: const Text(
                "Free Advertisement",
              ),

              subtitle: const Text(
                "Advertisement visible for 24 hours",
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
              ),

              onTap: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Free ad request selected.",
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

// ==================================================================
// FIND FOR ME SCREEN
// ==================================================================

class FindForMeScreen extends StatelessWidget {
  const FindForMeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFFF8F1),

      appBar: AppBar(
        title: Text(
          "Find For Me",
          style:
              GoogleFonts.poppins(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        backgroundColor:
            const Color(0xffff6b16),

        foregroundColor:
            Colors.white,

        elevation: 0,
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),

        children: [
          findOption(
            context,
            icon:
                Icons.home_work_rounded,
            color: Colors.green,
            title: "Property",
            subtitle:
                "Rent, lease or buy property.",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PropertySearchScreen(),
                ),
              );
            },
          ),

          findOption(
            context,
            icon:
                Icons.handyman_rounded,
            color: Colors.purple,
            title: "Workers",
            subtitle:
                "Electricians, plumbers, carpenters and more.",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const WorkerSearchScreen(),
                ),
              );
            },
          ),

          findOption(
            context,
            icon:
                Icons.directions_car_rounded,
            color: Colors.blue,
            title: "Travel",
            subtitle:
                "Drivers, vehicles and trip planning.",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const TravelScreen(),
                ),
              );
            },
          ),

          findOption(
            context,
            icon:
                Icons.hotel_rounded,
            color: Colors.orange,
            title: "Hotels",
            subtitle:
                "Find hotels and accommodation.",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CategoryListScreen(
                    category: "Hotel",
                  ),
                ),
              );
            },
          ),

          findOption(
            context,
            icon:
                Icons.content_cut_rounded,
            color: Colors.pink,
            title: "Salon",
            subtitle:
                "Find salons and beauty services.",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CategoryListScreen(
                    category: "Salon",
                  ),
                ),
              );
            },
          ),

          findOption(
            context,
            icon:
                Icons.event_rounded,
            color: Colors.red,
            title: "Function Halls",
            subtitle:
                "Find events and function halls.",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CategoryListScreen(
                    category: "Function Hall",
                  ),
                ),
              );
            },
          ),

          findOption(
            context,
            icon:
                Icons.local_hospital_rounded,
            color: Colors.teal,
            title: "Clinics",
            subtitle:
                "Find nearby clinics and doctors.",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CategoryListScreen(
                    category: "Clinic",
                  ),
                ),
              );
            },
          ),

          findOption(
            context,
            icon:
                Icons.construction_rounded,
            color: Colors.brown,
            title: "Machinery",
            subtitle:
                "JCB, cranes, tractors and other machinery.",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CategoryListScreen(
                    category: "Machinery",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// FIND OPTION
// ==================================================================

Widget findOption(
  BuildContext context, {
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,

    child: Container(
      margin:
          const EdgeInsets.only(bottom: 14),

      padding:
          const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,

            decoration: BoxDecoration(
              color:
                  color.withValues(alpha: 0.12),
              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: Icon(
              icon,
              color: color,
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
                  title,
                  style:
                      GoogleFonts.poppins(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
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

          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15,
            color: Colors.grey,
          ),
        ],
      ),
    ),
  );
}

// ==================================================================
// CATEGORY LIST SCREEN
// ==================================================================

class CategoryListScreen extends StatelessWidget {
  final String category;

  const CategoryListScreen({
    super.key,
    required this.category,
  });

  // ================================================================
  // SAMPLE BUSINESS DATA
  // ================================================================

  List<Map<String, dynamic>> getBusinesses() {
    switch (category) {
      case "Hotel":
        return [
          {
            "name": "Hotel Grand Palace",
            "location": "Ranebennur",
            "rating": "4.5",
            "description":
                "Comfortable rooms, family accommodation and quality service.",
            "icon": Icons.hotel_rounded,
          },
          {
            "name": "Sri Krishna Residency",
            "location": "Ranebennur",
            "rating": "4.3",
            "description":
                "Affordable and comfortable stay for families and travellers.",
            "icon": Icons.hotel_rounded,
          },
          {
            "name": "Royal Stay Hotel",
            "location": "Ranebennur",
            "rating": "4.2",
            "description":
                "Modern rooms with convenient facilities and city access.",
            "icon": Icons.hotel_rounded,
          },
        ];

      case "Salon":
        return [
          {
            "name": "Style Studio Salon",
            "location": "Ranebennur",
            "rating": "4.6",
            "description":
                "Hair styling, grooming, bridal makeup and beauty services.",
            "icon": Icons.content_cut_rounded,
          },
          {
            "name": "Looks Beauty Salon",
            "location": "Ranebennur",
            "rating": "4.4",
            "description":
                "Professional beauty and personal grooming services.",
            "icon": Icons.content_cut_rounded,
          },
          {
            "name": "Royal Hair & Beauty",
            "location": "Ranebennur",
            "rating": "4.3",
            "description":
                "Complete hair and beauty care for men and women.",
            "icon": Icons.content_cut_rounded,
          },
        ];

      case "Clinic":
        return [
          {
            "name": "City Care Clinic",
            "location": "Ranebennur",
            "rating": "4.7",
            "description":
                "General healthcare and consultation services.",
            "icon":
                Icons.local_hospital_rounded,
          },
          {
            "name": "Sri Sai Clinic",
            "location": "Ranebennur",
            "rating": "4.5",
            "description":
                "Family healthcare and medical consultation.",
            "icon":
                Icons.local_hospital_rounded,
          },
          {
            "name": "Health First Clinic",
            "location": "Ranebennur",
            "rating": "4.4",
            "description":
                "Primary healthcare and specialist consultation.",
            "icon":
                Icons.local_hospital_rounded,
          },
        ];

      case "Function Hall":
        return [
          {
            "name": "Royal Function Hall",
            "location": "Ranebennur",
            "rating": "4.6",
            "description":
                "Large function hall suitable for weddings and events.",
            "icon": Icons.celebration_rounded,
          },
          {
            "name": "Sri Lakshmi Convention Hall",
            "location": "Ranebennur",
            "rating": "4.5",
            "description":
                "Modern venue for weddings, receptions and celebrations.",
            "icon": Icons.celebration_rounded,
          },
          {
            "name": "City Celebration Hall",
            "location": "Ranebennur",
            "rating": "4.3",
            "description":
                "Affordable event venue for family and social functions.",
            "icon": Icons.celebration_rounded,
          },
        ];

      case "Machinery":
        return [
          {
            "name": "Sri Sai JCB Services",
            "location": "Ranebennur",
            "rating": "4.6",
            "description":
                "JCB available for construction, digging and earthwork.",
            "icon": Icons.construction_rounded,
          },
          {
            "name": "Royal Crane Services",
            "location": "Ranebennur",
            "rating": "4.4",
            "description":
                "Crane rental and heavy machinery services.",
            "icon": Icons.construction_rounded,
          },
          {
            "name": "Farm Machinery Services",
            "location": "Ranebennur",
            "rating": "4.5",
            "description":
                "Tractors and agricultural machinery available for hire.",
            "icon": Icons.agriculture_rounded,
          },
        ];

      default:
        return [];
    }
  }

  // ================================================================
  // CATEGORY ICON
  // ================================================================

  IconData getCategoryIcon() {
    switch (category) {
      case "Hotel":
        return Icons.hotel_rounded;

      case "Salon":
        return Icons.content_cut_rounded;

      case "Clinic":
        return Icons.local_hospital_rounded;

      case "Function Hall":
        return Icons.celebration_rounded;

      case "Machinery":
        return Icons.construction_rounded;

      default:
        return Icons.store_rounded;
    }
  }

  // ================================================================
  // CATEGORY COLOR
  // ================================================================

  Color getCategoryColor() {
    switch (category) {
      case "Hotel":
        return Colors.orange;

      case "Salon":
        return Colors.pink;

      case "Clinic":
        return Colors.teal;

      case "Function Hall":
        return Colors.red;

      case "Machinery":
        return Colors.brown;

      default:
        return const Color(0xffF97316);
    }
  }

  @override
  Widget build(BuildContext context) {
    final businesses = getBusinesses();

    final color = getCategoryColor();

    return Scaffold(
      backgroundColor:
          const Color(0xffFFF8F1),

      appBar: AppBar(
        title: Text(
          category,
          style:
              GoogleFonts.poppins(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        backgroundColor:
            const Color(0xffff6b16),

        foregroundColor:
            Colors.white,

        elevation: 0,
      ),

      body: Column(
        children: [
          // ========================================================
          // HEADER
          // ========================================================

          Container(
            width: double.infinity,

            margin:
                const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              10,
            ),

            padding:
                const EdgeInsets.all(18),

            decoration: BoxDecoration(
              gradient:
                  LinearGradient(
                colors: [
                  color,
                  color.withValues(
                    alpha: 0.75,
                  ),
                ],
              ),

              borderRadius:
                  BorderRadius.circular(22),
            ),

            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,

                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withValues(
                      alpha: 0.20,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),

                  child: Icon(
                    getCategoryIcon(),
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        "Find $category",
                        style:
                            GoogleFonts.poppins(
                          color:
                              Colors.white,
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        "${businesses.length} options available in Ranebennur",
                        style:
                            GoogleFonts.poppins(
                          color:
                              Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ========================================================
          // SEARCH
          // ========================================================

          Container(
            margin:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),

            height: 50,

            decoration:
                BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(15),

              border: Border.all(
                color:
                    const Color(0xffffdfca),
              ),
            ),

            child: TextField(
              decoration:
                  InputDecoration(
                hintText:
                    "Search $category...",

                hintStyle:
                    GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey,
                ),

                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: color,
                ),

                border:
                    InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 5),

          // ========================================================
          // BUSINESS LIST
          // ========================================================

          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                5,
                16,
                25,
              ),

              itemCount:
                  businesses.length,

              itemBuilder:
                  (context, index) {
                final business =
                    businesses[index];

                return categoryBusinessCard(
                  context: context,
                  name:
                      business["name"],
                  location:
                      business["location"],
                  rating:
                      business["rating"],
                  description:
                      business["description"],
                  icon:
                      business["icon"],
                  color: color,
                  category: category,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// BUSINESS CARD
// ==================================================================

Widget categoryBusinessCard({
  required BuildContext context,
  required String name,
  required String location,
  required String rating,
  required String description,
  required IconData icon,
  required Color color,
  required String category,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              BusinessDetailsScreen(
            name: name,
            location: location,
            rating: rating,
            description:
                description,
            icon: icon,
            color: color,
            category: category,
          ),
        ),
      );
    },

    child: Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
          const EdgeInsets.all(15),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(21),

        border: Border.all(
          color:
              const Color(0xffffdfca),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,

            decoration:
                BoxDecoration(
              color: color.withValues(
                alpha: 0.12,
              ),

              borderRadius:
                  BorderRadius.circular(18),
            ),

            child: Icon(
              icon,
              color: color,
              size: 34,
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
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        const Color(0xff34251E),
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Colors.red,
                    ),

                    const SizedBox(width: 3),

                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            GoogleFonts.poppins(
                          fontSize: 10,
                          color:
                              Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 17,
                    ),

                    const SizedBox(width: 3),

                    Text(
                      rating,
                      style:
                          GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            width: 38,
            height: 38,

            decoration:
                BoxDecoration(
              color:
                  color.withValues(
                alpha: 0.10,
              ),

              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

// ==================================================================
// BUSINESS DETAILS SCREEN
// ==================================================================

class BusinessDetailsScreen
    extends StatelessWidget {
  final String name;
  final String location;
  final String rating;
  final String description;
  final IconData icon;
  final Color color;
  final String category;

  const BusinessDetailsScreen({
    super.key,
    required this.name,
    required this.location,
    required this.rating,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFFF8F1),

      appBar: AppBar(
        title: Text(
          category,
          style:
              GoogleFonts.poppins(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        backgroundColor:
            const Color(0xffff6b16),

        foregroundColor:
            Colors.white,

        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ======================================================
            // BUSINESS HEADER
            // ======================================================

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(28),

              decoration:
                  BoxDecoration(
                gradient:
                    LinearGradient(
                  colors: [
                    color,
                    color.withValues(
                      alpha: 0.75,
                    ),
                  ],

                  begin:
                      Alignment.topLeft,

                  end:
                      Alignment.bottomRight,
                ),

                borderRadius:
                    const BorderRadius.vertical(
                  bottom:
                      Radius.circular(35),
                ),
              ),

              child: Column(
                children: [
                  Container(
                    width: 95,
                    height: 95,

                    decoration:
                        BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        25,
                      ),
                    ),

                    child: Icon(
                      icon,
                      color: color,
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    name,
                    textAlign:
                        TextAlign.center,

                    style:
                        GoogleFonts.poppins(
                      color:
                          Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color:
                            Colors.white,
                        size: 17,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        location,
                        style:
                            GoogleFonts.poppins(
                          color:
                              Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color:
                            Colors.amber,
                        size: 20,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        "$rating Rating",
                        style:
                            GoogleFonts.poppins(
                          color:
                              Colors.white,
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ======================================================
            // CONTENT
            // ======================================================

            Padding(
              padding:
                  const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    "About",
                    style:
                        GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          const Color(0xff3A2418),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    description,
                    style:
                        GoogleFonts.poppins(
                      color:
                          Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Services",
                    style:
                        GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          const Color(0xff3A2418),
                    ),
                  ),

                  const SizedBox(height: 12),

                  detailInfoCard(
                    icon:
                        Icons.check_circle_rounded,
                    title: "Available",
                    subtitle:
                        "Currently accepting enquiries",
                    color:
                        Colors.green,
                  ),

                  detailInfoCard(
                    icon:
                        Icons.location_on_rounded,
                    title: "Location",
                    subtitle:
                        "Ranebennur, Karnataka",
                    color:
                        Colors.red,
                  ),

                  detailInfoCard(
                    icon:
                        Icons.access_time_rounded,
                    title:
                        "Working Hours",
                    subtitle:
                        "Contact business for current timings",
                    color:
                        Colors.blue,
                  ),

                  const SizedBox(height: 15),

                  // ==================================================
                  // CALL + BOOK
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,

                          child:
                              ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger
                                  .of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Calling $name...",
                                  ),
                                ),
                              );
                            },

                            icon:
                                const Icon(
                              Icons.call_rounded,
                              color:
                                  Colors.white,
                            ),

                            label:
                                Text(
                              "Call",
                              style:
                                  GoogleFonts
                                      .poppins(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  Colors.green,
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: SizedBox(
                          height: 52,

                          child:
                              ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger
                                  .of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Opening booking for $name...",
                                  ),
                                ),
                              );
                            },

                            icon:
                                const Icon(
                              Icons
                                  .calendar_month_rounded,
                              color:
                                  Colors.white,
                            ),

                            label:
                                Text(
                              "Book",
                              style:
                                  GoogleFonts
                                      .poppins(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  const Color(
                                0xffF97316,
                              ),
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // LOCATION
                  // ==================================================

                  Container(
                    width: double.infinity,
                    height: 150,

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.grey.shade200,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons
                              .location_on_rounded,
                          color: color,
                          size: 40,
                        ),

                        const SizedBox(height: 7),

                        Text(
                          "View location",
                          style:
                              GoogleFonts.poppins(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        Text(
                          "Ranebennur",
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
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// DETAIL INFORMATION CARD
// ==================================================================

Widget detailInfoCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
}) {
  return Container(
    width: double.infinity,

    margin:
        const EdgeInsets.only(bottom: 10),

    padding:
        const EdgeInsets.all(15),

    decoration:
        BoxDecoration(
      color: Colors.white,

      borderRadius:
          BorderRadius.circular(17),

      border: Border.all(
        color:
            const Color(0xffffdfca),
      ),
    ),

    child: Row(
      children: [
        Container(
          width: 45,
          height: 45,

          decoration:
              BoxDecoration(
            color:
                color.withValues(
              alpha: 0.10,
            ),

            borderRadius:
                BorderRadius.circular(13),
          ),

          child: Icon(
            icon,
            color: color,
          ),
        ),

        const SizedBox(width: 13),

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
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style:
                    GoogleFonts.poppins(
                  color:
                      Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ==================================================================
// PROPERTY
// ==================================================================

class PropertySearchScreen
    extends StatelessWidget {
  const PropertySearchScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFFF8F1),

      appBar: AppBar(
        title: const Text("Property"),
        backgroundColor:
            const Color(0xffff6b16),
        foregroundColor:
            Colors.white,
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),

        children: [
          propertyOption(
            icon: Icons.key_rounded,
            title: "For Rent",
            subtitle:
                "Find houses, flats and properties for rent.",
          ),

          propertyOption(
            icon:
                Icons.assignment_rounded,
            title: "For Lease",
            subtitle:
                "Find properties available for lease.",
          ),

          propertyOption(
            icon: Icons.sell_rounded,
            title: "For Sale",
            subtitle:
                "Find properties available for purchase.",
          ),
        ],
      ),
    );
  }
}

Widget propertyOption({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Container(
    margin:
        const EdgeInsets.only(bottom: 14),

    padding:
        const EdgeInsets.all(20),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(20),
    ),

    child: Row(
      children: [
        Icon(
          icon,
          color: Colors.green,
          size: 32,
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
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style:
                    GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
        ),
      ],
    ),
  );
}

// ==================================================================
// WORKERS
// ==================================================================

class WorkerSearchScreen extends StatefulWidget {
  const WorkerSearchScreen({super.key});

  @override
  State<WorkerSearchScreen> createState() =>
      _WorkerSearchScreenState();
}

class _WorkerSearchScreenState
    extends State<WorkerSearchScreen> {

  // ================================================================
  // FORM
  // ================================================================

  final _formKey = GlobalKey<FormState>();

  // ================================================================
  // SERVICES
  // ================================================================

  final AuthService _authService =
      AuthService();

  final FirestoreService _firestoreService =
      FirestoreService();

  final OrderService _orderService =
      OrderService();

  // ================================================================
  // CURRENT USER
  // ================================================================

  UserModel? currentUser;

  bool isLoadingUser = true;

  bool isSubmitting = false;

  // ================================================================
  // TEXT CONTROLLERS
  // ================================================================

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController addressController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  // ================================================================
  // BOOKING VARIABLES
  // ================================================================

  String selectedService = "Electrician";

  DateTime? selectedDate;

  TimeOfDay? selectedTime;

  String urgency = "Normal";

  // ================================================================
  // WORKER LIST
  // ================================================================

  final List<Map<String, dynamic>> workers = [
    {
      "name": "Electrician",
      "icon": Icons.electrical_services,
    },
    {
      "name": "Plumber",
      "icon": Icons.plumbing,
    },
    {
      "name": "Carpenter",
      "icon": Icons.handyman,
    },
    {
      "name": "Painter",
      "icon": Icons.format_paint,
    },
    {
      "name": "Mechanic",
      "icon": Icons.car_repair,
    },
    {
      "name": "Cleaner",
      "icon": Icons.cleaning_services,
    },
    {
      "name": "AC Technician",
      "icon": Icons.ac_unit,
    },
    {
      "name": "Other Workers",
      "icon": Icons.engineering,
    },
  ];

  // ================================================================
  // INIT STATE
  // ================================================================

  @override
  void initState() {
    super.initState();

    loadCurrentUser();
  }

  // ================================================================
  // LOAD CURRENT USER
  // ================================================================

  Future<void> loadCurrentUser() async {
    try {
      final User? firebaseUser =
          _authService.currentUser;

      if (firebaseUser == null) {
        throw Exception(
          'No user is currently logged in.',
        );
      }

      final UserModel? user =
          await _firestoreService.getUser(
        firebaseUser.uid,
      );

      if (user == null) {
        throw Exception(
          'User profile was not found.',
        );
      }

      if (!mounted) return;

      setState(() {
        currentUser = user;

        // Automatically fill existing user details.
        nameController.text = user.name;
        phoneController.text = user.phone;
        emailController.text = user.email;

        isLoadingUser = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingUser = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load user details: $e',
          ),
        ),
      );
    }
  }

  // ================================================================
  // DISPOSE
  // ================================================================

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  // ================================================================
  // DATE PICKER
  // ================================================================

  Future<void> selectDate() async {
    final DateTime? pickedDate =
        await showDatePicker(
      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime.now(),

      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // ================================================================
  // TIME PICKER
  // ================================================================

  Future<void> selectTime() async {
    final TimeOfDay? pickedTime =
        await showTimePicker(
      context: context,

      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  // ================================================================
  // CONFIRM BOOKING
  // ================================================================

  Future<void> confirmBooking() async {

    // Prevent duplicate submissions.
    if (isSubmitting) {
      return;
    }

    // --------------------------------------------------------------
    // VALIDATE FORM
    // --------------------------------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // --------------------------------------------------------------
    // CHECK DATE
    // --------------------------------------------------------------

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a preferred date",
          ),
        ),
      );

      return;
    }

    // --------------------------------------------------------------
    // CHECK TIME
    // --------------------------------------------------------------

    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a preferred time",
          ),
        ),
      );

      return;
    }

    // --------------------------------------------------------------
    // CHECK USER
    // --------------------------------------------------------------

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to load your user details.",
          ),
        ),
      );

      return;
    }

    // --------------------------------------------------------------
    // START LOADING
    // --------------------------------------------------------------

    setState(() {
      isSubmitting = true;
    });

    try {

      // ============================================================
      // CREATE ORDER MODEL
      // ============================================================

      final OrderModel order =
          OrderModel(
        // Temporary ID.
        // OrderService generates the real Firestore ID.
        orderId: '',

        // ----------------------------------------------------------
        // USER INFORMATION
        // ----------------------------------------------------------

        userId:
            currentUser!.userId,

        userName:
            nameController.text.trim(),

        userPhone:
            phoneController.text.trim(),

        userEmail:
            emailController.text.trim(),

        // ----------------------------------------------------------
        // SERVICE
        // ----------------------------------------------------------

        serviceType:
            selectedService,

        // No worker assigned yet.
        serviceProviderId:
            null,

        // ----------------------------------------------------------
        // BOOKING DATE
        // ----------------------------------------------------------

        preferredDate:
            selectedDate!,

        // ----------------------------------------------------------
        // BOOKING TIME
        // ----------------------------------------------------------

        preferredTime:
            selectedTime!.format(context),

        // ----------------------------------------------------------
        // ADDRESS
        // ----------------------------------------------------------

        address:
            addressController.text.trim(),

        // ----------------------------------------------------------
        // URGENCY
        // ----------------------------------------------------------

        urgency:
            urgency.toLowerCase(),

        // ----------------------------------------------------------
        // DESCRIPTION
        // ----------------------------------------------------------

        description:
            descriptionController.text.trim(),

        // ----------------------------------------------------------
        // STATUS
        // ----------------------------------------------------------

        status:
            'pending',

        // ----------------------------------------------------------
        // CREATED DATE
        // ----------------------------------------------------------

        createdAt:
            DateTime.now(),
      );

      // ============================================================
      // SAVE ORDER TO FIRESTORE
      // ============================================================

      final String orderId =
          await _orderService.createOrder(
        order,
      );

      // ============================================================
      // CHECK SCREEN
      // ============================================================

      if (!mounted) {
        return;
      }

      // ============================================================
      // STOP LOADING
      // ============================================================

      setState(() {
        isSubmitting = false;
      });

      // ============================================================
      // SUCCESS DIALOG
      // ============================================================

      showDialog(
        context: context,

        builder: (context) {

          return AlertDialog(

            title: const Text(
              "Booking Submitted",
            ),

            content: Text(
              "Your $selectedService request "
              "has been submitted successfully.\n\n"
              "Order ID: $orderId\n\n"
              "The admin will review your request "
              "and contact you.",
            ),

            actions: [

              TextButton(
                onPressed: () {

                  Navigator.pop(context);
                },

                child: const Text(
                  "OK",
                ),
              ),
            ],
          );
        },
      );

    } catch (e) {

      // ============================================================
      // ERROR
      // ============================================================

      if (!mounted) {
        return;
      }

      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to submit booking: $e",
          ),
        ),
      );
    }
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xffFFF8F1),

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(

        title: const Text(
          "Find Workers",
        ),

        backgroundColor:
            const Color(0xffff6b16),

        foregroundColor:
            Colors.white,

        elevation: 0,
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: isLoadingUser

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : SingleChildScrollView(

              padding:
                  const EdgeInsets.all(16),

              child: Form(

                key: _formKey,

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // ==================================================
                    // TITLE
                    // ==================================================

                    Text(
                      "Select a Service",

                      style:
                          GoogleFonts.poppins(
                        fontSize: 20,

                        fontWeight:
                            FontWeight.w700,

                        color:
                            Colors.black87,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      "Choose the type of worker you need",

                      style:
                          GoogleFonts.poppins(
                        fontSize: 13,

                        color:
                            Colors.grey[600],
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // ==================================================
                    // WORKER GRID
                    // ==================================================

                    GridView.builder(

                      shrinkWrap: true,

                      physics:
                          const NeverScrollableScrollPhysics(),

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(

                        crossAxisCount:
                            2,

                        crossAxisSpacing:
                            14,

                        mainAxisSpacing:
                            14,

                        childAspectRatio:
                            1.15,
                      ),

                      itemCount:
                          workers.length,

                      itemBuilder:
                          (context, index) {

                        final worker =
                            workers[index];

                        final bool isSelected =
                            selectedService ==
                                worker["name"];

                        return GestureDetector(

                          onTap: () {

                            setState(() {

                              selectedService =
                                  worker["name"];
                            });
                          },

                          child: Container(

                            decoration:
                                BoxDecoration(

                              color:
                                  Colors.white,

                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),

                              border:
                                  Border.all(

                                color:
                                    isSelected

                                        ? const Color(
                                            0xffff6b16,
                                          )

                                        : Colors
                                            .transparent,

                                width:
                                    2,
                              ),

                              boxShadow: [

                                BoxShadow(

                                  color: Colors
                                      .black
                                      .withValues(
                                    alpha: 0.05,
                                  ),

                                  blurRadius:
                                      8,

                                  offset:
                                      const Offset(
                                    0,
                                    3,
                                  ),
                                ),
                              ],
                            ),

                            child: Column(

                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,

                              children: [

                                Container(

                                  padding:
                                      const EdgeInsets
                                          .all(
                                    12,
                                  ),

                                  decoration:
                                      BoxDecoration(

                                    color:
                                        isSelected

                                            ? const Color(
                                                0xffff6b16,
                                              ).withValues(
                                                alpha: 0.12,
                                              )

                                            : Colors
                                                .purple
                                                .withValues(
                                                alpha: 0.10,
                                              ),

                                    shape:
                                        BoxShape.circle,
                                  ),

                                  child: Icon(

                                    worker["icon"],

                                    size:
                                        32,

                                    color:

                                        isSelected

                                            ? const Color(
                                                0xffff6b16,
                                              )

                                            : Colors
                                                .purple,
                                  ),
                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                Text(

                                  worker["name"],

                                  textAlign:
                                      TextAlign.center,

                                  style:
                                      GoogleFonts.poppins(

                                    fontWeight:
                                        FontWeight.w600,

                                    fontSize:
                                        14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // ==================================================
                    // BOOKING FORM
                    // ==================================================

                    Container(

                      padding:
                          const EdgeInsets.all(
                        20,
                      ),

                      decoration:
                          BoxDecoration(

                        color:
                            Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          22,
                        ),

                        boxShadow: [

                          BoxShadow(

                            color: Colors
                                .black
                                .withValues(
                              alpha: 0.06,
                            ),

                            blurRadius:
                                12,

                            offset:
                                const Offset(
                              0,
                              4,
                            ),
                          ),
                        ],
                      ),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          // ==================================================
                          // FORM TITLE
                          // ==================================================

                          Text(

                            "Service Request",

                            style:
                                GoogleFonts.poppins(

                              fontSize:
                                  21,

                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(

                            "Provide the details of the service you require",

                            style:
                                GoogleFonts.poppins(

                              fontSize:
                                  12,

                              color:
                                  Colors.grey[600],
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ==================================================
                          // SELECTED SERVICE
                          // ==================================================

                          Text(

                            "Selected Service",

                            style:
                                GoogleFonts.poppins(

                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Container(

                            width:
                                double.infinity,

                            padding:
                                const EdgeInsets
                                    .symmetric(

                              horizontal:
                                  15,

                              vertical:
                                  14,
                            ),

                            decoration:
                                BoxDecoration(

                              color:
                                  const Color(
                                0xffff6b16,
                              ).withValues(
                                alpha: 0.08,
                              ),

                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),

                              border:
                                  Border.all(

                                color:
                                    const Color(
                                  0xffff6b16,
                                ),
                              ),
                            ),

                            child: Row(

                              children: [

                                const Icon(

                                  Icons.build,

                                  color:
                                      Color(
                                    0xffff6b16,
                                  ),
                                ),

                                const SizedBox(
                                  width: 10,
                                ),

                                Text(

                                  selectedService,

                                  style:
                                      GoogleFonts.poppins(

                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ==================================================
                          // NAME
                          // ==================================================

                          buildTextField(

                            controller:
                                nameController,

                            label:
                                "Full Name",

                            hint:
                                "Enter your name",

                            icon:
                                Icons.person,

                            validator:
                                (value) {

                              if (value ==
                                      null ||
                                  value
                                      .trim()
                                      .isEmpty) {

                                return "Please enter your name";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          // ==================================================
                          // PHONE
                          // ==================================================

                          buildTextField(

                            controller:
                                phoneController,

                            label:
                                "Phone Number",

                            hint:
                                "Enter your phone number",

                            icon:
                                Icons.phone,

                            keyboardType:
                                TextInputType.phone,

                            validator:
                                (value) {

                              if (value ==
                                      null ||
                                  value
                                      .trim()
                                      .isEmpty) {

                                return "Please enter phone number";
                              }

                              if (value
                                      .trim()
                                      .length <
                                  10) {

                                return "Enter a valid phone number";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          // ==================================================
                          // EMAIL
                          // ==================================================

                          buildTextField(

                            controller:
                                emailController,

                            label:
                                "Email",

                            hint:
                                "Enter your email",

                            icon:
                                Icons.email,

                            keyboardType:
                                TextInputType.emailAddress,

                            validator:
                                (value) {

                              if (value ==
                                      null ||
                                  value
                                      .trim()
                                      .isEmpty) {

                                return "Please enter email";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ==================================================
                          // DATE
                          // ==================================================

                          Text(

                            "Preferred Date",

                            style:
                                GoogleFonts.poppins(

                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          GestureDetector(

                            onTap:
                                selectDate,

                            child:
                                Container(

                              width:
                                  double.infinity,

                              padding:
                                  const EdgeInsets
                                      .symmetric(

                                horizontal:
                                    15,

                                vertical:
                                    15,
                              ),

                              decoration:
                                  BoxDecoration(

                                border:
                                    Border.all(

                                  color:
                                      Colors.grey[300]!,
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                              ),

                              child: Row(

                                children: [

                                  const Icon(

                                    Icons.calendar_month,

                                    color:
                                        Color(
                                      0xffff6b16,
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 12,
                                  ),

                                  Text(

                                    selectedDate ==
                                            null

                                        ? "Select preferred date"

                                        : "${selectedDate!.day}/"
                                          "${selectedDate!.month}/"
                                          "${selectedDate!.year}",

                                    style:
                                        GoogleFonts.poppins(

                                      color:
                                          selectedDate ==
                                                  null

                                              ? Colors.grey

                                              : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ==================================================
                          // TIME
                          // ==================================================

                          Text(

                            "Preferred Time",

                            style:
                                GoogleFonts.poppins(

                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          GestureDetector(

                            onTap:
                                selectTime,

                            child:
                                Container(

                              width:
                                  double.infinity,

                              padding:
                                  const EdgeInsets
                                      .symmetric(

                                horizontal:
                                    15,

                                vertical:
                                    15,
                              ),

                              decoration:
                                  BoxDecoration(

                                border:
                                    Border.all(

                                  color:
                                      Colors.grey[300]!,
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                              ),

                              child: Row(

                                children: [

                                  const Icon(

                                    Icons.access_time,

                                    color:
                                        Color(
                                      0xffff6b16,
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 12,
                                  ),

                                  Text(

                                    selectedTime ==
                                            null

                                        ? "Select preferred time"

                                        : selectedTime!
                                            .format(
                                            context,
                                          ),

                                    style:
                                        GoogleFonts.poppins(

                                      color:
                                          selectedTime ==
                                                  null

                                              ? Colors.grey

                                              : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ==================================================
                          // ADDRESS
                          // ==================================================

                          buildTextField(

                            controller:
                                addressController,

                            label:
                                "Full Address",

                            hint:
                                "Enter complete service address",

                            icon:
                                Icons.location_on,

                            maxLines:
                                3,

                            validator:
                                (value) {

                              if (value ==
                                      null ||
                                  value
                                      .trim()
                                      .isEmpty) {

                                return "Please enter service address";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ==================================================
                          // URGENCY
                          // ==================================================

                          Text(

                            "Urgency",

                            style:
                                GoogleFonts.poppins(

                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Column(

                            children: [

                              buildUrgencyOption(
                                "Normal",
                                "Can be handled normally",
                              ),

                              buildUrgencyOption(
                                "Priority",
                                "Needs attention soon",
                              ),

                              buildUrgencyOption(
                                "Emergency",
                                "Requires immediate attention",
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ==================================================
                          // DESCRIPTION
                          // ==================================================

                          buildTextField(

                            controller:
                                descriptionController,

                            label:
                                "Service Description",

                            hint:
                                "Describe the service or problem in detail",

                            icon:
                                Icons.description,

                            maxLines:
                                5,

                            validator:
                                (value) {

                              if (value ==
                                      null ||
                                  value
                                      .trim()
                                      .isEmpty) {

                                return "Please describe the required service";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 25,
                          ),

                          // ==================================================
                          // CONFIRM BOOKING
                          // ==================================================

                          SizedBox(

                            width:
                                double.infinity,

                            height:
                                55,

                            child:
                                ElevatedButton(

                              onPressed:
                                  isSubmitting
                                      ? null
                                      : confirmBooking,

                              style:
                                  ElevatedButton.styleFrom(

                                backgroundColor:
                                    const Color(
                                  0xffff6b16,
                                ),

                                foregroundColor:
                                    Colors.white,

                                disabledBackgroundColor:
                                    Colors.grey[400],

                                shape:
                                    RoundedRectangleBorder(

                                  borderRadius:
                                      BorderRadius.circular(
                                    14,
                                  ),
                                ),

                                elevation:
                                    0,
                              ),

                              child:
                                  isSubmitting

                                      ? const SizedBox(

                                          height:
                                              24,

                                          width:
                                              24,

                                          child:
                                              CircularProgressIndicator(

                                            strokeWidth:
                                                2.5,

                                            valueColor:
                                                AlwaysStoppedAnimation<
                                                    Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )

                                      : Text(

                                          "Confirm Booking",

                                          style:
                                              GoogleFonts.poppins(

                                            fontSize:
                                                16,

                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ================================================================
  // TEXT FIELD
  // ================================================================

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(

          label,

          style:
              GoogleFonts.poppins(

            fontWeight:
                FontWeight.w600,
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        TextFormField(

          controller:
              controller,

          keyboardType:
              keyboardType,

          maxLines:
              maxLines,

          validator:
              validator,

          decoration:
              InputDecoration(

            hintText:
                hint,

            prefixIcon:
                Icon(

              icon,

              color:
                  const Color(
                0xffff6b16,
              ),
            ),

            filled:
                true,

            fillColor:
                const Color(
              0xffFAFAFA,
            ),

            border:
                OutlineInputBorder(

              borderRadius:
                  BorderRadius.circular(
                12,
              ),

              borderSide:
                  BorderSide.none,
            ),

            enabledBorder:
                OutlineInputBorder(

              borderRadius:
                  BorderRadius.circular(
                12,
              ),

              borderSide:
                  BorderSide(

                color:
                    Colors.grey[300]!,
              ),
            ),

            focusedBorder:
                OutlineInputBorder(

              borderRadius:
                  BorderRadius.circular(
                12,
              ),

              borderSide:
                  const BorderSide(

                color:
                    Color(
                  0xffff6b16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // URGENCY OPTION
  // ================================================================

  Widget buildUrgencyOption(
    String value,
    String subtitle,
  ) {

    return RadioListTile<String>(

      value:
          value,

      groupValue:
          urgency,

      onChanged:
          (newValue) {

        setState(() {

          urgency =
              newValue!;
        });
      },

      title:
          Text(

        value,

        style:
            GoogleFonts.poppins(

          fontWeight:
              FontWeight.w600,
        ),
      ),

      subtitle:
          Text(

        subtitle,

        style:
            GoogleFonts.poppins(

          fontSize:
              11,
        ),
      ),

      activeColor:
          const Color(
        0xffff6b16,
      ),

      contentPadding:
          EdgeInsets.zero,
    );
  }
}

// ==================================================================
// TRAVEL
// ==================================================================

class TravelScreen
    extends StatelessWidget {
  const TravelScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFFF8F1),

      appBar: AppBar(
        title: const Text("Travel"),
        backgroundColor:
            const Color(0xffff6b16),
        foregroundColor:
            Colors.white,
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),

        children: [
          travelOption(
            icon:
                Icons.person_rounded,
            title: "Hire Driver",
            subtitle:
                "Hire only a driver for your journey.",
          ),

          travelOption(
            icon:
                Icons.directions_car_rounded,
            title: "Hire Vehicle",
            subtitle:
                "Choose Auto, Car, Tempo or another vehicle.",
          ),

          travelOption(
            icon:
                Icons.map_rounded,
            title: "Plan a Trip",
            subtitle:
                "Enter destination, duration, members and requirements.",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const TripPlanningScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget travelOption({
  required IconData icon,
  required String title,
  required String subtitle,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,

    child: Container(
      margin:
          const EdgeInsets.only(bottom: 14),

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,

            decoration:
                BoxDecoration(
              color:
                  Colors.blue.withValues(
                alpha: 0.12,
              ),
              borderRadius:
                  BorderRadius.circular(15),
            ),

            child: Icon(
              icon,
              color: Colors.blue,
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
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style:
                      GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15,
          ),
        ],
      ),
    ),
  );
}

// ==================================================================
// TRIP PLANNING
// ==================================================================

class TripPlanningScreen
    extends StatefulWidget {
  const TripPlanningScreen({
    super.key,
  });

  @override
  State<TripPlanningScreen> createState() =>
      _TripPlanningScreenState();
}

class _TripPlanningScreenState
    extends State<TripPlanningScreen> {
  final fromController =
      TextEditingController();

  final destinationController =
      TextEditingController();

  final daysController =
      TextEditingController();

  final membersController =
      TextEditingController();

  String vehicle = "Car";

  bool driverRequired = false;

  @override
  void dispose() {
    fromController.dispose();
    destinationController.dispose();
    daysController.dispose();
    membersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFFF8F1),

      appBar: AppBar(
        title:
            const Text("Plan a Trip"),
        backgroundColor:
            const Color(0xffff6b16),
        foregroundColor:
            Colors.white,
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              "Tell us about your trip",
              style:
                  GoogleFonts.poppins(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "Enter your requirements and find suitable travel options.",
              style:
                  GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 25),

            tripField(
              controller:
                  fromController,
              label: "From",
              icon:
                  Icons.trip_origin,
            ),

            const SizedBox(height: 15),

            tripField(
              controller:
                  destinationController,
              label: "Destination",
              icon:
                  Icons.location_on_rounded,
            ),

            const SizedBox(height: 15),

            tripField(
              controller:
                  daysController,
              label: "Number of Days",
              icon:
                  Icons.calendar_month_rounded,
              keyboardType:
                  TextInputType.number,
            ),

            const SizedBox(height: 15),

            tripField(
              controller:
                  membersController,
              label: "Number of Members",
              icon:
                  Icons.people_rounded,
              keyboardType:
                  TextInputType.number,
            ),

            const SizedBox(height: 20),

            Text(
              "Vehicle",
              style:
                  GoogleFonts.poppins(
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: vehicle,

              decoration:
                  InputDecoration(
                prefixIcon:
                    const Icon(
                  Icons
                      .directions_car_rounded,
                ),

                filled: true,

                fillColor:
                    Colors.white,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                  borderSide:
                      BorderSide.none,
                ),
              ),

              items: const [
                DropdownMenuItem(
                  value: "Auto",
                  child:
                      Text("Auto"),
                ),
                DropdownMenuItem(
                  value: "Car",
                  child:
                      Text("Car"),
                ),
                DropdownMenuItem(
                  value: "Tempo",
                  child:
                      Text("Tempo"),
                ),
                DropdownMenuItem(
                  value: "JCB",
                  child:
                      Text("JCB"),
                ),
                DropdownMenuItem(
                  value: "Other",
                  child:
                      Text("Other"),
                ),
              ],

              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  vehicle = value;
                });
              },
            ),

            const SizedBox(height: 15),

            Container(
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),

              child:
                  SwitchListTile(
                title: Text(
                  "Driver Required",
                  style:
                      GoogleFonts.poppins(
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                subtitle:
                    const Text(
                  "I need a driver for this trip",
                ),

                value:
                    driverRequired,

                activeThumbColor:
                    const Color(
                  0xffF97316,
                ),

                onChanged:
                    (value) {
                  setState(() {
                    driverRequired =
                        value;
                  });
                },
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width:
                  double.infinity,
              height: 55,

              child:
                  ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Trip request submitted.",
                      ),
                    ),
                  );
                },

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xffF97316,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),

                child:
                    Text(
                  "Find Travel Options",
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
    );
  }
}

// ==================================================================
// TRIP FIELD
// ==================================================================

Widget tripField({
  required TextEditingController
      controller,
  required String label,
  required IconData icon,
  TextInputType keyboardType =
      TextInputType.text,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,

    decoration:
        InputDecoration(
      labelText: label,

      prefixIcon: Icon(
        icon,
        color:
            const Color(0xffF97316),
      ),

      filled: true,

      fillColor: Colors.white,

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

// ==================================================================
// ANNOUNCEMENTS SCREEN
// ==================================================================

class AnnouncementsScreen
    extends StatelessWidget {
  const AnnouncementsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFFF8F1),

      appBar: AppBar(
        title:
            const Text("Announcements"),

        backgroundColor:
            const Color(0xffff6b16),

        foregroundColor:
            Colors.white,
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),

        children: [
          announcementCard(
            icon:
                Icons.power_rounded,
            color: Colors.orange,
            title:
                "Power Cut Updates",
            subtitle:
                "View electricity interruption and restoration updates.",
          ),

          announcementCard(
            icon:
                Icons.newspaper_rounded,
            color: Colors.blue,
            title:
                "Local News",
            subtitle:
                "Stay updated with important local news from Ranebennur.",
          ),

          announcementCard(
            icon:
                Icons.warning_rounded,
            color: Colors.red,
            title:
                "Emergency Alerts",
            subtitle:
                "Important emergency information and safety alerts.",
          ),

          announcementCard(
            icon:
                Icons.water_drop_rounded,
            color: Colors.cyan,
            title:
                "Water Supply",
            subtitle:
                "View water supply and interruption announcements.",
          ),

          announcementCard(
            icon:
                Icons.campaign_rounded,
            color: Colors.green,
            title:
                "City Announcements",
            subtitle:
                "Important announcements related to Ranebennur.",
          ),
        ],
      ),
    );
  }
}

Widget announcementCard({
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
}) {
  return Container(
    margin:
        const EdgeInsets.only(bottom: 14),

    padding:
        const EdgeInsets.all(17),

    decoration:
        BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(20),
    ),

    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,

          decoration:
              BoxDecoration(
            color:
                color.withValues(
              alpha: 0.12,
            ),
            borderRadius:
                BorderRadius.circular(15),
          ),

          child: Icon(
            icon,
            color: color,
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
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
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

        const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
          color: Colors.grey,
        ),
      ],
    ),
  );
}

// ==================================================================
// NEW IN CITY SCREEN
// ==================================================================

class NewInCityScreen
    extends StatelessWidget {
  const NewInCityScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFFF8F1),

      appBar: AppBar(
        title:
            const Text("New in City"),

        backgroundColor:
            const Color(0xffff6b16),

        foregroundColor:
            Colors.white,
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),

        children: [
          announcementCard(
            icon:
                Icons.store_rounded,
            color: Colors.orange,
            title:
                "New Businesses",
            subtitle:
                "Discover newly opened shops and businesses in Ranebennur.",
          ),

          announcementCard(
            icon:
                Icons.location_city_rounded,
            color: Colors.blue,
            title:
                "City Information",
            subtitle:
                "Important information and useful details about Ranebennur.",
          ),

          announcementCard(
            icon:
                Icons.local_offer_rounded,
            color: Colors.green,
            title:
                "Local Promotions",
            subtitle:
                "Special offers and promotional advertisements from local businesses.",
          ),

          announcementCard(
            icon:
                Icons.explore_rounded,
            color: Colors.purple,
            title:
                "Places & Services",
            subtitle:
                "Explore useful places and services available around the city.",
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// SOS SCREEN
// ==================================================================

class SOSScreen
    extends StatelessWidget {
  const SOSScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xfffff7f7),

      appBar: AppBar(
        title:
            const Text(
          "Emergency & Safety",
        ),

        backgroundColor:
            const Color(0xffD62828),

        foregroundColor:
            Colors.white,

        elevation: 0,
      ),

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [
            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(24),

              decoration:
                  BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xffB91C1C),
                    Color(0xffEF4444),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(
                  28,
                ),
              ),

              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,

                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),

                    child:
                        const Center(
                      child: Text(
                        "SOS",
                        style:
                            TextStyle(
                          color:
                              Colors.red,
                          fontSize: 30,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Help when every second matters",
                    textAlign:
                        TextAlign.center,

                    style:
                        GoogleFonts.poppins(
                      color:
                          Colors.white,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    "Quick access to emergency contacts and safety services.",
                    textAlign:
                        TextAlign.center,

                    style:
                        GoogleFonts.poppins(
                      color:
                          Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            GestureDetector(
              onTap: () {
                showEmergencyMessage(
                  context,
                  "Emergency 112 selected",
                );
              },

              child: Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 18,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xffD62828),

                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),
                ),

                child:
                    const Center(
                  child: Text(
                    "🆘  CALL 112 EMERGENCY",
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            GridView.count(
              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              crossAxisCount: 2,

              crossAxisSpacing: 14,
              mainAxisSpacing: 14,

              childAspectRatio: 1.1,

              children: [
                emergencyCard(
                  emoji: "🚓",
                  title: "Emergency",
                  number: "112",
                  onTap: () {
                    showEmergencyMessage(
                      context,
                      "Emergency 112",
                    );
                  },
                ),

                emergencyCard(
                  emoji: "🚑",
                  title: "Ambulance",
                  number: "108",
                  onTap: () {
                    showEmergencyMessage(
                      context,
                      "Ambulance 108",
                    );
                  },
                ),

                emergencyCard(
                  emoji: "🔥",
                  title: "Fire",
                  number: "101",
                  onTap: () {
                    showEmergencyMessage(
                      context,
                      "Fire 101",
                    );
                  },
                ),

                emergencyCard(
                  emoji: "👩",
                  title: "Women Safety",
                  number: "112",
                  onTap: () {
                    showEmergencyMessage(
                      context,
                      "Women Safety 112",
                    );
                  },
                ),

                emergencyCard(
                  emoji: "👧",
                  title: "Child Help",
                  number: "1098",
                  onTap: () {
                    showEmergencyMessage(
                      context,
                      "Child Help 1098",
                    );
                  },
                ),

                emergencyCard(
                  emoji: "🏥",
                  title: "Nearby Hospital",
                  number: "Find now",
                  onTap: () {
                    showEmergencyMessage(
                      context,
                      "Nearby hospitals",
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(20),

              decoration:
                  BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  22,
                ),

                border: Border.all(
                  color:
                      Colors.red.shade100,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    "🛡️  Women & Girls Safety",
                    style:
                        GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    "Save trusted contacts and quickly share your location when you need help.",
                    style:
                        GoogleFonts.poppins(
                      color:
                          Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 48,

                    child:
                        OutlinedButton(
                      onPressed: () {
                        showEmergencyMessage(
                          context,
                          "Trusted contacts feature",
                        );
                      },

                      child:
                          const Text(
                        "Manage Trusted Contacts",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// EMERGENCY CARD
// ==================================================================

Widget emergencyCard({
  required String emoji,
  required String title,
  required String number,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,

    child: Container(
      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border: Border.all(
          color:
              Colors.red.shade100,
        ),
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Text(
            emoji,
            style:
                const TextStyle(
              fontSize: 38,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style:
                GoogleFonts.poppins(
              fontWeight:
                  FontWeight.bold,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            number,
            style:
                GoogleFonts.poppins(
              color:
                  Colors.red.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

// ==================================================================
// EMERGENCY MESSAGE
// ==================================================================

void showEmergencyMessage(
  BuildContext context,
  String message,
) {
  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor:
          const Color(0xffD62828),
    ),
  );
}