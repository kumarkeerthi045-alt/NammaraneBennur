import 'package:url_launcher/url_launcher.dart';

/// Opens only the external link types used by the v2.11.3 master application.
/// Unknown schemes are rejected so Firestore content cannot launch unsafe links.
class LinkService {
  const LinkService._();

  static const allowedSchemes = {'https', 'http', 'tel', 'mailto'};

  static Future<bool> open(String value) async {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !allowedSchemes.contains(uri.scheme.toLowerCase())) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> call(String phone) {
    var clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) return Future.value(false);
    if (RegExp(r'^[6-9]\d{9}$').hasMatch(clean)) clean = '+91$clean';
    return open('tel:$clean');
  }

  static Future<bool> mapSearch(String query) => open(
    Uri.https('maps.google.com', '/', {'q': '$query, Ranebennur, Karnataka'}).toString(),
  );

  static Future<bool> mapCoordinates(num latitude, num longitude) => open(
    Uri.https('maps.google.com', '/', {'q': '$latitude,$longitude'}).toString(),
  );
}
