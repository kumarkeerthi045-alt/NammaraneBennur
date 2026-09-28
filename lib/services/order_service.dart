import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // CREATE ORDER
  // ============================================================

  Future<String> createOrder(OrderModel order) async {
    try {
      // Generate Firestore document reference.
      final DocumentReference<Map<String, dynamic>> orderRef =
          _firestore.collection('orders').doc();

      // Create the order with generated ID.
      final OrderModel orderWithId = OrderModel(
        orderId: orderRef.id,

        // USER
        userId: order.userId,
        userName: order.userName,
        userPhone: order.userPhone,
        userEmail: order.userEmail,

        // SERVICE
        serviceType: order.serviceType,

        // PROVIDER
        serviceProviderId:
            order.serviceProviderId,

        // BOOKING
        preferredDate:
            order.preferredDate,

        preferredTime:
            order.preferredTime,

        address:
            order.address,

        urgency:
            order.urgency,

        description:
            order.description,

        // ORDER STATUS
        status:
            'pending',

        // CREATED DATE
        createdAt:
            order.createdAt,
      );

      // Save to Firestore.
      await orderRef.set(
        orderWithId.toMap(),
      );

      return orderRef.id;
    } catch (e) {
      throw Exception(
        'Failed to create order: $e',
      );
    }
  }
}