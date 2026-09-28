# Google Maps setup for the v2.11.3 clone

The map UI uses a client-restricted Maps SDK key. Road distance uses a separate server key stored in Firebase Secret Manager. Never place the server key in Dart, `google-services.json`, `local.properties` committed to source control, or the APK.

## Google Cloud APIs

Enable billing and these APIs on the Firebase project's Google Cloud project:

- Maps SDK for Android
- Maps SDK for iOS (when building iOS)
- Maps JavaScript API (when building web)
- Geocoding API
- Routes API

## Android key

Restrict the Android key by Android application and the production package name/SHA certificate. Add this private line to `android/local.properties`:

```properties
google.maps.androidKey=PASTE_ANDROID_RESTRICTED_KEY
```

## Firebase road-route function

From the Flutter project root, sign into the correct Firebase account and run:

```powershell
firebase use namma-ranebennur-production
firebase functions:secrets:set GOOGLE_MAPS_SERVER_KEY
cd functions
npm install
cd ..
firebase deploy --only functions:calculateRoadRoute
```

Paste the server-restricted Routes API key only when the secret command requests it.

After deployment, sign in to the app, open Travel, confirm pickup and destination pins, and verify that a road distance appears. Repeat in Nimma Sevaka Delivery. Submission must stay disabled whenever a pin or route result is missing.

## iOS and web

For iOS, define `GOOGLE_MAPS_IOS_KEY` in the Xcode build configuration using an iOS-restricted key. For web, follow the current `google_maps_flutter_web` setup and use a website-restricted browser key. These client keys are not substitutes for `GOOGLE_MAPS_SERVER_KEY`.
