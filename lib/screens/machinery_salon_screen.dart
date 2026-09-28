import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MachineryScreen extends StatefulWidget {
  const MachineryScreen({super.key});

  @override
  State<MachineryScreen> createState() => _MachineryScreenState();
}

class _MachineryScreenState extends State<MachineryScreen> {
  static const Color orange = Color(0xffF97316);

  String selectedMachine = "JCB";
  String selectedWork = "Construction Work";
  String selectedHours = "2 Hours";

  DateTime? selectedDate;

  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  final List<String> machines = [
    "JCB",
    "Truck",
    "Tractor",
    "Crane",
    "Excavator",
    "Tanker",
    "Loader",
    "Other",
  ];

  final List<String> works = [
    "Construction Work",
    "Road Work",
    "Agricultural Work",
    "Transportation",
    "Digging",
    "Loading / Unloading",
    "Demolition",
    "Other",
  ];

  final List<String> hours = [
    "1 Hour",
    "2 Hours",
    "3 Hours",
    "4 Hours",
    "5 Hours",
    "6 Hours",
    "8 Hours",
    "Full Day",
  ];

  @override
  void dispose() {
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 90),
      ),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String getEstimatedPrice() {
    switch (selectedMachine) {
      case "JCB":
        return "₹1,200 / hour";
      case "Truck":
        return "₹1,000 / hour";
      case "Tractor":
        return "₹800 / hour";
      case "Crane":
        return "₹2,500 / hour";
      case "Excavator":
        return "₹2,000 / hour";
      case "Tanker":
        return "₹1,200 / hour";
      case "Loader":
        return "₹1,500 / hour";
      default:
        return "Price on request";
    }
  }

  void submitRequest() {
    if (locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your location."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select the required date."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Request Submitted",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Your $selectedMachine booking request has been submitted successfully.\n\nOur team will contact you regarding availability and final pricing.",
            style: GoogleFonts.poppins(
              fontSize: 13,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
              ),
              child: const Text(
                "OK",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Machinery Booking",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),

            const SizedBox(height: 25),

            _sectionTitle("What do you need?"),

            const SizedBox(height: 12),

            _dropdown(
              value: selectedWork,
              items: works,
              icon: Icons.work_outline_rounded,
              label: "Type of Work",
              onChanged: (value) {
                setState(() {
                  selectedWork = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            _dropdown(
              value: selectedMachine,
              items: machines,
              icon: Icons.agriculture_rounded,
              label: "Select Machinery",
              onChanged: (value) {
                setState(() {
                  selectedMachine = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            _dropdown(
              value: selectedHours,
              items: hours,
              icon: Icons.access_time_rounded,
              label: "Required Duration",
              onChanged: (value) {
                setState(() {
                  selectedHours = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            _datePicker(),

            const SizedBox(height: 15),

            _textField(
              controller: locationController,
              label: "Work Location",
              icon: Icons.location_on_outlined,
            ),

            const SizedBox(height: 15),

            _textField(
              controller: descriptionController,
              label: "Additional Requirements",
              icon: Icons.description_outlined,
              maxLines: 4,
            ),

            const SizedBox(height: 20),

            _priceCard(),

            const SizedBox(height: 25),

            _sectionTitle("Nearby Machinery"),

            const SizedBox(height: 12),

            _machineryCard(
              "Sri Sai Machinery",
              "JCB • Tractor • Loader",
              "2.1 km",
              "Available",
            ),

            _machineryCard(
              "Ranebennur Earth Movers",
              "JCB • Excavator • Crane",
              "3.4 km",
              "Available",
            ),

            _machineryCard(
              "Shree Ganesh Transport",
              "Truck • Tractor • Tanker",
              "4.2 km",
              "Available",
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: submitRequest,
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  "Request Machinery Booking",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xffF97316),
            Color(0xffEA580C),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.agriculture_rounded,
            color: Colors.white,
            size: 45,
          ),
          const SizedBox(height: 12),
          Text(
            "Book Machinery",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Find machinery and vehicles for your work near you.",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: orange,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _datePicker() {
    return InkWell(
      onTap: selectDate,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: orange,
            ),
            const SizedBox(width: 12),
            Text(
              selectedDate == null
                  ? "Select Required Date"
                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              style: GoogleFonts.poppins(
                color: selectedDate == null
                    ? Colors.grey
                    : Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: orange,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _priceCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: orange.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.currency_rupee_rounded,
            color: orange,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Estimated Price",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  getEstimatedPrice(),
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _machineryCard(
    String name,
    String machines,
    String distance,
    String availability,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              color: orange,
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
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  machines,
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                Text(
                  distance,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            availability,
            style: GoogleFonts.poppins(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SALON SCREEN
// ================================================================

class SalonScreen extends StatefulWidget {
  const SalonScreen({super.key});

  @override
  State<SalonScreen> createState() => _SalonScreenState();
}

class _SalonScreenState extends State<SalonScreen> {
  static const Color pink = Color(0xffDB2777);

  String selectedService = "Haircut";
  String selectedTime = "10:00 AM";

  DateTime? selectedDate;

  final List<String> services = [
    "Haircut",
    "Hair Styling",
    "Hair Colour",
    "Facial",
    "Beard Styling",
    "Manicure",
    "Pedicure",
    "Bridal Makeup",
    "Hair + Facial",
  ];

  final List<String> timeSlots = [
    "9:00 AM",
    "10:00 AM",
    "11:00 AM",
    "12:00 PM",
    "1:00 PM",
    "2:00 PM",
    "3:00 PM",
    "4:00 PM",
    "5:00 PM",
    "6:00 PM",
    "7:00 PM",
  ];

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 90),
      ),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String getPrice() {
    switch (selectedService) {
      case "Haircut":
        return "₹150";
      case "Hair Styling":
        return "₹300";
      case "Hair Colour":
        return "₹800";
      case "Facial":
        return "₹500";
      case "Beard Styling":
        return "₹150";
      case "Manicure":
        return "₹300";
      case "Pedicure":
        return "₹400";
      case "Bridal Makeup":
        return "₹3,500";
      case "Hair + Facial":
        return "₹700";
      default:
        return "Price on request";
    }
  }

  void bookAppointment() {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an appointment date."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Appointment Requested",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Your appointment request for $selectedService at $selectedTime has been submitted.",
            style: GoogleFonts.poppins(
              fontSize: 13,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: pink,
              ),
              child: const Text(
                "Done",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFDF7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Salon & Beauty",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),

            const SizedBox(height: 25),

            Text(
              "Book a Service",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _serviceDropdown(),

            const SizedBox(height: 15),

            _datePicker(),

            const SizedBox(height: 15),

            _timeDropdown(),

            const SizedBox(height: 20),

            _priceCard(),

            const SizedBox(height: 25),

            Text(
              "Nearby Salons",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _salonCard(
              "Looks Unisex Salon",
              "Main Road, Ranebennur",
              "1.2 km",
              "4.7",
            ),

            _salonCard(
              "Style Studio",
              "PB Road, Ranebennur",
              "2.3 km",
              "4.6",
            ),

            _salonCard(
              "Green Trends Salon",
              "Market Road, Ranebennur",
              "3.1 km",
              "4.8",
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: bookAppointment,
                icon: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  "Book Appointment",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xffDB2777),
            Color(0xffBE185D),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.content_cut_rounded,
            color: Colors.white,
            size: 45,
          ),
          const SizedBox(height: 12),
          Text(
            "Salon & Beauty Services",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Find nearby salons and book your preferred service.",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedService,
      decoration: InputDecoration(
        labelText: "Select Service",
        prefixIcon: const Icon(
          Icons.content_cut_rounded,
          color: pink,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      items: services.map((service) {
        return DropdownMenuItem(
          value: service,
          child: Text(service),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedService = value!;
        });
      },
    );
  }

  Widget _timeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedTime,
      decoration: InputDecoration(
        labelText: "Select Time Slot",
        prefixIcon: const Icon(
          Icons.access_time_rounded,
          color: pink,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      items: timeSlots.map((time) {
        return DropdownMenuItem(
          value: time,
          child: Text(time),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedTime = value!;
        });
      },
    );
  }

  Widget _datePicker() {
    return InkWell(
      onTap: selectDate,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: pink,
            ),
            const SizedBox(width: 12),
            Text(
              selectedDate == null
                  ? "Select Appointment Date"
                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              style: GoogleFonts.poppins(
                color: selectedDate == null
                    ? Colors.grey
                    : Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: pink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: pink.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.currency_rupee_rounded,
            color: pink,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Service Price",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  getPrice(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: pink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _salonCard(
    String name,
    String address,
    String distance,
    String rating,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: pink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.content_cut_rounded,
              color: pink,
              size: 27,
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
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$distance away",
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Colors.amber,
                size: 20,
              ),
              Text(
                rating,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}