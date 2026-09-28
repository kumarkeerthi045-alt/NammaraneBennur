// Storage security rules emulator tests for Namma Ranebennur v2.11.3.
//
// Run from the project root:
//   npx firebase-tools emulators:exec --project=demo-namma-ranebennur \
//     --only firestore,storage,auth "node --test firebase-tests/*.test.mjs"
//
// Storage rules call firestore.get(...) to check adminUsers, so the Firestore
// emulator must be running alongside the Storage emulator (it is, per firebase.json).

import { test, before, after } from 'node:test';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import { ref, uploadBytes, getBytes } from 'firebase/storage';
import { doc, setDoc } from 'firebase/firestore';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectId = 'demo-namma-ranebennur';

let testEnv;
const tinyPng = new Uint8Array([137, 80, 78, 71, 13, 10, 26, 10]);

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, '..', 'firestore.rules'), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
    storage: {
      rules: fs.readFileSync(path.join(__dirname, '..', 'storage.rules'), 'utf8'),
      host: '127.0.0.1',
      port: 9199,
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

async function seedFirestore(fn) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await fn(context.firestore());
  });
}

function storageCtx(uid) {
  return uid ? testEnv.authenticatedContext(uid).storage() : testEnv.unauthenticatedContext().storage();
}

test('a user can upload to their own users/{uid} folder but not someone else\'s', async () => {
  const alice = storageCtx('alice');
  await assertSucceeds(uploadBytes(ref(alice, 'users/alice/profile.jpg'), tinyPng, { contentType: 'image/jpeg' }));
  await assertFails(uploadBytes(ref(alice, 'users/bob/profile.jpg'), tinyPng, { contentType: 'image/jpeg' }));
});

test('sale listing photos: only the owning uid can write into their own folder, any signed-in user can read', async () => {
  const alice = storageCtx('alice');
  await assertSucceeds(uploadBytes(ref(alice, 'saleListings/alice/listing1/0.jpg'), tinyPng, { contentType: 'image/jpeg' }));
  const bob = storageCtx('bob');
  await assertFails(uploadBytes(ref(bob, 'saleListings/alice/listing1/1.jpg'), tinyPng, { contentType: 'image/jpeg' }));
  await assertSucceeds(getBytes(ref(bob, 'saleListings/alice/listing1/0.jpg')));
});

test('an oversized or wrong-content-type file is rejected for a user upload', async () => {
  const alice = storageCtx('alice');
  await assertFails(uploadBytes(ref(alice, 'users/alice/doc.exe'), tinyPng, { contentType: 'application/x-msdownload' }));
});

test('driver partner documents: only the owning driver or a market/travel admin can read', async () => {
  await seedFirestore((db) => setDoc(doc(db, 'adminUsers/travelAdmin'), { active: true, role: 'market_travel_admin' }));
  const driver = storageCtx('driverX');
  await assertSucceeds(uploadBytes(ref(driver, 'driverPartners/driverX/license.jpg'), tinyPng, { contentType: 'image/jpeg' }));
  const stranger = storageCtx('stranger');
  await assertFails(getBytes(ref(stranger, 'driverPartners/driverX/license.jpg')));
  const travelAdmin = storageCtx('travelAdmin');
  await assertSucceeds(getBytes(ref(travelAdmin, 'driverPartners/driverX/license.jpg')));
});

test('public assets are readable by anyone but only writable by an active admin', async () => {
  const anonymous = storageCtx(null);
  await assertFails(uploadBytes(ref(anonymous, 'public/banner.jpg'), tinyPng, { contentType: 'image/jpeg' }));
  await seedFirestore((db) => setDoc(doc(db, 'adminUsers/publicAdmin'), { active: true, role: 'super_admin' }));
  const admin = storageCtx('publicAdmin');
  await assertSucceeds(uploadBytes(ref(admin, 'public/banner.jpg'), tinyPng, { contentType: 'image/jpeg' }));
  await assertSucceeds(getBytes(ref(anonymous, 'public/banner.jpg')));
});

test('default-deny: an unlisted storage path is fully inaccessible', async () => {
  const alice = storageCtx('alice');
  await assertFails(uploadBytes(ref(alice, 'random/whatever.jpg'), tinyPng, { contentType: 'image/jpeg' }));
});
