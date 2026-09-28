import 'package:flutter/material.dart';

import '../models/service_category.dart';
import '../services/firestore_service.dart';

class BookingFormScreen extends StatefulWidget {
  final ServiceCategory parent;
  final ServiceCategory service;
  const BookingFormScreen({super.key, required this.parent, required this.service});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final location = TextEditingController();
  final details = TextEditingController();
  final budget = TextEditingController();
  DateTime date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay time = const TimeOfDay(hour: 10, minute: 0);
  bool sending = false;

  @override
  void dispose() {
    for (final controller in [name, phone, location, details, budget]) { controller.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.service.title)),
    body: Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (widget.service.asset != null)
            ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.asset(widget.service.asset!, height: 180, fit: BoxFit.cover))
          else
            Icon(widget.service.icon, size: 76, color: Colors.deepOrange),
          const SizedBox(height: 18),
          field(name, 'Customer name', Icons.person),
          field(phone, '10-digit mobile number', Icons.phone, phoneField: true),
          field(location, 'Location / address', Icons.location_on),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black26)),
            title: const Text('Required date and time'),
            subtitle: Text('${date.day}/${date.month}/${date.year} · ${time.format(context)}'),
            trailing: const Icon(Icons.calendar_month),
            onTap: chooseSchedule,
          ),
          const SizedBox(height: 12),
          TextFormField(controller: details, maxLines: 4, decoration: const InputDecoration(labelText: 'Purpose / requirements', border: OutlineInputBorder())),
          if (widget.parent.id == 'home_services') ...[
            const SizedBox(height: 12),
            TextFormField(controller: budget, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Expected budget ₹ (optional)', border: OutlineInputBorder())),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(onPressed: sending ? null : submit, icon: const Icon(Icons.check), label: Text(sending ? 'Submitting…' : widget.parent.id == 'home_services' ? 'Request verified worker' : 'Submit booking request')),
          const SizedBox(height: 10),
          const Text('Availability and final price must be confirmed by the provider or Admin. Contact details remain protected until confirmation.', textAlign: TextAlign.center),
        ],
      ),
    ),
  );

  Widget field(TextEditingController controller, String label, IconData icon, {bool phoneField = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: phoneField ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return 'Required';
        if (phoneField && !RegExp(r'^\d{10}$').hasMatch(text)) return 'Enter a valid 10-digit number';
        return null;
      },
    ),
  );

  Future<void> chooseSchedule() async {
    final selectedDate = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (selectedDate == null || !mounted) return;
    final selectedTime = await showTimePicker(context: context, initialTime: time);
    if (selectedTime != null) setState(() { date = selectedDate; time = selectedTime; });
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => sending = true);
    try {
      final scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      final homeService = widget.parent.id == 'home_services';
      final id = homeService
          ? await FirestoreService().createRequirement({
              'category': 'Workers',
              'subcategory': widget.service.title,
              'title': 'Need ${widget.service.title}',
              'details': '${details.text.trim()} · Preferred: ${time.format(context)} · Address: ${location.text.trim()}',
              'area': 'Ranebennur',
              'requiredDate': scheduledAt,
              'budget': int.tryParse(budget.text.trim()),
            })
          : await FirestoreService().createBooking({
              'category': widget.parent.id, 'serviceType': widget.service.id,
              'serviceName': widget.service.title, 'customerName': name.text.trim(),
              'customerPhone': phone.text.trim(), 'address': location.text.trim(),
              'scheduledAt': scheduledAt, 'description': details.text.trim(),
              'availabilityStatus': 'requested', 'advancePaymentStatus': 'not_requested',
            });
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (_) => AlertDialog(title: Text(homeService ? 'Service request received' : 'Booking requested'), content: Text('Reference: $id\n\n${homeService ? 'A verified worker can respond with a protected quote inside Namma Ranebennur.' : 'This request is awaiting confirmation.'}'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not submit: $error')));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }
}
