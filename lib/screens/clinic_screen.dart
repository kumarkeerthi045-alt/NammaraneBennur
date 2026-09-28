import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/firestore_service.dart';

class ClinicScreen extends StatefulWidget {
  const ClinicScreen({super.key, this.kannada = false});
  final bool kannada;

  @override
  State<ClinicScreen> createState() => _ClinicScreenState();
}

class _ClinicScreenState extends State<ClinicScreen> {
  QueryDocumentSnapshot<Map<String, dynamic>>? selected;
  String tr(String en, String kn) => widget.kannada ? kn : en;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('Clinics & Doctors', 'ಕ್ಲಿನಿಕ್ ಮತ್ತು ವೈದ್ಯರು'))),
    body: selected == null ? clinicList() : appointmentPage(),
  );

  Widget clinicList() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance.collection('businesses').where('category', isEqualTo: 'Clinic').snapshots(),
    builder: (_, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      final clinics = (snapshot.data?.docs ?? []).where((doc) {
        final data = doc.data();
        return data['verified'] != false && data['acceptingBookings'] != false && data['active'] != false;
      }).toList();
      return ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          const CircleAvatar(radius: 30, backgroundColor: Color(0xffffeadf), child: Icon(Icons.local_hospital_rounded, color: Color(0xfff45b22), size: 32)),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr('Find a Clinic', 'ಕ್ಲಿನಿಕ್ ಹುಡುಕಿ'), style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800)),
            Text(tr('Choose a verified doctor and an available appointment slot.', 'ಪರಿಶೀಲಿಸಿದ ವೈದ್ಯರು ಮತ್ತು ಲಭ್ಯ ಸಮಯವನ್ನು ಆಯ್ಕೆಮಾಡಿ.'), style: const TextStyle(color: Colors.black54)),
          ])),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xfffff0e6), borderRadius: BorderRadius.circular(13)),
          child: Text(tr('Emergency? Call 112 or go directly to the nearest hospital.', 'ತುರ್ತು ಪರಿಸ್ಥಿತಿ? 112 ಗೆ ಕರೆ ಮಾಡಿ ಅಥವಾ ಹತ್ತಿರದ ಆಸ್ಪತ್ರೆಗೆ ಹೋಗಿ.'), style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
        ),
        const SizedBox(height: 16),
        if (clinics.isEmpty)
          Padding(padding: const EdgeInsets.only(top: 52), child: Column(children: [
            const Icon(Icons.medical_services_outlined, size: 72, color: Colors.black26),
            const SizedBox(height: 12),
            Text(tr('No verified clinic is accepting appointments now.', 'ಈಗ ಯಾವುದೇ ಪರಿಶೀಲಿಸಿದ ಕ್ಲಿನಿಕ್ ಅಪಾಯಿಂಟ್‌ಮೆಂಟ್ ಸ್ವೀಕರಿಸುತ್ತಿಲ್ಲ.'), textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(tr('The list updates when the Booking Admin approves a clinic counter.', 'ಬುಕಿಂಗ್ ಅಡ್ಮಿನ್ ಕ್ಲಿನಿಕ್ ಕೌಂಟರ್ ಅನುಮೋದಿಸಿದಾಗ ಪಟ್ಟಿ ನವೀಕರಿಸುತ್ತದೆ.'), textAlign: TextAlign.center),
          ]))
        else
          ...clinics.map(clinicCard),
      ]);
    },
  );

  Widget clinicCard(QueryDocumentSnapshot<Map<String, dynamic>> clinic) {
    final data = clinic.data();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(13),
        leading: const CircleAvatar(backgroundColor: Color(0xffffeadf), child: Icon(Icons.medical_services, color: Color(0xfff45b22))),
        title: Text((data['name'] ?? tr('Clinic / Doctor', 'ಕ್ಲಿನಿಕ್ / ವೈದ್ಯರು')).toString(), style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('${data['description'] ?? tr('Verified clinic', 'ಪರಿಶೀಲಿಸಿದ ಕ್ಲಿನಿಕ್')}\n📍 ${data['area'] ?? 'Ranebennur'}${data['startingPrice'] == null ? '' : ' · ₹${data['startingPrice']}'}'),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => setState(() => selected = clinic),
      ),
    );
  }

  Widget appointmentPage() {
    final clinic = selected!.data();
    final counterId = clinic['counterId']?.toString();
    if (counterId == null || counterId.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(tr('Appointment slots are not connected yet.', 'ಅಪಾಯಿಂಟ್‌ಮೆಂಟ್ ಸಮಯಗಳು ಇನ್ನೂ ಸಂಪರ್ಕಗೊಂಡಿಲ್ಲ.'), textAlign: TextAlign.center),
        TextButton(onPressed: () => setState(() => selected = null), child: Text(tr('Choose another clinic', 'ಬೇರೆ ಕ್ಲಿನಿಕ್ ಆಯ್ಕೆಮಾಡಿ'))),
      ])));
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('providerSlots').where('counterId', isEqualTo: counterId).snapshots(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final slots = (snapshot.data?.docs ?? []).where((doc) => doc.data()['active'] != false).toList();
        return ClinicAppointmentForm(
          kannada: widget.kannada,
          clinicId: selected!.id,
          counterId: counterId,
          clinic: clinic,
          slots: slots,
          onBack: () => setState(() => selected = null),
        );
      },
    );
  }
}

class ClinicAppointmentForm extends StatefulWidget {
  const ClinicAppointmentForm({
    super.key,
    required this.kannada,
    required this.clinicId,
    required this.counterId,
    required this.clinic,
    required this.slots,
    required this.onBack,
  });
  final bool kannada;
  final String clinicId;
  final String counterId;
  final Map<String, dynamic> clinic;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> slots;
  final VoidCallback onBack;

  @override
  State<ClinicAppointmentForm> createState() => _ClinicAppointmentFormState();
}

class _ClinicAppointmentFormState extends State<ClinicAppointmentForm> {
  final formKey = GlobalKey<FormState>();
  final bookerName = TextEditingController();
  final patientName = TextEditingController();
  final age = TextEditingController();
  final phone = TextEditingController();
  final purpose = TextEditingController();
  DateTime date = DateTime.now().add(const Duration(days: 1));
  String? slotId;
  bool sending = false;
  String tr(String en, String kn) => widget.kannada ? kn : en;

  @override
  void initState() {
    super.initState();
    if (widget.slots.isNotEmpty) slotId = widget.slots.first.id;
  }

  @override
  void didUpdateWidget(covariant ClinicAppointmentForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.slots.every((slot) => slot.id != slotId)) slotId = widget.slots.isEmpty ? null : widget.slots.first.id;
  }

  @override
  void dispose() {
    bookerName.dispose();
    patientName.dispose();
    age.dispose();
    phone.dispose();
    purpose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: ListView(padding: const EdgeInsets.all(16), children: [
      TextButton.icon(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back), label: Text(tr('All clinics', 'ಎಲ್ಲ ಕ್ಲಿನಿಕ್‌ಗಳು'))),
      Card(child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xffffeadf), child: Icon(Icons.medical_services, color: Color(0xfff45b22))),
        title: Text((widget.clinic['name'] ?? 'Clinic').toString(), style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('${widget.clinic['description'] ?? ''}\n📍 ${widget.clinic['area'] ?? 'Ranebennur'}'),
        isThreeLine: true,
      )),
      const SizedBox(height: 12),
      Text(tr('Patient information', 'ರೋಗಿಯ ಮಾಹಿತಿ'), style: GoogleFonts.poppins(fontSize: 21, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      field(bookerName, tr('Your name (person booking)', 'ನಿಮ್ಮ ಹೆಸರು (ಬುಕ್ ಮಾಡುತ್ತಿರುವವರು)')),
      field(patientName, tr('Patient name', 'ರೋಗಿಯ ಹೆಸರು')),
      field(age, tr('Patient age', 'ರೋಗಿಯ ವಯಸ್ಸು'), number: true),
      field(phone, tr('10-digit mobile number', '10 ಅಂಕಿಯ ಮೊಬೈಲ್ ಸಂಖ್ಯೆ'), phone: true),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: purpose, minLines: 2, maxLines: 4, decoration: InputDecoration(labelText: tr('Purpose of visit', 'ಭೇಟಿಯ ಉದ್ದೇಶ'), hintText: tr('Fever, follow-up, consultation…', 'ಜ್ವರ, ಫಾಲೋ-ಅಪ್, ಸಮಾಲೋಚನೆ…')), validator: required)),
      ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13), side: const BorderSide(color: Colors.black26)),
        title: Text(tr('Appointment date', 'ಅಪಾಯಿಂಟ್‌ಮೆಂಟ್ ದಿನಾಂಕ')),
        subtitle: Text('${date.day}/${date.month}/${date.year}'),
        trailing: const Icon(Icons.calendar_month),
        onTap: pickDate,
      ),
      const SizedBox(height: 12),
      if (widget.slots.isEmpty)
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xfffff0e6), borderRadius: BorderRadius.circular(13)), child: Text(tr('No appointment slot is open. Please choose another clinic or check later.', 'ಯಾವುದೇ ಅಪಾಯಿಂಟ್‌ಮೆಂಟ್ ಸಮಯ ತೆರೆದಿಲ್ಲ. ಬೇರೆ ಕ್ಲಿನಿಕ್ ಆಯ್ಕೆಮಾಡಿ ಅಥವಾ ನಂತರ ಪರಿಶೀಲಿಸಿ.'), textAlign: TextAlign.center))
      else
        DropdownButtonFormField<String>(
          initialValue: slotId,
          decoration: InputDecoration(labelText: tr('Available appointment time', 'ಲಭ್ಯ ಅಪಾಯಿಂಟ್‌ಮೆಂಟ್ ಸಮಯ')),
          items: widget.slots.map((slot) => DropdownMenuItem(value: slot.id, child: Text((slot.data()['name'] ?? slot.data()['timeSlot'] ?? 'Appointment').toString()))).toList(),
          onChanged: (value) => setState(() => slotId = value),
        ),
      const SizedBox(height: 14),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xffffeadf), borderRadius: BorderRadius.circular(12)), child: Text(tr('The clinic confirms the appointment and fee. Contact remains protected until confirmation.', 'ಕ್ಲಿನಿಕ್ ಅಪಾಯಿಂಟ್‌ಮೆಂಟ್ ಮತ್ತು ಶುಲ್ಕವನ್ನು ದೃಢೀಕರಿಸುತ್ತದೆ. ದೃಢೀಕರಣದವರೆಗೆ ಸಂಪರ್ಕ ಸುರಕ್ಷಿತವಾಗಿರುತ್ತದೆ.'), textAlign: TextAlign.center)),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: sending || slotId == null ? null : submit, icon: const Icon(Icons.check), label: Text(sending ? tr('Sending…', 'ಕಳುಹಿಸಲಾಗುತ್ತಿದೆ…') : tr('Request Appointment', 'ಅಪಾಯಿಂಟ್‌ಮೆಂಟ್ ವಿನಂತಿಸಿ'))),
    ]),
  );

  Widget field(TextEditingController controller, String label, {bool number = false, bool phone = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: number || phone ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return tr('Required', 'ಅಗತ್ಯ');
        if (number) {
          final parsed = int.tryParse(text);
          if (parsed == null || parsed < 1 || parsed > 120) return tr('Enter age from 1 to 120', '1 ರಿಂದ 120 ರವರೆಗೆ ವಯಸ್ಸು ನಮೂದಿಸಿ');
        }
        if (phone && !RegExp(r'^[6-9]\d{9}$').hasMatch(text)) return tr('Enter a valid mobile number', 'ಸರಿಯಾದ ಮೊಬೈಲ್ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ');
        return null;
      },
    ),
  );

  String? required(String? value) => value == null || value.trim().isEmpty ? tr('Required', 'ಅಗತ್ಯ') : null;

  Future<void> pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 120)));
    if (picked != null) setState(() => date = picked);
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate() || slotId == null) return;
    final selectedSlot = widget.slots.firstWhere((slot) => slot.id == slotId);
    setState(() => sending = true);
    try {
      final reference = await FirestoreService().createBooking({
        'category': 'Clinic',
        'businessId': widget.clinicId,
        'counterId': widget.counterId,
        'businessName': widget.clinic['name'] ?? 'Clinic',
        'serviceType': 'clinic_appointment',
        'bookedByName': bookerName.text.trim(),
        'patientName': patientName.text.trim(),
        'patientAge': int.parse(age.text.trim()),
        'customerName': bookerName.text.trim(),
        'customerPhone': phone.text.trim(),
        'visitPurpose': purpose.text.trim(),
        'bookingDate': date,
        'slotId': selectedSlot.id,
        'timeSlot': selectedSlot.data()['name'] ?? selectedSlot.data()['timeSlot'],
        'availabilityStatus': 'pending_clinic_confirmation',
        'advancePaymentStatus': 'not_required',
      });
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: Text(tr('Appointment requested', 'ಅಪಾಯಿಂಟ್‌ಮೆಂಟ್ ವಿನಂತಿಸಲಾಗಿದೆ')),
        content: Text('${tr('Reference', 'ಉಲ್ಲೇಖ')}: $reference\n\n${tr('The clinic will confirm the time and consultation fee.', 'ಕ್ಲಿನಿಕ್ ಸಮಯ ಮತ್ತು ಸಮಾಲೋಚನಾ ಶುಲ್ಕವನ್ನು ದೃಢೀಕರಿಸುತ್ತದೆ.')}'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ));
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tr('Could not request appointment', 'ಅಪಾಯಿಂಟ್‌ಮೆಂಟ್ ವಿನಂತಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ')}: $error')));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }
}
