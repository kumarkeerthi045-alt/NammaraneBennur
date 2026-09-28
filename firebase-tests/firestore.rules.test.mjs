// Firestore security rules emulator tests for Namma Ranebennur v2.11.3.
//
// Run from the project root:
//   npx firebase-tools emulators:exec --project=demo-namma-ranebennur \
//     --only firestore,storage,auth "node --test firebase-tests/*.test.mjs"
//
// These tests load the real firestore.rules file and exercise it through the
// emulator (not a mock) — every assertSucceeds/assertFails is a real rules
// evaluation against the actual production rules file.

import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import {
  doc,
  setDoc,
  getDoc,
  getDocs,
  updateDoc,
  deleteDoc,
  collection,
  serverTimestamp,
  runTransaction,
  writeBatch,
} from 'firebase/firestore';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectId = 'demo-namma-ranebennur';

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, '..', 'firestore.rules'), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

// Seed documents that other rules read via get()/getAfter() cross-document
// checks, bypassing security rules (this is what withSecurityRulesDisabled is for).
async function seed(fn) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await fn(context.firestore());
  });
}

function ctx(uid) {
  return uid ? testEnv.authenticatedContext(uid).firestore() : testEnv.unauthenticatedContext().firestore();
}

// ---------------------------------------------------------------------------
// Customer orders
// ---------------------------------------------------------------------------

test('unauthenticated user cannot create or read any order', async () => {
  const db = ctx(null);
  await assertFails(setDoc(doc(db, 'orders/o1'), { userId: 'someone', status: 'pending' }));
  await assertFails(getDoc(doc(db, 'orders/o1')));
});

test('customer can create their own order but not one claiming another user', async () => {
  const alice = ctx('alice');
  await assertSucceeds(setDoc(doc(alice, 'orders/o1'), {
    userId: 'alice', category: 'home_services', status: 'pending', createdAt: serverTimestamp(),
  }));
  await assertFails(setDoc(doc(alice, 'orders/o2'), {
    userId: 'bob', category: 'home_services', status: 'pending',
  }));
});

test('customer cannot read another customer\'s order', async () => {
  await seed((db) => setDoc(doc(db, 'orders/oPriv'), { userId: 'alice', category: 'home_services', status: 'pending' }));
  const bob = ctx('bob');
  await assertFails(getDoc(doc(bob, 'orders/oPriv')));
  const alice = ctx('alice');
  await assertSucceeds(getDoc(doc(alice, 'orders/oPriv')));
});

test('customer can cancel their own pending order but cannot alter other fields', async () => {
  await seed((db) => setDoc(doc(db, 'orders/oCancel'), { userId: 'alice', category: 'home_services', status: 'pending' }));
  const alice = ctx('alice');
  await assertFails(updateDoc(doc(alice, 'orders/oCancel'), { status: 'completed' }));
  await assertSucceeds(updateDoc(doc(alice, 'orders/oCancel'), { status: 'cancelled', updatedAt: serverTimestamp() }));
});

test('customer cannot escalate their own user role', async () => {
  const alice = ctx('alice');
  await assertSucceeds(setDoc(doc(alice, 'users/alice'), { userId: 'alice', role: 'user', email: 'a@x.com' }));
  await assertFails(updateDoc(doc(alice, 'users/alice'), { role: 'super_admin' }));
});

// ---------------------------------------------------------------------------
// Admin role scoping — the three roles must only see their own domain
// ---------------------------------------------------------------------------

test('booking admin can read a hotel order but not a travel order', async () => {
  await seed(async (db) => {
    await setDoc(doc(db, 'adminUsers/bookingAdminUid'), { active: true, role: 'booking_admin' });
    await setDoc(doc(db, 'orders/oHotel'), { userId: 'alice', category: 'hotels', status: 'pending' });
    await setDoc(doc(db, 'orders/oTravel'), { userId: 'alice', category: 'travel', status: 'pending' });
  });
  const bookingAdmin = ctx('bookingAdminUid');
  await assertSucceeds(getDoc(doc(bookingAdmin, 'orders/oHotel')));
  await assertFails(getDoc(doc(bookingAdmin, 'orders/oTravel')));
});

test('market/travel admin can read a travel order but not a hotel order', async () => {
  await seed(async (db) => {
    await setDoc(doc(db, 'adminUsers/marketAdminUid'), { active: true, role: 'market_travel_admin' });
  });
  const marketAdmin = ctx('marketAdminUid');
  await assertSucceeds(getDoc(doc(marketAdmin, 'orders/oTravel')));
  await assertFails(getDoc(doc(marketAdmin, 'orders/oHotel')));
});

test('super admin can read both hotel and travel orders', async () => {
  await seed((db) => setDoc(doc(db, 'adminUsers/superUid'), { active: true, role: 'super_admin' }));
  const superAdmin = ctx('superUid');
  await assertSucceeds(getDoc(doc(superAdmin, 'orders/oHotel')));
  await assertSucceeds(getDoc(doc(superAdmin, 'orders/oTravel')));
});

test('a deactivated admin record is denied admin access', async () => {
  await seed((db) => setDoc(doc(db, 'adminUsers/disabledUid'), { active: false, role: 'super_admin' }));
  const disabled = ctx('disabledUid');
  await assertFails(getDoc(doc(disabled, 'orders/oHotel')));
});

test('booking admin cannot write platformSettings (super-admin only)', async () => {
  await seed((db) => setDoc(doc(db, 'adminUsers/bookingAdminUid2'), { active: true, role: 'booking_admin' }));
  const bookingAdmin = ctx('bookingAdminUid2');
  await assertFails(setDoc(doc(bookingAdmin, 'platformSettings/features'), { feature_travel: true }));
  await seed((db) => setDoc(doc(db, 'adminUsers/superUid2'), { active: true, role: 'super_admin' }));
  const superAdmin = ctx('superUid2');
  await assertSucceeds(setDoc(doc(superAdmin, 'platformSettings/features'), { feature_travel: true }));
});

test('booking admin can atomically approve a service provider and connect the user profile', async () => {
  await seed(async (db) => {
    await setDoc(doc(db, 'adminUsers/bookingProviderAdmin'), { active: true, role: 'booking_admin' });
    await setDoc(doc(db, 'users/providerApplicant'), { userId: 'providerApplicant', role: 'Customer' });
    await setDoc(doc(db, 'serviceProviderRequests/providerApplicant'), {
      uid: 'providerApplicant', name: 'Test Electrician', phone: '9999999999',
      serviceType: 'electrician', city: 'Ranebennur', area: 'Test Area', status: 'pending',
    });
  });
  const db = ctx('bookingProviderAdmin');
  const batch = writeBatch(db);
  batch.set(doc(db, 'serviceProviders/providerApplicant'), {
    serviceProviderId: 'providerApplicant', uid: 'providerApplicant', name: 'Test Electrician',
    phone: '9999999999', serviceType: 'electrician', status: 'approved', approvedByAdmin: true,
  });
  batch.update(doc(db, 'users/providerApplicant'), {
    role: 'serviceProvider', serviceProviderId: 'providerApplicant', updatedAt: serverTimestamp(),
  });
  batch.update(doc(db, 'serviceProviderRequests/providerApplicant'), {
    status: 'approved', approvedByAdmin: true, serviceProviderId: 'providerApplicant', updatedAt: serverTimestamp(),
  });
  batch.set(doc(db, 'notifications/providerApprovalNotice'), {
    userId: 'providerApplicant', title: 'Service provider approved', read: false, createdAt: serverTimestamp(),
  });
  batch.set(doc(db, 'adminActivity/providerApprovalAudit'), {
    adminUid: 'bookingProviderAdmin', action: 'service_provider_approved',
    targetType: 'serviceProviderRequest', targetId: 'providerApplicant', createdAt: serverTimestamp(),
  });
  await assertSucceeds(batch.commit());
  assert.equal((await getDoc(doc(db, 'serviceProviderRequests/providerApplicant'))).data().status, 'approved');
});

test('market travel admin cannot process worker service-provider applications', async () => {
  await seed(async (db) => {
    await setDoc(doc(db, 'adminUsers/marketProviderAdmin'), { active: true, role: 'market_travel_admin' });
    await setDoc(doc(db, 'serviceProviderRequests/marketDeniedApplicant'), {
      uid: 'marketDeniedApplicant', serviceType: 'electrician', status: 'pending',
    });
  });
  const db = ctx('marketProviderAdmin');
  await assertFails(getDoc(doc(db, 'serviceProviderRequests/marketDeniedApplicant')));
  await assertFails(setDoc(doc(db, 'serviceProviders/unauthorisedProvider'), {
    uid: 'someone', serviceType: 'electrician', status: 'approved',
  }));
});

test('booking admin cannot delete an approved service provider', async () => {
  await seed(async (db) => {
    await setDoc(doc(db, 'adminUsers/bookingDeleteAdmin'), { active: true, role: 'booking_admin' });
    await setDoc(doc(db, 'serviceProviders/deleteProtectedProvider'), { uid: 'worker', serviceType: 'electrician', status: 'approved' });
  });
  const db = ctx('bookingDeleteAdmin');
  await assertFails(deleteDoc(doc(db, 'serviceProviders/deleteProtectedProvider')));
});

test('market seller phone is private to the market admin role', async () => {
  await seed(async (db) => {
    await setDoc(doc(db, 'adminUsers/marketAdminPrivate'), { active: true, role: 'market_travel_admin' });
    await setDoc(doc(db, 'marketProducts/tomato'), { name: 'Tomato', price: 40, active: true });
    await setDoc(doc(db, 'marketProductPrivate/tomato'), { productId: 'tomato', sellerPhone: '9999999999' });
  });
  const customer = ctx('customerMarket');
  await assertSucceeds(getDoc(doc(customer, 'marketProducts/tomato')));
  await assertFails(getDoc(doc(customer, 'marketProductPrivate/tomato')));

  const marketAdmin = ctx('marketAdminPrivate');
  await assertSucceeds(getDoc(doc(marketAdmin, 'marketProductPrivate/tomato')));
  await assertSucceeds(setDoc(doc(marketAdmin, 'marketProductPrivate/onion'), {
    productId: 'onion', sellerPhone: '9888888888',
  }));
});

// ---------------------------------------------------------------------------
// Used-item Sale — privacy invariants (Phase 3 fixes under direct test)
// ---------------------------------------------------------------------------

test('sale listing creation is rejected if it carries a seller phone or is not trial_live/hidden', async () => {
  const alice = ctx('alice');
  await assertFails(setDoc(doc(alice, 'saleListings/s1'), {
    sellerId: 'alice', status: 'trial_live', contactVisible: false, sellerPhone: '9999999999', interestCount: 0,
  }));
  await assertFails(setDoc(doc(alice, 'saleListings/s1'), {
    sellerId: 'alice', status: 'paid_active', contactVisible: false, interestCount: 0,
  }));
  await assertSucceeds(setDoc(doc(alice, 'saleListings/s1'), {
    sellerId: 'alice', status: 'trial_live', contactVisible: false, interestCount: 0, title: 'Item', createdAt: serverTimestamp(),
  }));
});

test('seller can self-request payment_pending but cannot grant themselves paid_active', async () => {
  await seed((db) => setDoc(doc(db, 'saleListings/s2'), {
    sellerId: 'alice', status: 'trial_live', contactVisible: false, interestCount: 0,
  }));
  const alice = ctx('alice');
  await assertFails(updateDoc(doc(alice, 'saleListings/s2'), { status: 'paid_active', updatedAt: serverTimestamp() }));
  await assertSucceeds(updateDoc(doc(alice, 'saleListings/s2'), { status: 'payment_pending', updatedAt: serverTimestamp() }));
  // Once pending, the seller still cannot jump to paid_active themselves.
  const stillAlice = ctx('alice');
  await assertFails(updateDoc(doc(stillAlice, 'saleListings/s2'), { status: 'paid_active', updatedAt: serverTimestamp() }));
});

test('admin can move a listing to verified_free and paid_active', async () => {
  await seed(async (db) => {
    await setDoc(doc(db, 'adminUsers/saleAdminUid'), { active: true, role: 'super_admin' });
    await setDoc(doc(db, 'saleListings/s3'), { sellerId: 'alice', status: 'trial_live', contactVisible: false, interestCount: 0 });
  });
  const admin = ctx('saleAdminUid');
  await assertSucceeds(updateDoc(doc(admin, 'saleListings/s3'), { status: 'verified_free', contactVisible: false, expiresAt: serverTimestamp() }));
  await assertSucceeds(updateDoc(doc(admin, 'saleListings/s3'), { status: 'paid_active', contactVisible: true, sellerPhone: '9999999999' }));
});

test('buyer interest transaction succeeds via the paired write; seller cannot read the interest document', async () => {
  await seed((db) => setDoc(doc(db, 'saleListings/s4'), {
    sellerId: 'alice', status: 'trial_live', contactVisible: false, interestCount: 0,
  }));
  const bob = ctx('bob');
  await runTransaction(bob, async (tx) => {
    const listingRef = doc(bob, 'saleListings/s4');
    const snap = await tx.get(listingRef);
    tx.set(doc(bob, 'saleInterests/s4_bob'), { listingId: 's4', buyerId: 'bob', status: 'interested', createdAt: serverTimestamp() });
    tx.update(listingRef, { interestCount: snap.data().interestCount + 1, updatedAt: serverTimestamp() });
  });
  // Buyer can read their own interest doc.
  await assertSucceeds(getDoc(doc(bob, 'saleInterests/s4_bob')));
  // The seller — even though it's their own listing — must NOT be able to read
  // the interest document directly (count-only, never identity). This directly
  // guards the Phase 3 privacy fix.
  const alice = ctx('alice');
  await assertFails(getDoc(doc(alice, 'saleInterests/s4_bob')));
});

test('a seller cannot register interest in their own listing', async () => {
  await seed((db) => setDoc(doc(db, 'saleListings/s5'), {
    sellerId: 'alice', status: 'trial_live', contactVisible: false, interestCount: 0,
  }));
  const alice = ctx('alice');
  await assertFails(setDoc(doc(alice, 'saleInterests/s5_alice'), { listingId: 's5', buyerId: 'alice', status: 'interested' }));
});

test('seller phone (saleListingPrivate) is unreadable by a buyer', async () => {
  await seed((db) => setDoc(doc(db, 'saleListingPrivate/s6'), { listingId: 's6', sellerId: 'alice', sellerPhone: '9999999999' }));
  const bob = ctx('bob');
  await assertFails(getDoc(doc(bob, 'saleListingPrivate/s6')));
  const alice = ctx('alice');
  await assertSucceeds(getDoc(doc(alice, 'saleListingPrivate/s6')));
});

// ---------------------------------------------------------------------------
// Vibe Town slot locking — atomic booking + lock (Phase 3 per-service fix)
// ---------------------------------------------------------------------------

test('vibe town slot lock create requires a genuinely-owned backing order', async () => {
  await seed((db) => setDoc(doc(db, 'orders/vtOrder1'), { userId: 'alice', category: 'vibe_town', status: 'pending' }));
  const alice = ctx('alice');
  await assertSucceeds(setDoc(doc(alice, 'vibeTownSlotLocks/lock1'), {
    dayKey: '20260910', serviceType: 'Movie Show', timeSlot: '18:00 - 19:00', orderId: 'vtOrder1', active: true, createdAt: serverTimestamp(),
  }));
  // Someone else cannot create a lock claiming an order that isn't theirs.
  const bob = ctx('bob');
  await assertFails(setDoc(doc(bob, 'vibeTownSlotLocks/lock2'), {
    dayKey: '20260910', serviceType: 'Movie Show', timeSlot: '19:00 - 20:00', orderId: 'vtOrder1', active: true,
  }));
});

test('vibe town double-booking is prevented under real concurrency (not just by rules)', async () => {
  // Reproduces the exact read-check-then-write pattern
  // FirestoreService.createVibeTownBooking uses: read the lock doc, throw if
  // it's already active, otherwise atomically write the order + the lock in
  // one transaction. Firing two of these at the same slot concurrently must
  // leave exactly one booking standing — this is Firestore's transaction
  // optimistic-concurrency guarantee doing the real work, not the security
  // rules (the rules only gate *who* may write, not *when two writers race*).
  await seed(async (db) => {
    await setDoc(doc(db, 'orders/raceOrderBob'), { userId: 'bob', category: 'vibe_town', status: 'pending' });
    await setDoc(doc(db, 'orders/raceOrderCarol'), { userId: 'carol', category: 'vibe_town', status: 'pending' });
  });
  const lockId = 'lockRace';
  async function attempt(uid, orderId) {
    const db = ctx(uid);
    try {
      await runTransaction(db, async (tx) => {
        const lockRef = doc(db, `vibeTownSlotLocks/${lockId}`);
        const existing = await tx.get(lockRef);
        if (existing.exists() && existing.data().active !== false) {
          throw new Error('SLOT_TAKEN');
        }
        tx.set(lockRef, { dayKey: '20260910', serviceType: 'Movie Show', timeSlot: '18:00 - 19:00', orderId, active: true, createdAt: serverTimestamp() });
      });
      return 'won';
    } catch (error) {
      return error.message === 'SLOT_TAKEN' ? 'lost' : `error:${error.message}`;
    }
  }
  const [bobResult, carolResult] = await Promise.all([attempt('bob', 'raceOrderBob'), attempt('carol', 'raceOrderCarol')]);
  const results = [bobResult, carolResult].sort();
  assert.deepEqual(results, ['lost', 'won'], `expected exactly one winner, got: bob=${bobResult} carol=${carolResult}`);
});

// ---------------------------------------------------------------------------
// Driver job board — job acceptance scoped to matching vehicle type
// ---------------------------------------------------------------------------

test('a driver can only accept a pending job matching their own vehicle type', async () => {
  await seed(async (db) => {
    await setDoc(doc(db, 'driverPartners/driverBike'), { ownerUid: 'driverBike', registrationStatus: 'approved', vehicleType: 'Bike' });
    await setDoc(doc(db, 'driverPartners/driverAuto'), { ownerUid: 'driverAuto', registrationStatus: 'approved', vehicleType: 'Auto' });
    await setDoc(doc(db, 'orders/jobOrder1'), { userId: 'alice', category: 'delivery', status: 'pending', driverId: null });
    await setDoc(doc(db, 'driverJobs/jobOrder1'), { orderId: 'jobOrder1', createdBy: 'alice', category: 'delivery', vehicleType: 'Bike', status: 'pending', assignedDriverId: null });
  });
  const autoDriver = ctx('driverAuto');
  await assertFails(updateDoc(doc(autoDriver, 'driverJobs/jobOrder1'), { status: 'assigned', assignedDriverId: 'driverAuto', updatedAt: serverTimestamp() }));
});

// ---------------------------------------------------------------------------
// Identity / contact protection for partner and payment records
// ---------------------------------------------------------------------------

test('a booking counter\'s registration record cannot be read by an unrelated signed-in user', async () => {
  await seed((db) => setDoc(doc(db, 'bookingCounters/counter1'), { ownerUid: 'ownerX', registrationStatus: 'approved' }));
  const stranger = ctx('stranger');
  await assertFails(getDoc(doc(stranger, 'bookingCounters/counter1')));
  const owner = ctx('ownerX');
  await assertSucceeds(getDoc(doc(owner, 'bookingCounters/counter1')));
});

test('a payment record is only readable by its own customer or an admin', async () => {
  await seed(async (db) => {
    await setDoc(doc(db, 'payments/pay1'), { userId: 'alice', amount: 500, status: 'verified' });
    await setDoc(doc(db, 'adminUsers/payAdmin'), { active: true, role: 'super_admin' });
  });
  const bob = ctx('bob');
  await assertFails(getDoc(doc(bob, 'payments/pay1')));
  const alice = ctx('alice');
  await assertSucceeds(getDoc(doc(alice, 'payments/pay1')));
  const admin = ctx('payAdmin');
  await assertSucceeds(getDoc(doc(admin, 'payments/pay1')));
});

test('trusted contacts are only readable/writable by their own owner', async () => {
  await seed((db) => setDoc(doc(db, 'trustedContacts/tc1'), { ownerUid: 'alice', name: 'Mom', phone: '9999999999' }));
  const bob = ctx('bob');
  await assertFails(getDoc(doc(bob, 'trustedContacts/tc1')));
  await assertFails(deleteDoc(doc(bob, 'trustedContacts/tc1')));
  const alice = ctx('alice');
  await assertSucceeds(getDoc(doc(alice, 'trustedContacts/tc1')));
});

test('default-deny: an unlisted collection is fully inaccessible', async () => {
  const alice = ctx('alice');
  await assertFails(setDoc(doc(alice, 'somethingNotInRules/doc1'), { any: 'field' }));
});
