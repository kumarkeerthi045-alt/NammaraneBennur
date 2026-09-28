# Firebase project migration — service-provider-a54c8 → namma-ranebennur-production

Date: 2026-09-05

## What changed and why

The owner confirmed `namma-ranebennur-production` (owned by `dinesh7v72@gmail.com`)
is the final production Firebase project — not `service-provider-a54c8`, which the
checkpoint's config had been pointing at (a dev/prototype project the owner does
not have access to). The new project already had an Android app pre-registered
under the permanent production package name `in.nammarane.bennur` (not the
placeholder `com.example.service_provider`), so this migration bundled both
changes together — updating Firebase config alone would have produced an app
whose package name didn't match its own `google-services.json`.

Scope, per the owner's explicit choices: **Android only** for now (no iOS/macOS/
Web/Windows app registered in the new project — matches the plan's Android-first
release target; those platforms' `firebase_options.dart` entries were left
pointing at the old project, untouched, since nothing ships for them yet).

## Safety approach

- Tagged the pre-migration commit as `pre-namma-ranebennur-production-migration`
  before touching anything, so every change here is trivially revertable
  (`git checkout pre-namma-ranebennur-production-migration -- <file>`).
- Did not delete anything in the old `service-provider-a54c8` project (no access
  to it anyway) or touch its data.
- Deployed rules/indexes to the new project using the exact `firestore.rules`
  already verified by the 29-test emulator suite in Phase 4 — not a new,
  unverified ruleset.
- Did **not** force-overwrite pre-existing indexes already present on the new
  project that aren't in this repo's `firestore.indexes.json` (see "Open
  question" below) — deploy ran without `--force`, so nothing was deleted.

## Changes made

1. **`lib/firebase_options.dart`** — `android` block now points to
   `namma-ranebennur-production` (app id
   `1:166569429852:android:aed605af44d74bf4c6cf99`, API key, storage bucket).
   `ios`/`macos`/`web`/`windows` blocks intentionally left unchanged (still
   `service-provider-a54c8`) — see Scope above.
2. **`android/app/google-services.json`** — replaced wholesale with the new
   project's Android app config (fetched via `firebase apps:sdkconfig`).
3. **`android/app/build.gradle.kts`** — `namespace` and `applicationId` changed
   from `com.example.service_provider` to `in.nammarane.bennur`.
4. **`android/app/src/main/kotlin/`** — `MainActivity.kt` moved from
   `com/example/service_provider/` to `in/nammarane/bennur/` (`git mv`, history
   preserved) and its `package` declaration updated. Note: `in` is a reserved
   keyword in Kotlin, so the declaration had to be
   `` package `in`.nammarane.bennur `` (backtick-escaped) — a plain
   `package in.nammarane.bennur` would not compile. Verified with
   `flutter analyze` (0 errors) after the change.
5. **`firebase.json`** — `flutter.platforms.android` and
   `flutter.platforms.dart.lib/firebase_options.dart` blocks updated to the new
   project id/app id; the ios/macos/web/windows app-id entries were removed
   from the `dart.configurations` map since flutterfire's own config block
   should only list apps that actually exist in the *current* target project
   (those platforms' options in `firebase_options.dart` itself are untouched,
   as above — this only affects what `flutterfire configure` would regenerate
   if re-run, not runtime behavior).
6. **`.firebaserc`** (new file) — pins the CLI's default project to
   `namma-ranebennur-production` so `firebase` commands don't need `--project`
   every time.
7. **`MAPS_SETUP.md`** — the example `firebase use service-provider-a54c8`
   command updated to `firebase use namma-ranebennur-production`.
8. Searched the whole project for every remaining reference to
   `com.example.service_provider`, `com.example.serviceProvider`,
   `service-provider-a54c8`, and the old project number (`142325336828`) —
   confirmed no other Android/Gradle/manifest file still references them.

## Verification performed

```
flutter clean && flutter pub get  -> OK
flutter analyze                    -> 0 errors, 0 warnings, 8 deferred info (unchanged)
flutter test                       -> 1/1 passing
```

`firebase deploy --only firestore:rules,firestore:indexes --project
namma-ranebennur-production` — **succeeded**, deploying the exact rules already
proven by the Phase 4 emulator suite.

## Update 2026-09-05, later same day

- **Existing data confirmed by the owner directly in the console:** a real
  `users` collection exists with at least one genuine customer record and an
  FCM token. **No `bookings`, `orders`, or `announcements` collections exist**
  — the 3 pre-existing indexes referencing a `bookings`/`announcements` schema
  point at collections that are currently empty (an index can outlive its
  collection in Firestore once all documents are deleted, which is
  consistent with "index exists, collection doesn't"). Owner confirmed: no
  old-schema migration is needed, and the existing `users` data must be
  preserved as-is. Nothing has touched, migrated, or deleted it — the
  currently-deployed `firestore.rules` gate `users/{uid}` access purely by
  matching the document id to the signed-in uid (`owns(uid)`), never by
  validating the existing document's internal field shape, so that customer's
  record and FCM token remain fully readable/writable by its own owner (and
  admins) exactly as before, with zero schema changes required.
- **Storage provisioned** by the owner (asia-south1/Mumbai, production mode,
  empty bucket, project on Blaze). **`storage.rules` deployed successfully.**
- **Re-verified after deployment:** ran the full 29-test emulator suite again
  against the exact rules files now live in production — still 29/29 passing.
  Re-ran the indexes deploy (idempotent) — confirms `firestore.indexes.json`'s
  2 indexes are live, and the 3 pre-existing `bookings`/`announcements`
  indexes remain untouched (no `--force` used anywhere in this migration).

## Update 2026-09-05, Maps setup completed

- **Authentication confirmed:** Email/Password is now enabled on
  `namma-ranebennur-production` (Phone and Anonymous sign-in are also
  enabled from earlier setup — flagged to the owner as worth reconsidering
  disabling Anonymous specifically, since the app never uses it and every
  `signedIn()` check in `firestore.rules`/`storage.rules` would otherwise
  accept an anonymous session as equivalent to a real registered user).
- **Maps SDK for Android, Geocoding API, and Routes API** all enabled by the
  owner in Google Cloud Console.
- **Two restricted API keys created** by the owner:
  - Android-restricted key, restricted to package `in.nammarane.bennur` +
    the current debug-keystore SHA-1
    (`A7:EE:29:65:0D:60:20:CE:4E:2C:83:73:93:C3:F9:20:F4:BB:6F:55` — will
    need a second SHA-1 added for the release keystore once that's created,
    per Phase 6). Restricted to Maps SDK for Android only. Saved by the
    owner directly into `android/local.properties` (never seen in this
    chat, never committed — that file is gitignored).
  - Server-restricted key (Application restrictions: None — used only
    server-to-server from the Cloud Function, never sent to a client),
    restricted to Routes API + Geocoding API only.
- **`GOOGLE_MAPS_SERVER_KEY` secret** set directly by the owner via
  `firebase functions:secrets:set` in their own terminal — the value was
  never visible in this chat or any file/log I can read.
- **`calculateRoadRoute` deployed** to `namma-ranebennur-production`
  (asia-south1, Cloud Functions Gen2, Node.js 22, callable). Confirmed via
  `firebase functions:list` (state present) and `firebase functions:log`
  (container started cleanly, `secretEnvironmentVariables` correctly bound
  to `GOOGLE_MAPS_SERVER_KEY` version 1, no errors). Also set a cleanup
  policy for old container images in `asia-south1` (Cloud Functions' own
  first-deploy prompt flagged this as missing) to avoid unnecessary
  Artifact Registry storage costs accumulating over time.

**Not yet verified — needs the real app on a real device (Phase 5/7), not
achievable from this sandboxed session:** actually calling
`calculateRoadRoute` from the signed-in Flutter app (Travel and Nimma Sevaka
Delivery screens) and confirming a real road distance comes back, per the
master prompt's own verification step in `MAPS_SETUP.md`. Everything
structural (deployment, secret binding, key restrictions, API enablement) is
confirmed healthy; only true end-to-end functional confirmation remains,
which requires a debug/release APK — still blocked by the sandboxed
environment's Gradle-distribution-download network restriction (Phase 2
finding, unrelated to this migration). Build and test from the owner's own
terminal when ready.

## Still open

- **FCM** — no separate enablement needed once an app is registered (already
  true, and proven true here — the existing customer's FCM token is real).
  "Notification handling works end-to-end" remains the pre-existing Phase 3/4
  finding (no send-side exists anywhere yet), unaffected by this migration.
- **Debug/release APK build** — see above.
- **Release signing / permanent keystore** — Phase 6 work, not started; the
  Android key's restriction will need the release SHA-1 added once that
  exists.

## Rollback

If anything here needs to be undone:
```powershell
git checkout pre-namma-ranebennur-production-migration -- lib/firebase_options.dart android/app/google-services.json android/app/build.gradle.kts firebase.json MAPS_SETUP.md
git mv "android/app/src/main/kotlin/in/nammarane/bennur/MainActivity.kt" "android/app/src/main/kotlin/com/example/service_provider/MainActivity.kt"
rm .firebaserc
```
Nothing was deployed destructively — the rules/indexes deploy to
`namma-ranebennur-production` only added/updated rules and indexes there,
using `--force` nowhere.
