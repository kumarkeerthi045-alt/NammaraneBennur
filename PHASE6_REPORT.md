# Phase 6 — production identity and signing

Date: 2026-09-05

## Status: complete

Most of Phase 6 was already done as a side effect of the Firebase project
migration (see `FIREBASE_PROJECT_MIGRATION.md`):
- Permanent Android application ID decided and implemented: `in.nammarane.bennur`
- Registered in Firebase, `google-services.json` replaced
- Display name ("Namma Ranebennur") and launcher icons already correct
- iOS bundle ID intentionally left untouched (no iOS Firebase app registered — not a current release target)

This phase closed out the remaining item: a real release/upload keystore,
with debug signing removed from the release build.

## What was built

- Owner generated `namma-ranebennur-release.jks` themselves (`keytool
  -genkeypair`), stored outside the project at
  `D:\NammaRanebennur-Keys\namma-ranebennur-release.jks`. Passwords were
  never shared with or typed by me.
- `android/app/build.gradle.kts` now defines a real `release` signingConfig,
  falling back to debug signing only when no keystore config is present
  (e.g. a contributor's machine without the keystore) — so
  `flutter build apk --release` never fails outright for other developers,
  it just isn't properly signed for distribution in that case.
- Final signing secrets (store password, key password, Maps Android key) are
  read from environment variables (`NAMMA_STORE_PASSWORD`,
  `NAMMA_KEY_PASSWORD`, `NAMMA_MAPS_ANDROID_KEY`) first, falling back to
  `android/key.properties` / `android/local.properties`. Both files are
  gitignored at two layers (the project's own `.gitignore` plus Flutter's
  default `android/.gitignore`).

## The debugging trail (worth keeping for the next person)

Getting a real signed build out of this sandboxed-and-remote-terminal setup
surfaced a genuine sequence of distinct, real problems — not one bug wearing
different masks. Each is now fixed or worked around:

1. **`java.util.Properties()` unresolved in Gradle's Kotlin DSL** — this was
   the *first real Gradle compile* this project had ever gone through (every
   earlier attempt failed upstream at the Gradle-distribution-download step
   in the sandboxed dev environment). Fixed with an explicit
   `import java.util.Properties` instead of the fully-qualified inline form.
2. **Disk completely full mid-build** (`C:` drive) — caused a Kotlin
   incremental-compilation cache to end up corrupted
   ("Could not close incremental caches"). Fixed by disabling
   `kotlin.incremental` in `android/gradle.properties` — trades some rebuild
   speed for immunity to this exact failure mode.
3. **`key.properties`-based passwords silently failing** — repeated attempts
   to save `storePassword`/`keyPassword` into a `.properties` file kept
   either not persisting (placeholder text left in place across several
   different edit methods: PowerShell here-strings, `Add-Content`, even a
   manual Notepad edit) or getting corrocted by format-specific issues (a
   UTF-8 BOM silently prepended to the first key, corrupting its name).
   Solved by reading `NAMMA_STORE_PASSWORD`/`NAMMA_KEY_PASSWORD`/
   `NAMMA_MAPS_ANDROID_KEY` from environment variables first — this sidesteps
   `.properties` file parsing (and its `#`/`=`/`:`/`!`-as-special-character
   rules, and BOM issues) entirely.
4. **A stale Gradle daemon** — Gradle keeps a background process alive
   between builds for speed, and that daemon only reads environment
   variables once, at its own startup. After it had been running for a
   while, newly-set environment variables in the terminal stopped reaching
   it, causing an inexplicable-looking "keystore password was incorrect"
   even with a verified-correct password. Fixed by running
   `android\gradlew.bat --stop` to force a fresh daemon before rebuilding.
5. **A stray control character in a copy-pasted Maps API key** — copying
   from the Google Cloud Console web UI picked up an invisible Unicode
   control character, breaking the built `AndroidManifest.xml`'s XML.
   Fixed by re-copying via the console's copy button rather than manual
   text selection.
6. **Key password vs. store password mismatch** — the owner intended both
   to be identical, but a re-typed value didn't actually match. Fixed by
   copying `$env:NAMMA_STORE_PASSWORD` directly into
   `$env:NAMMA_KEY_PASSWORD` in PowerShell rather than re-typing it a second
   time, guaranteeing byte-for-byte equality.

None of these were guessed at — each was diagnosed from the actual Gradle
error text or an independent `keytool`/`apksigner` check before being
"fixed," and each fix was verified to actually resolve that specific error
before moving to the next one.

## Final verification

```powershell
& apksigner.bat verify --print-certs build\app\outputs\flutter-apk\app-release.apk
```
→ `Signer #1 certificate SHA-1 digest: 80b4446fcf7ac750ea44f48994fe6fb96131c71d`
— matches the release keystore's own fingerprint exactly (independently
confirmed via `keytool -list -v` on the `.jks` file itself).

Manifest's `com.google.android.geo.API_KEY` meta-data value confirmed (by
length and format check only, value itself withheld from all logs/chat):
39 characters, matches `^AIzaSy[A-Za-z0-9_-]{20,40}$`, not either of the two
placeholder strings that had been there during earlier failed attempts.

The release-key SHA-1 (`80:B4:44:6F:CF:7A:C7:50:EA:44:F4:89:94:FE:6F:B9:61:31:C7:1D`)
has been added by the owner as a second entry (alongside the existing debug
SHA-1) on the Android-restricted Maps API key, so both debug and release
builds can use Maps.

## What's still open (Phase 7 territory, not Phase 6)

- Installing this release APK on a real Android phone and confirming Maps/
  Travel/Delivery road-distance actually returns a result end-to-end — the
  Cloud Function and key are both confirmed correctly wired, but nothing has
  exercised the full request path from a real device yet.
- The full Phase 7 device-testing checklist (all roles, all Quick Booking
  options, notifications, privacy-denial cases) — see
  `FINAL_RELEASE_CHECKLIST.md`.
- The debug-keystore SHA-1 remains on the Android Maps key alongside the
  release one — fine for now (both are needed while both debug and release
  builds are still in active use), but worth pruning the debug entry once
  this app is release-only.
