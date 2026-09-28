# Phase 4 — Firebase security and deployment

Date: 2026-09-05

## What this phase covers (per the master prompt)

1. Validate `firebase.json`, Firestore rules, Storage rules and indexes.
2. Add/run Firebase Emulator tests covering allowed and denied operations for
   customer, provider, counter, driver, Booking Admin, Market/Travel Admin and
   Super Admin.
3. Test atomic booking/interest/job-acceptance operations and concurrency.
4. Verify seller phone, customer phone, precise locations, identity documents
   and payment records cannot be read by unauthorized users.
5. Confirm FCM tokens are stored securely and notification handling works.
6. Follow `MAPS_SETUP.md` to enable Google APIs, create restricted keys, set
   the Firebase Function secret, and deploy the route function.
7. Deploy Firestore rules, Storage rules and indexes to the production project.

Items 1–4 and part of 5 are things I could do entirely inside this sandbox
(no real Firebase project, no billing, no owner credentials needed — the
Firestore/Storage emulator only needs a fake "demo-" project id). Items 6 and
7 need the owner's own Google/Firebase account, billing, and console access —
I did not attempt those and should not; details on exactly what to run
yourself are at the bottom of this report.

## 1. Config validation

- `firebase.json` was a single-line minified file with no `emulators` block.
  Reformatted for readability and added an `emulators` section (Firestore
  8080, Storage 9199, Auth 9099, UI disabled, `singleProjectMode`) so the
  emulator suite below can actually run. No existing config was changed —
  only the new block was added.
- `functions/index.js` (the protected road-distance callable): syntax-checked
  clean (`node --check`), its declared dependency (`firebase-functions@7.3.2`)
  resolves, and `npm install` in `functions/` completes with no errors (only
  an expected Node-version *engine* warning, since this dev machine's local
  Node is newer than the Cloud Functions runtime the function will actually
  run on — irrelevant to deployment). The function correctly requires
  authentication, validates pickup/destination as real lat/lng pairs, never
  logs or returns the Maps server key, and only ever sends it as an outbound
  header to Google's Routes API.
- `firestore.indexes.json`: had 2 composite indexes. Cross-checked against
  every `.where(...).orderBy(...)` query pattern in `lib/` and found one
  missing — the Phase 3 `MySaleAdsScreen` query
  (`saleListings.where('sellerId', ==, uid).orderBy('createdAt', desc)`) had
  no matching index. Added it. Also empirically verified (see below) that the
  app's two *equality-only* compound queries (`providerQuotes` by
  `providerUid`+`requirementId`, `vibeTownSlotLocks` by `dayKey`+`serviceType`)
  do **not** need an explicit index — Firestore serves those from single-field
  indexes automatically, so nothing was missing there.
- `storage.rules`: read in full; cross-checked every `match` block against
  what the app actually uploads (`users/{uid}`, `bookingCounters/{uid}`,
  `driverPartners/{uid}`, `saleListings/{uid}`, `public/`) — all consistent
  with the app's own upload paths, size/content-type limits present, and a
  final default-deny catch-all.

## 2–4. Emulator test suite — 29/29 passing

Added `firebase-tests/` (Node, `@firebase/rules-unit-testing`) and ran it
against a real local Firestore + Storage emulator — these are genuine rules
evaluations against the actual `firestore.rules`/`storage.rules` files, not
mocks or code-reading guesses. Running them required a JDK the machine didn't
have (`firebase-tools` now requires JDK 21+; this machine only had a JRE 8) —
downloaded a portable Eclipse Temurin 21 to
`D:\namma ranebennur\jdk-tools\` (self-contained, not a system-wide install;
delete the folder any time to remove it — nothing was changed outside it).

**Note on disk space:** while doing this, I found the `C:` drive completely
full (0 bytes free at the time — a JDK zip download to `%TEMP%` failed
outright as a result). I cleaned up my own leftover files there, which
freed a little space, but this is worth your own attention separately — a
fully-out-of-space system drive can cause unrelated problems (failed
Windows/app updates, apps crashing on save, etc.) well beyond this project.

Command to reproduce (from the project root, JDK 21+ on `PATH`):
```powershell
$env:JAVA_HOME = "D:\namma ranebennur\jdk-tools\jdk-21.0.12.1+1"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
cd "firebase-tests"; npm install; cd ..
.\firebase-tests\node_modules\.bin\firebase emulators:exec --project=demo-namma-ranebennur --only firestore,storage "node --test firebase-tests/*.test.mjs"
```

**Results: 29/29 tests passing.** Coverage includes:
- Unauthenticated users denied everywhere sensitive; default-deny confirmed
  for any collection/path not explicitly listed in either rules file.
- Customer order lifecycle: can create only their own order, cannot read or
  modify another customer's order, can cancel their own pending order but
  cannot alter other fields, cannot escalate their own account role.
- All three admin roles' category scoping proven directly: Booking Admin can
  read a hotel order but is denied a travel order; Market/Travel Admin is the
  exact mirror image; Super Admin can read both; a *deactivated* admin record
  (`active: false`) is denied admin access entirely, even with the right role
  value stored.
- **Sale privacy invariants (the exact rules changed in Phase 3), proven
  directly rather than re-read:** a listing cannot be created carrying a
  seller phone or any non-`trial_live`/visible status; a seller can move
  their own listing to `payment_pending` but cannot grant themselves
  `paid_active`; the buyer-interest paired transaction (increment count +
  create interest doc) succeeds for a real buyer but a seller — even for
  their own listing — is denied reading the interest document directly
  (this is the exact leak fixed in Phase 3, now under a permanent regression
  test); a seller cannot register interest in their own listing;
  `saleListingPrivate` (the seller's real phone) is unreadable by a buyer.
- **Real concurrency, not just rules:** fired two genuine Firestore
  transactions at the same Vibe Town slot simultaneously (the identical
  read-check-then-write pattern `FirestoreService.createVibeTownBooking`
  uses) and asserted exactly one wins — this exercises Firestore's actual
  optimistic-concurrency guarantee under real contention, directly verifying
  the double-booking prevention the parity matrix claims, not assuming it
  from reading the code.
- Driver job board: a driver of the wrong vehicle type is denied accepting a
  pending job.
- Identity/contact protection: a booking counter's registration record,
  a payment record, and trusted contacts are all confirmed unreadable by an
  unrelated signed-in user, readable only by their owner or the correct
  admin role.
- Storage: per-uid folder isolation for user/counter/driver/sale-listing
  uploads, size/content-type limits enforced, public assets readable by
  anyone but writable only by an active admin, default-deny for any
  unlisted path.

No rule bugs were found by this pass beyond the missing index above — the
existing rules (including the Phase 3 changes) hold up under direct
adversarial testing, not just inspection.

## 5. FCM token storage

Already covered directly in Phase 3: `NotificationService` requests
permission, captures the token, and stores it under
`users/{uid}.notificationTokens` — protected the same way the rest of the
`users` document is (owner or admin only, per the rules tests above; the
`users` collection wasn't re-tested here specifically, but is covered by the
same `owns(uid) || activeAdmin()` pattern proven elsewhere in this suite).
"Notification handling works" remains not true end-to-end — see the Phase 3
report: nothing anywhere in the project (client or Cloud Function) currently
*sends* a push, so there's no send-then-receive path to verify yet. This is
unchanged from Phase 3 and still flagged as future work, not a regression.

## 6–7. Maps deployment and production rules deployment — owner action required

**Update 2026-09-05, later same day:** logged in via the terminal as
`dinesh7v72@gmail.com`. `firebase projects:list` for that account shows only
two projects — `fir-demo-project` and `namma-ranebennur-production` — and
`firebase use service-provider-a54c8` fails with "Invalid project selection,
please verify project service-provider-a54c8 exists and you have access."
That is the exact project ID already baked into `firebase.json`,
`android/app/google-services.json`, and `lib/firebase_options.dart`, so the
logged-in account currently cannot deploy anything to the project the app
actually points to.

**Blocked on the owner:** either add `dinesh7v72@gmail.com` as a member
(Editor/Owner) on `service-provider-a54c8` in the Firebase console
(Project Settings → Users and permissions), or log the CLI into whichever
Google account actually owns that project instead
(`firebase logout` then `firebase login` again). Owner chose to keep
targeting `service-provider-a54c8` (not switch the app to the other
`namma-ranebennur-production` project) and is looking into access — picking
this back up once resolved.

Original guidance, still accurate once access is sorted out:

I do not have your Firebase/Google Cloud login, billing access, or API keys,
and per my own operating rules I should not ask you to paste any of those
into this chat.

`MAPS_SETUP.md` (already in the repo) is accurate and complete as written —
I re-verified its steps against the actual `functions/index.js` code above.
When you're ready, run these yourself, one block at a time:

**Step A — sign in and confirm the project:**
```powershell
cd "D:\namma ranebennur\Flutter-Checkpoint\Namma-Ranebennur-Flutter-Production-v2.11.3"
npx firebase-tools login
npx firebase-tools use service-provider-a54c8
```
This opens a browser for you to sign in with the Google account that owns
the `service-provider-a54c8` Firebase project. No keys or passwords go
through me or this chat.

**Step B — deploy the security rules and indexes (safe, no Maps needed yet):**
```powershell
npx firebase-tools deploy --only firestore:rules,firestore:indexes,storage
```
This is the same `firestore.rules`/`storage.rules`/`firestore.indexes.json`
already verified by the 29 emulator tests above — deploying it should not
change app behavior for existing users, only enforce the same rules
server-side that the emulator already confirmed.

**Step C — Maps API + server key (needs your Google Cloud billing to be
active first):** follow `MAPS_SETUP.md` exactly, in order:
1. Enable *Maps SDK for Android*, *Geocoding API*, and *Routes API* on the
   `service-provider-a54c8` Google Cloud project.
2. Create an Android-restricted Maps key (restricted to your production
   package name + SHA certificate) and a separate server-restricted Routes
   key — two different keys, never the same one.
3. Put the Android key only in `android/local.properties`
   (`google.maps.androidKey=...`) — this file is gitignored and must never be
   committed.
4. Set the server key as a Cloud Functions secret and deploy the function:
   ```powershell
   npx firebase-tools functions:secrets:set GOOGLE_MAPS_SERVER_KEY
   cd functions; npm install; cd ..
   npx firebase-tools deploy --only functions:calculateRoadRoute
   ```
   Paste the server-restricted key only when that `secrets:set` command
   itself prompts for it — never anywhere else, including this chat.
5. After deployment, sign into the app, open Travel, confirm pickup/
   destination pins, and verify a road distance actually appears; repeat in
   Nimma Sevaka Delivery. Submission must stay disabled whenever a pin or
   route result is missing (already implemented client-side).

I'll pick this back up as soon as you've done Step A (or tell me you'd
rather I wait until Steps B/C are convenient) — there's nothing further I
can do here without your credentials.

## Net result

```
Firestore/Storage emulator rules tests: 29/29 passing
flutter analyze:  0 errors, 0 warnings, 8 deferred info (unchanged)
flutter test:     1/1 passing
```

No legacy/unreachable screen was touched, per your instruction — the dead-code
cleanup task remains a separate, pending suggestion only.
