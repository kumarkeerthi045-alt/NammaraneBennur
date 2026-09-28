import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/firestore_service.dart';

class CateringBookingScreen extends StatefulWidget {
  const CateringBookingScreen({super.key, required this.kannada});
  final bool kannada;

  @override
  State<CateringBookingScreen> createState() => _CateringBookingScreenState();
}

class _CateringBookingScreenState extends State<CateringBookingScreen> {
  static const foodTypes = [
    (name: 'Pure Veg', emoji: '🥗', note: 'Only vegetarian food'),
    (name: 'Veg & Non-Veg', emoji: '🍱', note: 'Separate menu choices'),
    (name: 'Non-Veg', emoji: '🍗', note: 'Non-vegetarian menu'),
  ];
  static const occasions = ['Wedding', 'Engagement', 'Birthday', 'House function', 'Meeting', 'Other event'];
  static const meals = ['Breakfast', 'Lunch', 'Dinner', 'Snacks & Tea'];
  static const extras = ['Serving staff', 'Plates & vessels', 'Tables & chairs', 'Water supply', 'Decoration'];

  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final guests = TextEditingController();
  final menu = TextEditingController();
  final address = TextEditingController(text: 'Ranebennur');
  final area = TextEditingController(text: 'Ranebennur');
  final budget = TextEditingController();
  String? foodType;
  String? occasion;
  final selectedMeals = <String>{};
  final selectedExtras = <String>{};
  DateTime eventDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay servingTime = const TimeOfDay(hour: 12, minute: 0);
  bool sending = false;
  String? mealsError;

  String tr(String en, String kn) => widget.kannada ? kn : en;

  @override
  void dispose() {
    for (final c in [name, phone, guests, menu, address, area, budget]) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('Book Catering', 'ಕೇಟರಿಂಗ್ ಬುಕ್ ಮಾಡಿ'))),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xffffeadf), borderRadius: BorderRadius.circular(12)),
        child: Text(
          tr('🛡️ Your phone number stays protected. Payment is requested only after Admin confirms availability, menu and price.',
              '🛡️ ನಿಮ್ಮ ಫೋನ್ ಸಂಖ್ಯೆ ಸುರಕ್ಷಿತವಾಗಿರುತ್ತದೆ. ಅಡ್ಮಿನ್ ಲಭ್ಯತೆ, ಮೆನು ಮತ್ತು ಬೆಲೆಯನ್ನು ದೃಢೀಕರಿಸಿದ ನಂತರವೇ ಪಾವತಿ ಕೇಳಲಾಗುತ್ತದೆ.'),
        ),
      ),
      const SizedBox(height: 18),
      Text(tr('STEP 1', 'ಹಂತ 1'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black54)),
      Text(tr('Choose food type', 'ಆಹಾರ ಪ್ರಕಾರ ಆಯ್ಕೆಮಾಡಿ'), style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      ...foodTypes.map((type) => Card(
        color: foodType == type.name ? const Color(0xffffeadf) : null,
        child: ListTile(
          onTap: () => setState(() => foodType = type.name),
          leading: Text(type.emoji, style: const TextStyle(fontSize: 26)),
          title: Text(type.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(type.note),
          trailing: foodType == type.name ? const Icon(Icons.check_circle, color: Color(0xfff45b22)) : null,
        ),
      )),
      if (foodType == null)
        Padding(padding: const EdgeInsets.only(top: 20), child: Text(tr('Select a food type above to open the catering request form.', 'ಕೇಟರಿಂಗ್ ವಿನಂತಿ ಫಾರ್ಮ್ ತೆರೆಯಲು ಮೇಲಿನ ಆಹಾರ ಪ್ರಕಾರ ಆಯ್ಕೆಮಾಡಿ.'), textAlign: TextAlign.center)),
      if (foodType != null) ...[
        const SizedBox(height: 20),
        Text(tr('STEP 2 · ENTER BOOKING DETAILS', 'ಹಂತ 2 · ಬುಕ್ಕಿಂಗ್ ವಿವರಗಳನ್ನು ನಮೂದಿಸಿ'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black54)),
        const SizedBox(height: 10),
        Form(key: formKey, child: Column(children: [
          field(name, tr('Your name', 'ನಿಮ್ಮ ಹೆಸರು')),
          field(phone, tr('Mobile number', 'ಮೊಬೈಲ್ ಸಂಖ್ಯೆ'), phoneField: true),
          dropdown(tr('Occasion', 'ಕಾರ್ಯಕ್ರಮ'), occasion, occasions, (v) => setState(() => occasion = v)),
          field(guests, tr('Number of guests', 'ಅತಿಥಿಗಳ ಸಂಖ್ಯೆ'), number: true, min: 10, max: 10000),
          Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(tr('Meal required (choose at least one)', 'ಬೇಕಾದ ಊಟ (ಕನಿಷ್ಠ ಒಂದನ್ನು ಆಯ್ಕೆಮಾಡಿ)'), style: const TextStyle(fontWeight: FontWeight.w700))),
          Wrap(spacing: 8, children: meals.map((meal) => FilterChip(
            label: Text(meal),
            selected: selectedMeals.contains(meal),
            onSelected: (value) => setState(() {
              value ? selectedMeals.add(meal) : selectedMeals.remove(meal);
              mealsError = null;
            }),
          )).toList()),
          if (mealsError != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(mealsError!, style: const TextStyle(color: Colors.red, fontSize: 12))),
          const SizedBox(height: 12),
          TextFormField(controller: menu, maxLines: 3, decoration: InputDecoration(labelText: tr('Preferred menu', 'ಬಯಸುವ ಮೆನು'), hintText: 'Example: Idli, poori, rice, sambar, sweet...', border: const OutlineInputBorder()), validator: required),
          const SizedBox(height: 12),
          dateTile(tr('Event date', 'ಕಾರ್ಯಕ್ರಮದ ದಿನಾಂಕ'), eventDate, (value) => setState(() => eventDate = value)),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Colors.black26)),
            title: Text(tr('Serving time', 'ಬಡಿಸುವ ಸಮಯ')),
            subtitle: Text(servingTime.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: servingTime);
              if (picked != null) setState(() => servingTime = picked);
            },
          ),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: Text(tr('Extra requirements (optional)', 'ಹೆಚ್ಚುವರಿ ಅಗತ್ಯಗಳು (ಐಚ್ಛಿಕ)'), style: const TextStyle(fontWeight: FontWeight.w700))),
          const SizedBox(height: 6),
          Wrap(spacing: 8, children: extras.map((extra) => FilterChip(
            label: Text(extra),
            selected: selectedExtras.contains(extra),
            onSelected: (value) => setState(() => value ? selectedExtras.add(extra) : selectedExtras.remove(extra)),
          )).toList()),
          const SizedBox(height: 12),
          TextFormField(controller: address, maxLines: 2, decoration: InputDecoration(labelText: tr('Full event address', 'ಪೂರ್ಣ ಕಾರ್ಯಕ್ರಮ ವಿಳಾಸ'), hintText: 'Hall/house, road, landmark and PIN code', border: const OutlineInputBorder()), validator: required),
          const SizedBox(height: 12),
          field(area, tr('Area', 'ಪ್ರದೇಶ')),
          field(budget, tr('Expected budget ₹ (optional)', 'ನಿರೀಕ್ಷಿತ ಬಜೆಟ್ ₹ (ಐಚ್ಛಿಕ)'), number: true, required: false),
          const SizedBox(height: 16),
          FilledButton(onPressed: sending ? null : submit, child: Text(sending ? tr('Sending…', 'ಕಳುಹಿಸಲಾಗುತ್ತಿದೆ…') : tr('Send request to Admin', 'ಅಡ್ಮಿನ್‌ಗೆ ವಿನಂತಿ ಕಳುಹಿಸಿ'))),
          const SizedBox(height: 10),
          Text(tr('Admin will call approved caterers, check availability and give you the final quote. Booking is confirmed only after your approval and minimum advance.',
              'ಅಡ್ಮಿನ್ ಅನುಮೋದಿತ ಕೇಟರರ್‌ಗಳನ್ನು ಕರೆ ಮಾಡಿ, ಲಭ್ಯತೆ ಪರಿಶೀಲಿಸಿ ಅಂತಿಮ ದರ ನೀಡುತ್ತಾರೆ. ನಿಮ್ಮ ಅನುಮೋದನೆ ಮತ್ತು ಕನಿಷ್ಠ ಮುಂಗಡದ ನಂತರವೇ ಬುಕ್ಕಿಂಗ್ ದೃಢೀಕರಿಸಲಾಗುತ್ತದೆ.'),
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ])),
      ],
    ]),
  );

  String? required(String? value) => (value == null || value.trim().isEmpty) ? tr('Required', 'ಅಗತ್ಯ') : null;

  Widget field(TextEditingController controller, String label, {bool phoneField = false, bool number = false, bool required = true, int? min, int? max}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: phoneField || number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (!required && text.isEmpty) return null;
        if (text.isEmpty) return tr('Required', 'ಅಗತ್ಯ');
        if (phoneField && !RegExp(r'^[6-9]\d{9}$').hasMatch(text)) return tr('Enter a valid mobile number', 'ಸರಿಯಾದ ಮೊಬೈಲ್ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ');
        if (number) {
          final parsed = int.tryParse(text);
          if (parsed == null) return tr('Enter a number', 'ಸಂಖ್ಯೆ ನಮೂದಿಸಿ');
          if (min != null && parsed < min) return tr('Minimum $min', 'ಕನಿಷ್ಠ $min');
          if (max != null && parsed > max) return tr('Maximum $max', 'ಗರಿಷ್ಠ $max');
        }
        return null;
      },
    ),
  );

  Widget dropdown(String label, String? value, List<String> items, ValueChanged<String?> changed) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: items.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
      onChanged: changed,
      validator: (v) => v == null ? tr('Required', 'ಅಗತ್ಯ') : null,
    ),
  );

  Widget dateTile(String label, DateTime value, ValueChanged<DateTime> changed) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Colors.black26)),
      title: Text(label),
      subtitle: Text('${value.day}/${value.month}/${value.year}'),
      trailing: const Icon(Icons.calendar_month),
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: value, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
        if (picked != null) changed(picked);
      },
    ),
  );

  Future<void> submit() async {
    final formValid = formKey.currentState?.validate() ?? false;
    if (selectedMeals.isEmpty) {
      setState(() => mealsError = tr('Please choose at least one meal: Breakfast, Lunch, Dinner or Snacks & Tea.', 'ದಯವಿಟ್ಟು ಕನಿಷ್ಠ ಒಂದು ಊಟ ಆಯ್ಕೆಮಾಡಿ: ಬ್ರೇಕ್‌ಫಾಸ್ಟ್, ಲಂಚ್, ಡಿನ್ನರ್ ಅಥವಾ ಸ್ನ್ಯಾಕ್ಸ್ & ಟೀ.'));
    }
    if (!formValid || selectedMeals.isEmpty) return;
    setState(() => sending = true);
    try {
      final requiredDate = DateTime(eventDate.year, eventDate.month, eventDate.day, servingTime.hour, servingTime.minute);
      final details = [
        'Food: $foodType',
        'Guests: ${guests.text.trim()}',
        'Meals: ${selectedMeals.join(', ')}',
        'Menu: ${menu.text.trim()}',
        'Serving: ${servingTime.format(context)}',
        'Extras: ${selectedExtras.isEmpty ? 'None' : selectedExtras.join(', ')}',
        'Address: ${address.text.trim()}',
      ].join(' | ');
      final id = await FirestoreService().createRequirement({
        'name': name.text.trim(),
        'phone': phone.text.trim(),
        'category': 'Events',
        'subcategory': 'Catering',
        'title': '$occasion catering for ${guests.text.trim()} guests',
        'details': details,
        'area': area.text.trim(),
        'requiredDate': requiredDate,
        'budget': int.tryParse(budget.text.trim()) ?? 0,
      });
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: Text(tr('Request sent to Admin', 'ವಿನಂತಿಯನ್ನು ಅಡ್ಮಿನ್‌ಗೆ ಕಳುಹಿಸಲಾಗಿದೆ')),
        content: Text('${tr('Reference', 'ಉಲ್ಲೇಖ')}: $id\n\n${tr('Admin will check the caterer, menu and final price, then contact you before taking any advance.', 'ಅಡ್ಮಿನ್ ಕೇಟರರ್, ಮೆನು ಮತ್ತು ಅಂತಿಮ ಬೆಲೆಯನ್ನು ಪರಿಶೀಲಿಸಿ, ಯಾವುದೇ ಮುಂಗಡ ಪಡೆಯುವ ಮೊದಲು ನಿಮ್ಮನ್ನು ಸಂಪರ್ಕಿಸುತ್ತಾರೆ.')}'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ));
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tr('Could not submit', 'ಸಲ್ಲಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ')}: $error')));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }
}
