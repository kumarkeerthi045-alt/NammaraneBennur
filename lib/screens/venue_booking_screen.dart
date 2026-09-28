import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/firestore_service.dart';

class VenueBookingScreen extends StatefulWidget {
  const VenueBookingScreen({super.key, required this.hotel, required this.kannada});
  final bool hotel;
  final bool kannada;

  @override
  State<VenueBookingScreen> createState() => _VenueBookingScreenState();
}

class _VenueBookingScreenState extends State<VenueBookingScreen> {
  QueryDocumentSnapshot<Map<String, dynamic>>? selected;
  bool showForm = false;
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final guests = TextEditingController();
  final rooms = TextEditingController(text: '1');
  final occasion = TextEditingController();
  final notes = TextEditingController();
  DateTime startDate = DateTime.now().add(const Duration(days: 1));
  DateTime endDate = DateTime.now().add(const Duration(days: 2));
  String timeSlot = 'Morning';
  String roomType = 'Standard Room';
  bool sending = false;

  String tr(String en, String kn) => widget.kannada ? kn : en;
  String get category => widget.hotel ? 'Hotel' : 'Function Hall';

  @override
  void initState() {
    super.initState();
    guests.text = widget.hotel ? '2' : '100';
  }

  @override
  void dispose() {
    for (final c in [name, phone, guests, rooms, occasion, notes]) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.hotel ? tr('Hotel Rooms', 'ಹೋಟೆಲ್ ಕೊಠಡಿಗಳು') : tr('Function Halls', 'ಫಂಕ್ಷನ್ ಹಾಲ್‌ಗಳು'))),
    body: selected == null ? venueList() : showForm ? bookingForm() : venueDetails(),
  );

  Widget venueList() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance.collection('businesses').where('category', isEqualTo: category).snapshots(),
    builder: (_, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      final items = (snapshot.data?.docs ?? []).where((doc) => doc.data()['acceptingBookings'] != false && doc.data()['verified'] != false).toList();
      return ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          CircleAvatar(radius: 29, backgroundColor: const Color(0xffffeadf), child: Icon(widget.hotel ? Icons.hotel_rounded : Icons.celebration_rounded, color: const Color(0xfff45b22), size: 32)),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.hotel ? tr('See room details', 'ಕೊಠಡಿ ವಿವರಗಳನ್ನು ನೋಡಿ') : tr('Find the right hall', 'ಸರಿಯಾದ ಹಾಲ್ ಹುಡುಕಿ'), style: GoogleFonts.poppins(fontSize: 21, fontWeight: FontWeight.w800)),
            Text(widget.hotel ? tr('Ask us to confirm availability.', 'ಲಭ್ಯತೆಯನ್ನು ದೃಢೀಕರಿಸಲು ವಿನಂತಿಸಿ.') : tr('Choose a hall and let us confirm your date.', 'ಹಾಲ್ ಆಯ್ಕೆಮಾಡಿ; ನಿಮ್ಮ ದಿನಾಂಕವನ್ನು ದೃಢೀಕರಿಸುತ್ತೇವೆ.'), style: const TextStyle(color: Colors.black54)),
          ])),
        ]),
        const SizedBox(height: 18),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xffffeadf), borderRadius: BorderRadius.circular(14)), child: Row(children: [Text('${items.length}', style: GoogleFonts.poppins(fontSize: 29, fontWeight: FontWeight.w800, color: const Color(0xfff45b22))), const SizedBox(width: 12), Text(widget.hotel ? tr('verified hotels\ncurrently listed', 'ಪರಿಶೀಲಿಸಿದ ಹೋಟೆಲ್‌ಗಳು') : tr('verified halls\ncurrently listed', 'ಪರಿಶೀಲಿಸಿದ ಹಾಲ್‌ಗಳು'))])),
        const SizedBox(height: 14),
        if (items.isEmpty)
          Padding(padding: const EdgeInsets.only(top: 60), child: Column(children: [Icon(widget.hotel ? Icons.hotel_outlined : Icons.celebration_outlined, size: 72, color: Colors.black26), const SizedBox(height: 14), Text(tr('No verified ${widget.hotel ? 'hotel' : 'hall'} is listed yet', 'ಇನ್ನೂ ಪರಿಶೀಲಿಸಿದ ಸ್ಥಳ ಲಭ್ಯವಿಲ್ಲ'), textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 7), Text(tr('This list updates automatically after Admin verifies a partner.', 'ಅಡ್ಮಿನ್ ಪಾಲುದಾರರನ್ನು ಪರಿಶೀಲಿಸಿದ ನಂತರ ಪಟ್ಟಿ ಸ್ವಯಂಚಾಲಿತವಾಗಿ ನವೀಕರಿಸುತ್ತದೆ.'), textAlign: TextAlign.center)]))
        else
          ...items.map((item) => venueCard(item)),
      ]);
    },
  );

  Widget venueCard(QueryDocumentSnapshot<Map<String, dynamic>> item) {
    final data = item.data();
    return Card(margin: const EdgeInsets.only(bottom: 11), child: InkWell(
      borderRadius: BorderRadius.circular(18), onTap: () => setState(() => selected = item),
      child: Padding(padding: const EdgeInsets.all(13), child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            widget.hotel ? 'assets/images/hotel-room.png' : 'assets/images/function-hall.png',
            width: 76,
            height: 76,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text((data['name'] ?? category).toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
          Text('📍 ${data['area'] ?? 'Ranebennur'} · ⭐ ${data['rating'] ?? 'New'}', style: const TextStyle(fontSize: 11)),
          Text((data['description'] ?? tr('Verified local partner', 'ಪರಿಶೀಲಿಸಿದ ಸ್ಥಳೀಯ ಪಾಲುದಾರ')).toString(), maxLines: 2, overflow: TextOverflow.ellipsis),
          Text(data['startingPrice'] == null ? tr('Price confirmed first', 'ಮೊದಲು ದರ ದೃಢೀಕರಣ') : 'From ₹${data['startingPrice']}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xfff45b22))),
        ])),
        const Icon(Icons.chevron_right_rounded),
      ])),
    ));
  }

  Widget venueDetails() {
    final data = selected!.data();
    final minimumAdvance = data['minimumAdvance'] ?? 500;
    return ListView(padding: const EdgeInsets.all(16), children: [
      TextButton.icon(onPressed: () => setState(() => selected = null), icon: const Icon(Icons.arrow_back), label: Text(tr('All ${widget.hotel ? 'hotels' : 'halls'}', 'ಎಲ್ಲ ಸ್ಥಳಗಳು'))),
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          widget.hotel ? 'assets/images/hotel-room.png' : 'assets/images/function-hall.png',
          height: 190,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(height: 16),
      Text((data['name'] ?? category).toString(), style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w800)),
      Text('📍 ${data['area'] ?? 'Ranebennur'} · ⭐ ${data['rating'] ?? 'New'}'),
      const SizedBox(height: 8), Text((data['description'] ?? '').toString()), const SizedBox(height: 14),
      Row(children: [Expanded(child: info('STARTING RATE', data['startingPrice'] == null ? 'Confirm first' : '₹${data['startingPrice']}')), const SizedBox(width: 10), Expanded(child: info('MINIMUM ADVANCE', '₹$minimumAdvance'))]),
      const SizedBox(height: 18),
      FilledButton(onPressed: () => setState(() => showForm = true), child: Text(tr('Select and check date', 'ಆಯ್ಕೆ ಮಾಡಿ ದಿನಾಂಕ ಪರಿಶೀಲಿಸಿ'))),
    ]);
  }

  Widget info(String label, String value) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 9, color: Colors.black54)), Text(value, style: const TextStyle(fontWeight: FontWeight.w800))]));

  Widget bookingForm() => Form(key: formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
    TextButton.icon(onPressed: () => setState(() => showForm = false), icon: const Icon(Icons.arrow_back), label: Text(tr('Room / hall details', 'ಸ್ಥಳದ ವಿವರಗಳು'))),
    Text(widget.hotel ? tr('Request this room', 'ಈ ಕೊಠಡಿಗೆ ವಿನಂತಿಸಿ') : tr('Request this hall', 'ಈ ಹಾಲ್‌ಗೆ ವಿನಂತಿಸಿ'), style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800)),
    Text(tr('This remains pending until the owner confirms availability.', 'ಮಾಲೀಕರು ಲಭ್ಯತೆಯನ್ನು ದೃಢೀಕರಿಸುವವರೆಗೆ ವಿನಂತಿ ಬಾಕಿ ಇರುತ್ತದೆ.')), const SizedBox(height: 16),
    field(name, tr('Your name', 'ನಿಮ್ಮ ಹೆಸರು')), field(phone, tr('10-digit mobile number', '10 ಅಂಕಿಯ ಮೊಬೈಲ್ ಸಂಖ್ಯೆ'), phoneField: true),
    if (widget.hotel) ...[
      dateTile(tr('Check-in', 'ಚೆಕ್-ಇನ್'), startDate, (value) => startDate = value), dateTile(tr('Check-out', 'ಚೆಕ್-ಔಟ್'), endDate, (value) => endDate = value),
      dropdown(tr('Room type', 'ಕೊಠಡಿ ಪ್ರಕಾರ'), roomType, const ['Standard Room', 'Deluxe Room', 'Family Room'], (v) => roomType = v!), field(rooms, tr('Number of rooms', 'ಕೊಠಡಿಗಳ ಸಂಖ್ಯೆ'), number: true),
    ] else ...[
      dateTile(tr('Function date', 'ಕಾರ್ಯಕ್ರಮದ ದಿನಾಂಕ'), startDate, (value) => startDate = value),
      dropdown(tr('Time', 'ಸಮಯ'), timeSlot, const ['Morning', 'Evening', 'Full Day'], (v) => timeSlot = v!), field(occasion, tr('Occasion', 'ಕಾರ್ಯಕ್ರಮ'), hint: 'Wedding, birthday, engagement…'),
    ],
    field(guests, tr('Number of guests', 'ಅತಿಥಿಗಳ ಸಂಖ್ಯೆ'), number: true),
    Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: notes, maxLines: 3, decoration: InputDecoration(labelText: tr('Additional requirement', 'ಹೆಚ್ಚುವರಿ ಅಗತ್ಯ')))),
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xffffeadf), borderRadius: BorderRadius.circular(12)), child: Text(tr('Pending availability → Owner checks privately → Advance payment → Confirmed', 'ಲಭ್ಯತೆ ಬಾಕಿ → ಮಾಲೀಕರ ಪರಿಶೀಲನೆ → ಮುಂಗಡ ಪಾವತಿ → ದೃಢೀಕರಣ'), textAlign: TextAlign.center)),
    const SizedBox(height: 16), FilledButton(onPressed: sending ? null : submit, child: Text(sending ? tr('Sending…', 'ಕಳುಹಿಸಲಾಗುತ್ತಿದೆ…') : tr('Send availability request', 'ಲಭ್ಯತೆ ವಿನಂತಿ ಕಳುಹಿಸಿ'))),
  ]));

  Widget field(TextEditingController controller, String label, {bool phoneField = false, bool number = false, String? hint}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: controller, keyboardType: phoneField || number ? TextInputType.number : TextInputType.text, decoration: InputDecoration(labelText: label, hintText: hint), validator: (value) { final text = value?.trim() ?? ''; if (text.isEmpty) return tr('Required', 'ಅಗತ್ಯ'); if (phoneField && !RegExp(r'^[6-9]\d{9}$').hasMatch(text)) return tr('Enter a valid mobile number', 'ಸರಿಯಾದ ಮೊಬೈಲ್ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ'); return null; }));
  Widget dropdown(String label, String value, List<String> items, ValueChanged<String?> changed) => Padding(padding: const EdgeInsets.only(bottom: 12), child: DropdownButtonFormField<String>(initialValue: value, decoration: InputDecoration(labelText: label), items: items.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: changed));
  Widget dateTile(String label, DateTime value, ValueChanged<DateTime> changed) => Padding(padding: const EdgeInsets.only(bottom: 12), child: ListTile(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Colors.black26)), title: Text(label), subtitle: Text('${value.day}/${value.month}/${value.year}'), trailing: const Icon(Icons.calendar_month), onTap: () async { final picked = await showDatePicker(context: context, initialDate: value, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365))); if (picked != null) setState(() => changed(picked)); }));

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => sending = true);
    try {
      final data = selected!.data();
      final reference = await FirestoreService().createBooking({
        'category': widget.hotel ? 'hotels' : 'halls', 'businessId': selected!.id, 'counterId': data['counterId'], 'businessName': data['name'] ?? category,
        'customerName': name.text.trim(), 'customerPhone': phone.text.trim(), 'bookingDate': startDate,
        'checkoutDate': widget.hotel ? endDate : null, 'timeSlot': widget.hotel ? 'Availability check' : timeSlot,
        'serviceType': widget.hotel ? roomType : occasion.text.trim(), 'roomCount': widget.hotel ? int.tryParse(rooms.text) : null,
        'guestCount': int.tryParse(guests.text), 'notes': notes.text.trim(), 'availabilityStatus': 'pending_owner_confirmation',
        'minimumAdvance': data['minimumAdvance'] ?? 500, 'advancePaymentStatus': 'not_requested',
      });
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (_) => AlertDialog(icon: const Icon(Icons.check_circle, color: Colors.green, size: 48), title: Text(tr('Availability request received', 'ಲಭ್ಯತೆ ವಿನಂತಿ ಸ್ವೀಕರಿಸಲಾಗಿದೆ')), content: Text('${tr('Reference', 'ಉಲ್ಲೇಖ')}: $reference\n\n${tr('The booking becomes confirmed only after owner availability and payment verification.', 'ಮಾಲೀಕರ ಲಭ್ಯತೆ ಮತ್ತು ಪಾವತಿ ಪರಿಶೀಲನೆಯ ನಂತರ ಮಾತ್ರ ಬುಕ್ಕಿಂಗ್ ದೃಢೀಕರಿಸುತ್ತದೆ.')}'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
      if (mounted) Navigator.pop(context);
    } finally { if (mounted) setState(() => sending = false); }
  }
}
