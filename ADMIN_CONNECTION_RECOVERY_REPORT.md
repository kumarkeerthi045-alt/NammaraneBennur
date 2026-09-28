# Namma Ranebennur v2.11.3 Admin Connection Recovery

## Outcome

The Admin backend was not completely deleted. The handover routed live Admin login to
`AdminControlCenterScreen`, a generic collection browser. Three detailed legacy Admin
screens remained in the repository but were unreachable. The live generic provider
approval only changed a request status and did not complete the provider onboarding
connection.

This recovery reconnects the live Admin workflow without touching production data.

## Confirmed root causes

1. Live Admin login opens `AdminControlCenterScreen`; the older large Admin dashboard
   and service-provider screens are dead code.
2. Admin 2 could not see general worker applications in the live control centre.
3. Firestore rules assigned `serviceProviderRequests` to Market/Travel Admin even
   though the approved role plan assigns workers to Admin 2.
4. Generic approval did not atomically create the provider record, update the customer
   user role, update the request, create a notification, and create an audit record.
5. Ads and Requirements omitted market orders and machinery requests from that section.
6. Generic menus showed actions that did not match the current record state.
7. The Dashboard had counts only; it lacked the work queue and audit feed.
8. Business and market-product editor workflows were absent from the live Admin route.
9. Market rates had no daily seller-call attestation.
10. Advertisement pricing was absent from Settings.

## Repaired connections

### Service provider approval

Admin 2 now sees:

- Service-provider applications
- Booking-counter applications
- Approved service providers in the directory
- Booking businesses

Approving a service provider now commits one atomic batch:

- Creates or updates `serviceProviders/{uid}`
- Updates `users/{uid}` with the service-provider role and provider ID
- Marks the original application approved
- Creates a customer notification
- Creates an immutable Admin activity record

If any write is denied or fails, the full batch fails. It cannot leave a half-approved
provider.

### Admin role security

- Admin 2 may read and process worker service-provider applications.
- Market/Travel Admin may not process worker applications.
- Admin 2 may create or update service-provider records but may not delete them.
- Super Admin retains deletion authority.

### Operational screens

- Ads and Requirements now includes machinery requests, market orders, Sale listings,
  advertisements, and customer requirements.
- Actions are state-aware for bookings, market orders, Sale listings, approvals,
  requirements, advertisements, payments, settlements, complaints, and content.
- Dashboard now shows role-specific work queues.
- Super Admin Dashboard now shows the last 12 Admin activity records.
- Business Directory can add/edit businesses, pause/open bookings, and publish/hide.
- Market Catalogue can add/edit products, call sellers through the existing detail
  view, verify rates today, control stock, and show/hide products.
- Market rate saving requires the Admin to attest that the seller was contacted today.
- Seller phone numbers are stored in `marketProductPrivate`, which customers cannot
  read, instead of the customer-readable `marketProducts` records.
- Settings includes advertisement pricing from ₹0 to ₹100,000.
- Admin feature, role, active-state, pricing, content, status, quote, business, and
  market mutations write Admin audit records.

## Verification

- Firestore and Storage emulator tests: 33 passed, 0 failed.
- New tests prove the atomic Admin 2 provider approval workflow succeeds.
- New denial tests prove Market/Travel Admin cannot process worker applications.
- New denial test proves Admin 2 cannot delete an approved provider.
- New privacy test proves customers cannot read market seller phone records.
- Existing customer, role, Sale privacy, booking-lock, driver, payment, Storage, and
  default-deny tests remain passing.

Flutter compilation was not available in the recovery environment. The technical team
must run the commands below before building an APK.

## Team commands

From the repaired project folder:

```powershell
D:\develop\flutter\bin\flutter.bat clean
D:\develop\flutter\bin\flutter.bat pub get
D:\develop\flutter\bin\dart.bat format lib\screens\admin_control_center_screen.dart
D:\develop\flutter\bin\flutter.bat analyze
D:\develop\flutter\bin\flutter.bat test
```

Run the Firebase emulator suite with Java 17 or newer using the tested CLI version:

```powershell
cd firebase-tests
npm ci
cd ..
npx firebase-tools@13.35.1 emulators:exec --project=demo-namma-ranebennur --only firestore,storage,auth "node --test firebase-tests/*.test.mjs"
```

## Production safety gate

Do not deploy this source or `firestore.rules` directly to production until:

1. Flutter analyze and tests pass.
2. Admin 2 test account completes one TEST worker approval.
3. The TEST provider sees My Business.
4. Admin 3 is denied the same worker request.
5. Super Admin sees the audit row.
6. The approved TEST provider is removed or retained according to the test plan.
7. No real customer record is used during verification.

No production Firebase data was read, changed, migrated, or deleted during this
recovery.
