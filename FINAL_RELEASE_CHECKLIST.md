# Namma Ranebennur v2.11.3 final release checklist

The functional source parity checklist is complete. Run this release gate on the Windows development computer before creating or sharing the final APK.

## 1. Open the correct project

Open the inner folder that directly contains `pubspec.yaml`, `lib`, `android`, `firestore.rules` and `storage.rules`.

## 2. Run one verification cycle

From PowerShell in that folder:

```powershell
D:\develop\flutter\bin\flutter.bat clean
D:\develop\flutter\bin\flutter.bat pub get
D:\develop\flutter\bin\flutter.bat analyze
D:\develop\flutter\bin\flutter.bat test
```

Do not build an APK if analyze or tests report an error.

## 3. Deploy Firebase security rules

Deploy both `firestore.rules` and `storage.rules` to the same Firebase project used by `google-services.json`. Confirm that Email/Password Authentication, Cloud Firestore, Firebase Storage and FCM are enabled.

## 4. Test the four access paths

1. Customer: signup, verify email, login, every Quick Booking option, Find For Me, announcements, New in City and SOS.
2. Booking Admin: hotel, hall, clinic, worker/catering approvals, quotes, advance verification and customer support.
3. Market/Travel Admin: products, advertisements, service providers, drivers, travel, delivery and settlements.
4. Super Admin: all panels, content publishing, payments, complaints, roles and feature controls.

Also test the provider, booking-counter and driver portals using separate approved accounts.

## 5. Visual comparison

Compare each customer screen beside the approved v2.11.3 reference at the same phone size. Check text, spacing, colors, icon order, overflow and Kannada/English labels. Do not package until the owner accepts this comparison.

## 6. Build only after acceptance

```powershell
D:\develop\flutter\bin\flutter.bat build apk --release
```

The final APK will be in `build\app\outputs\flutter-apk\app-release.apk`.
