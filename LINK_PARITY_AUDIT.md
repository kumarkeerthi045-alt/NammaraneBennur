# v2.11.3 Link and Destination Parity Audit

This file is the release checklist for every internal destination and external
action in the existing `Namma-Ranebennur-Production-Source-v2.11.3` master.
An item is checked only when the Flutter source has the corresponding action.

## Internal destinations

| v2.11.3 destination | Flutter destination | Status |
| --- | --- | --- |
| `/` customer app | `ProductionHomeScreen` | [x] |
| `/demo` | `DemoModeScreen` | [x] |
| `/hotels` | `VenueBookingScreen(hotel: true)` | [x] |
| `/halls` | `VenueBookingScreen(hotel: false)` | [x] |
| `/home-services` | `ServiceScreen` with Home Services | [x] |
| `/machinery` | `ServiceScreen` with Machinery | [x] |
| `/travel` | `TravelScopeScreen` | [x] |
| `/market` | `MarketCatalogScreen` | [x] |
| `/sale` | `LocalSaleScreen` | [x] |
| `/catering` | `BookingFormScreen` for Catering | [x] |
| `/partner` | `PartnerServicesScreen` | [x] |
| `/admin` | authenticated `AdminControlCenterScreen` | [x] |
| `/?open=profile` | `ProfileScreen` / provider registration | [x] |
| Browser back / Home links | App bar back / Navigator pop | [x] |

## External and device actions

| v2.11.3 action | Flutter action | Status |
| --- | --- | --- |
| Approved sponsored-ad `targetUrl` | Restricted HTTP/HTTPS external launch | [x] |
| Emergency 112, ambulance 108, fire 101, child 1098 | Confirmation then native phone dialler | [x] |
| Nearby hospital | Google Maps search | [x] |
| Find For Me location choices | Google Maps search | [x] |
| Trusted-contact safety location | GPS coordinates → Google Maps link → system share sheet | [x] |
| Visible approved seller contact | Native phone dialler | [x] |
| Authorized admin contact details | Native phone dialler | [x] |
| Authorized admin addresses/map pin | Google Maps | [x] |
| Assigned driver customer contact | Native phone dialler, only after assignment | [x] |
| Assigned driver pickup/destination | Google Maps | [x] |
| Travel trip reference sharing | System share sheet | [x] |
| Exact embedded pickup/destination pin selector | Embedded Google Map, reverse geocoding and protected Firebase route result | [x] |

## Privacy invariants

- [x] Unknown URL protocols are rejected.
- [x] Seller phone remains hidden until the record explicitly allows contact.
- [x] Provider phone remains protected while quotes are exchanged.
- [x] Driver sees exact customer contact and locations only after assignment.
- [x] Admin contact actions are available only inside the authenticated role-based control centre.
- [x] Safety location is requested only after the customer taps **Share Location**.

## Release gate

- [ ] Run `flutter pub get` on the Windows Flutter installation.
- [ ] Run `flutter analyze` with no errors.
- [ ] Run `flutter test` with all tests passing.
- [ ] Test calls, Maps, GPS permission and sharing on a physical Android phone.
- [ ] Verify every route and back action against the existing v2.11.3 app.
- [ ] Owner accepts the final visual and workflow comparison.
