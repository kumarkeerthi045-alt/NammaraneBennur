# Namma Ranebennur v2.11.3 — Real-Device Test Log

Guided, one-test-at-a-time role-by-role testing on the owner's physical Samsung phone.
Build under test: current debug build (all fixes through the Home-screen polish batch
and Vibe Town parity work). The delivered release APK will be rebuilt fresh from
source only after every issue found here is fixed, per the owner's instruction.

Status legend: **Passed** / **Failed** (with notes) / **Pending** (not yet run).

## Customer flow

| # | Test | Status | Notes |
|---|---|---|---|
| C1 | App launch / splash screen | Passed | Loaded to Home screen (already logged in from before). Initial "nothing" report was the phone's own screen-timeout/screensaver kicking in during the pause, not an app freeze — confirmed via logcat (app process stayed alive, foreground was Android's DreamActivity) and by waking the screen. |
| C1b | Header brand title / bottom nav labels (found while checking C1/C5) | Passed (after fix) | "NAMMA RANEB…" was hard-clipped on the real device; "Announcements" nav label wrapped to 3 lines. Fixed with FittedBox(scaleDown) on the title and a smaller uniform nav label size (commit 2c0b95e). Owner confirmed corrected on device. Clarified: header subtitle "· Connecting People" is static tagline text, not a stuck loading indicator — left as-is. |
| C2 | Signup (new account) | Passed | |
| C3 | Login (existing account) | Passed | Logout + login with existing credentials both confirmed. |
| C4 | Language toggle (English/Kannada) | Passed | |
| C5 | Home tab — sponsored ad panel | Passed (after fix) | Real device (SM-G770F): "BOTTOM OVERFLOWED BY 9.0 PIXELS". Fixed by removing the rigid `height:136` in favor of a minHeight + content-driven layout (commit 2c0b95e). Owner confirmed corrected on device. |
| C6 | Home tab — announcement marquee | Passed (after fix) | Marquee text visibly clipped/cut off — the sliding text window was fixed at 16px tall, shorter than the actual rendered text height. Increased to 22px (commit 2c0b95e). Owner confirmed corrected on device. |
| C7 | Home tab — Quick Booking grid loads all categories | Passed | |
| C8 | Home tab — Nimma Sevaka genie button (drag + open) | Passed (after fix) | Dragging was janky on real device — root cause: whole-screen setState per drag pixel. Isolated into its own DraggableSevakaButton widget with local state (commit eb2d0df). Owner confirmed drag now smooth and tap opens the assistant panel correctly. |
| C9 | Bottom nav — Find For Me tab | Passed | |
| C10 | Bottom nav — Announcements tab | Passed (after fix) | Screen itself opened correctly (filters, empty state all fine) on first check. Real bug was the "Announcements" nav label still wrapping to 2 lines ("Announcement"/"s") even after the earlier size reduction, since it's one compound word that can only break mid-word. Reduced label to 8px + slight negative letter-spacing, and nav icon emoji 21px→18px for more breathing room per owner's request (commit 560e8d6). Owner confirmed one line + better spacing on device. |
| C11 | Bottom nav — New in City tab | Passed | |
| C12 | Bottom nav — SOS tab | Passed | Genie button correctly hidden on SOS screen. |
| C13 | Booking: Hotels | Passed | Back navigation confirmed working. |
| C14 | Booking: Function Halls | Passed | |
| C15 | Booking: Clinic | Passed | |
| C16 | Booking: Travel (within city) | Passed (after fix) | Owner: "not good looking compared to old master file." Root cause: bare AppBar() falls back to Material 3's washed-out colorScheme.surface instead of the brand orange, since app-wide AppBarTheme only sets centerTitle. Owner chose "restyle only" (not a full functional rebuild) over the alternative of matching the master's full searching-driver/OTP/quote-accept experience. Applied branded orange AppBar + exact brand-orange icon accents to both Travel screens (commit 429352d). Note: every other bare-AppBar screen (Hotels/Halls/Clinic/Vibe Town/Delivery) has the same washed-out default but was left untouched since those already passed testing and weren't in scope. Owner confirmed branded header + working Google Map pickup picker on device. |
| C17 | Booking: Home Services | Passed | |
| C18 | Booking: Nimma Sevaka Delivery | Passed | |
| C19 | Booking: Machinery | Passed | |
| C20 | Booking: Vibe Town | Passed | Gold VT logo, experience options, purpose field, color-coded slots, and dark call button all confirmed on device. |
| C21 | Community Market / Namma Market browsing | Passed | |
| C22 | Used-item Sale listing | Passed | |
| C23 | My Bookings / Profile | Passed | |
| C24 | Back navigation from every screen above | Passed | Confirmed working on Hotels (C13) explicitly and used without issue throughout every other screen tested in this section. |

## Booking Admin

Test account: Firebase Auth user + `adminUsers/{uid}` doc with `role: booking_admin`, `active: true`.

| # | Test | Status | Notes |
|---|---|---|---|
| B1 | Admin Login (from Login screen → "Admin Login") | Passed (after data-setup fix) | Not an app bug — was a Firestore Console data-entry issue. The `adminUsers/{uid}` document ID was mistyped: the real UID starts with capital "I" and has digit "0" (zero) before "h1", but the Console's rendered font made these look like lowercase "l" and letter "O", so the document was created under a different (non-matching) ID. Diagnosed by temporarily adding a debug message to admin_access_service.dart printing the real UID's character codes (`user.uid.codeUnits`), which proved the mismatch beyond doubt; the diagnostic was reverted immediately after confirming the fix. Correct account: dinesh7v7@gmail.com, UID I2o9zuvro6gYqYamHOCtskwqq0h1, role booking_admin. |
| B2 | Admin dashboard/control center loads | Pending | |
| B3 | Hotel booking approvals | Pending | |
| B4 | Function Hall booking approvals | Pending | |
| B5 | Clinic approvals | Pending | |
| B6 | Worker/catering approvals | Pending | |
| B7 | Sending a price quote | Pending | |
| B8 | Advance payment verification | Pending | |
| B9 | Customer support / messaging | Pending | |
| B10 | Admin logout | Pending | |

## Market/Travel Admin

_Not started._

## Super Admin

_Not started._

## Provider portal

_Not started._

## Booking-counter portal

_Not started._

## Driver portal

_Not started._

## Notifications (foreground / background / terminated)

_Not started._

## Location / Maps

_Not started._

## Permission-denial handling

_Not started._

## Issues found (fix only after owner reports them here)

_None yet._
