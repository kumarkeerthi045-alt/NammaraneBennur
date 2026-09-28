# Phase 3 — functional parity review

Date: 2026-09-05

Two passes, same session. Part 1 covered the areas judged highest-risk from the
Phase 1 inventory (the generic `OrderModel` question) plus the modules with the
most surface area. Part 2 (appended below) covers the rest of the master prompt's
15-module Phase 3 list, closing it out. Method throughout: read the master's actual
route/component/schema code side by side with the Flutter screen/service code
(directly, and via parallel research passes), require concrete file:line evidence
for every claim, then fix what was clearly wrong without redesigning anything
around it — never trust a checkmark or a collection-name grep alone (one finding
below was itself corrected after direct verification showed the research pass had
missed a category-filter mechanism).

## Part 1

## Areas verified with evidence, fixed where a real gap was found

### Travel — mostly at parity, 3 gaps found and left open
- Vehicle types, all three scopes (Within City / Outstation-Tour / Goods Transport),
  and the protected road-distance callable (no exposed key) all confirmed matching
  master.
- Full lifecycle (quote → advance → assignment → trip-start OTP → completion →
  share) confirmed matching, contact protected pre-assignment.
- **Not fixed:** master rejects a booking whose vehicle doesn't suit the entered
  passenger count / goods weight (`app/api/travel/route.ts`); Flutter only filters
  the vehicle *list*, no submit-time check. Master computes and stores
  `estimatedFare`; Flutter's travel submit never writes one. Master's outstation/tour
  bookings also carry `returnDate`/`tourDays`/`acPreference`; Flutter's outstation
  form doesn't collect them. None of these break privacy/security invariants — they're
  missing data-capture, not missing protection — so left open for a follow-up pass.

### Nimma Sevaka delivery — at parity, 1 minor gap found and left open
- All seven delivery types, weight/dimension/value/budget limits, and pickup +
  delivery OTP with correct reveal timing all confirmed matching master.
- **Not fixed:** master caps city delivery distance at 20km; Flutter has no
  equivalent check after the route callable returns a distance.

### Vibe Town — 1 real regression found and fixed, 2 gaps left open
- **Fixed:** `FirestoreService.createVibeTownBooking`'s slot lock was keyed only by
  `(day, timeSlot)`, so booking any one experience (e.g. "Movie Show" at 6 PM) locked
  out every *other* experience at that same hour too — a customer wanting "VR & PS5"
  at 6 PM would be wrongly told it's booked. Master's uniqueness check is scoped to
  `(bookingDate, serviceType, timeSlot)`. Fixed by adding `serviceType` to the lock
  document id and to the `vibeTownSlotAvailability` query, and updating the one
  caller (`special_booking_screens.dart`) to pass the selected experience.
- The Phase 1 concern about whether an actual booking record (not just a lock
  marker) gets persisted was **resolved as a non-issue**: `createVibeTownBooking`
  already writes a full `orders` document transactionally alongside the lock.
- **Not fixed:** master defines a different slot grid per experience (e.g. Movie
  Show = two 3-hour blocks, VR & PS5 = 30-minute slots) and computes a per-experience
  price at booking time; Flutter uses one generic hourly 9AM–10PM grid for every
  experience and captures no price/estimate field. This is a real polish gap but a
  larger, layout-affecting change than Catering/Sale, so left open.

### Used-item Sale — verified against all 9 required rules, 2 real gaps found and fixed
1. 5-hour free trial — confirmed matching.
2. Admin 24-hour free verification — confirmed matching.
3. ₹100/30-day paid activation terminal state — confirmed matching.
4. Seller phone hidden until paid — confirmed, and Flutter enforces this at the
   **Firestore rules level** (a listing document is physically forbidden from
   carrying `sellerPhone` at creation), stricter than master's API-response-only
   filtering.
5. Buyer interest = protected count only — **gap found and fixed:**
   `firestore.rules` let a listing's own seller read `saleInterests` documents
   directly, which contain `buyerId` — the UI never used this path, but the rule
   didn't prevent it either. Removed the seller's direct read grant; only the buyer
   themself or an admin can read an interest document now. Confirmed no Flutter code
   relied on the removed path before changing it.
6. 30-day same-title repost block — confirmed matching (keyed by seller uid instead
   of phone, a reasonable architecture difference given Flutter's Auth-based design).
7. Phone/WhatsApp/website content moderation — confirmed matching (Flutter's regex is
   a superset of master's, no under-blocking).
8. Up to 8 photos in Firebase Storage — confirmed matching; actually stronger than
   master's own implementation, which only stores selected file *names* as text.
9. Categories/filters/feed — confirmed matching. **Gap found and fixed:** master lets
   a seller self-request the ₹100 activation ("Pay ₹100" button, sets
   `payment_pending`); Flutter was admin-push-only, with an existing snackbar telling
   users to "Open My Sale Ads" that pointed at no screen at all. Added
   `MySaleAdsScreen` (the seller's own listings, status, expiry, interest count, and
   a "Request ₹100 activation" action) reachable from a new icon on the Buy & Sell
   screen, plus a scoped Firestore rule letting a seller move their own listing to
   `payment_pending` only — `paid_active` stays admin-only, matching master's
   admin-confirms-payment model.

### Market / Home Services / Machinery catalogues — full parity, no gaps
- Market: exact 63-product / 12-category count verified by direct comparison against
  master's `market-catalog-data.ts` — same ids, names, emoji, and prices, not just a
  matching total.
- Home Services: exact 8-worker match (name + real photo) against master's
  `booking-catalog.tsx` list.
- Machinery: exact 8-service match (name + real photo) against master's
  `commerce-pages.tsx` `MACHINERY` list. Both codebases carry the same 6 unreferenced
  leftover SVG files in the machinery asset folder — harmless, present on both sides.

### Admin roles and contact-protection invariants — full parity, no gaps
- The three roles (Super / Booking / Market-Travel Admin) are enforced by
  `firestore.rules` helper functions gating real collection writes, not just hidden
  in the UI, and match master's three roles field-for-field.
- Home and SOS are structurally excluded from the feature-flag system in **both**
  codebases (no `feature_home`/`nav_home` key exists anywhere; SOS is a hardcoded,
  non-toggle row), not merely a convention either side could accidentally break.
- Seller/driver/customer contact protection confirmed enforced at the Firestore rules
  layer, matching master's protected-workflow model.

### Hotels / Halls venue booking — at parity, 1 minor deferred item
- `VenueBookingScreen` is a faithful, near line-for-line port of master's
  `VenueBookingPage` (list → details → form → confirmation flow, hotel check-in/out +
  room type, hall date/time-slot + occasion, minimum-advance display).
- Not fixed (deferred as a possible future enhancement, not a required-feature loss):
  master renders up to 3 owner-uploaded photos per venue from a stored `imagesJson`
  field; Flutter always shows one generic stock photo per category. Building a real
  per-venue photo gallery would need new Storage/upload plumbing on the provider side,
  which is a larger feature addition, not a same-file fix — flagged for a dedicated
  pass rather than done ad hoc here.

### Catering — real gap found and fixed
- Catering (`Find For Me → Events → Catering`) was silently falling through
  `ProductionHomeScreen.openFind`'s generic `_` case straight into the bare-bones
  `BookingFormScreen` (name/phone/address/date-time/purpose/budget) — losing the
  master's entire 2-step wizard: food-type choice (Pure Veg / Veg & Non-Veg /
  Non-Veg), occasion dropdown, guest-count range validation (10–10,000), a
  meals checklist requiring at least one selection, a menu text field, a serving
  time separate from the event date, and an extras checklist (serving staff, plates,
  tables, water, decoration). It was also posting a plain `orders` booking instead of
  an Events/Catering `requirements` document like master does.
- Fixed by adding `CateringBookingScreen`, which reproduces that exact 2-step wizard
  bilingually (Kannada/English, consistent with the rest of the production screens),
  and wiring `openFind('Catering')` to it instead of the generic fallback.

Part 1 verification:

```
flutter analyze  -> 0 errors, 0 warnings, 8 deferred info (Radio deprecation, unchanged from Phase 2)
flutter test     -> 1/1 passing
```

## Part 2 — remaining modules

Covers everything Part 1 left unaudited: Clinic, Requirements, Find For Me's
Property/Events/Location filters, Announcements/New in City/SOS, notifications, and
admin dashboard functional depth. This closes out all 15 modules from the master
prompt's Phase 3 list.

### Clinic — at parity, 1 moderate gap found and fixed
- Confirmed genuinely clinic-specific, not a reused generic venue form: Flutter's
  `clinic_screen.dart` collects `patientName`/`patientAge`/`visitPurpose`, mapping
  directly to master's dedicated `businesses`-category-conditional fields and
  `bookings` table columns for Clinic (master enforces these are non-empty
  specifically when `category === "Clinic"`). Live verified-clinic discovery,
  partner-defined slots, and the confirm/complete status lifecycle with phone
  protection pre-confirmation all confirmed matching.
- **Fixed:** master collects an independent booker/guardian name distinct from the
  patient's own name (so someone can book for a family member); Flutter collapsed
  the two by reusing `patientName` as `customerName`. Added a separate "Your name
  (person booking)" field (`bookedByName`/`customerName`), keeping `patientName` as
  the patient's own identity.

### Requirements — real gap found and fixed (also fixed a pre-existing display bug)
- Master has a genuine standalone "Post Requirement" feature (not just an internal
  API other flows call), with a structured schema (name, phone, category, title,
  details, area, requiredDate, budget) so providers can filter and quote it.
- **Fixed:** Flutter's `RequirementsScreen` wrote only a single free-text field plus
  `status: 'new'` — a status value the provider-facing requirement queue never
  queries for (it filters `status == 'pending'`), so anything posted through this
  screen was invisible to providers. Worse, the thin field shape meant even
  requirements created correctly by Catering/Home Services (which already use
  `FirestoreService().createRequirement`) would render with blank category/title/
  details wherever the app expected those fields — which both
  `partner_portals_screen.dart`'s requirement card and `profile_screen.dart`'s own
  "My Requirements" tab already did, before this screen existed. Rebuilt the form
  to collect the full structured shape and submit through the same
  `createRequirement` path, fixing the display bug everywhere at once, not just in
  this screen.

### Find For Me — Property and Events at parity; Location gap found and fixed
- Property and Events confirmed matching master exactly (same group lists, same
  live-Firestore-feed filtering by category/subcategory/listingMode).
- **Fixed:** Location previously intercepted every tap and launched an external
  Google Maps search (`if (main == 'Location') { LinkService.mapSearch(...); return; }`),
  so its live listings feed — which master reads with the *exact same* mechanism
  as Property/Events, no special-casing — could never be shown. Removed the
  redirect; Location now behaves identically to the other two filters.

### Announcements, New in City, SOS — full parity, no gaps
- Announcements: both read only admin-verified/published rows.
- New in City: confirmed to be a **static informational placeholder in both apps**
  — master's own implementation doesn't back this tab with live data either, so
  Flutter matching that (rather than building live data support master itself
  lacks) is correct parity, not a shortfall.
- SOS: exact same numbers (112/108/101/1098), same confirm-then-dial behavior, and
  structurally excluded from the feature-flag system in both apps (no toggle exists
  for it either side, not just a convention). Trusted-contact storage is actually
  stronger in Flutter (server-backed Firestore, 5-contact cap, phone validation)
  versus master's client-only `localStorage` — an improvement, not a regression.
  Nearby-hospital is likewise stronger in Flutter (opens a real map search; master
  only shows a toast).

### Notifications — Flutter-only feature, half-built, no master equivalent to compare
- Master (primarily a web/Capacitor app) has no push-notification implementation at
  all — nothing to hold Flutter's FCM integration to parity *against*.
- `NotificationService` is real, wired code (not dead) — it requests permission,
  captures the FCM token, and stores it on the user's Firestore document. But there
  is no foreground-message handler and no background/terminated-tap-to-navigate
  handler, **and — checked directly — nothing anywhere in the project (no Cloud
  Function trigger, no admin broadcast action) ever actually sends a push
  notification either.** This is a stub on both ends, not a broken half of a working
  feature. Completing it is real, valuable work, but it's a cross-cutting addition
  (Cloud Function triggers + client message handling + a navigation/deep-link
  contract) better suited to its own dedicated pass than a partial patch here.

### Admin dashboard functional depth — 1 finding corrected, 1 real gap found, dead code noted
- **Corrected a research-pass false positive:** an initial finding claimed Market/
  Travel Admin has no way to manage Machinery requests. Direct verification showed
  this is wrong — `admin_control_center_screen.dart`'s `marketTravelCategories`
  list already includes `'machinery'/'Machinery'`, and the shared "Bookings /
  Orders" panel filters the `orders` collection by that category chip, giving full
  quote/confirm/complete/reject access. The research pass had grepped for a
  dedicated `machineryRequests` collection name and missed the category-filter
  mechanism — a reminder to verify agent findings against the actual code before
  acting on them, which this session did before treating it as real.
- **Real gap found, not fixed:** master writes an audit-trail row to `adminActivity`
  on every content create/update; Flutter's admin actions (`updateStatus`,
  `createContent`) never write an equivalent record, even though an `adminActivity`
  collection already exists and is read for dashboard counts. There's no "who did
  what, when" trail in Flutter's admin today.
- **Dead code noted, not touched:** `admin_dashboard_screen.dart`,
  `admin_service_providers_screen.dart`, and `admin_service_provider_requests_screen.dart`
  are unreachable — the only screen actually routed to from admin login is
  `AdminControlCenterScreen`. Several legacy/duplicate classes also exist inside
  `home_screen.dart`, `city_explore_screen.dart`, and `machinery_salon_screen.dart`
  that are unreachable from the live `ProductionHomeScreen` entry point. None of
  this affects user-facing parity (the live screens are what this whole audit
  checked), but it's confusing for future maintenance — flagged as a separate
  cleanup task rather than deleted here, since confirming a file is *entirely* dead
  (versus dead classes mixed with live code in the same file) needs its own careful
  pass.

## Verification after Part 2

```
flutter analyze  -> 0 errors, 0 warnings, 8 deferred info (unchanged)
flutter test     -> 1/1 passing
```

## All 15 Phase 3 modules — final status

Every module from the master prompt's Phase 3 list has now had an evidence-based
pass. Fixed this session: Catering, Vibe Town slot-lock scoping, Sale (2 gaps),
Find For Me Location, Requirements, market-order admin labels, and Clinic
booker-name. Confirmed already correct: Market/Home Services/Machinery catalogues,
admin role security scoping, Hotels/Halls (core flow), Find For Me Property/Events,
Announcements/New in City/SOS, and machinery-request admin handling.

## Deferred, real gaps (documented, not fixed)

Each is either larger in scope than a same-file fix, or lower-risk (missing data
capture / missing polish, not a privacy or security issue):
- Travel: no vehicle-suitability check at submit time, no fare estimate captured,
  outstation/tour missing `returnDate`/`tourDays`/`acPreference`.
- Nimma Sevaka: no 20km city-delivery distance cap.
- Vibe Town: generic hourly slot grid and no price capture, where master varies
  slot length/pricing per experience.
- Hotels/Halls: no per-venue photo gallery (Flutter shows one stock photo per
  category instead of the master's owner-uploaded `imagesJson` photos).
- Admin: no audit-trail (`adminActivity`) writes on content/status changes.
- Notifications: token capture only, no send side anywhere yet, no foreground/
  background message handling — greenfield work, not a regression.
- Dead/unreachable legacy screens and classes (listed above) — cleanup, not parity.

## Next recommended step

With all 15 modules now audited at least once, the natural next step is Phase 4
(Firebase security rules validation + emulator allow/deny tests + Maps deployment)
rather than a third Phase 3 pass — the remaining open items above are either
follow-up polish or need the emulator/device testing Phases 4–5 exist for anyway.
