import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/firestore_service.dart';
import '../services/link_service.dart';

class CommunityMarketScreen extends StatefulWidget {
  const CommunityMarketScreen({super.key});

  @override
  State<CommunityMarketScreen> createState() => _CommunityMarketScreenState();
}

class _CommunityMarketScreenState extends State<CommunityMarketScreen> {
  final Map<String, int> cart = {};

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Namma Market'),
          actions: [
            Badge(
              label: Text('${cart.values.fold<int>(0, (a, b) => a + b)}'),
              child: IconButton(icon: const Icon(Icons.shopping_cart), onPressed: cart.isEmpty ? null : checkout),
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('marketProducts').where('active', isEqualTo: true).snapshots(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final products = snapshot.data?.docs ?? [];
            if (products.isEmpty) {
              return const _EmptyState(
                icon: Icons.storefront,
                title: 'Market is opening soon',
                message: 'Verified local products added by the market administrator will appear here.',
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(14),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .72, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: products.length,
              itemBuilder: (_, i) {
                final product = products[i];
                final data = product.data();
                final price = (data['price'] as num?)?.toDouble() ?? 0;
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Center(child: Icon(Icons.local_mall, size: 58, color: Theme.of(context).colorScheme.primary))),
                      Text(data['name']?.toString() ?? 'Local product', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(data['sellerName']?.toString() ?? 'Verified seller', maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: double.infinity, child: FilledButton.tonal(onPressed: () => setState(() => cart[product.id] = (cart[product.id] ?? 0) + 1), child: const Text('Add'))),
                    ]),
                  ),
                );
              },
            );
          },
        ),
      );

  Future<void> checkout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final items = cart.entries.map((e) => {'productId': e.key, 'quantity': e.value}).toList();
    final ref = await FirebaseFirestore.instance.collection('marketOrders').add({
      'userId': user.uid,
      'items': items,
      'status': 'pending_confirmation',
      'contactProtected': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (!mounted) return;
    setState(cart.clear);
    await showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('Order requested'), content: Text('Reference: ${ref.id}\nThe seller confirms stock and final amount before payment.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
  }
}

class LocalSaleScreen extends StatefulWidget {
  const LocalSaleScreen({super.key});
  @override
  State<LocalSaleScreen> createState() => _LocalSaleScreenState();
}

class _LocalSaleScreenState extends State<LocalSaleScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Buy & Sell'), actions: [
          IconButton(tooltip: 'My Sale Ads', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MySaleAdsScreen())), icon: const Icon(Icons.receipt_long_outlined)),
          IconButton(onPressed: createListing, icon: const Icon(Icons.add_circle_outline)),
        ]),
        floatingActionButton: FloatingActionButton.extended(onPressed: createListing, icon: const Icon(Icons.add), label: const Text('Sell an item')),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('saleListings').where('status', whereIn: const ['trial_live', 'verified_free', 'payment_pending', 'paid_active']).orderBy('createdAt', descending: true).snapshots(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return const _EmptyState(icon: Icons.error_outline, title: 'Could not load Sale advertisements', message: 'Deploy the included Firestore rules and indexes, then try again.');
            final now = DateTime.now();
            final listings = (snapshot.data?.docs ?? []).where((doc) {
              final expiry = doc.data()['expiresAt'];
              return expiry is! Timestamp || expiry.toDate().isAfter(now);
            }).toList();
            if (listings.isEmpty) return const _EmptyState(icon: Icons.sell, title: 'No active advertisements yet', message: 'Post an item free for five hours. Admin can verify it for 24 hours.');
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
              itemCount: listings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final data = listings[i].data();
                final phone = (data['sellerPhone'] ?? '').toString();
                final contactVisible = data['contactVisible'] == true && RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
                final imageUrls = (data['imageUrls'] as List?)?.whereType<String>().toList() ?? const <String>[];
                return Card(child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 8, 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    if (imageUrls.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(imageUrls.first, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image_outlined, size: 52))),
                        ),
                      ),
                    ListTile(
                      leading: imageUrls.isEmpty ? const CircleAvatar(child: Icon(Icons.inventory_2)) : null,
                      title: Text(data['title']?.toString() ?? 'Item'),
                      subtitle: Text('${data['category'] ?? 'Other'} · ${data['condition'] ?? 'Used'} · 📍 ${data['area'] ?? 'Ranebennur'}\n${contactVisible ? '+91 $phone' : 'Contact hidden until ₹100 activation'}'),
                      trailing: Text('₹${data['price'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      isThreeLine: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('${data['interestCount'] ?? 0} interested', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          OutlinedButton(onPressed: () => registerInterest(listings[i]), child: const Text("I'm Interested")),
                          if (contactVisible) IconButton.filledTonal(tooltip: 'Call seller', onPressed: () => LinkService.call(phone), icon: const Icon(Icons.call)),
                        ],
                      ),
                    ),
                  ]),
                ));
              },
            );
          },
        ),
      );

  Future<void> createListing() async {
    final sellerName = TextEditingController();
    final sellerPhone = TextEditingController();
    final title = TextEditingController();
    final price = TextEditingController();
    final description = TextEditingController();
    final purchaseYear = TextEditingController();
    final area = TextEditingController(text: 'Ranebennur');
    final form = GlobalKey<FormState>();
    var category = 'Vehicles';
    var condition = 'Good';
    var itemType = 'Car';
    var selectedPhotos = <XFile>[];
    const categoryItems = <String, List<String>>{
      'Vehicles': ['Car', 'Bike', 'Auto', 'Tractor', 'Other vehicle'],
      'Gadgets': ['Mobile phone', 'Camera', 'Laptop', 'Tablet', 'Other gadget'],
      'Home Appliances': ['Refrigerator', 'Washing machine', 'Television', 'AC', 'Mixer / Grinder'],
      'Furniture': ['Sofa', 'Bed', 'Table', 'Chair', 'Cupboard'],
      'Electronics': ['Speaker', 'Inverter', 'Computer', 'Printer', 'Other electronics'],
      'Agricultural Equipment': ['Pump set', 'Sprayer', 'Tools', 'Small machinery'],
      'Other': ['Books', 'Sports', 'Fashion', 'Other used item'],
    };
    final accepted = await showDialog<bool>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (_, setDialogState) => AlertDialog(
      title: const Text('Sell an item'),
      content: Form(key: form, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(initialValue: category, decoration: const InputDecoration(labelText: 'Category'), items: categoryItems.keys.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setDialogState(() { category = v!; itemType = categoryItems[category]!.first; })),
        DropdownButtonFormField<String>(key: ValueKey(category), initialValue: itemType, decoration: const InputDecoration(labelText: 'Item type'), items: categoryItems[category]!.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setDialogState(() => itemType = v!)),
        TextFormField(controller: sellerName, decoration: const InputDecoration(labelText: 'Seller name'), validator: required),
        TextFormField(controller: sellerPhone, keyboardType: TextInputType.phone, maxLength: 10, decoration: const InputDecoration(labelText: 'Verified mobile number'), validator: (v) => RegExp(r'^[6-9]\d{9}$').hasMatch(v?.trim() ?? '') ? null : 'Enter a valid mobile number'),
        TextFormField(controller: title, maxLength: 120, decoration: const InputDecoration(labelText: 'Advertisement title'), validator: required),
        TextFormField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Expected price'), validator: (v) => double.tryParse(v ?? '') == null ? 'Enter a valid price' : null),
        TextFormField(controller: purchaseYear, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Purchase year (optional)')),
        DropdownButtonFormField<String>(initialValue: condition, decoration: const InputDecoration(labelText: 'Condition'), items: const ['Like new','Good','Fair','Needs repair'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setDialogState(() => condition = v!)),
        TextFormField(controller: area, decoration: const InputDecoration(labelText: 'Area'), validator: required),
        TextFormField(controller: description, maxLength: 1000, maxLines: 3, decoration: const InputDecoration(labelText: 'Description'), validator: required),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final photos = await ImagePicker().pickMultiImage(imageQuality: 82, limit: 8);
            if (photos.isNotEmpty) setDialogState(() => selectedPhotos = photos.take(8).toList());
          },
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(selectedPhotos.isEmpty ? 'Add item photos (up to 8)' : '${selectedPhotos.length} photo(s) selected'),
        ),
        if (selectedPhotos.isNotEmpty)
          Wrap(spacing: 4, children: selectedPhotos.map((photo) => Chip(label: Text(photo.name, overflow: TextOverflow.ellipsis))).toList()),
        const Padding(padding: EdgeInsets.only(top: 10), child: Text('Free start: live for 5 hours → Admin verification → free for 24 hours → ₹100 for 30 days and contact display.', style: TextStyle(fontSize: 12))),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          if (!form.currentState!.validate()) return;
          if (_containsContact(title.text) || _containsContact(description.text)) {
            ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Do not type phone numbers, WhatsApp links or websites inside the advertisement.')));
            return;
          }
          Navigator.pop(dialogContext, true);
        }, child: const Text('Post free for 5 hours')),
      ],
    )));
    if (accepted == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final reference = FirebaseFirestore.instance.collection('saleListings').doc();
        try {
          final recentListings = await FirebaseFirestore.instance.collection('saleListings').where('sellerId', isEqualTo: user.uid).get();
          final duplicateSince = DateTime.now().subtract(const Duration(days: 30));
          final normalizedTitle = title.text.trim().toLowerCase();
          final duplicate = recentListings.docs.any((document) {
            final data = document.data();
            final createdAt = data['createdAt'];
            return data['title']?.toString().trim().toLowerCase() == normalizedTitle
              && (createdAt is! Timestamp || createdAt.toDate().isAfter(duplicateSince));
          });
          if (duplicate) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This same item was already posted recently. Open My Sale Ads to continue the existing advertisement.')));
            return;
          }
          final imageUrls = <String>[];
          for (var index = 0; index < selectedPhotos.length; index++) {
            final photo = selectedPhotos[index];
            final bytes = await photo.readAsBytes();
            final extension = photo.name.contains('.') ? photo.name.split('.').last.toLowerCase() : 'jpg';
            final storageReference = FirebaseStorage.instance.ref('saleListings/${user.uid}/${reference.id}/$index.$extension');
            await storageReference.putData(bytes, SettableMetadata(contentType: _imageContentType(extension)));
            imageUrls.add(await storageReference.getDownloadURL());
          }
          final expiresAt = Timestamp.fromDate(DateTime.now().add(const Duration(hours: 5)));
          final batch = FirebaseFirestore.instance.batch();
          batch.set(reference, {'listingId': reference.id, 'reference': 'SALE-${reference.id.substring(0, 8).toUpperCase()}', 'sellerId': user.uid, 'sellerName': sellerName.text.trim(), 'title': title.text.trim(), 'category': category, 'itemType': itemType, 'condition': condition, 'purchaseYear': int.tryParse(purchaseYear.text.trim()), 'area': area.text.trim(), 'price': double.parse(price.text), 'description': description.text.trim(), 'imageUrls': imageUrls, 'status': 'trial_live', 'contactVisible': false, 'contactProtected': true, 'interestCount': 0, 'trialExpiresAt': expiresAt, 'expiresAt': expiresAt, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
          batch.set(FirebaseFirestore.instance.collection('saleListingPrivate').doc(reference.id), {'listingId': reference.id, 'sellerId': user.uid, 'sellerPhone': sellerPhone.text.trim(), 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
          await batch.commit();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Advertisement is live for 5 hours. Reference ${reference.id.substring(0, 8).toUpperCase()}')));
        } catch (_) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not upload the advertisement. Check internet access and Firebase Storage, then try again.')));
        }
      }
    }
    sellerName.dispose(); sellerPhone.dispose(); title.dispose(); price.dispose(); description.dispose(); purchaseYear.dispose(); area.dispose();
  }

  Future<void> registerInterest(QueryDocumentSnapshot<Map<String, dynamic>> listing) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (listing.data()['sellerId'] == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You cannot register interest in your own item.')));
      return;
    }
    final interest = FirebaseFirestore.instance.collection('saleInterests').doc('${listing.id}_${user.uid}');
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final existing = await transaction.get(interest);
        if (existing.exists) return;
        transaction.set(interest, {'listingId': listing.id, 'buyerId': user.uid, 'status': 'interested', 'createdAt': FieldValue.serverTimestamp()});
        transaction.update(listing.reference, {'interestCount': FieldValue.increment(1), 'updatedAt': FieldValue.serverTimestamp()});
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Interest recorded. The seller sees only the interested-buyer count.')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your interest was already recorded or the advertisement is no longer active.')));
    }
  }

  static String? required(String? value) => (value?.trim().isEmpty ?? true) ? 'Required' : null;

  static bool _containsContact(String value) {
    final normalized = value.toLowerCase();
    return RegExp(r'\d{10,}').hasMatch(normalized)
      || normalized.contains('whatsapp')
      || normalized.contains('wa.me')
      || normalized.contains('http://')
      || normalized.contains('https://')
      || normalized.contains('www.');
  }

  static String _imageContentType(String extension) => switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    'gif' => 'image/gif',
    _ => 'image/jpeg',
  };
}

class MySaleAdsScreen extends StatefulWidget {
  const MySaleAdsScreen({super.key});
  @override
  State<MySaleAdsScreen> createState() => _MySaleAdsScreenState();
}

class _MySaleAdsScreenState extends State<MySaleAdsScreen> {
  final requestingPayment = <String>{};

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('My Sale Ads')),
      body: user == null
          ? const _EmptyState(icon: Icons.lock_outline, title: 'Please sign in', message: 'Sign in to see the advertisements you have posted.')
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('saleListings').where('sellerId', isEqualTo: user.uid).orderBy('createdAt', descending: true).snapshots(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return const _EmptyState(icon: Icons.error_outline, title: 'Could not load your advertisements', message: 'Deploy the included Firestore rules and indexes, then try again.');
                final listings = snapshot.data?.docs ?? [];
                if (listings.isEmpty) return const _EmptyState(icon: Icons.sell_outlined, title: 'You have not posted any items yet', message: 'Use "Sell an item" on the Buy & Sell screen to post your first free advertisement.');
                return ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: listings.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => listingCard(listings[i]),
                );
              },
            ),
    );
  }

  Widget listingCard(QueryDocumentSnapshot<Map<String, dynamic>> listing) {
    final data = listing.data();
    final status = data['status']?.toString() ?? 'trial_live';
    final expiresAt = data['expiresAt'];
    final expiryText = expiresAt is Timestamp
        ? (expiresAt.toDate().isAfter(DateTime.now())
            ? 'Until ${expiresAt.toDate().day}/${expiresAt.toDate().month}/${expiresAt.toDate().year} ${expiresAt.toDate().hour.toString().padLeft(2, '0')}:${expiresAt.toDate().minute.toString().padLeft(2, '0')}'
            : 'Expired')
        : '';
    final canRequestPayment = status == 'trial_live' || status == 'verified_free';
    final requesting = requestingPayment.contains(listing.id);
    return Card(child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(data['title']?.toString() ?? 'Item', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 4),
        Text('${data['category'] ?? 'Other'} · ₹${data['price'] ?? 0} · 📍 ${data['area'] ?? 'Ranebennur'}', style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Chip(label: Text(statusLabel(status)), visualDensity: VisualDensity.compact),
          if (expiryText.isNotEmpty) Text(expiryText, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text('${data['interestCount'] ?? 0} interested', style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ]),
        const SizedBox(height: 10),
        if (canRequestPayment)
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: requesting ? null : () => requestPaidActivation(listing),
            icon: const Icon(Icons.payments_outlined),
            label: Text(requesting ? 'Sending…' : 'Request ₹100 activation (30 days)'),
          ))
        else if (status == 'payment_pending')
          const Text('₹100 activation requested. Admin will confirm payment and activate this ad for 30 days.', style: TextStyle(fontSize: 12, color: Colors.black54))
        else if (status == 'paid_active')
          const Text('Active for 30 days. Your phone number is visible to interested buyers.', style: TextStyle(fontSize: 12, color: Colors.black54)),
      ]),
    ));
  }

  String statusLabel(String status) => switch (status) {
    'trial_live' => 'Free trial · 5 hours',
    'verified_free' => 'Admin verified · free 24 hours',
    'payment_pending' => 'Payment requested',
    'paid_active' => 'Active · 30 days',
    'sold' => 'Sold',
    'rejected' => 'Rejected',
    _ => status,
  };

  Future<void> requestPaidActivation(QueryDocumentSnapshot<Map<String, dynamic>> listing) async {
    setState(() => requestingPayment.add(listing.id));
    try {
      await listing.reference.update({'status': 'payment_pending', 'updatedAt': FieldValue.serverTimestamp()});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request sent. Pay ₹100 as guided by Admin; the ad activates for 30 days once confirmed.')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not send the request. Please try again.')));
    } finally {
      if (mounted) setState(() => requestingPayment.remove(listing.id));
    }
  }
}

class RequirementsScreen extends StatefulWidget {
  const RequirementsScreen({super.key});
  @override
  State<RequirementsScreen> createState() => _RequirementsScreenState();
}

class _RequirementsScreenState extends State<RequirementsScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final category = TextEditingController();
  final title = TextEditingController();
  final details = TextEditingController();
  final area = TextEditingController(text: 'Ranebennur');
  final budget = TextEditingController();
  DateTime requiredDate = DateTime.now().add(const Duration(days: 1));
  bool sending = false;

  @override
  void dispose() {
    for (final c in [name, phone, category, title, details, area, budget]) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My Requirements')),
    body: Form(key: formKey, child: ListView(padding: const EdgeInsets.all(18), children: [
      const Icon(Icons.manage_search, size: 76, color: Colors.deepOrange),
      const Text('Cannot find the right service or product? Describe it once. Verified providers respond through Namma Ranebennur.', textAlign: TextAlign.center),
      const SizedBox(height: 20),
      field(name, 'Your name'),
      field(phone, 'Mobile number', phoneField: true),
      field(category, 'Category', hint: 'Example: Workers, Events, Machinery…'),
      field(title, 'Short title', hint: 'Example: Need a verified tractor mechanic'),
      TextFormField(controller: details, minLines: 4, maxLines: 8, maxLength: 500, decoration: const InputDecoration(labelText: 'Describe what you need', border: OutlineInputBorder()), validator: required),
      field(area, 'Area'),
      ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black26)),
        title: const Text('Required by'),
        subtitle: Text('${requiredDate.day}/${requiredDate.month}/${requiredDate.year}'),
        trailing: const Icon(Icons.calendar_month),
        onTap: chooseDate,
      ),
      const SizedBox(height: 12),
      field(budget, 'Expected budget ₹ (optional)', number: true, required: false),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: sending ? null : submit, icon: const Icon(Icons.send), label: Text(sending ? 'Sending…' : 'Send requirement')),
    ])),
  );

  static String? required(String? value) => (value?.trim().isEmpty ?? true) ? 'Required' : null;

  Widget field(TextEditingController controller, String label, {bool phoneField = false, bool number = false, bool required = true, String? hint}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: phoneField || number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (!required && text.isEmpty) return null;
        if (text.isEmpty) return 'Required';
        if (phoneField && !RegExp(r'^[6-9]\d{9}$').hasMatch(text)) return 'Enter a valid mobile number';
        return null;
      },
    ),
  );

  Future<void> chooseDate() async {
    final picked = await showDatePicker(context: context, initialDate: requiredDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null) setState(() => requiredDate = picked);
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() => sending = true);
    try {
      await FirestoreService().createRequirement({
        'name': name.text.trim(),
        'phone': phone.text.trim(),
        'category': category.text.trim(),
        'title': title.text.trim(),
        'details': details.text.trim(),
        'area': area.text.trim(),
        'requiredDate': requiredDate,
        'budget': int.tryParse(budget.text.trim()) ?? 0,
      });
      for (final c in [name, phone, category, title, details, budget]) { c.clear(); }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Requirement sent successfully.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not send: $error')));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon; final String title; final String message;
  const _EmptyState({required this.icon, required this.title, required this.message});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 76, color: Colors.deepOrange), const SizedBox(height: 16), Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center), const SizedBox(height: 8), Text(message, textAlign: TextAlign.center)])));
}
