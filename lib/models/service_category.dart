import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String title;
  final String kannadaTitle;
  final IconData icon;
  final String? asset;
  final String? emoji;

  const ServiceCategory(this.id, this.title, this.kannadaTitle, this.icon,
      {this.asset, this.emoji});
}

const quickBookings = <ServiceCategory>[
  ServiceCategory('hotels', 'Hotel', 'ಹೋಟೆಲ್', Icons.hotel, emoji: '🏨'),
  ServiceCategory('vibe_town', 'Vibe Town', 'ವೈಬ್ ಟೌನ್', Icons.theaters, emoji: '🎭'),
  ServiceCategory('halls', 'Function Hall', 'ಫಂಕ್ಷನ್ ಹಾಲ್', Icons.celebration, emoji: '🎊'),
  ServiceCategory('clinic', 'Clinic', 'ಡಾಕ್ಟರ್', Icons.local_hospital, emoji: '🩺'),
  ServiceCategory('travel', 'Travel', 'ಪ್ರಯಾಣ', Icons.local_taxi, emoji: '🛺'),
  ServiceCategory('home_services', 'Home Services', 'ಮನೆ ಸೇವೆ', Icons.home_repair_service, emoji: '🔧'),
  ServiceCategory('delivery', 'Nimma Sevaka', 'ನಿಮ್ಮ ಸೇವಕ', Icons.delivery_dining, emoji: '🛵'),
  ServiceCategory('machinery', 'Machinery', 'ಯಂತ್ರೋಪಕರಣ', Icons.agriculture, emoji: '🚜'),
];

const homeServices = <ServiceCategory>[
  ServiceCategory('maid', 'Maid Service', 'ಮನೆಕೆಲಸದವರು', Icons.cleaning_services, asset: 'assets/images/home-services/maid.webp'),
  ServiceCategory('plumber', 'Plumber', 'ಪ್ಲಂಬರ್', Icons.plumbing, asset: 'assets/images/home-services/plumber.webp'),
  ServiceCategory('electrician', 'Electrician', 'ಎಲೆಕ್ಟ್ರಿಷಿಯನ್', Icons.electrical_services, asset: 'assets/images/home-services/electrician.webp'),
  ServiceCategory('mechanic', 'Mechanic', 'ಮೆಕ್ಯಾನಿಕ್', Icons.build, asset: 'assets/images/home-services/mechanic.webp'),
  ServiceCategory('ac_installation', 'AC Installation', 'ಎಸಿ ಅಳವಡಿಕೆ', Icons.ac_unit, asset: 'assets/images/home-services/ac-installation.webp'),
  ServiceCategory('painter', 'Painter', 'ಪೇಂಟರ್', Icons.format_paint, asset: 'assets/images/home-services/painter.webp'),
  ServiceCategory('carpenter', 'Carpenter', 'ಬಡಗಿ', Icons.carpenter, asset: 'assets/images/home-services/carpenter.webp'),
  ServiceCategory('home_cleaning', 'Home Cleaning', 'ಮನೆ ಸ್ವಚ್ಛತೆ', Icons.cleaning_services, asset: 'assets/images/home-services/home-cleaning.webp'),
];

const machineryServices = <ServiceCategory>[
  ServiceCategory('jcb', 'JCB', 'ಜೆಸಿಬಿ', Icons.agriculture, asset: 'assets/images/machinery/jcb.webp'),
  ServiceCategory('crane', 'Crane', 'ಕ್ರೇನ್', Icons.precision_manufacturing, asset: 'assets/images/machinery/crane.webp'),
  ServiceCategory('horizontal_drilling', 'Horizontal directional drilling machine', 'ಅಡ್ಡ ದಿಕ್ಕಿನ ಕೊರೆಯುವ ಯಂತ್ರ', Icons.construction, asset: 'assets/images/machinery/horizontal-drilling.webp'),
  ServiceCategory('tractor_lifter', 'Hydraulic rotary tractor with lifter', 'ಲಿಫ್ಟರ್ ಹೊಂದಿದ ಹೈಡ್ರಾಲಿಕ್ ಟ್ರಾಕ್ಟರ್', Icons.agriculture, asset: 'assets/images/machinery/tractor-lifter.webp'),
  ServiceCategory('sewer_cleaning', 'Sewer cleaning machine', 'ಒಳಚರಂಡಿ ಸ್ವಚ್ಛತಾ ಯಂತ್ರ', Icons.cleaning_services, asset: 'assets/images/machinery/sewer-cleaning.webp'),
  ServiceCategory('towing_vehicle', 'Towing service vehicle', 'ಟೋಯಿಂಗ್ ಸೇವಾ ವಾಹನ', Icons.car_repair, asset: 'assets/images/machinery/towing-vehicle.webp'),
  ServiceCategory('tractor_trolley', 'Tractor with trolley', 'ಟ್ರಾಲಿ ಹೊಂದಿದ ಟ್ರಾಕ್ಟರ್', Icons.agriculture, asset: 'assets/images/machinery/tractor-trolley.webp'),
  ServiceCategory('borewell', 'Tubewell boring machine', 'ಟ್ಯೂಬ್‌ವೆಲ್ ಬೋರಿಂಗ್ ಯಂತ್ರ', Icons.water, asset: 'assets/images/machinery/tubewell-boring.webp'),
];

const travelVehicles = <ServiceCategory>[
  ServiceCategory('auto', 'Auto', 'ಆಟೋ', Icons.electric_rickshaw),
  ServiceCategory('bike', 'Bike', 'ಬೈಕ್', Icons.two_wheeler),
  ServiceCategory('car_cab', 'Car / Cab', 'ಕಾರ್ / ಕ್ಯಾಬ್', Icons.local_taxi),
  ServiceCategory('goods_vehicle', 'Goods Vehicle', 'ಸರಕು ವಾಹನ', Icons.local_shipping),
  ServiceCategory('tempo_traveller', 'Tempo Traveller', 'ಟೆಂಪೋ ಟ್ರಾವೆಲರ್', Icons.airport_shuttle),
  ServiceCategory('bus', 'Bus', 'ಬಸ್', Icons.directions_bus),
];

const goodsVehicles = <ServiceCategory>[
  ServiceCategory('bike_goods', 'Bike', 'ಬೈಕ್', Icons.two_wheeler),
  ServiceCategory('goods_vehicle', 'Goods Vehicle', 'ಸರಕು ವಾಹನ', Icons.local_shipping),
  ServiceCategory('truck', 'Truck', 'ಟ್ರಕ್', Icons.fire_truck),
];
