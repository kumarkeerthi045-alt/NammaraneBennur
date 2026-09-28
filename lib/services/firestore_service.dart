import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Based on the master's slotsFor(service) (app/api/vibe-town/route.ts),
  // with one deliberate deviation from the owner: the two hourly-style
  // experiences (the default list, and VR & PS5) are extended to run to
  // 10 PM instead of stopping at 9 PM. Movie Show and Mini Function keep
  // the master's exact fixed named blocks — extending those needs a real
  // decision about screening/event length, not just adding a time slot.
  // Each experience has its own real slot list — these are not a generic
  // hourly grid with a "duration": Movie Show is only ever bookable as one
  // of two fixed 3-hour screenings, Mini Function as one of three fixed
  // 3-hour blocks with a turnover gap between them, VR & PS5 in 30-minute
  // slots with a lunch gap, and everything else hourly 10 AM-10 PM.
  static List<String> vibeTownSlotsFor(String service) {
    if (service == 'Movie Show') {
      return ['09:00 AM – 12:00 PM', '12:00 PM – 03:00 PM'];
    }
    if (service == 'Mini Function') {
      return ['10:00 AM – 01:00 PM', '02:00 PM – 05:00 PM', '06:00 PM – 09:00 PM'];
    }
    if (service == 'VR & PS5') {
      return [
        '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM',
        '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
        '05:00 PM', '05:30 PM', '06:00 PM', '06:30 PM', '07:00 PM', '07:30 PM',
        '08:00 PM', '08:30 PM', '09:00 PM', '09:30 PM', '10:00 PM',
      ];
    }
    return [
      '10:00 AM', '11:00 AM', '12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM',
      '04:00 PM', '05:00 PM', '06:00 PM', '07:00 PM', '08:00 PM', '09:00 PM', '10:00 PM',
    ];
  }

  // Exact port of the master's PRICES map (same file).
  static const vibeTownPrices = <String, int>{
    'Private Theater': 999,
    'Movie Show': 1499,
    'VR & PS5': 200,
    'Birthday': 1499,
    'Anniversary': 1499,
    'Mini Function': 2999,
  };

  Stream<Map<String, bool>> vibeTownSlotAvailability(DateTime date, String serviceType) {
    final dayKey = '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
    final slots = vibeTownSlotsFor(serviceType);
    return _firestore.collection('vibeTownSlotLocks')
        .where('dayKey', isEqualTo: dayKey)
        .where('serviceType', isEqualTo: serviceType)
        .snapshots()
        .map((snapshot) {
          final occupied = snapshot.docs
              .where((doc) => doc.data()['active'] != false)
              .map((doc) => doc.data()['timeSlot']?.toString())
              .whereType<String>()
              .toSet();
          return {for (final slot in slots) slot: !occupied.contains(slot)};
        });
  }

  Future<String> createVibeTownBooking(Map<String, dynamic> booking) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Please sign in before booking.');
    final date = booking['bookingDate'] as DateTime;
    final day = DateTime(date.year, date.month, date.day);
    final dayKey = '${day.year.toString().padLeft(4, '0')}'
        '${day.month.toString().padLeft(2, '0')}'
        '${day.day.toString().padLeft(2, '0')}';
    final timeSlot = booking['timeSlot'].toString();
    // Each experience type has its own independent set of slots, matching the
    // master's per-(bookingDate, serviceType, timeSlot) uniqueness check —
    // do not scope the lock by time alone or one experience blocks all others.
    final serviceType = booking['serviceType'].toString();
    final serviceKey = serviceType.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    if (!vibeTownSlotsFor(serviceType).contains(timeSlot)) {
      throw StateError('Choose an available date and time.');
    }
    final lockId = '${dayKey}_${serviceKey}_${timeSlot.replaceAll(RegExp(r'[^0-9]'), '')}';
    final orderRef = _firestore.collection('orders').doc();
    final lockRef = _firestore.collection('vibeTownSlotLocks').doc(lockId);

    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(lockRef);
      if (existing.exists && existing.data()?['active'] != false) {
        throw StateError('This slot was just booked. Please choose another time.');
      }
      transaction.set(orderRef, {
        ...booking,
        'bookingDate': Timestamp.fromDate(day),
        'orderId': orderRef.id,
        'userId': user.uid,
        'userEmail': user.email ?? '',
        'status': 'pending',
        'contactProtected': true,
        'estimatedAmount': vibeTownPrices[serviceType] ?? 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(lockRef, {
        'dayKey': dayKey,
        'bookingDate': Timestamp.fromDate(day),
        'serviceType': serviceType,
        'timeSlot': timeSlot,
        'orderId': orderRef.id,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
    return orderRef.id;
  }

  Future<String> createBooking(Map<String, dynamic> booking) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Please sign in before booking.');
    final reference = _firestore.collection('orders').doc();
    final category = booking['category']?.toString();
    final order = <String, dynamic>{
      ...booking,
      'orderId': reference.id,
      'userId': user.uid,
      'userEmail': user.email ?? '',
      'status': 'pending',
      'driverId': null,
      'contactProtected': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final publishDriverJob = category == 'delivery'
        || (category == 'travel' && booking['travelScope'] != 'outstation');
    String? tripShareCode;
    if (category == 'travel') {
      order['tripStartOtp'] = (1000 + Random.secure().nextInt(9000)).toString();
      const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
      tripShareCode = List.generate(10, (_) => alphabet[Random.secure().nextInt(alphabet.length)]).join();
      order['tripShareCode'] = tripShareCode;
    } else if (category == 'delivery') {
      order['pickupOtp'] = (1000 + Random.secure().nextInt(9000)).toString();
      order['deliveryOtp'] = (1000 + Random.secure().nextInt(9000)).toString();
    }
    final batch = _firestore.batch();
    batch.set(reference, order);
    if (tripShareCode != null) {
      batch.set(_firestore.collection('tripShares').doc(tripShareCode), {
        'shareCode': tripShareCode,
        'orderId': reference.id,
        'ownerUid': user.uid,
        'vehicleType': booking['vehicleType'],
        'travelScope': booking['travelScope'],
        'tripType': booking['tripType'],
        'scheduleType': booking['scheduleType'],
        'status': 'pending',
        'privacyNotice': 'Exact address and contact details are protected.',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    if (publishDriverJob) {
      batch.set(_firestore.collection('driverJobs').doc(reference.id), {
        'orderId': reference.id,
        'createdBy': user.uid,
        'category': category,
        'serviceType': booking['serviceType'],
        'vehicleType': booking['vehicleType'],
        'travelScope': booking['travelScope'],
        'publicPickup': 'Ranebennur pickup · exact address protected',
        'publicDestination': category == 'delivery' ? 'Ranebennur delivery · exact address protected' : 'Destination shown after acceptance',
        'status': 'pending',
        'assignedDriverId': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    return reference.id;
  }

  Future<String> createRequirement(Map<String, dynamic> requirement) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Please sign in before posting a requirement.');
    final reference = _firestore.collection('requirements').doc();
    await reference.set({
      ...requirement,
      'requirementId': reference.id,
      'reference': reference.id,
      'userId': user.uid,
      'status': 'pending',
      'contactProtected': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return reference.id;
  }

  // ============================================================
  // USERS
  // ============================================================

  Future<void> saveUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.userId)
        .set(
      user.toMap(),
      SetOptions(merge: true),
    );
  }

  Future<UserModel?> getUser(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _firestore
            .collection('users')
            .doc(uid)
            .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserModel.fromMap(doc.data()!);
  }

  Future<bool> userExists(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _firestore
            .collection('users')
            .doc(uid)
            .get();

    return doc.exists;
  }

  Future<void> updateUser(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update(data);
  }

  Future<void> deleteUser(String uid) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .delete();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser(
    String uid,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots();
  }

  Future<void> setUserStatus(
    String uid,
    bool isActive,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // SERVICE PROVIDER REQUEST
  // ============================================================

  Future<String> createServiceProviderRequest({
    required String uid,
    required String name,
    required String phone,
    required String serviceType,
    required String city,
    required String area,
  }) async {
    final DocumentReference<Map<String, dynamic>> docRef =
        await _firestore
            .collection('serviceProviderRequests')
            .add({
      'uid': uid,
      'name': name,
      'phone': phone,
      'serviceType': serviceType,
      'city': city,
      'area': area,

      'status': 'pending',
      'approvedByAdmin': false,

      'adminMessage': '',
      'rejectionReason': '',

      'serviceProviderId': null,

      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // ============================================================
  // GET SINGLE REQUEST
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>>
      getServiceProviderRequest(
    String requestId,
  ) async {
    return await _firestore
        .collection('serviceProviderRequests')
        .doc(requestId)
        .get();
  }

  // ============================================================
  // STREAM PENDING REQUESTS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      streamPendingServiceProviderRequests() {
    return _firestore
        .collection('serviceProviderRequests')
        .where(
          'status',
          isEqualTo: 'pending',
        )
        .snapshots();
  }

  // ============================================================
  // STREAM ALL REQUESTS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      streamServiceProviderRequests() {
    return _firestore
        .collection('serviceProviderRequests')
        .snapshots();
  }

  // ============================================================
  // GET PENDING REQUEST COUNT
  // ============================================================

  Future<int> getPendingRequestCount() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore
            .collection('serviceProviderRequests')
            .where(
              'status',
              isEqualTo: 'pending',
            )
            .get();

    return snapshot.size;
  }

  // ============================================================
  // ADMIN
  // APPROVE SERVICE PROVIDER REQUEST
  // ============================================================

  Future<String> approveServiceProviderRequest({
    required String requestId,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> requestDoc =
        await _firestore
            .collection('serviceProviderRequests')
            .doc(requestId)
            .get();

    if (!requestDoc.exists ||
        requestDoc.data() == null) {
      throw Exception(
        'Service provider request not found.',
      );
    }

    final Map<String, dynamic> request =
        requestDoc.data()!;

    final String status =
        request['status']?.toString() ?? 'pending';

    if (status != 'pending') {
      throw Exception(
        'This request has already been processed.',
      );
    }

    final String uid =
        request['uid']?.toString() ?? '';

    final String name =
        request['name']?.toString() ?? '';

    final String phone =
        request['phone']?.toString() ?? '';

    final String serviceType =
        request['serviceType']?.toString() ?? '';

    final String city =
        request['city']?.toString() ?? '';

    final String area =
        request['area']?.toString() ?? '';

    if (uid.isEmpty) {
      throw Exception(
        'Invalid user ID.',
      );
    }

    // ----------------------------------------------------------
    // CREATE SERVICE PROVIDER
    // ----------------------------------------------------------

    final DocumentReference<Map<String, dynamic>>
        providerRef =
        _firestore
            .collection('serviceProviders')
            .doc();

    final String serviceProviderId =
        providerRef.id;

    await providerRef.set({
      'serviceProviderId':
          serviceProviderId,

      'uid': uid,

      'name': name,

      'phone': phone,

      'serviceType':
          serviceType,

      'city': city,

      'area': area,

      'status': 'approved',

      'approvedByAdmin': true,

      'createdAt':
          FieldValue.serverTimestamp(),

      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    // ----------------------------------------------------------
    // UPDATE USER
    // ----------------------------------------------------------

    await _firestore
        .collection('users')
        .doc(uid)
        .update({
      'role': 'serviceProvider',

      'serviceProviderId':
          serviceProviderId,

      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    // ----------------------------------------------------------
    // UPDATE REQUEST
    // ----------------------------------------------------------

    await _firestore
        .collection('serviceProviderRequests')
        .doc(requestId)
        .update({
      'status': 'approved',

      'approvedByAdmin': true,

      'serviceProviderId':
          serviceProviderId,

      'adminMessage':
          'Your service provider request has been approved.',

      'rejectionReason': '',

      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    return serviceProviderId;
  }

  // ============================================================
  // ADMIN
  // REJECT SERVICE PROVIDER REQUEST
  // ============================================================

  Future<void> rejectServiceProviderRequest({
    required String requestId,
    String reason = '',
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> requestDoc =
        await _firestore
            .collection('serviceProviderRequests')
            .doc(requestId)
            .get();

    if (!requestDoc.exists) {
      throw Exception(
        'Service provider request not found.',
      );
    }

    await _firestore
        .collection('serviceProviderRequests')
        .doc(requestId)
        .update({
      'status': 'rejected',

      'approvedByAdmin': false,

      'rejectionReason': reason,

      'adminMessage': reason.isEmpty
          ? 'Your service provider request was rejected.'
          : reason,

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // SERVICE PROVIDERS
  // ============================================================

  Future<String> createServiceProvider({
    required String uid,
    required String name,
    required String phone,
    required String serviceType,
    required String city,
    required String area,
  }) async {
    final DocumentReference<Map<String, dynamic>>
        providerRef =
        _firestore
            .collection('serviceProviders')
            .doc();

    await providerRef.set({
      'serviceProviderId':
          providerRef.id,

      'uid': uid,

      'name': name,

      'phone': phone,

      'serviceType':
          serviceType,

      'city': city,

      'area': area,

      'status': 'approved',

      'approvedByAdmin': true,

      'createdAt':
          FieldValue.serverTimestamp(),

      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    return providerRef.id;
  }

  // ============================================================
  // GET SERVICE PROVIDER
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>>
      getServiceProvider(
    String serviceProviderId,
  ) async {
    return await _firestore
        .collection('serviceProviders')
        .doc(serviceProviderId)
        .get();
  }

  // ============================================================
  // GET PROVIDERS BY USER
  // ============================================================

  Future<QuerySnapshot<Map<String, dynamic>>>
      getServiceProviderByUser(
    String uid,
  ) async {
    return await _firestore
        .collection('serviceProviders')
        .where(
          'uid',
          isEqualTo: uid,
        )
        .get();
  }

  // ============================================================
  // STREAM APPROVED PROVIDERS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      streamServiceProviders() {
    return _firestore
        .collection('serviceProviders')
        .where(
          'status',
          isEqualTo: 'approved',
        )
        .snapshots();
  }

  // ============================================================
  // LINK PROVIDER TO USER
  // ============================================================

  Future<void> linkServiceProviderToUser({
    required String uid,
    required String serviceProviderId,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
      'role': 'serviceProvider',

      'serviceProviderId':
          serviceProviderId,

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // REMOVE PROVIDER FROM USER
  // ============================================================

  Future<void> removeServiceProviderFromUser(
    String uid,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
      'role': 'user',

      'serviceProviderId':
          FieldValue.delete(),

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // DEACTIVATE PROVIDER
  // ============================================================

  Future<void> deactivateServiceProvider(
    String serviceProviderId,
  ) async {
    final DocumentSnapshot<Map<String, dynamic>>
        providerDoc =
        await _firestore
            .collection('serviceProviders')
            .doc(serviceProviderId)
            .get();

    if (!providerDoc.exists ||
        providerDoc.data() == null) {
      throw Exception(
        'Service provider not found.',
      );
    }

    final String uid =
        providerDoc.data()?['uid']
                ?.toString() ??
            '';

    await _firestore
        .collection('serviceProviders')
        .doc(serviceProviderId)
        .update({
      'status': 'inactive',
      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    if (uid.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({
        'role': 'user',

        'serviceProviderId':
            FieldValue.delete(),

        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    }
  }

  // ============================================================
  // REACTIVATE PROVIDER
  // ============================================================

  Future<void> reactivateServiceProvider(
    String serviceProviderId,
  ) async {
    final DocumentSnapshot<Map<String, dynamic>>
        providerDoc =
        await _firestore
            .collection('serviceProviders')
            .doc(serviceProviderId)
            .get();

    if (!providerDoc.exists ||
        providerDoc.data() == null) {
      throw Exception(
        'Service provider not found.',
      );
    }

    final String uid =
        providerDoc.data()?['uid']
                ?.toString() ??
            '';

    await _firestore
        .collection('serviceProviders')
        .doc(serviceProviderId)
        .update({
      'status': 'approved',

      'approvedByAdmin': true,

      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    if (uid.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({
        'role': 'serviceProvider',

        'serviceProviderId':
            serviceProviderId,

        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    }
  }

  // ============================================================
  // ADMIN STATISTICS
  // ============================================================

  Future<int> getUserCount() async {
    final QuerySnapshot<Map<String, dynamic>>
        snapshot =
        await _firestore
            .collection('users')
            .get();

    return snapshot.size;
  }

  Future<int> getServiceProviderCount() async {
    final QuerySnapshot<Map<String, dynamic>>
        snapshot =
        await _firestore
            .collection('serviceProviders')
            .get();

    return snapshot.size;
  }

  // ============================================================
  // ORDERS / BOOKINGS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      streamOrders() {
    return _firestore
        .collection('orders')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }
}
