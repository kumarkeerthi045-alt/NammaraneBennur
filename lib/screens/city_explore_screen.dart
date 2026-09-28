import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CityExploreScreen extends StatelessWidget {
  const CityExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

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
          "Explore Ranebennur",
          style: GoogleFonts.poppins(
            color: const Color(0xffF97316),
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(16, 5, 16, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              // ======================================================
              // HEADER
              // ======================================================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xffF97316),
                      Color(0xffEA580C),
                    ],

                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(25),

                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffF97316)
                          .withValues(alpha: 0.20),

                      blurRadius: 15,

                      offset: const Offset(0, 7),
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
                            BorderRadius.circular(18),
                      ),

                      child: const Icon(
                        Icons.location_city_rounded,
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
                            "Namma Ranebennur",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "Everything happening around your city",
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

              const SizedBox(height: 28),

              // ======================================================
              // SECTION TITLE
              // ======================================================

              Text(
                "Explore",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Choose what you want to discover",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 18),

              // ======================================================
              // NEW IN CITY
              // ======================================================

              exploreCard(
                context: context,

                icon: Icons.new_releases_rounded,

                color: Colors.blue,

                title: "New in City",

                subtitle:
                    "Discover new businesses, places, services, offers and city information.",

                onTap: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                          const NewInCityScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              // ======================================================
              // ANNOUNCEMENTS
              // ======================================================

              exploreCard(
                context: context,

                icon: Icons.campaign_rounded,

                color: Colors.orange,

                title: "Announcements",

                subtitle:
                    "Power cuts, emergency alerts, local news, water supply and important updates.",

                onTap: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                          const AnnouncementsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              // ======================================================
              // FIND FOR ME
              // ======================================================

              exploreCard(
                context: context,

                icon: Icons.manage_search_rounded,

                color: Colors.green,

                title: "Find for Me",

                subtitle:
                    "Find properties, workers, drivers, vehicles and travel services.",

                onTap: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                          const FindForMeScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // ======================================================
              // QUICK INFORMATION
              // ======================================================

              Text(
                "Quick Information",
                style: GoogleFonts.poppins(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [

                  Expanded(
                    child: quickCard(
                      icon: Icons.business_rounded,
                      title: "Businesses",
                      subtitle: "Local businesses",
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: quickCard(
                      icon: Icons.event_rounded,
                      title: "Events",
                      subtitle: "City events",
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [

                  Expanded(
                    child: quickCard(
                      icon: Icons.local_offer_rounded,
                      title: "Offers",
                      subtitle: "Local promotions",
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: quickCard(
                      icon: Icons.info_outline_rounded,
                      title: "City Info",
                      subtitle: "Useful information",
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ======================================================
              // FOOTER
              // ======================================================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Row(
                  children: [

                    Container(
                      padding:
                          const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: const Color(0xffffeee2),

                        borderRadius:
                            BorderRadius.circular(15),
                      ),

                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xffF97316),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            "Made for Ranebennur",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            "Your city. Your information. Your services.",
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 10,
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
      ),
    );
  }

  // ================================================================
  // EXPLORE CARD
  // ================================================================

  static Widget exploreCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(22),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(22),

        child: Container(
          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(22),

            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),

          child: Row(
            children: [

              // Icon

              Container(
                width: 58,
                height: 58,

                decoration: BoxDecoration(
                  color:
                      color.withValues(alpha: 0.12),

                  borderRadius:
                      BorderRadius.circular(17),
                ),

                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),

              const SizedBox(width: 15),

              // Text

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      maxLines: 3,

                      overflow:
                          TextOverflow.ellipsis,

                      style: GoogleFonts.poppins(
                        color:
                            Colors.grey.shade600,

                        fontSize: 11,

                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_ios_rounded,

                size: 16,

                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // QUICK CARD
  // ================================================================

  static Widget quickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),
      ),

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

          const SizedBox(height: 12),

          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// NEW IN CITY SCREEN
// ==================================================================

class NewInCityScreen extends StatelessWidget {
  const NewInCityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      appBar: AppBar(
        title: Text(
          "New in City",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Colors.transparent,

        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          cityInfoCard(
            icon: Icons.store_rounded,
            color: Colors.orange,
            title: "New Businesses",
            subtitle:
                "Discover newly opened shops and businesses in Ranebennur.",
          ),

          cityInfoCard(
            icon: Icons.location_city_rounded,
            color: Colors.blue,
            title: "City Information",
            subtitle:
                "View useful information and basic details about Ranebennur.",
          ),

          cityInfoCard(
            icon: Icons.local_offer_rounded,
            color: Colors.green,
            title: "Local Promotions",
            subtitle:
                "Explore offers and promotional advertisements from local businesses.",
          ),

          cityInfoCard(
            icon: Icons.explore_rounded,
            color: Colors.purple,
            title: "Places & Services",
            subtitle:
                "Discover useful places and services available around the city.",
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// ANNOUNCEMENTS SCREEN
// ==================================================================

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      appBar: AppBar(
        title: Text(
          "Announcements",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Colors.transparent,

        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          cityInfoCard(
            icon: Icons.power_rounded,
            color: Colors.orange,
            title: "Power Cut Updates",
            subtitle:
                "View electricity interruption and restoration updates.",
          ),

          cityInfoCard(
            icon: Icons.newspaper_rounded,
            color: Colors.blue,
            title: "Local News",
            subtitle:
                "Stay updated with important local news from Ranebennur.",
          ),

          cityInfoCard(
            icon: Icons.warning_rounded,
            color: Colors.red,
            title: "Emergency Alerts",
            subtitle:
                "Important emergency information and safety alerts.",
          ),

          cityInfoCard(
            icon: Icons.water_drop_rounded,
            color: Colors.cyan,
            title: "Water Supply",
            subtitle:
                "View water supply and interruption announcements.",
          ),

          cityInfoCard(
            icon: Icons.campaign_rounded,
            color: Colors.green,
            title: "City Announcements",
            subtitle:
                "Important announcements related to Ranebennur.",
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// FIND FOR ME SCREEN
// ==================================================================

class FindForMeScreen extends StatelessWidget {
  const FindForMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      appBar: AppBar(
        title: Text(
          "Find for Me",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Colors.transparent,

        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          findOption(
            context,

            icon: Icons.home_work_rounded,

            color: Colors.green,

            title: "Property",

            subtitle:
                "Find properties available for rent, lease or sale.",

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

            icon: Icons.handyman_rounded,

            color: Colors.purple,

            title: "Workers",

            subtitle:
                "Find electricians, plumbers, carpenters and other workers.",

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

            icon: Icons.directions_car_rounded,

            color: Colors.blue,

            title: "Travel",

            subtitle:
                "Find drivers, vehicles or plan a trip.",

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
        ],
      ),
    );
  }
}

// ==================================================================
// PROPERTY SCREEN
// ==================================================================

class PropertySearchScreen extends StatelessWidget {
  const PropertySearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      appBar: AppBar(
        title: Text(
          "Property",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Colors.transparent,

        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          propertyOption(
            icon: Icons.key_rounded,

            title: "For Rent",

            subtitle:
                "Find houses, flats and properties available for rent.",
          ),

          propertyOption(
            icon: Icons.assignment_rounded,

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

// ==================================================================
// WORKER SCREEN
// ==================================================================

class WorkerSearchScreen extends StatelessWidget {
  const WorkerSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workers = [
      ["Electrician", Icons.electrical_services],
      ["Plumber", Icons.plumbing],
      ["Carpenter", Icons.handyman],
      ["Painter", Icons.format_paint],
      ["Mechanic", Icons.car_repair],
      ["Cleaner", Icons.cleaning_services],
      ["AC Technician", Icons.ac_unit],
      ["Other Workers", Icons.engineering],
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      appBar: AppBar(
        title: Text(
          "Workers",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Colors.transparent,

        elevation: 0,
      ),

      body: GridView.builder(
        padding: const EdgeInsets.all(16),

        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,

          crossAxisSpacing: 14,

          mainAxisSpacing: 14,

          childAspectRatio: 1.15,
        ),

        itemCount: workers.length,

        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                Icon(
                  workers[index][1] as IconData,

                  size: 35,

                  color: Colors.purple,
                ),

                const SizedBox(height: 10),

                Text(
                  workers[index][0] as String,

                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================================================================
// TRAVEL SCREEN
// ==================================================================

class TravelScreen extends StatelessWidget {
  const TravelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      appBar: AppBar(
        title: Text(
          "Travel",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Colors.transparent,

        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          travelOption(
            icon: Icons.person_rounded,

            title: "Hire Driver",

            subtitle:
                "Hire only a driver for your journey.",
          ),

          travelOption(
            icon: Icons.directions_car_rounded,

            title: "Hire Vehicle",

            subtitle:
                "Choose Auto, Car, Tempo or another vehicle.",
          ),

          travelOption(
            icon: Icons.map_rounded,

            title: "Plan a Trip",

            subtitle:
                "Enter destination, duration, members and travel requirements.",

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

// ==================================================================
// TRIP PLANNING SCREEN
// ==================================================================

class TripPlanningScreen extends StatefulWidget {
  const TripPlanningScreen({super.key});

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
      backgroundColor: const Color(0xffF7F8FC),

      appBar: AppBar(
        title: Text(
          "Plan a Trip",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Colors.transparent,

        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              "Tell us about your trip",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "Enter your requirements and find suitable travel options.",
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 25),

            tripField(
              controller: fromController,

              label: "From",

              icon: Icons.trip_origin,
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
              controller: daysController,

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

              icon: Icons.people_rounded,

              keyboardType:
                  TextInputType.number,
            ),

            const SizedBox(height: 20),

            Text(
              "Vehicle",

              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: vehicle,

              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.directions_car_rounded,
                ),

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),

                  borderSide: BorderSide.none,
                ),
              ),

              items: const [

                DropdownMenuItem(
                  value: "Auto",
                  child: Text("Auto"),
                ),

                DropdownMenuItem(
                  value: "Car",
                  child: Text("Car"),
                ),

                DropdownMenuItem(
                  value: "Tempo",
                  child: Text("Tempo"),
                ),

                DropdownMenuItem(
                  value: "Other",
                  child: Text("Other"),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  vehicle = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: SwitchListTile(
                title: Text(
                  "Driver Required",

                  style: GoogleFonts.poppins(
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                subtitle: const Text(
                  "I need a driver for this trip",
                ),

                value: driverRequired,

                activeThumbColor:
                    const Color(0xffF97316),

                onChanged: (value) {
                  setState(() {
                    driverRequired = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              height: 55,

              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
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
                      const Color(0xffF97316),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),

                child: Text(
                  "Find Travel Options",

                  style: GoogleFonts.poppins(
                    color: Colors.white,

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
// REUSABLE CITY INFORMATION CARD
// ==================================================================

Widget cityInfoCard({
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
}) {
  return Container(
    margin:
        const EdgeInsets.only(bottom: 14),

    padding: const EdgeInsets.all(17),

    decoration: BoxDecoration(
      color: Colors.white,

      borderRadius:
          BorderRadius.circular(20),
    ),

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

                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,

                style: GoogleFonts.poppins(
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
          const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(22),
      ),

      child: Row(
        children: [

          Container(
            width: 58,
            height: 58,

            decoration: BoxDecoration(
              color:
                  color.withValues(alpha: 0.12),

              borderRadius:
                  BorderRadius.circular(17),
            ),

            child: Icon(
              icon,
              color: color,
              size: 30,
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
                    fontWeight:
                        FontWeight.bold,

                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,

                  style: GoogleFonts.poppins(
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

            size: 16,

            color: Colors.grey,
          ),
        ],
      ),
    ),
  );
}

// ==================================================================
// PROPERTY OPTION
// ==================================================================

Widget propertyOption({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Container(
    margin:
        const EdgeInsets.only(bottom: 15),

    padding: const EdgeInsets.all(20),

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

                style: GoogleFonts.poppins(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,

                style: GoogleFonts.poppins(
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
// TRAVEL OPTION
// ==================================================================

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
          const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(20),

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

                  style: GoogleFonts.poppins(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,

                  style: GoogleFonts.poppins(
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
// TRIP FIELD
// ==================================================================

Widget tripField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType keyboardType =
      TextInputType.text,
}) {
  return TextField(
    controller: controller,

    keyboardType: keyboardType,

    decoration: InputDecoration(
      labelText: label,

      prefixIcon: Icon(
        icon,

        color: const Color(0xffF97316),
      ),

      filled: true,

      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),

        borderSide: BorderSide.none,
      ),
    ),
  );
}