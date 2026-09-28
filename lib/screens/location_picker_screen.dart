import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/map_point.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, required this.title, this.initialPoint});

  final String title;
  final MapPoint? initialPoint;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const ranebennur = LatLng(14.6167, 75.6167);
  final geocoding = Geocoding();
  final searchController = TextEditingController();
  GoogleMapController? mapController;
  MapPoint? selected;
  bool busy = false;
  String status = 'Search or tap the exact point on the map';

  @override
  void initState() {
    super.initState();
    selected = widget.initialPoint;
    searchController.text = widget.initialPoint?.address ?? '';
  }

  @override
  void dispose() {
    searchController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = selected == null
        ? ranebennur
        : LatLng(selected!.latitude, selected!.longitude);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => search(),
                      decoration: const InputDecoration(
                        hintText: 'Shop, road or landmark',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Search',
                    onPressed: busy ? null : search,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Use my location',
                    onPressed: busy ? null : useCurrentLocation,
                    icon: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: position, zoom: 14),
                onMapCreated: (controller) => mapController = controller,
                onTap: selectCoordinates,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                mapToolbarEnabled: false,
                markers: selected == null
                    ? const {}
                    : {
                        Marker(
                          markerId: const MarkerId('selected-location'),
                          position: position,
                        ),
                      },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (busy) const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(status),
                  if (selected != null) ...[
                    const SizedBox(height: 6),
                    Text(selected!.address, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: selected == null || busy ? null : () => Navigator.pop(context, selected),
                    icon: const Icon(Icons.location_on),
                    label: const Text('Confirm this location'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> search() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      busy = true;
      status = 'Finding location…';
    });
    try {
      final results = await geocoding.locationFromAddress('$query, Ranebennur, Karnataka, India');
      if (results.isEmpty) throw StateError('Location not found');
      await selectCoordinates(LatLng(results.first.latitude, results.first.longitude));
    } catch (_) {
      if (mounted) setState(() => status = 'Location not found. Add a landmark or tap the map.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> useCurrentLocation() async {
    setState(() {
      busy = true;
      status = 'Finding your location…';
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Turn on phone location services.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw StateError('Location permission is required.');
      }
      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      await selectCoordinates(LatLng(current.latitude, current.longitude));
    } catch (error) {
      if (mounted) setState(() => status = error.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> selectCoordinates(LatLng coordinates) async {
    if (mounted) setState(() => busy = true);
    var address = '${coordinates.latitude.toStringAsFixed(6)}, ${coordinates.longitude.toStringAsFixed(6)}';
    try {
      final places = await geocoding.placemarkFromCoordinates(coordinates.latitude, coordinates.longitude);
      if (places.isNotEmpty) {
        final place = places.first;
        address = [place.name, place.street, place.subLocality, place.locality, place.administrativeArea, place.postalCode]
            .whereType<String>()
            .where((part) => part.trim().isNotEmpty)
            .toSet()
            .join(', ');
      }
    } catch (_) {
      // Coordinates remain usable when platform reverse geocoding is unavailable.
    }
    selected = MapPoint(address: address, latitude: coordinates.latitude, longitude: coordinates.longitude);
    searchController.text = address;
    await mapController?.animateCamera(CameraUpdate.newLatLngZoom(coordinates, 16));
    if (mounted) {
      setState(() {
        busy = false;
        status = 'Location selected. Check the pin and confirm.';
      });
    }
  }
}
