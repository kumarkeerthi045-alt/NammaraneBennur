import 'package:flutter/material.dart';
import '../models/service_category.dart';
import 'booking_form_screen.dart';
import 'travel_booking_screen.dart';
import 'special_booking_screens.dart';
import 'clinic_screen.dart';

class ServiceScreen extends StatelessWidget {
  final ServiceCategory category;
  final bool kannada;
  const ServiceScreen({super.key, required this.category, required this.kannada});

  List<ServiceCategory> get items => category.id == 'home_services'
      ? homeServices
      : category.id == 'machinery'
          ? machineryServices
          : category.id == 'travel'
              ? travelVehicles
              : [category];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(kannada ? category.kannadaTitle : category.title)),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .9, crossAxisSpacing: 12, mainAxisSpacing: 12),
          itemBuilder: (_, i) {
            final item = items[i];
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    if (category.id == 'travel') return TravelBookingScreen(vehicle: item);
                    if (category.id == 'vibe_town') return const VibeTownBookingScreen();
                    if (category.id == 'delivery') return const DeliveryBookingScreen();
                    if (category.id == 'clinic') return ClinicScreen(kannada: kannada);
                    return BookingFormScreen(parent: category, service: item);
                  },
                ),
              ),
              child: Card(clipBehavior: Clip.antiAlias, child: Column(children: [
                Expanded(child: item.asset == null ? Icon(item.icon, size: 64, color: Colors.deepOrange) : Image.asset(item.asset!, width: double.infinity, fit: BoxFit.cover)),
                Padding(padding: const EdgeInsets.all(10), child: Text(kannada ? item.kannadaTitle : item.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
              ])),
            );
          },
        ),
      );
}
