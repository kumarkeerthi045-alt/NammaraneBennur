# Namma Ranebennur v2.11.3 — Claude handoff

## Goal and non-negotiable requirements

Continue the Flutter/Firebase rebuild as a pin-to-pin update/redesign of the supplied
`Namma-Ranebennur-Production-Source-v2.11.3` reference. Preserve every small feature,
screen, icon, image, destination, external link, back path, role restriction, timing rule
and contact-protection rule. Do not replace the product with a generic/basic app.

Approved application stack only:

- Flutter, Dart, Material UI and Google Fonts
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging
- Firebase Cloud Functions only for protecting the Google Routes server key; this is
  managed Firebase infrastructure, not a separate application backend

The Home screen must not show a “1 day free” promotion. Used-item Sale must retain the
master workflow: free 5-hour trial, Admin verification for 24 hours, and ₹100 activation
for 30 days with seller contact revealed only after Admin verifies payment.

## Which source is which

- `Namma-Ranebennur-Flutter-Production-v2.11.3/` — current Flutter/Firebase rebuild to continue.
- `Namma-Ranebennur-Production-Source-v2.11.3/` — original v2.11.3 web source; use as the visual and behavioural authority. Do not develop the final Android app inside this folder.

Read these files first in the Flutter project:

1. `V2_11_3_PARITY_MATRIX.md`
2. `LINK_PARITY_AUDIT.md`
3. `FINAL_RELEASE_CHECKLIST.md`
4. `MAPS_SETUP.md`
5. `README.md`

## Work already implemented

- Customer shell, original Quick Booking order, bottom navigation, announcements,
  New in City, sponsored advertisements, profile, Demo and SOS.
- Original supplied assets and Android launcher/adaptive icons.
- Hotels, halls, clinic, Vibe Town, Travel, Home Services, Nimma Sevaka, Machinery,
  Find For Me, Market, requirements and used-item Sale flows.
- Firebase Auth email verification/reset, Firestore, Storage, FCM token handling and
  role-restricted customer/provider/counter/driver/admin workflows.
- Booking Admin, Market/Travel Admin and Super Admin controls.
- Protected phone, Maps and share links; assigned-driver privacy; booking/payment ledger.
- Embedded Google Map pin selection for Travel and Delivery, reverse geocoding and a
  protected callable route-distance function in `functions/`.
- Sale state parity (`trial_live`, `verified_free`, `paid_active`), buyer-interest counts,
  private seller phone, Admin activation/sold controls, duplicate-title protection and
  up to eight Firebase Storage item photos.

## Remaining tasks — must be completed before claiming 100%

### A. Restore dependencies and fix compiler/analyzer findings

The last edits added `cloud_functions`, `geocoding`, `google_maps_flutter` and
`image_picker`; the included lock file may not yet reflect all four. On the Windows PC,
inside the Flutter project, run:

```powershell
D:\develop\flutter\bin\flutter.bat clean
D:\develop\flutter\bin\flutter.bat pub get
D:\develop\flutter\bin\flutter.bat analyze
D:\develop\flutter\bin\flutter.bat test
```

Fix every error. Review warnings and remove all meaningful warnings. Re-run until clean.
Do not delete tests merely to make the test command green.

### B. Validate recent Sale work

- Compile-test the `ImagePicker.pickMultiImage(..., limit: 8)` API with the resolved
  `image_picker` version.
- Test photo selection/upload/display on Android and Chrome.
- Confirm signed-in buyers can read Sale images but cannot overwrite them.
- Add Firestore/Storage emulator tests for private phone protection, buyer interest
  transaction, owner edits, Admin activation, and unauthorized denial.
- Confirm the Firestore Rules `getAfter` path for
  `saleInterests/{listingId}_{buyerUid}` passes the emulator transaction test.
- Test same-title duplicate protection within 30 days.
- Compare Sale category/filter/feed/My Sale Ads behavior with the reference source;
  implement any remaining My Sale Ads controls that are absent.
- Prevent orphaned uploaded images if a later Firestore commit fails.

### C. Configure and deploy Firebase Maps routing

Follow `MAPS_SETUP.md` exactly. Do not place server keys in Dart or commit them.

- Ensure Firebase billing/Cloud credits are active.
- Enable Maps SDK for Android, Maps SDK for iOS, Geocoding API and Routes API.
- Create separately restricted Android, iOS and server keys.
- Put the Android key only in local `android/local.properties`.
- Configure the iOS build setting for `GOOGLE_MAPS_IOS_KEY` if iOS is released.
- Set the Cloud Function secret `GOOGLE_MAPS_SERVER_KEY` and deploy the function.
- Deploy Firestore rules, Storage rules and indexes.
- Test valid routes, no-route results, permission denial and API failure messages.
- If Chrome/web remains a supported target, add a properly restricted browser Maps key
  and web Maps initialization; Android is the immediate release target.

### D. Full master parity review

Use the original source, its release notes and its tests as the authority. At the same
phone dimensions, compare every screen and state—not only the home screen.

- Every icon, supplied image, crop, order, label, Kannada/English string, color, font,
  spacing, card size, dialog, empty state, loading state and error state.
- Every tap target, internal destination, system back action and in-app back action.
- Every telephone, Maps, GPS sharing, external advertisement and trip-share link.
- Every customer, provider, counter, driver and three-admin-role workflow.
- Every approval, quote, payment, OTP, cancellation, completion and settlement state.
- Narrow-phone overflow and text-scale testing.

Record actual evidence in the parity matrices. A source-code checkbox is not a substitute
for Android interaction testing and owner visual approval.

### E. Production identity and signing

The Android package currently remains `com.example.service_provider` because it matches
the supplied `google-services.json`. Before production release:

- Decide the permanent application ID.
- Register that exact Android app in Firebase and replace `google-services.json` if the
  ID changes.
- Change Android namespace/application ID and iOS bundle ID consistently.
- Set the final app display name.
- Create a private release/upload keystore and remove debug signing from the release build.
- Keep credentials and keystores outside source control and make a secure backup.

### F. Final release gate

Only after A–E pass:

```powershell
D:\develop\flutter\bin\flutter.bat build apk --debug
D:\develop\flutter\bin\flutter.bat build apk --release
```

Install the release APK on a real Android phone and perform a clean-account end-to-end
test. Confirm notifications from foreground/background/terminated states. Confirm rules
against unauthorized accounts. Obtain owner approval of the full visual/workflow clone.
Then create the final source archive and checksums.

## Honest checkpoint status

This handoff is a source checkpoint, not a finished production release. Large functional
areas are implemented, but the last dependency changes have not been compiled in this
container because Flutter/Dart is unavailable here. Real-device parity, Firebase rule
emulator tests, Maps deployment, production package identity/signing, pixel approval and
final debug/release builds remain release blockers.
