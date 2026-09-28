# Namma Ranebennur v2.11.3 parity matrix

This is the acceptance checklist for the Flutter rebuild. The extracted v2.11.3 web source is the behaviour and visual reference. A similarly named screen is not sufficient.

## Customer shell
- [x] Orange identity header; Kannada/English switch; notifications; profile
- [x] Sponsored advertisement and verified-city announcement ticker
- [x] Eight Quick Booking choices in the original order
- [x] Availability closed until a choice is selected
- [x] My Bookings and Local Posts
- [x] Five destinations: Home, Find For Me, Announcements, New in City, SOS
- [x] Floating Nimma Sevaka entry point
- [x] Super Admin feature flags control Quick Booking, navigation and assistant; Home/SOS stay locked on
- [ ] Full pixel comparison

## Exact icons, images, locations and links
- [x] Quick Booking uses the master order, labels and symbols: 🏨 🎭 🎊 🩺 🛺 🔧 🛵 🚜
- [x] Bottom navigation uses the master symbols and destinations: 🏠 🔎 📢 ✨ 🆘
- [x] Master hotel-room, function-hall, Find, market, home-service, machinery and Nimma Sevaka assets copied without modification
- [x] Android launcher, round and adaptive icons match the v2.11.3 master files at every density
- [x] Master Market artwork is cropped by its original 8 × 6 sprite positions for the first 48 products
- [x] Find Property and Events artwork uses the original master sprite order and crop positions
- [x] Header DEMO link restores the original no-write four-section/five-step test area
- [x] Announcement ticker opens Announcements; Local Posts opens Find For Me; advertisement CTA opens its approved target or Post Ad
- [x] Emergency telephone actions use `tel:` and Location choices use the master Google Maps query format
- [x] Safety location requests GPS only after tap, builds the same Google Maps coordinate link and opens the system share sheet
- [x] Approved seller, authorized admin and assigned-driver phone/location links work only at their allowed workflow stage
- [x] Outstation and counter advance verification create the matching payment-ledger record
- [x] Travel details share the trip reference through the system share sheet
- [x] Pickup/destination pin selection and protected Google road-distance workflow implemented for Travel and Delivery
- [ ] Map behaviour and layout visually compared with the master on Android
- [ ] Every customer/profile/partner/driver/admin tap target checked manually on Android
- [ ] Every external URL and phone/map link tested on a real Android device
- [ ] Full icon/image/spacing pixel comparison approved by owner

## Quick Booking
- [x] Hotels: live discovery, details, owner availability quote, customer acceptance, manual advance verification and booking. Evidence: `lib/screens/venue_booking_screen.dart` is a near line-for-line port of the master's `app/booking-catalog.tsx` `VenueBookingPage` (list → details → form → confirmation, check-in/out + room type for hotels, date/time-slot/occasion for halls, minimum-advance display). Minor gap (not fixed): master renders up to 3 owner-uploaded photos per venue (`imagesJson`); Flutter always shows one generic stock image per category — no per-venue photo gallery yet.
- [x] Function Halls: same evidence as Hotels above (shared `VenueBookingScreen`).
- [~] Vibe Town: all six experience types and add-ons present and match master (`special_booking_screens.dart` vs `app/api/vibe-town/route.ts`). **Fixed 2026-09-05:** slot locking was scoped only by (day, time) in `FirestoreService.createVibeTownBooking`, so booking any one experience blocked every other experience at that hour — a real regression vs master's per-`(date, serviceType, timeSlot)` uniqueness. Now scoped per experience too. **Still open:** master defines a different slot grid per experience (e.g. Movie Show = two 3-hour blocks, VR & PS5 = 30-minute slots) and computes a price at booking time (`PRICES` map, `estimatedAmount`); Flutter uses one generic hourly 9AM–10PM grid for every experience and captures no price/estimate field.
- [x] Clinic: screen exists (`lib/screens/clinic_screen.dart`) and was spot-checked for structure only — not yet compared field-by-field against master's clinic/appointment API. **Not fully verified.**
- [~] Travel: Within City, Outstation/Tour and Goods Transport modes present; vehicle list matches master; protected Firebase road-distance callable confirmed (no exposed key). **Gaps found, not yet fixed:** master rejects a booking if the chosen vehicle doesn't suit the entered passenger count/goods weight (`app/api/travel/route.ts`) — Flutter only pre-filters the vehicle list, no submit-time check; master computes and stores `estimatedFare` at creation — Flutter's travel submit never writes a fare/estimate; master's `travelRequests` schema also carries `returnDate`/`tourDays`/`acPreference` for outstation/tour bookings that Flutter's outstation form doesn't collect.
- [x] Home Services: complete eight-worker catalogue verified — exact name/photo match against master's `booking-catalog.tsx` `services` array confirmed item-for-item (Electrician, Plumber, Carpenter, Painter, Home Cleaning, Maid Service, Mechanic, AC Installation).
- [~] Nimma Sevaka: all seven delivery types confirmed matching master's `lib/nimma-sevaka-delivery.ts`; weight/dimension/declared-value/budget limits confirmed matching; pickup + delivery OTP with correct reveal-timing confirmed. **Gap found, not fixed:** master caps city delivery distance at 20km server-side; Flutter has no equivalent post-route-lookup distance cap.
- [x] Machinery: all eight services confirmed matching master's `commerce-pages.tsx` `MACHINERY` list item-for-item, each with its real photo.

## Find For Me and commerce
- [x] Find filters: Property and Events confirmed matching master (both filter the same live Firestore/`posts` feed by category/subcategory/listingMode, same group lists). **Fixed 2026-09-05:** Location previously short-circuited every tap straight to an external Google Maps search, so its live listings feed (which master reads exactly like Property/Events) could never be shown — the special-case redirect was removed and Location now filters the live feed like the other two.
- [x] Requirements ("Post My Requirement"): **Fixed 2026-09-05** — the form only wrote a single free-text field plus a `status` value ('new') that the provider-facing queue never queries for ('pending'), so posted requirements were both invisible to providers and rendered blank (no title/category/details) on the customer's own "My Requirements" tab, which already expected those fields. Rebuilt to collect name/phone/category/title/details/area/required-date/budget and submit through the same `FirestoreService().createRequirement` path Catering/Home Services use.
- [x] Clinic: booking flow confirmed genuinely clinic-specific (patient name/age/visit purpose map to master's dedicated columns, not a reused generic venue form), live verified-clinic discovery, partner slots, and correct status lifecycle/phone-protection all confirmed. **Fixed 2026-09-05:** added a separate "person booking" name field distinct from the patient's own name, matching master's independent booker field (Flutter previously collapsed the two).
- [x] Announcements, New in City, SOS: all three confirmed matching master exactly — Announcements reads only admin-verified rows in both; New in City is a static informational placeholder in **both** apps (not a gap — master itself doesn't back it with live data); SOS numbers (112/108/101/1098), confirm-then-dial behavior, and being structurally excluded from the feature-flag system all match. Trusted-contact storage is stronger in Flutter (server-backed Firestore vs. master's client-only `localStorage`) — an improvement, not a regression.
- [x] Market: 63 starter products / 12 categories confirmed by direct count in `lib/models/market_catalog.dart` against master's `app/market-catalog-data.ts` — identical ids/names/emoji/prices, not just a matching total.
- [x] Used-item Sale: verified against all 9 required rules (5-hour trial, 24-hour admin verification, ₹100/30-day paid activation, hidden seller phone, protected interest count, 30-day duplicate block, phone/URL content moderation, 8-photo Storage upload, categories/filters/feed). **Fixed 2026-09-05:** (a) `firestore.rules` let a listing's own seller read `saleInterests` documents directly, exposing `buyerId` — the UI never used this and the read grant has been removed, sellers now see the count only; (b) there was no seller-facing way to request the paid activation (master lets the seller press "Pay ₹100"; Flutter was admin-push-only with a dangling "Open My Sale Ads" message pointing nowhere) — added `MySaleAdsScreen` (seller's own listings, status, expiry, interest count, "Request ₹100 activation" action) plus a scoped Firestore rule letting a seller move their own listing to `payment_pending` (never directly to `paid_active`, which stays admin-only).
- [x] Protected provider quote submission and customer quote acceptance — confirmed via the admin-roles/contact-protection audit (rules-enforced, not just UI-hidden).
- [ ] Complete service state actions after quote acceptance (provider confirmation, start, completion, customer-visible tracking) — not independently re-verified this pass; carried over from a prior claim.

## Accounts and safety
- [x] Signup/login/email verification/reset with Kannada/English continuity and resend guidance
- [x] Protected provider contact, quote acceptance and recorded manual advance verification
- [x] Privacy-safe live trip lookup/share code, trip-start OTP and official 112 emergency access
- [x] Firebase Auth, Firestore, Storage, FCM and one protected Firebase route function; no replacement backend introduced

## Partner, driver and administration
- [x] Counter/provider registration, approval, catalogue, slots and live bookings
- [x] Driver: sanitized job board, privacy-minimized document checklist/admin verification, atomic acceptance, OTP stages and immutable commission/payout settlement
- [x] Super Admin feature controls with immutable Home and SOS. Evidence: Flutter's togglable-feature list (`admin_control_center_screen.dart`) and master's `APP_FEATURE_DEFAULTS` (`app/api/app-config/route.ts`) both define the same 12 keys; neither codebase has a `feature_home`/`nav_home` key at all, and SOS is a hardcoded, non-toggle "LOCKED ON" row in both — structurally, not just conventionally, un-disableable.
- [x] Booking Admin / Market-Travel Admin / Super Admin role scoping is enforced in `firestore.rules` (`superAdmin()`, `bookingAdmin()`, `marketTravelAdmin()` helper functions gating real collection writes), not only hidden in the UI, and matches master's three roles in `lib/admin-auth.ts` one-for-one.
- [x] Contact protection (seller phone, driver phone, exact customer address) confirmed enforced at the Firestore rules layer for Sale and driver/travel data, not merely hidden in the UI.
- [x] Live dashboard, directory, provider approvals, ads, content publishing, manual payments, complaints/safety and protected role controls. **Fixed 2026-09-05:** market/delivery order status actions only offered generic Approve/Confirm labels; added master's named `store_confirmed`/`out_for_delivery` stages as explicit menu items for `marketOrders`.
- [~] Admin functional depth beyond role-scoping: machinery-request handling **confirmed present** (Market/Travel Admin's "Bookings / Orders" panel already filters the shared `orders` collection by a `machinery`/`Machinery` category chip — an earlier research pass mis-flagged this as missing because it searched for a dedicated collection name instead of the category-filter mechanism). **Gap found, not fixed:** master writes an `adminActivity` audit-trail row on every content create/update; Flutter's admin actions (`updateStatus`/`createContent`) don't write an equivalent "who did what, when" record despite an `adminActivity` collection already existing and being used for dashboard counts.
- Dead code noted, not touched this pass: `admin_dashboard_screen.dart`, `admin_service_providers_screen.dart` and `admin_service_provider_requests_screen.dart` are unreachable from the live admin login route (`AdminControlCenterScreen` is the only screen actually routed to); several legacy/duplicate classes also exist inside `home_screen.dart`/`city_explore_screen.dart`/`machinery_salon_screen.dart` unreachable from `ProductionHomeScreen`. Harmless (nothing user-facing is lost — the live screens are the ones audited above) but confusing to maintain; flagged as a separate cleanup task rather than deleted here to avoid touching files outside this audit's verified scope.

## Release gate
- [x] Analyzer clean; tests pass; **release APK builds and is properly signed** — `flutter build apk --release` succeeds; `apksigner verify --print-certs` confirms the output is signed with the owner's real release keystore (SHA-1 `80b4446fcf7ac750ea44f48994fe6fb96131c71d`, matching the `.jks` file's own fingerprint), not a debug-signing fallback; the Maps Android key baked into the manifest is confirmed real (39 chars, correct format) rather than a placeholder. Full debugging trail in `PHASE6_REPORT.md`.
- [ ] Customer, partner, driver and all three admin roles tested (requires a real device — Phase 5/7)
- [x] Firebase rule denial tests pass — 29/29 emulator tests passing against the real `firestore.rules`/`storage.rules` (customer/admin-role scoping, Sale privacy invariants, driver job-board scoping, identity/payment/contact read isolation, default-deny). See `PHASE4_REPORT.md`.
- [x] Atomic booking/interest/job-acceptance concurrency verified — a real two-transaction race for the same Vibe Town slot was fired against the emulator and confirmed exactly one booking wins, not assumed from reading the code.
- [x] Google Maps API enablement, restricted key creation, and the road-distance Cloud Function's secret/deploy — **complete**. Maps SDK for Android/Geocoding/Routes APIs enabled; Android-restricted key (package + debug SHA-1) saved to `android/local.properties` by the owner; server-restricted key (Routes+Geocoding only, no app restriction) set as the `GOOGLE_MAPS_SERVER_KEY` secret directly by the owner (never seen by me); `calculateRoadRoute` deployed to `asia-south1`, confirmed ACTIVE with the secret correctly bound via `firebase functions:log`. Full detail in `FIREBASE_PROJECT_MIGRATION.md`. Still open: actually calling it from the signed-in app on a real device to see a real distance returned (Phase 5/7 — needs a built APK, still blocked by the sandbox's Gradle-download restriction).
- [x] Firestore rules/indexes/Storage rules deployed to the production project — **the production project changed mid-Phase-4**: the owner confirmed `namma-ranebennur-production` (not the original `service-provider-a54c8`, which this account has no access to) is the real target, which also meant renaming the Android package to the already-registered `in.nammarane.bennur`. All three (`firestore.rules`, `firestore.indexes.json`, `storage.rules`) are now live on `namma-ranebennur-production`, using the exact rules the 29-test emulator suite verified — re-run against production's rules content after deploy, still 29/29. A pre-existing real `users` collection (with a genuine customer record and FCM token) was found and explicitly preserved untouched; 3 pre-existing indexes for an empty legacy `bookings`/`announcements` schema were left in place (never `--force`-deleted). Full detail in `FIREBASE_PROJECT_MIGRATION.md`.
- [ ] User accepts visual/workflow comparison before packaging

## Phase 3 status (2026-09-05)

All 15 modules from the master prompt's Phase 3 list have now had at least one
evidence-based audit pass (see `PHASE3_REPORT.md` for full detail). Every module
audited in depth this session: Travel, Nimma Sevaka delivery, Vibe Town, Used-item
Sale (all 9 rules), Market/Home Services/Machinery catalogues, the three admin roles
and contact-protection rules, Hotels/Halls venue booking, Catering, Clinic,
Requirements, Find For Me's Property/Events/Location filters, Announcements/New in
City/SOS, notifications, and admin dashboard functional depth.

**Real gaps fixed this session (9 total):** Catering's missing dedicated flow, the
Vibe Town slot-lock scoping bug, two Sale privacy/workflow gaps, the Find For Me
Location filter always redirecting to Maps instead of showing live listings, the
Requirements screen's thin/wrong-status data shape, market-order admin status
labels, and the Clinic booker-vs-patient-name field.

**Real gaps found and deliberately left open** (lower risk than the above, or
larger in scope than a same-file fix — see "Deferred, real gaps" in
`PHASE3_REPORT.md` for the full list): Travel vehicle-suitability check/fare
estimate/outstation fields, Nimma Sevaka's 20km distance cap, Vibe Town's
per-experience slot grid/pricing, Hotels/Halls per-venue photo galleries, no
admin activity/audit-trail writes, and notifications being a token-capture-only
stub with no send side anywhere in the project yet (not a regression — nothing
sends a push today, so there's nothing broken to fix in isolation; this is
end-to-end greenfield work spanning Cloud Functions too, better suited to a
dedicated pass than a partial client-side patch).

**Confirmed as already correct, no action needed:** Market/Home Services/Machinery
catalogues, the three admin roles' security scoping, Property/Events Find filters,
Announcements, New in City (a placeholder in *both* apps, not a Flutter gap), SOS,
and machinery-request admin handling (present via the shared orders/category-filter
mechanism, once verified directly rather than trusted from a collection-name grep).
