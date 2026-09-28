import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FunctionHallScreen extends StatefulWidget {
  const FunctionHallScreen({super.key});

  @override
  State<FunctionHallScreen> createState() =>
      _FunctionHallScreenState();
}

class _FunctionHallScreenState
    extends State<FunctionHallScreen> {
  static const Color orange = Color(0xffF97316);
  static const Color purple = Color(0xff7C3AED);

  final TextEditingController locationController =
      TextEditingController();

  String eventType = "Wedding";
  String guestCount = "100 - 300";
  String serviceRequired = "Hall Only";
  DateTime? eventDate;

  final List<String> eventTypes = [
    "Wedding",
    "Birthday",
    "Engagement",
    "Reception",
    "Naming Ceremony",
    "Corporate Event",
    "Meeting",
    "Party",
    "Other",
  ];

  final List<String> guestCounts = [
    "Below 50",
    "50 - 100",
    "100 - 300",
    "300 - 500",
    "500 - 1000",
    "1000+",
  ];

  final List<String> services = [
    "Hall Only",
    "Hall + Catering",
    "Hall + Decoration",
    "Hall + Catering + Decoration",
    "Complete Event Package",
  ];

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  Future<void> selectEventDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(
        const Duration(days: 1),
      ),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (picked != null) {
      setState(() {
        eventDate = picked;
      });
    }
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  void searchHalls() {
    if (locationController.text.trim().isEmpty) {
      showMessage("Please enter your location.");
      return;
    }

    if (eventDate == null) {
      showMessage("Please select your event date.");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FunctionHallResultsScreen(
          location: locationController.text.trim(),
          eventType: eventType,
          guestCount: guestCount,
          serviceRequired: serviceRequired,
          eventDate: eventDate!,
        ),
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Function Halls & Events",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    purple,
                    Color(0xff6D28D9),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.celebration_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Plan Your Event",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Find nearby function halls and event services.",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Text(
              "Event Requirements",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // LOCATION
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: "Location",
                hintText: "Enter area or locality",
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                  color: purple,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // EVENT TYPE
            DropdownButtonFormField<String>(
              initialValue: eventType,
              decoration: inputDecoration(
                "Type of Event",
                Icons.event_rounded,
              ),
              items: eventTypes.map((event) {
                return DropdownMenuItem(
                  value: event,
                  child: Text(event),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  eventType = value;
                });
              },
            ),

            const SizedBox(height: 15),

            // GUEST COUNT
            DropdownButtonFormField<String>(
              initialValue: guestCount,
              decoration: inputDecoration(
                "Number of Guests",
                Icons.groups_rounded,
              ),
              items: guestCounts.map((count) {
                return DropdownMenuItem(
                  value: count,
                  child: Text(count),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  guestCount = value;
                });
              },
            ),

            const SizedBox(height: 15),

            // DATE
            InkWell(
              onTap: selectEventDate,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: purple,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        eventDate == null
                            ? "Select Event Date"
                            : formatDate(eventDate!),
                        style: GoogleFonts.poppins(
                          color: eventDate == null
                              ? Colors.grey.shade600
                              : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            Text(
              "Services Required",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: serviceRequired,
              decoration: inputDecoration(
                "Required Services",
                Icons.room_service_rounded,
              ),
              items: services.map((service) {
                return DropdownMenuItem(
                  value: service,
                  child: Text(
                    service,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  serviceRequired = value;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: searchHalls,
                icon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  "Find Nearby Function Halls",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: purple,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}

// ================================================================
// FUNCTION HALL RESULTS
// ================================================================

class FunctionHallResultsScreen extends StatelessWidget {
  final String location;
  final String eventType;
  final String guestCount;
  final String serviceRequired;
  final DateTime eventDate;

  const FunctionHallResultsScreen({
    super.key,
    required this.location,
    required this.eventType,
    required this.guestCount,
    required this.serviceRequired,
    required this.eventDate,
  });

  static const Color purple = Color(0xff7C3AED);

  @override
  Widget build(BuildContext context) {
    final halls = [
      {
        "name": "Royal Celebration Hall",
        "area": location,
        "capacity": "500 Guests",
        "price": "₹25,000 / Day",
        "rating": "4.7",
      },
      {
        "name": "Sri Lakshmi Function Hall",
        "area": location,
        "capacity": "300 Guests",
        "price": "₹18,000 / Day",
        "rating": "4.5",
      },
      {
        "name": "Grand Palace Convention Hall",
        "area": location,
        "capacity": "1000 Guests",
        "price": "₹40,000 / Day",
        "rating": "4.8",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        title: Text(
          "Nearby Function Halls",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: halls.length,
        itemBuilder: (context, index) {
          return hallCard(
            context,
            halls[index],
          );
        },
      ),
    );
  }

  Widget hallCard(
    BuildContext context,
    Map<String, String> hall,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: purple,
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
                      hall["name"]!,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      hall["area"]!,
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                "★ ${hall["rating"]}",
                style: GoogleFonts.poppins(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              const Icon(
                Icons.groups_outlined,
                size: 19,
                color: purple,
              ),
              const SizedBox(width: 8),
              Text(
                hall["capacity"]!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.currency_rupee,
                size: 19,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                hall["price"]!,
                style: GoogleFonts.poppins(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FunctionHallBookingScreen(
                      hallName: hall["name"]!,
                      price: hall["price"]!,
                      eventType: eventType,
                      guestCount: guestCount,
                      serviceRequired:
                          serviceRequired,
                    ),
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
                "Request Booking",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// FUNCTION HALL BOOKING
// ================================================================

class FunctionHallBookingScreen
    extends StatelessWidget {
  final String hallName;
  final String price;
  final String eventType;
  final String guestCount;
  final String serviceRequired;

  const FunctionHallBookingScreen({
    super.key,
    required this.hallName,
    required this.price,
    required this.eventType,
    required this.guestCount,
    required this.serviceRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        title: const Text("Booking Request"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    hallName,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  detailRow(
                    "Event",
                    eventType,
                  ),

                  detailRow(
                    "Guests",
                    guestCount,
                  ),

                  detailRow(
                    "Services",
                    serviceRequired,
                  ),

                  detailRow(
                    "Hall Price",
                    price,
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Function hall booking request submitted successfully.",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xff7C3AED),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "Submit Booking Request",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
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

  Widget detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}