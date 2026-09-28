import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/link_service.dart';

class PartnerServicesScreen extends StatelessWidget {
  const PartnerServicesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Partner Service')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Text('Work with Namma Ranebennur', style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w800)),
      const Text('Choose the correct controlled portal for your business.'), const SizedBox(height: 18),
      portal(context, Icons.handyman_rounded, 'Verified Local Service Provider', 'Electrician, plumber, carpenter, worker, machinery, event or other local service · view requirements and quote', const ServiceProviderPortalScreen()),
      portal(context, Icons.storefront_rounded, 'Business Booking Counter', 'Clinics, salons, function halls and hotels · profiles, fees, slots and live bookings', const BookingCounterScreen()),
      portal(context, Icons.local_taxi_rounded, 'Driver & Delivery Partner', 'Auto, bike, cab, goods vehicle, traveller, bus or truck · service ON/OFF and trip workflow', const DriverPartnerScreen()),
    ]),
  );

  Widget portal(BuildContext context, IconData icon, String title, String subtitle, Widget screen) => Card(margin: const EdgeInsets.only(bottom: 12), child: InkWell(borderRadius: BorderRadius.circular(18), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)), child: Padding(padding: const EdgeInsets.all(17), child: Row(children: [CircleAvatar(radius: 28, backgroundColor: const Color(0xffffeadf), child: Icon(icon, color: const Color(0xfff45b22), size: 30)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(fontSize: 11))])), const Icon(Icons.chevron_right)]))));
}

class ServiceProviderPortalScreen extends StatelessWidget {
  const ServiceProviderPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Local Service Provider')),
      body: uid == null
          ? const Center(child: Text('Please sign in first.'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('serviceProviderRequests').doc(uid).snapshots(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final data = snapshot.data?.data();
                if (data == null) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No provider application found. Open Profile → Do Business With Us and submit your service first.', textAlign: TextAlign.center)));
                final status = data['status']?.toString() ?? 'pending';
                if (status != 'approved') return providerStatus(data, status);
                return ProviderRequirementBoard(uid: uid, provider: data);
              },
            ),
    );
  }

  Widget providerStatus(Map<String, dynamic> data, String status) => Center(child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(status == 'rejected' ? Icons.cancel : Icons.hourglass_top, size: 72, color: status == 'rejected' ? Colors.red : Colors.orange),
      const SizedBox(height: 12),
      Text((data['name'] ?? 'Service Provider').toString(), style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)),
      Text(status == 'rejected' ? 'Your application was not approved. Contact Admin for the reason.' : 'Your application is waiting for Admin verification.', textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(status.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800)),
    ]),
  ));
}

class ProviderRequirementBoard extends StatelessWidget {
  const ProviderRequirementBoard({super.key, required this.uid, required this.provider});
  final String uid;
  final Map<String, dynamic> provider;

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Card(child: ListTile(
      leading: const CircleAvatar(backgroundColor: Color(0xffffeadf), child: Icon(Icons.handyman, color: Color(0xfff45b22))),
      title: Text((provider['name'] ?? 'Verified provider').toString(), style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text('${provider['serviceType'] ?? 'Local service'} · ✓ Admin verified'),
    )),
    SwitchListTile(
      tileColor: provider['availability'] == 'online' ? const Color(0xffdcfce7) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(provider['availability'] == 'online' ? 'AVAILABLE ON' : 'OFFLINE', style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: const Text('Only availability is public. Your phone remains protected.'),
      value: provider['availability'] == 'online',
      onChanged: (value) => FirebaseFirestore.instance.collection('serviceProviderRequests').doc(uid).update({'availability': value ? 'online' : 'offline', 'updatedAt': FieldValue.serverTimestamp()}),
    ),
    const SizedBox(height: 16),
    Text('Open customer requirements', style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w800)),
    const Text('Customer phone and direct contact are not included. Send your quote inside Namma Ranebennur.'),
    const SizedBox(height: 10),
    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('requirements').where('status', isEqualTo: 'pending').limit(50).snapshots(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
        if (snapshot.hasError) return const Padding(padding: EdgeInsets.all(24), child: Text('Could not load requirements. Deploy the included Firestore rules, then retry.', textAlign: TextAlign.center));
        final requirements = snapshot.data?.docs ?? [];
        if (requirements.isEmpty) return const Padding(padding: EdgeInsets.all(24), child: Text('No open requirements right now.', textAlign: TextAlign.center));
        return Column(children: requirements.map((requirement) => requirementCard(context, requirement)).toList());
      },
    ),
    const SizedBox(height: 18),
    Text('My submitted quotes', style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w800)),
    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('providerQuotes').where('providerUid', isEqualTo: uid).limit(50).snapshots(),
      builder: (_, snapshot) {
        final quotes = snapshot.data?.docs ?? [];
        if (quotes.isEmpty) return const Padding(padding: EdgeInsets.all(18), child: Text('No quotes submitted yet.', textAlign: TextAlign.center));
        return Column(children: quotes.map((doc) {
          final quote = doc.data();
          final accepted = quote['status'] == 'accepted';
          final serviceStatus = (quote['serviceStatus'] ?? 'awaiting_provider').toString();
          return Card(color: accepted ? const Color(0xffdcfce7) : null, child: ListTile(
            leading: Icon(accepted ? Icons.verified_rounded : Icons.request_quote_rounded, color: accepted ? Colors.green : const Color(0xfff45b22)),
            title: Text('${quote['requirementTitle'] ?? 'Customer requirement'} · ₹${quote['quoteAmount'] ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${quote['category'] ?? 'Service'} · ${(quote['status'] ?? 'submitted').toString().toUpperCase()}${accepted ? '\nService: ${serviceStatus.replaceAll('_', ' ')}' : ''}'),
            isThreeLine: accepted,
            trailing: accepted && serviceStatus != 'completed' ? FilledButton(onPressed: () => advanceService(context, doc.reference, serviceStatus), child: Text(serviceStatus == 'awaiting_provider' ? 'Confirm' : serviceStatus == 'confirmed' ? 'Start' : 'Complete')) : null,
          ));
        }).toList());
      },
    ),
  ]);

  Future<void> advanceService(BuildContext context, DocumentReference<Map<String, dynamic>> quote, String current) async {
    final next = switch (current) { 'awaiting_provider' => 'confirmed', 'confirmed' => 'in_progress', 'in_progress' => 'completed', _ => null };
    if (next == null) return;
    final approved = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(next == 'confirmed' ? 'Confirm accepted service?' : next == 'in_progress' ? 'Start this service?' : 'Mark service complete?'),
      content: const Text('This status will be visible to the customer in My Requirements.'),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Not now')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Continue'))],
    ));
    if (approved != true) return;
    try {
      await quote.update({'serviceStatus': next, 'updatedAt': FieldValue.serverTimestamp()});
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Service updated: ${next.replaceAll('_', ' ')}.')));
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update service: $error')));
    }
  }

  Widget requirementCard(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> requirement) {
    final data = requirement.data();
    final quoteId = '${requirement.id}_$uid';
    return Card(child: Padding(padding: const EdgeInsets.all(13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${data['category'] ?? 'Requirement'} · ${data['area'] ?? 'Ranebennur'}', style: const TextStyle(color: Color(0xfff45b22), fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text((data['title'] ?? 'Customer requirement').toString(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      if ((data['details'] ?? '').toString().isNotEmpty) Text(data['details'].toString()),
      const SizedBox(height: 8),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('providerQuotes').where('providerUid', isEqualTo: uid).where('requirementId', isEqualTo: requirement.id).limit(1).snapshots(),
        builder: (_, quoteSnapshot) {
          final quoteDocs = quoteSnapshot.data?.docs ?? [];
          final quote = quoteDocs.isEmpty ? null : quoteDocs.first.data();
          if (quote != null) return Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xffdcfce7), borderRadius: BorderRadius.circular(10)), child: Text('✓ Your quote: ₹${quote['quoteAmount']} · ${(quote['status'] ?? 'submitted').toString().toUpperCase()}${(quote['message'] ?? '').toString().isEmpty ? '' : '\n${quote['message']}'}'));
          return Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: () => sendQuote(context, requirement, quoteId), icon: const Icon(Icons.send, size: 18), label: const Text('Send quote')));
        },
      ),
    ])));
  }

  Future<void> sendQuote(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> requirement, String quoteId) async {
    final amount = TextEditingController();
    final message = TextEditingController();
    final accepted = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Send protected quote'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Your price ₹')),
        const SizedBox(height: 10),
        TextField(controller: message, maxLength: 300, maxLines: 3, decoration: const InputDecoration(labelText: 'Short message (optional)')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Send quote'))],
    ));
    final quoteAmount = int.tryParse(amount.text.trim());
    if (accepted == true && quoteAmount != null && quoteAmount > 0) {
      try {
        await FirebaseFirestore.instance.collection('providerQuotes').doc(quoteId).set({
          'quoteId': quoteId,
          'requirementId': requirement.id,
          'providerUid': uid,
          'providerName': provider['name'] ?? 'Verified provider',
          'providerService': provider['serviceType'] ?? 'Local service',
          'requirementTitle': requirement.data()['title'] ?? 'Customer requirement',
          'category': requirement.data()['category'] ?? 'Service',
          'area': requirement.data()['area'] ?? 'Ranebennur',
          'quoteAmount': quoteAmount,
          'message': message.text.trim(),
          'status': 'submitted',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quote sent to the customer.')));
      } catch (error) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not send quote: $error')));
      }
    } else if (accepted == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid quote amount.')));
    }
    amount.dispose();
    message.dispose();
  }
}

class BookingCounterScreen extends StatefulWidget {
  const BookingCounterScreen({super.key});
  @override
  State<BookingCounterScreen> createState() => _BookingCounterScreenState();
}

class _BookingCounterScreenState extends State<BookingCounterScreen> {
  final organization = TextEditingController(); final contact = TextEditingController(); final phone = TextEditingController(); final area = TextEditingController(text: 'Ranebennur');
  String category = 'Clinic'; bool saving = false;
  String? get uid => FirebaseAuth.instance.currentUser?.uid;
  @override
  void dispose() { for (final c in [organization, contact, phone, area]) { c.dispose(); } super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Business Booking Counter')),
    body: uid == null ? const Center(child: Text('Please sign in first.')) : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('bookingCounters').where('ownerUid', isEqualTo: uid).limit(1).snapshots(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return registration();
        final doc = docs.first; final data = doc.data(); final status = data['registrationStatus']?.toString() ?? 'pending';
        if (status != 'approved') return statusCard(data, status);
        return counterConsole(doc.id, data);
      },
    ),
  );

  Widget registration() => ListView(padding: const EdgeInsets.all(18), children: [
    const Icon(Icons.storefront_rounded, color: Color(0xfff45b22), size: 70),
    Text('Register Booking Counter', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 23, fontWeight: FontWeight.w800)),
    const Text('Admin verifies the organisation before profiles or public slots can be added.', textAlign: TextAlign.center), const SizedBox(height: 18),
    field(organization, 'Organisation / business name'), field(contact, 'Contact person'), field(phone, '10-digit mobile number', phoneField: true),
    Padding(padding: const EdgeInsets.only(bottom: 12), child: DropdownButtonFormField<String>(initialValue: category, decoration: const InputDecoration(labelText: 'Category'), items: const ['Clinic','Salon','Function Hall','Hotel'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => category = v!))),
    field(area, 'Area'), FilledButton(onPressed: saving ? null : register, child: Text(saving ? 'Submitting…' : 'Send for Admin verification')),
  ]);

  Widget statusCard(Map<String, dynamic> data, String status) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(status == 'rejected' ? Icons.cancel : Icons.hourglass_top, size: 70, color: status == 'rejected' ? Colors.red : Colors.orange), const SizedBox(height: 12), Text(data['organizationName']?.toString() ?? 'Booking Counter', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)), Text(status == 'rejected' ? 'Registration was not approved. Contact Admin for the reason.' : 'Registration is waiting for Admin verification.', textAlign: TextAlign.center), const SizedBox(height: 10), Text('Status: ${status.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w800))])));

  Widget counterConsole(String counterId, Map<String, dynamic> data) => DefaultTabController(length: 3, child: Column(children: [
    ListTile(title: Text(data['organizationName']?.toString() ?? 'Booking Counter', style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${data['category']} · Verified'), trailing: Switch(value: data['acceptingBookings'] != false, onChanged: (value) => FirebaseFirestore.instance.collection('bookingCounters').doc(counterId).update({'acceptingBookings': value, 'updatedAt': FieldValue.serverTimestamp()}))),
    const TabBar(tabs: [Tab(text: 'Profiles'), Tab(text: 'Slots'), Tab(text: 'Bookings')]),
    Expanded(child: TabBarView(children: [
      CounterList(collection: 'businesses', ownerField: 'counterId', ownerId: counterId, empty: 'Add doctors, salon services, rooms or hall details after approval.', additionalData: {'category': data['category'], 'area': data['area'] ?? 'Ranebennur', 'acceptingBookings': true, 'verified': true}),
      CounterList(collection: 'providerSlots', ownerField: 'counterId', ownerId: counterId, empty: 'Add service times and available booking slots.'),
      CounterBookings(counterId: counterId),
    ])),
  ]));

  Widget field(TextEditingController controller, String label, {bool phoneField = false}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: controller, keyboardType: phoneField ? TextInputType.phone : TextInputType.text, decoration: InputDecoration(labelText: label)));
  Future<void> register() async { if (organization.text.trim().length < 2 || contact.text.trim().length < 2 || !RegExp(r'^[6-9]\d{9}$').hasMatch(phone.text.trim())) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter complete valid registration details.'))); return; } setState(() => saving = true); try { await FirebaseFirestore.instance.collection('bookingCounters').add({'ownerUid': uid, 'organizationName': organization.text.trim(), 'contactName': contact.text.trim(), 'phone': phone.text.trim(), 'category': category, 'area': area.text.trim(), 'registrationStatus': 'pending', 'acceptingBookings': false, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()}); } finally { if (mounted) setState(() => saving = false); } }
}

class CounterList extends StatelessWidget {
  const CounterList({super.key, required this.collection, required this.ownerField, required this.ownerId, required this.empty, this.additionalData = const {}});
  final String collection; final String ownerField; final String ownerId; final String empty; final Map<String, dynamic> additionalData;
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection(collection).where(ownerField, isEqualTo: ownerId).snapshots(), builder: (_, snapshot) { final docs = snapshot.data?.docs ?? []; return Stack(children: [docs.isEmpty ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(empty, textAlign: TextAlign.center))) : ListView.builder(padding: const EdgeInsets.all(12), itemCount: docs.length, itemBuilder: (_, index) { final data = docs[index].data(); return Card(child: ListTile(title: Text((data['name'] ?? data['serviceName'] ?? 'Entry').toString()), subtitle: Text((data['timeSlot'] ?? data['description'] ?? '').toString()), trailing: Switch(value: data['active'] != false, onChanged: (value) => docs[index].reference.update({'active': value, 'updatedAt': FieldValue.serverTimestamp()})))); }), Positioned(right: 16, bottom: 16, child: FloatingActionButton.small(onPressed: () => addEntry(context), child: const Icon(Icons.add)))]); });
  Future<void> addEntry(BuildContext context) async { final name = TextEditingController(); final details = TextEditingController(); final accepted = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(title: Text(collection == 'providerSlots' ? 'Add time / slot' : 'Add profile / service'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Name / time')), const SizedBox(height: 10), TextField(controller: details, decoration: const InputDecoration(labelText: 'Service, fee, capacity or details'))]), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Save'))])); if (accepted == true && name.text.trim().isNotEmpty) await FirebaseFirestore.instance.collection(collection).add({...additionalData, ownerField: ownerId, 'name': name.text.trim(), 'description': details.text.trim(), 'active': true, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()}); name.dispose(); details.dispose(); }
}

class CounterBookings extends StatelessWidget {
  const CounterBookings({super.key, required this.counterId}); final String counterId;
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('orders').where('counterId', isEqualTo: counterId).snapshots(), builder: (_, snapshot) { final docs = snapshot.data?.docs ?? []; if (docs.isEmpty) return const Center(child: Text('No live bookings yet.')); return ListView.builder(padding: const EdgeInsets.all(12), itemCount: docs.length, itemBuilder: (_, index) { final doc = docs[index]; final data = doc.data(); return Card(child: ListTile(title: Text((data['reference'] ?? doc.id).toString()), subtitle: Text('${data['customerName'] ?? 'Customer'} · ${(data['status'] ?? 'pending').toString().replaceAll('_', ' ')}${data['quotedFare'] == null ? '' : '\nQuote ₹${data['quotedFare']} · Advance ₹${data['advanceAmount'] ?? 0}'}'), isThreeLine: data['quotedFare'] != null, trailing: PopupMenuButton<String>(onSelected: (action) => bookingAction(context, doc.reference, action), itemBuilder: (_) => const [PopupMenuItem(value: 'quote', child: Text('Set price & advance')), PopupMenuItem(value: 'verify', child: Text('Verify advance & confirm')), PopupMenuItem(value: 'completed', child: Text('Complete')), PopupMenuItem(value: 'cancelled', child: Text('Cancel'))]))); }); });

  Future<void> bookingAction(BuildContext context, DocumentReference<Map<String, dynamic>> booking, String action) async {
    if (action == 'quote') {
      final price = TextEditingController();
      final advance = TextEditingController(text: '500');
      final accepted = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
        title: const Text('Set availability price'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Confirmed price ₹')),
          const SizedBox(height: 10),
          TextField(controller: advance, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Minimum advance ₹')),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Send to customer'))],
      ));
      final quote = int.tryParse(price.text.trim());
      final advanceAmount = int.tryParse(advance.text.trim());
      price.dispose(); advance.dispose();
      if (accepted != true) return;
      if (quote == null || quote < 1 || advanceAmount == null || advanceAmount < 0) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid price and advance.')));
        return;
      }
      await booking.update({'status': 'awaiting_customer', 'quotedFare': quote, 'advanceAmount': advanceAmount, 'advancePaymentStatus': 'required', 'quoteStatus': 'awaiting_customer', 'updatedAt': FieldValue.serverTimestamp()});
      return;
    }
    if (action == 'verify') {
      final orderSnapshot = await booking.get();
      final order = orderSnapshot.data();
      if (order == null) return;
      final advanceAmount = (order['advanceAmount'] as num?)?.toInt() ?? 0;
      final batch = FirebaseFirestore.instance.batch();
      batch.update(booking, {'status': 'confirmed', 'advancePaymentStatus': 'verified_manually', 'updatedAt': FieldValue.serverTimestamp()});
      if (advanceAmount > 0) {
        batch.set(FirebaseFirestore.instance.collection('payments').doc(booking.id), {
          'paymentId': booking.id,
          'orderId': booking.id,
          'userId': order['userId'],
          'counterId': counterId,
          'amount': advanceAmount,
          'method': 'manual',
          'status': 'verified',
          'verifiedBy': FirebaseAuth.instance.currentUser?.uid,
          'verifiedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await batch.commit();
      return;
    }
    await booking.update({'status': action, 'updatedAt': FieldValue.serverTimestamp()});
  }
}

class DriverPartnerScreen extends StatefulWidget {
  const DriverPartnerScreen({super.key});
  @override
  State<DriverPartnerScreen> createState() => _DriverPartnerScreenState();
}

class _DriverPartnerScreenState extends State<DriverPartnerScreen> {
  final name = TextEditingController(); final phone = TextEditingController(); final vehicleNumber = TextEditingController();
  final governmentIdLast4 = TextEditingController(); final bankName = TextEditingController(); final bankAccountLast4 = TextEditingController(); final bankIfsc = TextEditingController();
  String vehicleType = 'Auto'; bool saving = false; bool documentConsent = false; String? get uid => FirebaseAuth.instance.currentUser?.uid;
  @override
  void dispose() { name.dispose(); phone.dispose(); vehicleNumber.dispose(); governmentIdLast4.dispose(); bankName.dispose(); bankAccountLast4.dispose(); bankIfsc.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Driver & Delivery Partner')), body: uid == null ? const Center(child: Text('Please sign in first.')) : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('driverPartners').where('ownerUid', isEqualTo: uid).limit(1).snapshots(), builder: (_, snapshot) { if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator()); final docs = snapshot.data?.docs ?? []; if (docs.isEmpty) return registration(); final doc = docs.first; final data = doc.data(); return data['registrationStatus'] == 'approved' ? driverConsole(doc.id, data) : status(data); }));
  Widget registration() => ListView(padding: const EdgeInsets.all(18), children: [const Icon(Icons.local_taxi, size: 70, color: Color(0xfff45b22)), Text('Join Namma Partner Service', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)), const Text('Admin verifies your identity, vehicle and payout details before Service ON is enabled.', textAlign: TextAlign.center), const SizedBox(height: 18), field(name, 'Partner name'), field(phone, '10-digit mobile number'), DropdownButtonFormField<String>(initialValue: vehicleType, decoration: const InputDecoration(labelText: 'Service type'), items: const ['Auto','Car / Cab','Bike','Goods Vehicle','Tempo Traveller','Bus','Truck'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => vehicleType = v!)), const SizedBox(height: 12), field(vehicleNumber, 'Vehicle number · KA 27 AB 1234'), field(governmentIdLast4, 'Government ID · last 4 digits only'), field(bankName, 'Bank name'), field(bankAccountLast4, 'Bank account · last 4 digits only'), field(bankIfsc, 'Bank IFSC code'), CheckboxListTile(contentPadding: EdgeInsets.zero, value: documentConsent, onChanged: (value) => setState(() => documentConsent = value == true), title: const Text('I will show the original ID, live photo and bank passbook to the authorised admin.'), subtitle: const Text('Full document numbers are not stored in this form.')), const SizedBox(height: 14), FilledButton(onPressed: saving ? null : register, child: Text(saving ? 'Registering…' : 'Register Partner Service'))]);
  Widget field(TextEditingController c, String label) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: c, decoration: InputDecoration(labelText: label)));
  Widget status(Map<String, dynamic> data) { final value = data['registrationStatus']?.toString() ?? 'pending'; return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(value == 'rejected' ? Icons.cancel : Icons.hourglass_top, size: 70, color: value == 'rejected' ? Colors.red : Colors.orange), Text(data['name']?.toString() ?? 'Partner', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)), Text(value == 'rejected' ? 'Registration was not approved.' : 'Waiting for owner verification.'), Text(value.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800))])); }
  Widget driverConsole(String id, Map<String, dynamic> data) => ListView(padding: const EdgeInsets.all(16), children: [
    Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.local_taxi)), title: Text(data['name']?.toString() ?? 'Partner', style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${data['vehicleType']} · ${data['vehicleNumber']}\n✓ Owner verified'), isThreeLine: true)),
    Card(child: ListTile(leading: const Icon(Icons.account_balance_wallet, color: Color(0xfff45b22)), title: const Text('TRAVEL WALLET'), subtitle: Text('₹${data['walletBalance'] ?? 0} balance\n₹${data['commissionPerTrip'] ?? 0} platform fee after completed trip'), isThreeLine: true)),
    SwitchListTile(tileColor: data['online'] == true ? const Color(0xffdcfce7) : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Text(data['online'] == true ? 'READY FOR RIDES' : 'SERVICE OFF', style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(data['online'] == true ? 'Live matching is active.' : 'Your location is not being shared.'), value: data['online'] == true, onChanged: (value) => FirebaseFirestore.instance.collection('driverPartners').doc(id).update({'online': value, 'updatedAt': FieldValue.serverTimestamp()})),
    const SizedBox(height: 16), Text('Active & matching requests', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800)),
    if (data['online'] != true)
      const Padding(padding: EdgeInsets.all(24), child: Text('Turn Service ON to receive matching requests.', textAlign: TextAlign.center))
    else
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('driverJobs').where('vehicleType', isEqualTo: data['vehicleType']).limit(30).snapshots(),
        builder: (_, snapshot) {
          if (snapshot.hasError) return const Padding(padding: EdgeInsets.all(24), child: Text('Could not load matching requests. Check Firestore rules deployment.', textAlign: TextAlign.center));
          final rides = (snapshot.data?.docs ?? []).where((job) {
            final jobData = job.data();
            final assigned = jobData['assignedDriverId'];
            return ['pending', 'assigned', 'arrived', 'in_progress', 'picked_up'].contains(jobData['status'])
                && (assigned == null || assigned == id);
          }).toList();
          if (rides.isEmpty) return const Padding(padding: EdgeInsets.all(24), child: Text('No matching request now. Keep Service ON.', textAlign: TextAlign.center));
          return Column(children: rides.map((job) => driverJobCard(job, id)).toList());
        },
      ),
  ]);

  Widget driverJobCard(QueryDocumentSnapshot<Map<String, dynamic>> job, String driverId) {
    final data = job.data();
    final status = data['status']?.toString() ?? 'pending';
    final assignedToMe = data['assignedDriverId'] == driverId;
    return Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ListTile(
          leading: Icon(data['category'] == 'delivery' ? Icons.delivery_dining : Icons.local_taxi, color: const Color(0xfff45b22)),
          title: Text('${data['publicPickup'] ?? 'Ranebennur pickup'} → ${data['publicDestination'] ?? 'Protected destination'}'),
          subtitle: Text('${data['travelScope'] ?? data['serviceType'] ?? 'travel'} · ${status.replaceAll('_', ' ').toUpperCase()}'),
          trailing: PopupMenuButton<String>(
            onSelected: (action) => rideAction(job.reference, action, driverId),
            itemBuilder: (_) => rideActions(status, data['category']?.toString() ?? 'travel'),
          ),
        ),
        if (assignedToMe)
          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance.collection('orders').doc(data['orderId']?.toString() ?? job.id).get(),
            builder: (_, orderSnapshot) {
              if (orderSnapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
              final order = orderSnapshot.data?.data();
              if (order == null) return const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 14), child: Text('Assigned. Exact trip details are loading.'));
              final customerPhone = (order['customerPhone'] ?? '').toString();
              final pickup = (order['pickup'] ?? order['pickupAddress'] ?? '').toString();
              final destination = (order['destination'] ?? order['deliveryAddress'] ?? '').toString();
              final pickupLatitude = order['pickupLatitude'] as num?;
              final pickupLongitude = order['pickupLongitude'] as num?;
              final destinationLatitude = (order['destinationLatitude'] ?? order['deliveryLatitude']) as num?;
              final destinationLongitude = (order['destinationLongitude'] ?? order['deliveryLongitude']) as num?;
              return Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xfffff4ed), borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Assigned details\nPickup: ${pickup.isEmpty ? '—' : pickup}\nDestination: ${destination.isEmpty ? '—' : destination}\nCustomer: ${order['customerName'] ?? '—'} · ${customerPhone.isEmpty ? '—' : customerPhone}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 6, children: [
                    if (RegExp(r'^[6-9]\d{9}$').hasMatch(customerPhone))
                      OutlinedButton.icon(onPressed: () => LinkService.call('+91$customerPhone'), icon: const Icon(Icons.call, size: 18), label: const Text('Call customer')),
                    if (pickupLatitude != null && pickupLongitude != null)
                      OutlinedButton.icon(onPressed: () => LinkService.mapCoordinates(pickupLatitude, pickupLongitude), icon: const Icon(Icons.pin_drop, size: 18), label: const Text('Pickup map'))
                    else if (pickup.isNotEmpty)
                      OutlinedButton.icon(onPressed: () => LinkService.mapSearch(pickup), icon: const Icon(Icons.pin_drop, size: 18), label: const Text('Pickup map')),
                    if (destinationLatitude != null && destinationLongitude != null)
                      OutlinedButton.icon(onPressed: () => LinkService.mapCoordinates(destinationLatitude, destinationLongitude), icon: const Icon(Icons.flag, size: 18), label: const Text('Destination map'))
                    else if (destination.isNotEmpty)
                      OutlinedButton.icon(onPressed: () => LinkService.mapSearch(destination), icon: const Icon(Icons.flag, size: 18), label: const Text('Destination map')),
                  ]),
                ]),
              );
            },
          ),
      ]),
    );
  }

  List<PopupMenuEntry<String>> rideActions(String status, String category) => switch ((status, category)) {
    ('pending', _) => const [PopupMenuItem(value: 'assigned', child: Text('Accept'))],
    ('assigned', 'delivery') => const [PopupMenuItem(value: 'picked_up', child: Text('Confirm pickup OTP')), PopupMenuItem(value: 'cancelled', child: Text('Cancel'))],
    ('picked_up', 'delivery') => const [PopupMenuItem(value: 'completed', child: Text('Confirm delivery OTP')), PopupMenuItem(value: 'cancelled', child: Text('Cancel'))],
    ('assigned', _) => const [PopupMenuItem(value: 'arrived', child: Text('I arrived')), PopupMenuItem(value: 'cancelled', child: Text('Cancel'))],
    ('arrived', _) => const [PopupMenuItem(value: 'in_progress', child: Text('Start with OTP')), PopupMenuItem(value: 'cancelled', child: Text('Cancel'))],
    ('in_progress', _) => const [PopupMenuItem(value: 'completed', child: Text('Complete')), PopupMenuItem(value: 'cancelled', child: Text('Cancel'))],
    _ => const [],
  };
  Future<void> register() async { if (name.text.trim().length < 2 || !RegExp(r'^[6-9]\d{9}$').hasMatch(phone.text.trim()) || vehicleNumber.text.trim().length < 5 || !RegExp(r'^\d{4}$').hasMatch(governmentIdLast4.text.trim()) || bankName.text.trim().length < 2 || !RegExp(r'^\d{4}$').hasMatch(bankAccountLast4.text.trim()) || !RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(bankIfsc.text.trim().toUpperCase()) || !documentConsent) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete the partner, vehicle and protected document-verification checklist.'))); return; } setState(() => saving = true); try { await FirebaseFirestore.instance.collection('driverPartners').doc(uid).set({'ownerUid': uid, 'name': name.text.trim(), 'phone': phone.text.trim(), 'vehicleType': vehicleType, 'vehicleNumber': vehicleNumber.text.trim().toUpperCase(), 'governmentIdLast4': governmentIdLast4.text.trim(), 'bankName': bankName.text.trim(), 'bankAccountLast4': bankAccountLast4.text.trim(), 'bankIfsc': bankIfsc.text.trim().toUpperCase(), 'documentConsent': true, 'registrationStatus': 'pending', 'online': false, 'walletBalance': 0, 'commissionPerTrip': 0, 'documentsStatus': 'awaiting_admin_originals', 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()}); } finally { if (mounted) setState(() => saving = false); } }
  Future<void> rideAction(DocumentReference<Map<String, dynamic>> job, String action, String driverId) async {
    final initialJob = await job.get();
    final jobData = initialJob.data();
    if (jobData == null) return;
    final order = FirebaseFirestore.instance.collection('orders').doc(jobData['orderId']?.toString() ?? job.id);
    final initialOrder = await order.get();
    final tripShareCode = initialOrder.data()?['tripShareCode']?.toString();
    final driverCommission = action == 'completed'
        ? ((await FirebaseFirestore.instance.collection('driverPartners').doc(driverId).get()).data()?['commissionPerTrip'] as num? ?? 0)
        : 0;

    final deliveryOtpStep = jobData['category'] == 'delivery' && (action == 'picked_up' || action == 'completed');
    if (action == 'in_progress' || deliveryOtpStep) {
      final orderSnapshot = await order.get();
      final otpField = action == 'picked_up' ? 'pickupOtp' : action == 'completed' ? 'deliveryOtp' : 'tripStartOtp';
      final expected = orderSnapshot.data()?[otpField]?.toString();
      final otp = TextEditingController();
      if (!mounted) return;
      final entered = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(action == 'picked_up' ? 'Pickup OTP from sender' : action == 'completed' ? 'Delivery OTP from receiver' : 'Customer trip-start OTP'),
          content: TextField(controller: otp, keyboardType: TextInputType.number, maxLength: 4),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, otp.text.trim()), child: const Text('Verify & start')),
          ],
        ),
      );
      otp.dispose();
      if (entered == null) return;
      if (expected == null || entered != expected) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect OTP. Ask the customer to open My Bookings.')));
        return;
      }
    }

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final freshJob = await transaction.get(job);
        final freshData = freshJob.data();
        if (freshData == null) throw StateError('Request is no longer available.');
        final assigned = freshData['assignedDriverId'];
        if (action == 'assigned') {
          if (freshData['status'] != 'pending' || assigned != null) throw StateError('Another partner already accepted this request.');
          transaction.update(job, {'status': 'assigned', 'assignedDriverId': driverId, 'updatedAt': FieldValue.serverTimestamp()});
          transaction.update(order, {'status': 'assigned', 'driverId': driverId, 'updatedAt': FieldValue.serverTimestamp()});
          if (tripShareCode != null) transaction.update(FirebaseFirestore.instance.collection('tripShares').doc(tripShareCode), {'status': 'assigned', 'updatedAt': FieldValue.serverTimestamp()});
        } else {
          if (assigned != driverId) throw StateError('This request is not assigned to you.');
          transaction.update(job, {'status': action, 'updatedAt': FieldValue.serverTimestamp()});
          transaction.update(order, {'status': action, 'updatedAt': FieldValue.serverTimestamp()});
          if (tripShareCode != null) transaction.update(FirebaseFirestore.instance.collection('tripShares').doc(tripShareCode), {'status': action, 'updatedAt': FieldValue.serverTimestamp()});
          if (action == 'completed') {
            final gross = (initialOrder.data()?['quotedFare'] ?? initialOrder.data()?['estimatedFare'] ?? 0) as num;
            final commission = driverCommission;
            transaction.set(FirebaseFirestore.instance.collection('driverSettlements').doc('${order.id}_$driverId'), {
              'settlementId': '${order.id}_$driverId', 'orderId': order.id, 'driverId': driverId,
              'grossAmount': gross, 'commissionAmount': commission, 'netPayable': gross - commission,
              'status': 'pending', 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      });
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))));
    }
  }
}
