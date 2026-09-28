import 'package:flutter/material.dart';

import '../models/map_point.dart';
import '../services/firestore_service.dart';
import '../services/link_service.dart';
import '../services/route_distance_service.dart';
import 'location_picker_screen.dart';

class VibeTownBookingScreen extends StatefulWidget {
  const VibeTownBookingScreen({super.key, this.kannada = false});
  final bool kannada;
  @override
  State<VibeTownBookingScreen> createState() => _VibeTownBookingScreenState();
}

class _VibeTownBookingScreenState extends State<VibeTownBookingScreen> {
  final key = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final guests = TextEditingController(text: '2');
  final cake = TextEditingController();
  final purpose = TextEditingController();
  final notes = TextEditingController();
  String experience = 'Private Theater';
  String package = 'Standard';
  DateTime date = DateTime.now().add(const Duration(days: 1));
  String slot = '10:00 AM';
  bool sending = false;
  final experiences = const ['Private Theater', 'Movie Show', 'VR & PS5', 'Birthday', 'Anniversary', 'Mini Function'];
  final selectedAddOns = <String>{};
  static const addOns = ['Cake', 'Flower decoration', 'Theme decoration', 'Photography', 'Veg catering', 'Extra gaming time'];
  String tr(String en, String kn) => widget.kannada ? kn : en;

  @override
  void dispose() { name.dispose(); phone.dispose(); guests.dispose(); cake.dispose(); purpose.dispose(); notes.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('Vibe Town Booking', 'ವೈಬ್ ಟೌನ್ ಬುಕ್ಕಿಂಗ್'))),
    body: Form(key: key, child: ListView(padding: const EdgeInsets.all(18), children: [
      Center(child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset('assets/images/app/vibe-town-logo.jpg', width: 110, height: 110, fit: BoxFit.cover),
      )),
      const SizedBox(height: 12),
      Text(tr('Choose your private experience', 'ನಿಮ್ಮ ಖಾಸಗಿ ಅನುಭವವನ್ನು ಆಯ್ಕೆಮಾಡಿ'), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: experiences.map((item) => ChoiceChip(label: Text(item), selected: experience == item, onSelected: (_) => setState(() => experience = item))).toList()),
      const SizedBox(height: 8),
      Text('${tr('Price', 'ಬೆಲೆ')}: ₹${FirestoreService.vibeTownPrices[experience] ?? 0}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xfff45b22))),
      const SizedBox(height: 16),
      dropdown(tr('Package', 'ಪ್ಯಾಕೇಜ್'), package, const ['Standard', 'Celebration', 'Premium'], (v) => setState(() => package = v!)),
      ListTile(title: Text(tr('Date', 'ದಿನಾಂಕ')), subtitle: Text('${date.day}/${date.month}/${date.year}'), trailing: const Icon(Icons.calendar_month), onTap: chooseDate),
      StreamBuilder<Map<String, bool>>(
        key: ValueKey(experience),
        stream: FirestoreService().vibeTownSlotAvailability(date, experience),
        builder: (_, snapshot) {
          final slotsForExperience = FirestoreService.vibeTownSlotsFor(experience);
          final availability = snapshot.data ?? {for (final item in slotsForExperience) item: true};
          if (availability[slot] != true) {
            final available = availability.entries.where((item) => item.value).map((item) => item.key);
            if (available.isNotEmpty) slot = available.first;
          }
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr('Live shared slots for $experience', 'ಲೈವ್ ಹಂಚಿಕೆಯ ಸಮಯ: $experience'), style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(spacing: 7, runSpacing: 7, children: availability.entries.map((entry) => ChoiceChip(
              label: Text.rich(TextSpan(children: [
                TextSpan(text: '${entry.key}\n', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                TextSpan(
                  text: entry.value ? tr('available', 'ಲಭ್ಯ') : tr('booked', 'ಬುಕ್ ಆಗಿದೆ'),
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: entry.value ? Colors.green.shade700 : Colors.orange.shade800),
                ),
              ]), textAlign: TextAlign.center),
              selected: entry.value && slot == entry.key,
              onSelected: entry.value ? (_) => setState(() => slot = entry.key) : null,
            )).toList()),
            const SizedBox(height: 14),
          ]);
        },
      ),
      field(name, tr('Customer name', 'ಗ್ರಾಹಕರ ಹೆಸರು')), field(phone, tr('10-digit mobile number', '10 ಅಂಕಿಯ ಮೊಬೈಲ್ ಸಂಖ್ಯೆ'), phoneField: true), field(guests, tr('Number of guests', 'ಅತಿಥಿಗಳ ಸಂಖ್ಯೆ'), number: true),
      field(purpose, tr('Purpose of event (optional)', 'ಕಾರ್ಯಕ್ರಮದ ಉದ್ದೇಶ (ಐಚ್ಛಿಕ)'), required: false),
      if (['Birthday', 'Anniversary', 'Mini Function'].contains(experience)) field(cake, tr('Cake details (optional)', 'ಕೇಕ್ ವಿವರಗಳು (ಐಚ್ಛಿಕ)')),
      Text(tr('Add-ons', 'ಹೆಚ್ಚುವರಿ ಆಯ್ಕೆಗಳು'), style: const TextStyle(fontWeight: FontWeight.w700)),
      ...addOns.map((item) => CheckboxListTile(contentPadding: EdgeInsets.zero, dense: true, title: Text(item), value: selectedAddOns.contains(item), onChanged: (value) => setState(() => value == true ? selectedAddOns.add(item) : selectedAddOns.remove(item)))),
      TextField(controller: notes, maxLines: 3, maxLength: 500, decoration: InputDecoration(labelText: tr('Additional note', 'ಹೆಚ್ಚುವರಿ ಸೂಚನೆ'), hintText: tr('Tell us any special arrangement', 'ವಿಶೇಷ ವ್ಯವಸ್ಥೆಯನ್ನು ತಿಳಿಸಿ'), border: const OutlineInputBorder())),
      const SizedBox(height: 12),
      FilledButton(onPressed: sending ? null : submit, child: Text(sending ? tr('Submitting…', 'ಸಲ್ಲಿಸಲಾಗುತ್ತಿದೆ…') : tr('Request Vibe Town slot', 'ವೈಬ್ ಟೌನ್ ಸಮಯವನ್ನು ವಿನಂತಿಸಿ'))),
      Padding(padding: const EdgeInsets.all(12), child: Text(tr('Booking, payment and communication stay inside the controlled Namma Ranebennur system.', 'ಬುಕ್ಕಿಂಗ್, ಪಾವತಿ ಮತ್ತು ಸಂಪರ್ಕ ನಮ್ಮ ನಿಯಂತ್ರಿತ ವ್ಯವಸ್ಥೆಯಲ್ಲೇ ಇರುತ್ತದೆ.'), textAlign: TextAlign.center)),
      const SizedBox(height: 8),
      FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: const Color(0xff2b2118), foregroundColor: Colors.white),
        onPressed: () => LinkService.call('8073328335'),
        icon: const Icon(Icons.call),
        label: Text(tr('Call Vibe Town · 80733 28335', 'ವೈಬ್ ಟೌನ್‌ಗೆ ಕರೆ ಮಾಡಿ · 80733 28335')),
      ),
    ])),
  );

  Widget dropdown(String label, String? value, List<String> items, ValueChanged<String?>? changed) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(initialValue: value, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()), items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: changed),
  );
  Widget field(TextEditingController c, String label, {bool phoneField = false, bool number = false, bool required = true}) => Padding(
    padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: c, keyboardType: phoneField || number ? TextInputType.number : TextInputType.text, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()), validator: (v) { final t = v?.trim() ?? ''; if (!required && t.isEmpty) return null; if (t.isEmpty) return 'Required'; if (phoneField && !RegExp(r'^\d{10}$').hasMatch(t)) return 'Enter a valid mobile number'; return null; }),
  );
  Future<void> chooseDate() async { final result = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 180))); if (result != null) setState(() => date = result); }
  Future<void> submit() async {
    if (!key.currentState!.validate()) return;
    setState(() => sending = true);
    try {
      final id = await FirestoreService().createVibeTownBooking({'category':'vibe_town','serviceType':experience,'package':package,'customerName':name.text.trim(),'customerPhone':phone.text.trim(),'guestCount':int.tryParse(guests.text),'bookingDate':date,'timeSlot':slot,'cakeDetails':cake.text.trim(),'purpose':purpose.text.trim(),'addOns':selectedAddOns.toList(),'notes':notes.text.trim(),'advancePaymentStatus':'not_requested'});
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (_) => AlertDialog(title: Text(tr('Vibe Town request saved', 'ವೈಬ್ ಟೌನ್ ವಿನಂತಿ ಉಳಿಸಲಾಗಿದೆ')), content: Text('${tr('Reference', 'ಉಲ್ಲೇಖ')}: $id'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))));
    } finally { if (mounted) setState(() => sending = false); }
  }
}

class DeliveryBookingScreen extends StatefulWidget {
  const DeliveryBookingScreen({super.key, this.kannada = false});
  final bool kannada;
  @override
  State<DeliveryBookingScreen> createState() => _DeliveryBookingScreenState();
}

class _DeliveryBookingScreenState extends State<DeliveryBookingScreen> {
  final key = GlobalKey<FormState>();
  final name = TextEditingController(); final phone = TextEditingController();
  final pickup = TextEditingController(); final drop = TextEditingController();
  final landmark = TextEditingController(); final item = TextEditingController();
  final shop = TextEditingController(); final budget = TextEditingController();
  final weight = TextEditingController(text: '1'); final distance = TextEditingController();
  final length = TextEditingController(); final width = TextEditingController(); final height = TextEditingController();
  final declaredValue = TextEditingController(text: '0');
  String type = 'Move Parcel'; bool sending = false;
  MapPoint? pickupPoint; MapPoint? deliveryPoint;
  bool routeBusy = false; String? routeError;
  bool purchaseRequired = false; bool prescriptionConfirmed = false; bool cityConfirmed = false; bool safetyAccepted = false;
  final types = const ['Purchase Items','Collect Medicines','Pick Up Documents','Bring Prepared Food Parcels','Deliver Groceries','Take Cakes and Gifts','Move Parcel'];
  String tr(String en, String kn) => widget.kannada ? kn : en;
  bool get canPurchase => type == 'Purchase Items' || type == 'Deliver Groceries';
  int get estimatedFare {
    final kg = double.tryParse(weight.text) ?? 1;
    final km = double.tryParse(distance.text) ?? 1;
    final base = kg <= 1 ? 25 : kg <= 5 ? 25 : kg <= 10 ? 40 : 70;
    final distanceFare = (km.ceil() - 1).clamp(0, 100).toInt() * 15;
    return base + distanceFare + (purchaseRequired ? 10 : 0);
  }
  @override
  void dispose() { for (final c in [name,phone,pickup,drop,landmark,item,shop,budget,weight,distance,length,width,height,declaredValue]) { c.dispose(); } super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('Nimma Sevaka Delivery', 'ನಿಮ್ಮ ಸೇವಕ ಡೆಲಿವರಿ'))),
    body: Form(key: key, child: ListView(padding: const EdgeInsets.all(18), children: [
      const Icon(Icons.delivery_dining, size: 72, color: Colors.deepOrange),
      Text(tr('Ranebennur city limits · verified bike partners', 'ರಾಣೆಬೆಣ್ಣೂರು ನಗರ ಮಿತಿಯಲ್ಲಿ · ಪರಿಶೀಲಿಸಿದ ಬೈಕ್ ಪಾಲುದಾರರು'), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
      Text(tr('Bike only · Maximum 20 kg · Maximum 40 × 40 × 40 cm', 'ಬೈಕ್ ಮಾತ್ರ · ಗರಿಷ್ಠ 20 ಕೆಜಿ · ಗರಿಷ್ಠ 40 × 40 × 40 ಸೆಂ'), textAlign: TextAlign.center),
      const SizedBox(height: 16),
      Text(tr('Choose delivery service', 'ವಿತರಣಾ ಸೇವೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ'), style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Wrap(spacing: 7, runSpacing: 7, children: types.map((value) => ChoiceChip(label: Text(value), selected: type == value, onSelected: (_) => setState(() { type = value; purchaseRequired = value == 'Purchase Items'; }))).toList()),
      const SizedBox(height: 12),
      field(name, tr('Customer name', 'ಗ್ರಾಹಕರ ಹೆಸರು')),
      field(phone, tr('10-digit mobile number', '10 ಅಂಕಿಯ ಮೊಬೈಲ್ ಸಂಖ್ಯೆ'), phoneField: true),
      field(pickup, tr('Pickup complete address', 'ಪಿಕಪ್ ಪೂರ್ಣ ವಿಳಾಸ'), lines: 2),
      mapLocationTile(
        point: pickupPoint,
        title: tr('Choose pickup on Google Maps', 'Google Maps ನಲ್ಲಿ ಪಿಕಪ್ ಆಯ್ಕೆಮಾಡಿ'),
        confirmedTitle: tr('Pickup pin confirmed', 'ಪಿಕಪ್ ಪಿನ್ ದೃಢಪಟ್ಟಿದೆ'),
        icon: Icons.location_on,
        onTap: () => pickMapPoint(true),
      ),
      const SizedBox(height: 12),
      field(drop, tr('Delivery complete address', 'ವಿತರಣೆಯ ಪೂರ್ಣ ವಿಳಾಸ'), lines: 2),
      mapLocationTile(
        point: deliveryPoint,
        title: tr('Choose delivery on Google Maps', 'Google Maps ನಲ್ಲಿ ವಿತರಣೆ ಆಯ್ಕೆಮಾಡಿ'),
        confirmedTitle: tr('Delivery pin confirmed', 'ವಿತರಣಾ ಪಿನ್ ದೃಢಪಟ್ಟಿದೆ'),
        icon: Icons.flag,
        onTap: () => pickMapPoint(false),
      ),
      const SizedBox(height: 12),
      routeDistanceCard(),
      const SizedBox(height: 12),
      field(landmark, tr('Nearby landmark', 'ಹತ್ತಿರದ ಗುರುತು')),
      field(item, tr('Items / parcel details — maximum five items', 'ವಸ್ತು / ಪಾರ್ಸೆಲ್ ವಿವರ — ಗರಿಷ್ಠ ಐದು'), lines: 3, itemList: true),
      if (canPurchase) ...[
        CheckboxListTile(contentPadding: EdgeInsets.zero, title: Text(tr('Partner should purchase the items', 'ಪಾಲುದಾರರು ವಸ್ತುಗಳನ್ನು ಖರೀದಿಸಬೇಕು')), value: purchaseRequired, onChanged: (value) => setState(() => purchaseRequired = value ?? false)),
        if (purchaseRequired) ...[
          field(shop, tr('Preferred shop', 'ಆದ್ಯತೆಯ ಅಂಗಡಿ')),
          numberField(budget, tr('Prepaid product budget · maximum ₹500', 'ಮುಂಗಡ ವಸ್ತು ಬಜೆಟ್ · ಗರಿಷ್ಠ ₹500'), min: 1, max: 500),
          Text(tr('Final shop receipt is compulsory. Any balance returns to Namma Wallet.', 'ಅಂತಿಮ ಅಂಗಡಿ ರಸೀದಿ ಕಡ್ಡಾಯ. ಉಳಿದ ಹಣ ನಮ್ಮ ವಾಲೆಟ್‌ಗೆ ಮರಳುತ್ತದೆ.'), style: const TextStyle(fontSize: 11)),
        ],
      ],
      if (type == 'Collect Medicines') CheckboxListTile(contentPadding: EdgeInsets.zero, title: Text(tr('I will provide a valid prescription when required.', 'ಅಗತ್ಯವಿದ್ದಾಗ ಮಾನ್ಯ ಪ್ರಿಸ್ಕ್ರಿಪ್ಷನ್ ನೀಡುತ್ತೇನೆ.')), value: prescriptionConfirmed, onChanged: (value) => setState(() => prescriptionConfirmed = value ?? false)),
      const SizedBox(height: 12),
      Text(tr('Parcel measurements and estimate', 'ಪಾರ್ಸೆಲ್ ಅಳತೆ ಮತ್ತು ಅಂದಾಜು'), style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      numberField(weight, tr('Weight kg', 'ತೂಕ ಕೆಜಿ'), min: .1, max: 20, decimal: true),
      Row(children: [Expanded(child: numberField(length, tr('Length cm', 'ಉದ್ದ ಸೆಂ'), min: 1, max: 40)), const SizedBox(width: 8), Expanded(child: numberField(width, tr('Width cm', 'ಅಗಲ ಸೆಂ'), min: 1, max: 40)), const SizedBox(width: 8), Expanded(child: numberField(height, tr('Height cm', 'ಎತ್ತರ ಸೆಂ'), min: 1, max: 40))]),
      numberField(declaredValue, tr('Declared value · maximum ₹1500', 'ಘೋಷಿತ ಮೌಲ್ಯ · ಗರಿಷ್ಠ ₹1500'), min: 0, max: 1500),
      Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xff3f2b21), borderRadius: BorderRadius.circular(14)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(tr('Estimated delivery', 'ಅಂದಾಜು ವಿತರಣೆ'), style: const TextStyle(color: Colors.white)), Text('₹$estimatedFare', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800))])),
      CheckboxListTile(contentPadding: EdgeInsets.zero, title: Text(tr('Both addresses are inside Ranebennur city limits.', 'ಎರಡೂ ವಿಳಾಸಗಳು ರಾಣೆಬೆಣ್ಣೂರು ನಗರ ಮಿತಿಯಲ್ಲಿವೆ.')), value: cityConfirmed, onChanged: (value) => setState(() => cityConfirmed = value ?? false)),
      CheckboxListTile(contentPadding: EdgeInsets.zero, title: Text(tr('Parcel is safely packed and contains no prohibited items.', 'ಪಾರ್ಸೆಲ್ ಸುರಕ್ಷಿತವಾಗಿ ಪ್ಯಾಕ್ ಆಗಿದೆ ಮತ್ತು ನಿಷೇಧಿತ ವಸ್ತುಗಳಿಲ್ಲ.')), subtitle: Text(tr('No cash, jewellery, alcohol, tobacco, fuel, weapons, chemicals or illegal items.', 'ನಗದು, ಆಭರಣ, ಮದ್ಯ, ತಂಬಾಕು, ಇಂಧನ, ಆಯುಧ, ರಾಸಾಯನಿಕ ಅಥವಾ ಅಕ್ರಮ ವಸ್ತುಗಳಿಲ್ಲ.')), value: safetyAccepted, onChanged: (value) => setState(() => safetyAccepted = value ?? false)),
      FilledButton(onPressed: sending || routeBusy || distance.text.isEmpty ? null : submit, child: Text(sending ? tr('Submitting…', 'ಸಲ್ಲಿಸಲಾಗುತ್ತಿದೆ…') : tr('Confirm protected delivery', 'ಸುರಕ್ಷಿತ ವಿತರಣೆಯನ್ನು ದೃಢೀಕರಿಸಿ'))),
      Padding(padding: const EdgeInsets.all(12), child: Text(tr('Pickup and delivery OTPs appear only at the correct handover step. Partner contact remains protected.', 'ಪಿಕಪ್ ಮತ್ತು ವಿತರಣಾ OTP ಸರಿಯಾದ ಹಸ್ತಾಂತರ ಹಂತದಲ್ಲಿ ಮಾತ್ರ ಕಾಣಿಸುತ್ತದೆ. ಪಾಲುದಾರರ ಸಂಪರ್ಕ ಸುರಕ್ಷಿತವಾಗಿರುತ್ತದೆ.'), textAlign: TextAlign.center)),
    ])),
  );

  Widget field(TextEditingController controller, String label, {bool phoneField = false, int lines = 1, bool itemList = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(controller: controller, keyboardType: phoneField ? TextInputType.phone : TextInputType.text, maxLines: lines, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()), validator: (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return tr('Required', 'ಅಗತ್ಯ');
      if (phoneField && !RegExp(r'^[6-9]\d{9}$').hasMatch(text)) return tr('Enter a valid mobile number', 'ಮಾನ್ಯ ಮೊಬೈಲ್ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ');
      if (itemList && text.split(',').where((entry) => entry.trim().isNotEmpty).length > 5) return tr('Maximum five items', 'ಗರಿಷ್ಠ ಐದು ವಸ್ತುಗಳು');
      return null;
    }),
  );

  Widget numberField(TextEditingController controller, String label, {required num min, required num max, bool decimal = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(controller: controller, keyboardType: TextInputType.numberWithOptions(decimal: decimal), onChanged: (_) => setState(() {}), decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()), validator: (value) {
      final number = num.tryParse(value?.trim() ?? '');
      if (number == null || number < min || number > max) return '${tr('Enter', 'ನಮೂದಿಸಿ')} $min–$max';
      return null;
    }),
  );

  Widget mapLocationTile({
    required MapPoint? point,
    required String title,
    required String confirmedTitle,
    required IconData icon,
    required VoidCallback onTap,
  }) => Card(
    margin: EdgeInsets.zero,
    child: ListTile(
      onTap: routeBusy ? null : onTap,
      leading: Icon(icon, color: point == null ? Colors.deepOrange : Colors.green),
      title: Text(point == null ? title : confirmedTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(point?.address ?? tr('Tap to search or place the exact pin', 'ಹುಡುಕಲು ಅಥವಾ ನಿಖರ ಪಿನ್ ಇಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ')),
      trailing: Icon(point == null ? Icons.chevron_right : Icons.check_circle, color: point == null ? null : Colors.green),
    ),
  );

  Widget routeDistanceCard() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xfffff3e9), borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      const Icon(Icons.route, color: Colors.deepOrange),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr('GOOGLE MAP ROAD DISTANCE', 'GOOGLE MAP ರಸ್ತೆ ದೂರ'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(
          routeBusy
              ? tr('Calculating…', 'ಲೆಕ್ಕ ಹಾಕಲಾಗುತ್ತಿದೆ…')
              : routeError ?? (distance.text.isEmpty ? tr('Confirm both map locations', 'ಎರಡೂ ನಕ್ಷೆ ಸ್ಥಳಗಳನ್ನು ದೃಢೀಕರಿಸಿ') : '${distance.text} km · ${tr('rate updated automatically', 'ದರ ಸ್ವಯಂಚಾಲಿತವಾಗಿ ನವೀಕರಿಸಲಾಗಿದೆ')}'),
          style: TextStyle(fontWeight: FontWeight.w700, color: routeError == null ? null : Colors.red.shade700),
        ),
      ])),
      if (routeBusy) const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2)),
    ]),
  );

  Future<void> pickMapPoint(bool isPickup) async {
    final result = await Navigator.push<MapPoint>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          title: isPickup ? tr('Choose pickup location', 'ಪಿಕಪ್ ಸ್ಥಳ ಆಯ್ಕೆಮಾಡಿ') : tr('Choose delivery location', 'ವಿತರಣಾ ಸ್ಥಳ ಆಯ್ಕೆಮಾಡಿ'),
          initialPoint: isPickup ? pickupPoint : deliveryPoint,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (isPickup) {
        pickupPoint = result;
      } else {
        deliveryPoint = result;
      }
      distance.clear();
      routeError = null;
    });
    if (pickupPoint != null && deliveryPoint != null) await calculateRoute();
  }

  Future<void> calculateRoute() async {
    setState(() {
      routeBusy = true;
      routeError = null;
    });
    try {
      final km = await RouteDistanceService().roadDistanceKm(pickup: pickupPoint!, destination: deliveryPoint!);
      if (mounted) setState(() => distance.text = km.toStringAsFixed(1));
    } catch (_) {
      if (mounted) {
        setState(() {
          distance.clear();
          routeError = tr('Unable to calculate route. Check internet and select both pins again.', 'ಮಾರ್ಗ ಲೆಕ್ಕ ಹಾಕಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಇಂಟರ್ನೆಟ್ ಪರಿಶೀಲಿಸಿ ಎರಡೂ ಪಿನ್‌ಗಳನ್ನು ಮತ್ತೆ ಆಯ್ಕೆಮಾಡಿ.');
        });
      }
    } finally {
      if (mounted) setState(() => routeBusy = false);
    }
  }

  Future<void> submit() async {
    if (!key.currentState!.validate()) return;
    if (pickupPoint == null || deliveryPoint == null || distance.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Confirm pickup and delivery on Google Maps first.', 'ಮೊದಲು Google Maps ನಲ್ಲಿ ಪಿಕಪ್ ಮತ್ತು ವಿತರಣೆಯನ್ನು ದೃಢೀಕರಿಸಿ.'))));
      return;
    }
    if (!cityConfirmed || !safetyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Confirm the city-limit and parcel-safety declarations.', 'ನಗರ ಮಿತಿ ಮತ್ತು ಪಾರ್ಸೆಲ್ ಸುರಕ್ಷತಾ ಘೋಷಣೆಗಳನ್ನು ದೃಢೀಕರಿಸಿ.'))));
      return;
    }
    if (type == 'Collect Medicines' && !prescriptionConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Confirm prescription availability.', 'ಪ್ರಿಸ್ಕ್ರಿಪ್ಷನ್ ಲಭ್ಯತೆಯನ್ನು ದೃಢೀಕರಿಸಿ.'))));
      return;
    }
    setState(() => sending = true);
    try {
      final id = await FirestoreService().createBooking({
        'category':'delivery','serviceType':type,'vehicleType':'Bike','customerName':name.text.trim(),'customerPhone':phone.text.trim(),
        'pickupAddress':pickup.text.trim(),'deliveryAddress':drop.text.trim(),'landmark':landmark.text.trim(),'itemDetails':item.text.trim(),
        'pickupMapAddress':pickupPoint!.address,'pickupLatitude':pickupPoint!.latitude,'pickupLongitude':pickupPoint!.longitude,
        'deliveryMapAddress':deliveryPoint!.address,'deliveryLatitude':deliveryPoint!.latitude,'deliveryLongitude':deliveryPoint!.longitude,
        'preferredShop':shop.text.trim(),'purchaseRequired':purchaseRequired,'purchaseBudget':int.tryParse(budget.text) ?? 0,
        'prescriptionConfirmed':prescriptionConfirmed,'distanceKm':double.parse(distance.text),'weightKg':double.parse(weight.text),
        'lengthCm':int.parse(length.text),'widthCm':int.parse(width.text),'heightCm':int.parse(height.text),'declaredValue':int.parse(declaredValue.text),
        'estimatedFare':estimatedFare,'cityLimitConfirmed':cityConfirmed,'safetyAccepted':safetyAccepted,
        'pickupOtpStatus':'protected_until_driver_arrives','deliveryOtpStatus':'protected_until_delivery','tripStage':'unassigned',
      });
      if (!mounted) return;
      await showDialog<void>(context:context,builder:(_)=>AlertDialog(title:Text(tr('Delivery requested', 'ವಿತರಣೆ ವಿನಂತಿಸಲಾಗಿದೆ')),content:Text('${tr('Reference', 'ಉಲ್ಲೇಖ')}: $id\n${tr('Estimated fare', 'ಅಂದಾಜು ದರ')}: ₹$estimatedFare'),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('OK'))]));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))));
    } finally { if(mounted) setState(()=>sending=false); }
  }
}
