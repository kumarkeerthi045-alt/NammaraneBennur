import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_provider_model.dart';

class ServiceProviderService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ------------------------------------------------------------
  // SUBMIT SERVICE PROVIDER REQUEST
  // ------------------------------------------------------------

  Future<void> submitServiceProvider({
    required String userId,
    required String name,
    required String phone,
    required String serviceType,
  }) async {
    // Create a new Firestore document ID
    final docRef =
        _firestore.collection('serviceProviders').doc();

    final provider = ServiceProviderModel(
      serviceProviderId: docRef.id,
      userId: userId,
      name: name,
      phone: phone,
      serviceType: serviceType,
      status: 'pending',
      approvedBy: '',
      createdAt: DateTime.now(),
    );

    await docRef.set(provider.toMap());
  }

  // ------------------------------------------------------------
  // GET ALL SERVICE PROVIDERS
  // ------------------------------------------------------------

  Stream<List<ServiceProviderModel>>
      getAllServiceProviders() {
    return _firestore
        .collection('serviceProviders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ServiceProviderModel.fromMap(
          doc.data(),
        );
      }).toList();
    });
  }

  // ------------------------------------------------------------
  // UPDATE PROVIDER STATUS
  // ------------------------------------------------------------

  Future<void> updateProviderStatus({
    required String providerId,
    required String status,
    String approvedBy = '',
  }) async {
    await _firestore
        .collection('serviceProviders')
        .doc(providerId)
        .update({
      'status': status,
      'approvedBy': approvedBy,
    });
  }
}