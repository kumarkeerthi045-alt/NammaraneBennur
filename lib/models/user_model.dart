import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  // ============================================================
  // USER INFORMATION
  // ============================================================

  final String userId;
  final String name;
  final String email;
  final String phone;

  // ============================================================
  // LOCATION
  // ============================================================

  final String city;
  final String area;
  final String pincode;

  // ============================================================
  // ROLE
  // ============================================================

  // Possible values:
  // user
  // serviceProvider
  // admin
  final String role;

  // ============================================================
  // SERVICE PROVIDER
  // ============================================================

  // This remains null for normal users.
  //
  // Once admin approves a service provider:
  //
  // users.serviceProviderId
  //          ↓
  // serviceProviders/{serviceProviderId}
  //
  final String? serviceProviderId;

  // ============================================================
  // ACCOUNT STATUS
  // ============================================================

  final bool isActive;
  final bool isVerified;

  // ============================================================
  // DATE
  // ============================================================

  final DateTime createdAt;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.area,
    required this.pincode,
    required this.role,
    this.serviceProviderId,
    this.isActive = true,
    this.isVerified = false,
    required this.createdAt,
  });

  // ============================================================
  // CONVERT MODEL → FIRESTORE MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'area': area,
      'pincode': pincode,
      'role': role,

      // Null when the user is not a service provider.
      'serviceProviderId': serviceProviderId,

      'isActive': isActive,
      'isVerified': isVerified,

      // Firestore Timestamp
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ============================================================
  // CONVERT FIRESTORE MAP → MODEL
  // ============================================================

  factory UserModel.fromMap(
    Map<String, dynamic> map,
  ) {
    // ----------------------------------------------------------
    // CREATED AT
    // ----------------------------------------------------------

    final dynamic createdAtValue =
        map['createdAt'];

    DateTime createdAt;

    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else {
      createdAt = DateTime.now();
    }

    // ----------------------------------------------------------
    // RETURN USER MODEL
    // ----------------------------------------------------------

    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      city: map['city'] ?? '',
      area: map['area'] ?? '',
      pincode: map['pincode'] ?? '',

      // Default role for normal users.
      role: map['role'] ?? 'user',

      // Can be null for normal users.
      serviceProviderId:
          map['serviceProviderId'],

      // Default active.
      isActive:
          map['isActive'] ?? true,

      // Default not verified.
      isVerified:
          map['isVerified'] ?? false,

      createdAt: createdAt,
    );
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? city,
    String? area,
    String? pincode,
    String? role,
    String? serviceProviderId,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      area: area ?? this.area,
      pincode: pincode ?? this.pincode,
      role: role ?? this.role,

      // Keep the existing value when nothing new is supplied.
      serviceProviderId:
          serviceProviderId ?? this.serviceProviderId,

      isActive:
          isActive ?? this.isActive,

      isVerified:
          isVerified ?? this.isVerified,

      createdAt:
          createdAt ?? this.createdAt,
    );
  }
}