# Phase 5 — visual and interaction comparison

Date: 2026-09-05

## Method and its real limits

This sandboxed session has no Android device or emulator. To still get genuine
visual evidence rather than only reading source code, the app was run via
Flutter's **web** target (`flutter run -d web-server`) and viewed directly in
a browser at phone width (390×844), alongside code inspection for anything the
screenshots surfaced. This is a real, useful signal for **layout, color,
spacing, and structural** correctness, but it has two honest limits worth
stating up front rather than glossing over:

1. **Text rendering is not representative here.** Kannada script and emoji
   both rendered as "tofu" boxes in this specific headless browser
   environment — almost certainly because the sandbox lacks a Kannada font
   (e.g. Noto Sans Kannada) and a color-emoji font, not because the app is
   doing anything wrong. Every real Android device ships with both. This
   means any Kannada-text or emoji-rendering "finding" from this method
   would be a false positive — none is reported below for that reason.
2. **Interactive testing (clicking through screens) was unreliable** in this
   headless Chromium environment — pointer events into Flutter's web canvas
   timed out repeatedly. This limited exploration to screens reachable by
   direct load rather than a full click-through of the authenticated app.
   Full interactive/workflow testing remains Phase 7's real-device job.

Given these limits, this pass focused on what it's actually good for: the
customer-facing **authentication screens** (the only ones reachable without
a real or emulated backend session), checked directly against source for
anything the rendered page revealed.

## Real gap found and fixed: auth screens broke the orange brand identity

The rendered Login screen showed a **blue** primary button and a blue "Create
Account" link, while every other screen in the app (confirmed throughout
Phases 1–4) uses the orange brand identity (`0xfff45b22`/`0xfff97316`) the
master prompt requires ("Orange identity header" is a named non-negotiable).
Tracing this in source found the same hardcoded Material-blue pattern
(`Color(0xff1565c0)`, `Colors.blue`, `Colors.blue.shade700`) repeated across
every live authentication screen:

- `lib/screens/login_screen.dart` — Login button background, "Create Account" link
- `lib/screens/signup_screen.dart` — "Login" link (back to sign-in)
- `lib/screens/forgot_password_screen.dart` — "Send Reset Link" button background
- `lib/screens/email_verification_screen.dart` — mail icon, "Resend Verification Email" link

All four are reachable from the live `SplashScreen → LoginScreen` entry point
(confirmed via grep — each is actually navigated to, not dead code). Fixed by
replacing every hardcoded blue with the app's established `0xfff45b22`
orange, matching the color already used for "Forgot Password?" and "Admin
Login" on the very same screen. Re-rendered after the fix — confirmed visually
in the browser: the button and links are now orange, consistent with the rest
of the app.

Two screens with the identical blue pattern were **deliberately left
untouched**: `lib/screens/welcome_screen.dart` and `lib/screens/otp_screen.dart`
are both unreachable dead code (confirmed via grep — each only appears in its
own class declaration, never instantiated anywhere), part of the same legacy
dead-code cleanup already flagged and paused per the owner's earlier
instruction not to touch unreachable screens yet.

## Verification

```
flutter analyze  -> 0 errors, 0 warnings, 8 deferred info (unchanged)
flutter test     -> 1/1 passing
```

## What Phase 5 has NOT covered (needs Phase 7 / a real device)

- Every screen behind sign-in (Home, Quick Booking, all booking flows, Find
  For Me, Sale, admin/partner/driver portals) — not reachable in this session
  without either a real device or connecting to a Firebase emulator with a
  throwaway account, which was deliberately avoided here to keep this pass
  from touching or risking the live production project's real user data.
- Real Kannada and emoji rendering — needs an actual Android device, since
  this environment's font gaps make it unable to verify either honestly.
- Keyboard-covered fields, text scaling, system back-action behavior, dialogs/
  snackbars/pickers, and every external phone/Maps/share link — all require
  either a real device or a properly interactive browser session, neither
  available here.
- Small vs. normal phone size comparison beyond the single 390×844 viewport
  tried.

## Recommendation

This pass caught and fixed one real, visible, brand-identity-breaking bug
that would have been embarrassing to ship (blue buttons on an otherwise
all-orange app) and that no amount of source-reading alone would have
surfaced as clearly as actually seeing it rendered. That's a good return for
the method's limits. The rest of Phase 5 — the actual owner-facing visual
approval the master prompt requires — genuinely needs the owner looking at
the real app on a real phone; nothing further of substance can be verified
visually from this sandbox without one.
