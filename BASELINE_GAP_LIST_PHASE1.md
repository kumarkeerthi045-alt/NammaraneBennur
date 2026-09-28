# Phase 1 baseline — extraction, inventory, gap list

Date: 2026-09-05

## 1. Archive verification

Both archives opened cleanly:

- `Namma-Ranebennur-Flutter-Checkpoint-v2.11.3.zip` → extracted to
  `D:\namma ranebennur\Flutter-Checkpoint\`
- `Namma-Ranebennur-Original-Master-v2.11.3.zip` → extracted to
  `D:\namma ranebennur\Original-Master\`

## 2. Project roots confirmed

- **Flutter root (work continues here):**
  `D:\namma ranebennur\Flutter-Checkpoint\Namma-Ranebennur-Flutter-Production-v2.11.3\`
  Contains `pubspec.yaml`, `lib/`, `android/`, `ios/`, `firebase.json`,
  `firestore.rules`, `storage.rules`, `functions/` — matches the expected layout exactly.
- **Original master (reference only, not touched for development):**
  `D:\namma ranebennur\Original-Master\master_source\`
  A Next.js + Capacitor + Drizzle web/hybrid app (`app/`, `db/`, `lib/`, `drizzle/`,
  `worker/`, `wrangler.jsonc`). Confirms this is a reference stack, not something to
  reintroduce into the Flutter app.

## 3. Safety baseline

`git init` + one baseline commit created inside the Flutter root
(`038e60a — Baseline checkpoint v2.11.3 (pre-Phase-1 edits)`) before any code changes,
so every later change is reviewable/revertable.

## 4. Dependency/config sanity check (informs Phase 2)

- `pubspec.yaml` already declares all four dependencies the handoff notes flagged as
  unverified: `cloud_functions`, `geocoding`, `google_maps_flutter`, `image_picker`
  (plus `geolocator`, `share_plus`, `firebase_*`, `url_launcher`, `google_fonts`).
- `functions/` contains `index.js` + `package.json` (the protected Google-route callable).
- `android/local.properties` is correctly absent (machine-specific, must be recreated
  locally before building — never commit it).
- Only one test file exists: `test/widget_test.dart` — appears to be the default Flutter
  counter-app template, not real app coverage. Flagged for Phase 2/3, not fixed here.
- Flutter SDK confirmed present at `D:\develop\flutter\bin\flutter.bat`, so Phase 2
  (`clean`/`pub get`/`analyze`/`test`) is runnable now.

## 5. Flutter implementation inventory

`lib/` — 51 Dart files:

- **Models (6):** map_point, market_catalog, order_model, service_category,
  service_provider_model, user_model
- **Services (8):** admin_access_service, auth_service, firestore_service, link_service,
  location_share_service, notification_service, order_service, route_distance_service
- **Screens (36):** covers auth (login/signup/otp/email-verification/forgot-password),
  production home, demo mode, venue booking (hotel/hall), clinic, travel (scope +
  booking), machinery/salon, market catalog, community market, special bookings
  (Vibe Town etc. — grouped in `special_booking_screens.dart`), city explore,
  create/my posts, service screen + service providers, partner portals, profile,
  location picker, and three admin surfaces (control center, dashboard,
  service-provider requests/approvals, login).
- **Assets:** 38 image files under `assets/images/` (home-services, machinery,
  find-* category art, hotel/hall/market/genie art) vs. 44 in the master's `public/`
  — a small (6-file) gap to reconcile screen-by-screen in Phase 3/5, not a structural gap.
- Android launcher icons present at all five densities + adaptive
  (`mipmap-anydpi-v26`, `mdpi`→`xxxhdpi`).

Firestore collections actually referenced in `lib/` (and mirrored in `firestore.rules`):
`adminActivity, adminUsers, advertisements, announcements, bookingCounters, businesses,
complaints, driverJobs, driverPartners, driverSettlements, marketOrders, marketProducts,
notifications, orders, payments, platformSettings, posts, providerQuotes, providerSlots,
requirements, saleInterests, saleListingPrivate, saleListings, serviceProviderRequests,
serviceProviders, service_requests, tripShares, trustedContacts, users,
vibeTownSlotLocks`. `firestore.rules` also has a stray `cityEvents` match not
referenced anywhere in `lib/` yet — check in Phase 3 whether New in City needs it or
it's dead.

## 6. Original master inventory (reference authority)

`db/schema.ts` defines 25 tables: `bookingPartners, businesses, bookings, announcements,
advertisements, travelDrivers, travelRequests, localPosts, requirements, providerQuotes,
adminPayments, complaints, vibeTownEvents, vibeTownBookings, deliveryOrders,
adminActivity, providerApplications, platformSettings, machineryRequests, marketOrders,
marketProducts, saleListings, saleInterests, otpCodes, customerSessions`.

`app/` route surface: single-page-app style — most business logic lives in a few large
client components (`namma-app.tsx` 555 lines, `commerce-pages.tsx` 908 lines,
`booking-catalog.tsx`) rather than one file per feature, plus 37 API routes under
`app/api/**` (bookings, travel, delivery, machinery, vibe-town, sale-listings incl.
interest/payment sub-routes, market-orders, providers/quotes, admin/* by domain,
maps/config + maps/route, auth/request-otp + verify-otp, etc.) and top-level pages for
`/`, `/demo`, `/hotels`, `/halls`, `/home-services`, `/machinery`, `/market`, `/sale`,
`/travel`, `/catering`, `/partner`, `/admin`. This matches `LINK_PARITY_AUDIT.md`'s
route table — no undocumented top-level route was found.

## 7. Data-model mapping and gaps to verify in Phase 3

Master table → Flutter collection (mapping looks intentional/consolidated, not missing,
but each row needs a functional-parity check against the original's exact field/state
machine, since Flutter renamed/merged several tables):

| Master table | Flutter collection | Note |
| --- | --- | --- |
| bookingPartners | serviceProviders / bookingCounters | renamed/split — verify both partner types keep their original approval workflow |
| bookings | orders / service_requests | consolidated — verify no per-category field was dropped |
| travelDrivers | driverPartners | renamed |
| travelRequests | orders (serviceType field?) | **verify**: `OrderModel` (lib/models/order_model.dart) is a generic model with only pending/accepted/rejected/assigned/completed status and no OTP, quote, advance-payment, or map-pin fields — Travel/Delivery screens likely write richer raw maps directly; confirm no field from the master's `travelRequests` (OTP stages, driver assignment, trip-share) was silently dropped |
| deliveryOrders | orders | same consolidation risk as above, for Nimma Sevaka |
| machineryRequests | orders | same consolidation risk as above |
| localPosts | posts | renamed |
| adminPayments | payments | renamed |
| providerApplications | serviceProviderRequests | renamed |
| vibeTownEvents | (no dedicated collection found) | **verify**: confirm Vibe Town experience/package/add-on catalogue is sourced from a Firestore collection or an intentional static catalogue in Dart — master treats it as data, not hardcoded |
| vibeTownBookings | vibeTownSlotLocks | **verify**: slot-lock docs prevent double-booking, but confirm the actual booking record (customer, package, add-ons, payment) is persisted somewhere (`orders`?) and not only the lock marker |
| otpCodes | (none — Firebase Auth) | expected difference: email OTP/verification now goes through Firebase Auth; confirm delivery/pickup OTP (pure app-level, not auth) still has a persistence path |
| customerSessions | (none — Firebase Auth) | expected difference, no action needed |

`OrderModel.toMap()`/`fromMap()` only cover: orderId, user id/name/phone/email,
serviceType, serviceProviderId, preferredDate/Time, address, urgency, description,
status, createdAt. This model looks sized for simple worker/service requests
(Home Services, Machinery) — Phase 3 must confirm Travel, Vibe Town, Nimma Sevaka and
Hall/Hotel bookings, which need OTP/quote/advance-payment/map-pin/route-distance fields,
are not being force-fit into this narrow shape and are instead using their own
richer document structure (as the parity matrix claims) rather than losing fields.

## 8. What Phase 1 does **not** claim

This is a structural/inventory pass, not the full screen-by-screen visual and workflow
audit required by Section 4 of the master prompt and Phase 3/5 of the execution plan.
The existing `V2_11_3_PARITY_MATRIX.md` and `LINK_PARITY_AUDIT.md` already track most
items as `[x]`, but per the master prompt's own rule, a checked box is not proof —
Phase 3 must re-verify each item against the original master's actual behavior, and
Phase 5 must do the pixel/interaction comparison on-device. No code was modified in
this phase.

## 9. Immediate next step

Phase 2 (`flutter clean && pub get && analyze && test`) is unblocked — the Flutter SDK
is present at `D:\develop\flutter\bin\flutter.bat` and all previously-flagged
dependencies are already in `pubspec.yaml`. Recommend running Phase 2 next to get a
real compiler/analyzer baseline before any further comparison work.
