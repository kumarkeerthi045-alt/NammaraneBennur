import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';

/// Reproduces the v2.11.3 safety-location action on Android, iOS and web.
class LocationShareService {
  const LocationShareService._();

  static Future<void> shareText({required String title, required String text}) async {
    await SharePlus.instance.share(ShareParams(title: title, text: text));
  }

  static Future<String?> shareSafetyLocation({required bool kannada}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return kannada
          ? 'ಸ್ಥಳ ಸೇವೆಯನ್ನು ಆನ್ ಮಾಡಿ.'
          : 'Turn on Location services and try again.';
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return kannada
          ? 'ಸ್ಥಳ ಅನುಮತಿ ಅಗತ್ಯ.'
          : 'Location permission is required.';
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      final mapUrl = Uri.https('maps.google.com', '/', {
        'q': '${position.latitude},${position.longitude}',
      }).toString();
      final text = '${kannada ? 'ನನ್ನ ಸುರಕ್ಷತಾ ಸ್ಥಳ' : 'My safety location'}: $mapUrl';
      await shareText(title: 'Namma Ranebennur Safety', text: text);
      return null;
    } catch (_) {
      return kannada
          ? 'ಸ್ಥಳವನ್ನು ಪಡೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.'
          : 'Unable to get your location. Please try again.';
    }
  }
}
