import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/service_category.dart';
import 'travel_booking_screen.dart';

class TravelScopeScreen extends StatefulWidget {
  const TravelScopeScreen({super.key, required this.kannada});
  final bool kannada;

  @override
  State<TravelScopeScreen> createState() => _TravelScopeScreenState();
}

class _TravelScopeScreenState extends State<TravelScopeScreen> {
  String? scope;
  String tr(String en, String kn) => widget.kannada ? kn : en;

  List<ServiceCategory> get vehicles => switch (scope) {
    'within_city' => travelVehicles.where((x) => ['bike', 'auto', 'car_cab'].contains(x.id)).toList(),
    'outstation' => travelVehicles.where((x) => ['car_cab', 'tempo_traveller', 'bus'].contains(x.id)).toList(),
    'goods_transport' => goodsVehicles,
    _ => const [],
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xfff45b22),
      foregroundColor: Colors.white,
      title: Text(tr('Travel Booking', 'ಪ್ರಯಾಣ ಬುಕ್ಕಿಂಗ್'), style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
    ),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Text(tr('Where are you travelling?', 'ನೀವು ಎಲ್ಲಿಗೆ ಪ್ರಯಾಣಿಸುತ್ತಿದ್ದೀರಿ?'), style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w800)),
      Text(tr('Choose the journey first. We will show only suitable vehicles.', 'ಮೊದಲು ಪ್ರಯಾಣದ ಪ್ರಕಾರವನ್ನು ಆಯ್ಕೆಮಾಡಿ. ಸೂಕ್ತ ವಾಹನಗಳನ್ನು ಮಾತ್ರ ತೋರಿಸುತ್ತೇವೆ.'), style: const TextStyle(color: Colors.black54)),
      const SizedBox(height: 18),
      Row(children: [
        Expanded(child: scopeCard('within_city', Icons.location_city_rounded, tr('Within City', 'ನಗರದೊಳಗೆ'), tr('Auto, Bike or Cab', 'ಆಟೋ, ಬೈಕ್ ಅಥವಾ ಕ್ಯಾಬ್'))),
        const SizedBox(width: 8),
        Expanded(child: scopeCard('outstation', Icons.route_rounded, tr('Outstation / Tour', 'ಹೊರನಗರ / ಪ್ರವಾಸ'), tr('Admin price quote', 'ಅಡ್ಮಿನ್ ದರ'))),
        const SizedBox(width: 8),
        Expanded(child: scopeCard('goods_transport', Icons.local_shipping_rounded, tr('Goods Transport', 'ಸರಕು ಸಾಗಣೆ'), tr('Parcel to heavy load', 'ಪಾರ್ಸೆಲ್‌ನಿಂದ ಭಾರಿ ಸರಕು'))),
      ]),
      if (scope != null) ...[
        const SizedBox(height: 24),
        Text(tr('Choose a suitable vehicle', 'ಸೂಕ್ತ ವಾಹನವನ್ನು ಆಯ್ಕೆಮಾಡಿ'), style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vehicles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: .88),
          itemBuilder: (_, index) {
            final vehicle = vehicles[index];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TravelBookingScreen(vehicle: vehicle, travelScope: scope!))),
                child: Padding(padding: const EdgeInsets.all(10), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(vehicle.icon, size: 40, color: const Color(0xfff45b22)),
                  const SizedBox(height: 8),
                  Text(widget.kannada ? vehicle.kannadaTitle : vehicle.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
                ])),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color: const Color(0xffffeadf), borderRadius: BorderRadius.circular(13)),
          child: Text(scope == 'outstation'
            ? tr('Admin checks availability and sends the price quote. The driver is assigned only after quote acceptance and advance verification.', 'ಅಡ್ಮಿನ್ ಲಭ್ಯತೆ ಪರಿಶೀಲಿಸಿ ದರ ಕಳುಹಿಸುತ್ತಾರೆ. ದರ ಒಪ್ಪಿಗೆ ಮತ್ತು ಮುಂಗಡ ಪರಿಶೀಲನೆಯ ನಂತರ ಚಾಲಕರನ್ನು ನಿಯೋಜಿಸಲಾಗುತ್ತದೆ.')
            : tr('Your number and driver contact remain protected inside Namma Ranebennur.', 'ನಿಮ್ಮ ಸಂಖ್ಯೆ ಮತ್ತು ಚಾಲಕರ ಸಂಪರ್ಕ ನಮ್ಮ ರಾಣೆಬೆಣ್ಣೂರಿನಲ್ಲಿ ಸುರಕ್ಷಿತವಾಗಿರುತ್ತದೆ.')),
        ),
      ],
    ]),
  );

  Widget scopeCard(String value, IconData icon, String title, String subtitle) {
    final active = scope == value;
    return Material(
      color: active ? const Color(0xffffe5d7) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: active ? const Color(0xfff45b22) : Colors.black12, width: active ? 2 : 1)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => scope = value),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 14), child: Column(children: [
          Icon(icon, size: 31, color: const Color(0xfff45b22)), const SizedBox(height: 7),
          Text(title, textAlign: TextAlign.center, maxLines: 2, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3), Text(subtitle, textAlign: TextAlign.center, maxLines: 2, style: GoogleFonts.poppins(fontSize: 8.5, color: Colors.black54)),
        ])),
      ),
    );
  }
}
