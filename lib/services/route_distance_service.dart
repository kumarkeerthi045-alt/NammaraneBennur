import 'package:cloud_functions/cloud_functions.dart';

import '../models/map_point.dart';

class RouteDistanceService {
  RouteDistanceService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1');

  final FirebaseFunctions _functions;

  Future<double> roadDistanceKm({required MapPoint pickup, required MapPoint destination}) async {
    final result = await _functions.httpsCallable('calculateRoadRoute').call({
      'pickup': pickup.toJson(),
      'destination': destination.toJson(),
    });
    final data = Map<String, dynamic>.from(result.data as Map);
    final distance = (data['distanceKm'] as num?)?.toDouble();
    if (distance == null || distance <= 0) {
      throw StateError('Google Maps did not return a valid road distance.');
    }
    return distance;
  }
}
