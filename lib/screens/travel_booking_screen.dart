import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/map_point.dart';
import '../models/service_category.dart';
import '../services/firestore_service.dart';
import '../services/route_distance_service.dart';
import 'location_picker_screen.dart';

class TravelBookingScreen extends StatefulWidget {
  final ServiceCategory vehicle;
  final String travelScope;
  const TravelBookingScreen({super.key, required this.vehicle, this.travelScope = 'within_city'});

  @override
  State<TravelBookingScreen> createState() => _TravelBookingScreenState();
}

class _TravelBookingScreenState extends State<TravelBookingScreen> {
  final key = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final pickup = TextEditingController();
  final destination = TextEditingController();
  final passengers = TextEditingController(text: '1');
  final goodsWeight = TextEditingController();
  final goodsItem = TextEditingController();
  final intermediateStops = TextEditingController();
  final luggage = TextEditingController();
  final notes = TextEditingController();
  String tripType = 'one_way';
  String schedule = 'now';
  DateTime dateTime = DateTime.now();
  MapPoint? pickupPoint;
  MapPoint? destinationPoint;
  double? routeDistanceKm;
  bool routeBusy = false;
  String? routeError;
  bool sending = false;

  bool get isGoods => widget.travelScope == 'goods_transport';
  bool get isOutstation => widget.travelScope == 'outstation';

  @override
  void dispose() {
    for (final c in [name, phone, pickup, destination, passengers, goodsWeight, goodsItem, intermediateStops, luggage, notes]) {
      c.dispose();
    }
    super.dispose();
  }

  String? required(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xfff45b22),
          foregroundColor: Colors.white,
          title: Text('Book ${widget.vehicle.title}', style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
        ),
        body: Form(
          key: key,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: Icon(widget.vehicle.icon, size: 38, color: const Color(0xfff45b22)),
                  title: Text(widget.vehicle.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${scopeLabel(widget.travelScope)} · Selected vehicle'),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Customer name'), validator: required),
              const SizedBox(height: 12),
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Mobile number'),
                validator: (v) => v != null && RegExp(r'^\d{10}$').hasMatch(v) ? null : 'Enter a 10-digit number',
              ),
              const SizedBox(height: 12),
              TextFormField(controller: pickup, decoration: const InputDecoration(labelText: 'Pickup location / address'), validator: required),
              const SizedBox(height: 8),
              mapLocationTile(
                point: pickupPoint,
                title: 'Choose pickup on Google Maps',
                confirmedTitle: 'Pickup pin confirmed',
                icon: Icons.location_on,
                onTap: () => pickMapPoint(true),
              ),
              const SizedBox(height: 12),
              TextFormField(controller: destination, decoration: const InputDecoration(labelText: 'Destination'), validator: required),
              const SizedBox(height: 8),
              mapLocationTile(
                point: destinationPoint,
                title: 'Choose destination on Google Maps',
                confirmedTitle: 'Destination pin confirmed',
                icon: Icons.flag,
                onTap: () => pickMapPoint(false),
              ),
              const SizedBox(height: 10),
              routeDistanceCard(),
              const SizedBox(height: 12),
              TextFormField(controller: intermediateStops, decoration: const InputDecoration(labelText: 'Intermediate stops (optional)')),
              const SizedBox(height: 16),
              const Text('Trip type', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                initialValue: tripType,
                items: (isOutstation
                    ? const [('one_way', 'One way'), ('round_trip', 'Round trip'), ('tour', 'Tour package')]
                    : isGoods
                        ? const [('one_way', 'One way'), ('round_trip', 'Round trip')]
                        : const [('one_way', 'One way'), ('local', 'Local hire')])
                    .map((item) => DropdownMenuItem(value: item.$1, child: Text(item.$2))).toList(),
                onChanged: (v) => setState(() => tripType = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: isGoods ? goodsWeight : passengers,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: isGoods ? 'Approximate goods weight (kg)' : 'Number of passengers'),
                validator: required,
              ),
              if (isGoods) ...[
                const SizedBox(height: 12),
                TextFormField(controller: goodsItem, decoration: const InputDecoration(labelText: 'What item are you sending?'), validator: required),
              ] else ...[
                const SizedBox(height: 12),
                TextFormField(controller: luggage, decoration: const InputDecoration(labelText: 'Luggage details (optional)')),
              ],
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'now', label: Text('Ride now'), icon: Icon(Icons.bolt)),
                  ButtonSegment(value: 'later', label: Text('Schedule'), icon: Icon(Icons.schedule)),
                ],
                selected: {schedule},
                onSelectionChanged: (v) => setState(() => schedule = v.first),
              ),
              if (schedule == 'later') ...[
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.grey)),
                  title: const Text('Pickup date and time'),
                  subtitle: Text('${dateTime.day}/${dateTime.month}/${dateTime.year}  ${TimeOfDay.fromDateTime(dateTime).format(context)}'),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: pickDateTime,
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Purpose / special requirements')),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: sending || routeBusy || routeDistanceKm == null ? null : submit,
                icon: const Icon(Icons.near_me),
                label: Text(sending ? 'Requesting…' : isOutstation ? 'Request Admin quote' : 'Request nearest vehicle'),
              ),
              const SizedBox(height: 10),
              const Text('Driver contact remains protected. Outstation driver assignment happens only after quote acceptance and advance verification.', textAlign: TextAlign.center),
            ],
          ),
        ),
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
          leading: Icon(icon, color: point == null ? const Color(0xfff45b22) : Colors.green),
          title: Text(point == null ? title : confirmedTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(point?.address ?? 'Tap to search or place the exact pin'),
          trailing: Icon(point == null ? Icons.chevron_right : Icons.check_circle, color: point == null ? null : Colors.green),
        ),
      );

  Widget routeDistanceCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xfffff3e9), borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            const Icon(Icons.route, color: Color(0xfff45b22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('GOOGLE MAP ROAD DISTANCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(
                    routeBusy
                        ? 'Calculating…'
                        : routeError ?? (routeDistanceKm == null ? 'Confirm both map locations' : '${routeDistanceKm!.toStringAsFixed(1)} km · fare updated automatically'),
                    style: TextStyle(fontWeight: FontWeight.w700, color: routeError == null ? null : Colors.red.shade700),
                  ),
                ],
              ),
            ),
            if (routeBusy) const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      );

  Future<void> pickMapPoint(bool isPickup) async {
    final result = await Navigator.push<MapPoint>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          title: isPickup ? 'Choose pickup location' : 'Choose destination',
          initialPoint: isPickup ? pickupPoint : destinationPoint,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (isPickup) {
        pickupPoint = result;
      } else {
        destinationPoint = result;
      }
      routeDistanceKm = null;
      routeError = null;
    });
    if (pickupPoint != null && destinationPoint != null) await calculateRoute();
  }

  Future<void> calculateRoute() async {
    setState(() {
      routeBusy = true;
      routeError = null;
    });
    try {
      final value = await RouteDistanceService().roadDistanceKm(
        pickup: pickupPoint!,
        destination: destinationPoint!,
      );
      if (mounted) setState(() => routeDistanceKm = value);
    } catch (_) {
      if (mounted) {
        setState(() {
          routeDistanceKm = null;
          routeError = 'Unable to calculate route. Check internet and try both pins again.';
        });
      }
    } finally {
      if (mounted) setState(() => routeBusy = false);
    }
  }

  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(dateTime));
    if (time != null) {
      setState(() => dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
    }
  }

  Future<void> submit() async {
    if (!key.currentState!.validate()) return;
    if (pickupPoint == null || destinationPoint == null || routeDistanceKm == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Confirm pickup and destination on Google Maps first.')));
      return;
    }
    setState(() => sending = true);
    try {
      final ref = await FirestoreService().createBooking({
        'category': 'travel',
        'serviceType': widget.vehicle.id,
        'vehicleType': widget.vehicle.title,
        'travelScope': widget.travelScope,
        'travelPurpose': isGoods ? 'goods' : 'passenger',
        'tripType': tripType,
        'scheduleType': schedule,
        'scheduledAt': schedule == 'later' ? dateTime.toIso8601String() : null,
        'customerName': name.text.trim(),
        'customerPhone': phone.text.trim(),
        'pickup': pickup.text.trim(),
        'destination': destination.text.trim(),
        'pickupMapAddress': pickupPoint!.address,
        'pickupLatitude': pickupPoint!.latitude,
        'pickupLongitude': pickupPoint!.longitude,
        'destinationMapAddress': destinationPoint!.address,
        'destinationLatitude': destinationPoint!.latitude,
        'destinationLongitude': destinationPoint!.longitude,
        'distanceKm': routeDistanceKm,
        'passengerCount': isGoods ? null : int.tryParse(passengers.text.trim()),
        'goodsWeightKg': isGoods ? double.tryParse(goodsWeight.text.trim()) : null,
        'goodsItem': isGoods ? goodsItem.text.trim() : null,
        'intermediateStops': intermediateStops.text.trim(),
        'luggageDetails': isGoods ? null : luggage.text.trim(),
        'quoteStatus': isOutstation ? 'admin_quote_required' : 'not_required',
        'advancePaymentStatus': isOutstation ? 'not_requested' : 'not_required',
        'notes': notes.text.trim(),
      });
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Travel request submitted'),
          content: Text('Booking reference: $ref'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not submit: $e')));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  String scopeLabel(String value) => switch (value) {
    'outstation' => 'Outstation / Tour',
    'goods_transport' => 'Goods Transport',
    _ => 'Within City',
  };
}
