import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/market_catalog.dart';

class MarketCatalogScreen extends StatefulWidget {
  const MarketCatalogScreen({super.key});
  @override
  State<MarketCatalogScreen> createState() => _MarketCatalogScreenState();
}

class _MarketCatalogScreenState extends State<MarketCatalogScreen> {
  String category = 'Vegetables';
  String search = '';
  final Map<String, int> cart = {};
  static const categoryEmoji = <String, String>{
    'Vegetables': '🥕', 'Fruits': '🍎', 'Groceries': '🛒', 'Snacks': '🍪',
    'Meat & Eggs': '🍗', 'Stationery': '✏️', 'Dairy & Breakfast': '🥛',
    'Drinks': '🥤', 'Personal Care': '🧴', 'Cleaning Essentials': '🧼',
    'Baby & Pet Care': '🍼', 'Bakery': '🍞',
  };

  int get cartCount => cart.values.fold(0, (total, value) => total + value);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xfffff8f1),
    appBar: AppBar(
      title: const Text('Namma Market'),
      actions: [Padding(padding: const EdgeInsets.only(right: 14), child: Badge(label: Text('$cartCount'), isLabelVisible: cartCount > 0, child: IconButton(onPressed: cart.isEmpty ? null : openCart, icon: const Icon(Icons.shopping_cart_rounded))))],
    ),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('marketProducts').snapshots(),
      builder: (_, snapshot) {
        final overrides = <String, Map<String, dynamic>>{for (final doc in snapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[]) doc.id: doc.data()};
        final items = starterMarketItems.map((base) {
          final value = overrides[base.id];
          if (value == null) return base;
          return base.copyWith(name: value['name']?.toString(), category: value['category']?.toString(), emoji: value['emoji']?.toString(), price: (value['price'] as num?)?.toDouble(), unit: value['unit']?.toString());
        }).where((item) => overrides[item.id]?['active'] != false && item.category == category && item.name.toLowerCase().contains(search.toLowerCase())).toList();
        return Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 8), child: TextField(onChanged: (value) => setState(() => search = value), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search market products…'))),
          SizedBox(height: 54, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 14), scrollDirection: Axis.horizontal, itemCount: marketCategories.length, separatorBuilder: (_, _) => const SizedBox(width: 7), itemBuilder: (_, index) { final value = marketCategories[index]; return ChoiceChip(avatar: Text(categoryEmoji[value] ?? '📦'), label: Text(value), selected: category == value, onSelected: (_) => setState(() => category = value)); })),
          Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 7), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(category, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800)), Text('${items.length} products', style: const TextStyle(color: Colors.black54))])),
          Expanded(child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 100), itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .72, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemBuilder: (_, index) { final item = items[index]; final count = cart[item.id] ?? 0; return Card(child: Padding(padding: const EdgeInsets.all(11), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(14), child: MasterMarketPhoto(item: item))),
              const SizedBox(height: 8), Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(item.unit, style: const TextStyle(fontSize: 11, color: Colors.black54)), Text('₹${item.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              if (count == 0) SizedBox(width: double.infinity, child: FilledButton.tonal(onPressed: () => setState(() => cart[item.id] = 1), child: const Text('Add')))
              else Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconButton(onPressed: () => setState(() { if (count == 1) { cart.remove(item.id); } else { cart[item.id] = count - 1; } }), icon: const Icon(Icons.remove_circle_outline)), Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(onPressed: () => setState(() => cart[item.id] = count + 1), icon: const Icon(Icons.add_circle))]),
            ]))); },
          )),
        ]);
      },
    ),
    bottomSheet: cart.isEmpty ? null : SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(14, 8, 14, 8), child: SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: openCart, icon: const Icon(Icons.shopping_cart_checkout), label: Text('View cart · $cartCount item${cartCount == 1 ? '' : 's'}'))))),
  );

  Future<void> openCart() async {
    final address = TextEditingController();
    final phone = TextEditingController();
    final itemTotal = cart.entries.fold<double>(0, (total, entry) => total + starterMarketItems.firstWhere((x) => x.id == entry.key).price * entry.value);
    const delivery = 10.0;
    const handling = 4.0;
    final formKey = GlobalKey<FormState>();
    final accepted = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true, showDragHandle: true,
      builder: (sheetContext) => Padding(padding: EdgeInsets.fromLTRB(18, 4, 18, MediaQuery.viewInsetsOf(sheetContext).bottom + 20), child: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your cart', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800)), const SizedBox(height: 8),
        ...cart.entries.map((entry) { final item = starterMarketItems.firstWhere((x) => x.id == entry.key); return ListTile(contentPadding: EdgeInsets.zero, leading: Text(item.emoji, style: const TextStyle(fontSize: 28)), title: Text(item.name), subtitle: Text('${entry.value} × ${item.unit}'), trailing: Text('₹${(item.price * entry.value).toStringAsFixed(0)}')); }),
        const Divider(), summary('Item total', itemTotal), summary('Delivery starting charge', delivery), summary('Handling', handling), summary('Total', itemTotal + delivery + handling, strong: true),
        const SizedBox(height: 12), TextFormField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: '10-digit mobile number'), validator: (v) => RegExp(r'^[6-9]\d{9}$').hasMatch(v ?? '') ? null : 'Enter a valid number'), const SizedBox(height: 10),
        TextFormField(controller: address, minLines: 2, maxLines: 3, decoration: const InputDecoration(labelText: 'Delivery address / map link'), validator: (v) => (v?.trim().length ?? 0) >= 5 ? null : 'Enter the delivery address'),
        const SizedBox(height: 10), const Text('Payment: Cash on delivery / UPI after stock confirmation'), const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(sheetContext, true); }, child: const Text('Place order request'))),
      ])))),
    );
    if (accepted == true) await submitOrder(phone.text.trim(), address.text.trim(), itemTotal, delivery, handling);
    phone.dispose(); address.dispose();
  }

  Widget summary(String label, double amount, {bool strong = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontWeight: strong ? FontWeight.w800 : null)), Text('₹${amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: strong ? FontWeight.w800 : null))]));

  Future<void> submitOrder(String phone, String address, double subtotal, double delivery, double handling) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final items = cart.entries.map((entry) { final item = starterMarketItems.firstWhere((x) => x.id == entry.key); return {'productId': item.id, 'name': item.name, 'unit': item.unit, 'unitPrice': item.price, 'quantity': entry.value}; }).toList();
    final reference = await FirebaseFirestore.instance.collection('marketOrders').add({
      'userId': user.uid, 'customerPhone': phone, 'items': items, 'deliveryAddress': address,
      'subtotal': subtotal, 'deliveryCharge': delivery, 'handlingCharge': handling, 'total': subtotal + delivery + handling,
      'paymentMethod': 'cash_or_upi_after_confirmation', 'status': 'pending_stock_confirmation', 'contactProtected': true,
      'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
    });
    if (!mounted) return;
    setState(cart.clear);
    await showDialog<void>(context: context, builder: (_) => AlertDialog(icon: const Icon(Icons.check_circle, color: Colors.green, size: 48), title: const Text('Order requested'), content: Text('Reference: ${reference.id}\n\nThe verified store confirms stock and final amount before payment.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
  }
}

class MasterMarketPhoto extends StatelessWidget {
  const MasterMarketPhoto({super.key, required this.item});
  final MarketItem item;

  @override
  Widget build(BuildContext context) {
    final photoIndex = starterMarketItems.indexWhere((entry) => entry.id == item.id);
    if (photoIndex < 0 || photoIndex >= 48) {
      return Container(color: const Color(0xffffeadf), alignment: Alignment.center, child: Text(item.emoji, style: const TextStyle(fontSize: 48)));
    }
    return ClipRect(child: LayoutBuilder(builder: (_, constraints) {
      final width = constraints.maxWidth;
      final height = constraints.maxHeight;
      final column = photoIndex % 8;
      final row = photoIndex ~/ 8;
      return Transform.translate(
        offset: Offset(-width * column, -height * row),
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: width * 8,
          maxWidth: width * 8,
          minHeight: height * 6,
          maxHeight: height * 6,
          child: Image.asset('assets/images/market-products-v1.png', width: width * 8, height: height * 6, fit: BoxFit.fill),
        ),
      );
    }));
  }
}
