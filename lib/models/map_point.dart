class MapPoint {
  const MapPoint({required this.address, required this.latitude, required this.longitude});

  final String address;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => {
        'address': address,
        'lat': latitude,
        'lng': longitude,
      };
}
