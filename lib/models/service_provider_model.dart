import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProviderModel {
  final String serviceProviderId;
  final String userId;
  final String name;
  final String phone;
  final String serviceType;
  final String status;
  final String approvedBy;
  final DateTime createdAt;

  ServiceProviderModel({
    required this.serviceProviderId,
    required this.userId,
    required this.name,
    required this.phone,
    required this.serviceType,
    required this.status,
    required this.approvedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'serviceProviderId': serviceProviderId,
      'userId': userId,
      'name': name,
      'phone': phone,
      'serviceType': serviceType,
      'status': status,
      'approvedBy': approvedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ServiceProviderModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ServiceProviderModel(
      serviceProviderId:
          map['serviceProviderId'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      serviceType:
          map['serviceType'] ?? '',
      status:
          map['status'] ?? 'pending',
      approvedBy:
          map['approvedBy'] ?? '',
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }
}