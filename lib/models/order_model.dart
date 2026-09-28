import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  // ============================================================
  // ORDER INFORMATION
  // ============================================================

  final String orderId;

  // ============================================================
  // USER INFORMATION
  // ============================================================

  final String userId;
  final String userName;
  final String userPhone;
  final String userEmail;

  // ============================================================
  // SERVICE INFORMATION
  // ============================================================

  final String serviceType;

  // ============================================================
  // SERVICE PROVIDER
  // ============================================================

  // Null until admin assigns a provider.
  final String? serviceProviderId;

  // ============================================================
  // BOOKING INFORMATION
  // ============================================================

  final DateTime preferredDate;
  final String preferredTime;

  final String address;

  // normal / priority / emergency
  final String urgency;

  final String description;

  // pending / accepted / rejected / assigned / completed
  final String status;

  // ============================================================
  // DATE
  // ============================================================

  final DateTime createdAt;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  OrderModel({
    required this.orderId,

    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userEmail,

    required this.serviceType,

    this.serviceProviderId,

    required this.preferredDate,
    required this.preferredTime,

    required this.address,
    required this.urgency,
    required this.description,

    this.status = 'pending',

    required this.createdAt,
  });

  // ============================================================
  // MODEL → FIRESTORE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,

      // User
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userEmail': userEmail,

      // Service
      'serviceType': serviceType,

      // Provider
      'serviceProviderId': serviceProviderId,

      // Booking
      'preferredDate':
          Timestamp.fromDate(preferredDate),

      'preferredTime': preferredTime,

      'address': address,

      'urgency': urgency,

      'description': description,

      // Status
      'status': status,

      // Created date
      'createdAt':
          Timestamp.fromDate(createdAt),
    };
  }

  // ============================================================
  // FIRESTORE → MODEL
  // ============================================================

  factory OrderModel.fromMap(
    Map<String, dynamic> map,
  ) {
    final dynamic preferredDateValue =
        map['preferredDate'];

    final dynamic createdAtValue =
        map['createdAt'];

    DateTime preferredDate;

    DateTime createdAt;

    // ----------------------------------------------------------
    // PREFERRED DATE
    // ----------------------------------------------------------

    if (preferredDateValue is Timestamp) {
      preferredDate =
          preferredDateValue.toDate();
    } else if (preferredDateValue is DateTime) {
      preferredDate = preferredDateValue;
    } else {
      preferredDate = DateTime.now();
    }

    // ----------------------------------------------------------
    // CREATED DATE
    // ----------------------------------------------------------

    if (createdAtValue is Timestamp) {
      createdAt =
          createdAtValue.toDate();
    } else if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else {
      createdAt = DateTime.now();
    }

    // ----------------------------------------------------------
    // RETURN ORDER
    // ----------------------------------------------------------

    return OrderModel(
      orderId:
          map['orderId'] ?? '',

      userId:
          map['userId'] ?? '',

      userName:
          map['userName'] ?? '',

      userPhone:
          map['userPhone'] ?? '',

      userEmail:
          map['userEmail'] ?? '',

      serviceType:
          map['serviceType'] ?? '',

      serviceProviderId:
          map['serviceProviderId'],

      preferredDate:
          preferredDate,

      preferredTime:
          map['preferredTime'] ?? '',

      address:
          map['address'] ?? '',

      urgency:
          map['urgency'] ?? 'normal',

      description:
          map['description'] ?? '',

      status:
          map['status'] ?? 'pending',

      createdAt:
          createdAt,
    );
  }
}