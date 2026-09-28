# Namma Ranebennur — Flutter/Firebase v2.11.3

Production mobile source rebuilt from the approved Namma Ranebennur v2.11.3 workflows and the team's Flutter application.

## Technology boundary

- Flutter, Dart, Material 3 and Google Fonts
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging
- Firebase Cloud Functions for protected Google road-route calculation

There is no standalone server, Next.js, Cloudflare, D1, Capacitor or separate SQL database. The small JavaScript file under `functions/` is deployed and managed only as a Firebase Cloud Function; it keeps the Google Routes key out of the APK.

## Included customer workflows

- Email authentication and verification
- Kannada/English production home
- Travel: Auto, Bike, Cab, Goods Vehicle, Tempo Traveller and Bus
- Function halls, hotels, doctors/hospitals, home services, machinery and event requests
- Vibe Town live date/time availability
- Nimma Sevaka city delivery
- Namma Market catalogue, cart and order request
- Moderated local buy-and-sell listings
- Custom requirements
- Booking history and protected contact workflow
- Verified announcements, SOS and Firebase notifications
- Service-provider application and role-based administration inherited from the team application

## Firebase setup

1. Keep `android/app/google-services.json` matched to the Android application ID.
2. Enable Email/Password under Firebase Authentication.
3. Create a Cloud Firestore database and Firebase Storage bucket.
4. Deploy security configuration from the project root:

   ```powershell
   firebase deploy --only firestore:rules,firestore:indexes,storage
   ```

5. Create the first administrator in Firebase Authentication, then create `adminUsers/{uid}` with:

   ```text
   active: true
   role: "super_admin"
   ```

   Other supported roles are `booking_admin` and `market_travel_admin`.

6. Public market products belong in `marketProducts` and require `active: true`. Published announcements belong in `announcements` and require `published: true`.

7. Complete the one-time Google Maps configuration in `MAPS_SETUP.md`. Travel and Delivery intentionally remain disabled until both pins and a genuine road distance are confirmed.

## Run and verify

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

For one final APK after testing:

```powershell
flutter build apk --release
```

The output is `build/app/outputs/flutter-apk/app-release.apk`. Install only that final release; daily UI work should use `flutter run` and hot reload.

## Release requirement

The current Android release block uses the debug signing key to simplify device testing. Before Play Store or public distribution, configure a private upload keystore and release signing in `android/app/build.gradle.kts`. Do not publish a debug-signed APK.
