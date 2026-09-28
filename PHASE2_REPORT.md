# Phase 2 — restore and compile

Date: 2026-09-05

## Commands run (from the Flutter project root)

```powershell
D:\develop\flutter\bin\flutter.bat clean
D:\develop\flutter\bin\flutter.bat pub get
D:\develop\flutter\bin\flutter.bat analyze
D:\develop\flutter\bin\flutter.bat test
```

## Results

- `flutter clean` — OK.
- `flutter pub get` — OK. Resolved all four previously-unverified dependencies
  (`cloud_functions`, `geocoding`, `google_maps_flutter`, `image_picker`) plus
  their platform plugin packages. 78 dependency changes total.
- `flutter analyze` — **started at 34 issues (2 errors, 1 warning, 31 info),
  ends at 8 issues (0 errors, 0 warnings, 8 deferred info).**
- `flutter test` — **started failing (1/1 failing), ends at 1/1 passing.**

## Errors fixed (compile-blocking)

`geocoding` 5.0.0 removed the top-level `locationFromAddress()` and
`placemarkFromCoordinates()` functions the code was calling and replaced them
with an instantiable `Geocoding` class. Fixed in
[location_picker_screen.dart](lib/screens/location_picker_screen.dart) by
adding a `final geocoding = Geocoding();` field and calling
`geocoding.locationFromAddress(...)` / `geocoding.placemarkFromCoordinates(...)`.
This also cleared the resulting "unused import" warning.

## Test fixed (was failing, not just unverified)

`test/widget_test.dart`'s only test failed with `A Timer is still pending even
after the widget tree was disposed`. Root cause:
[splash_screen.dart](lib/screens/splash_screen.dart) starts a 2-second
`Future.delayed` timer in `initState`, and the previous test never advanced
the fake clock past it, so flutter_test's dangling-timer check failed the
test on every run — this was a real, always-failing test, not a template
placeholder as assumed in the Phase 1 notes.

Fix (test-only + one small testability seam, no behavior change):
- `AuthService` now takes an optional injectable `FirebaseAuth` (defaults to
  `FirebaseAuth.instance`, identical to before).
- `SplashScreen` now takes an optional injectable `AuthService` (defaults to
  `AuthService()`, identical to before).
- Added `firebase_auth_mocks` as a **dev-only** dependency.
- `widget_test.dart` now pumps `SplashScreen` with an `AuthService` backed by
  `MockFirebaseAuth()` (no signed-in user, no real Firebase platform channel),
  asserts the splash text, then pumps 3 seconds forward so the timer drains
  cleanly and the screen navigates to `LoginScreen` without needing a live
  Firebase connection.

No test assertions were removed or weakened — the test still verifies the
same thing (splash screen renders) and now also survives the real navigation
flow that follows it.

## Lint cleanup (mechanical, zero behavior change)

Fixed 23 of the 31 info-level lints flutter's default `flutter_lints` set
flagged, all safe rewrites with no visual or logic impact:
- 8× `unnecessary_underscores` — `(_, __)` / `(_, __, ___)` callback params
  simplified to repeated `_` (Dart 3 allows multiple wildcard params).
- 2× `avoid_types_as_parameter_names` — renamed `sum` fold-callback params to
  `total` in `market_catalog_screen.dart`.
- 1× `control_flow_in_finally` — `profile_screen.dart`'s `finally { if
  (!mounted) return; setState(...); }` restructured to `finally { if
  (mounted) { setState(...); } }` (identical behavior, no `return` in
  `finally`).
- 9× `avoid_print` — `auth_service.dart`'s debug `print()` calls switched to
  `debugPrint()`.
- 2× `use_build_context_synchronously` — added a `mounted`/`context.mounted`
  guard immediately before a `showDialog` call that followed an `await`, in
  `partner_portals_screen.dart` and `production_home_screen.dart`.

## Deliberately deferred (8 remaining info-level lints)

`deprecated_member_use` on `RadioListTile.groupValue` / `.onChanged` in
`home_screen.dart` (1 radio group), `signup_screen.dart` (2 radio groups) and
`widgets/service_request_form.dart` (1 radio group). Flutter's replacement
requires wrapping each existing radio group in a new `RadioGroup<T>` ancestor
widget — a widget-tree structural change across several call sites, not a
same-line fix. The old API still works correctly in Flutter 3.47.2 (deprecated,
not removed), so this carries no functional risk today. Deferring it to the
Phase 5 visual/interaction comparison, where the resulting layout can actually
be checked on-device rather than assumed safe from source alone.

## Attempted but blocked: debug APK build

`flutter build apk --debug` was tried as an extra sanity check beyond the
required Phase 2 commands. It failed before touching any app code — Gradle's
own wrapper could not download the Gradle distribution from this sandboxed
shell (`Connection timed out` reaching Gradle's download server, while
`pub.dev` itself was reachable during `pub get`). This is an environment/
network restriction of the sandbox, not a code defect. It is also expected to
need `android/local.properties` (SDK path + restricted Maps key), which per
the master prompt is intentionally not present yet. Real APK builds belong to
Phase 7 in the plan anyway, once Maps/Firebase setup (Phase 4) and full
parity/visual review (Phases 3 and 5) are done — recommend running the actual
build commands directly in your own Windows terminal (not through this
sandboxed session) when that phase is reached.

## Net result

```
flutter analyze  -> 0 errors, 0 warnings, 8 deferred info (Radio deprecation)
flutter test     -> 1/1 passing
```

No screens, workflows, labels, assets or business logic were changed —
every edit in this phase was either a compile-correctness fix, a mechanical
zero-behavior-change lint cleanup, or test-only infrastructure.
