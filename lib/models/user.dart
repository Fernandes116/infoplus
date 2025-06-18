import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String province;
  final int points;
  final bool isAdmin;
  final bool isSuperAdmin;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.province,
    this.points = 0,
    this.isAdmin = false,
    this.isSuperAdmin = false,
    this.role = 'user',
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  factory UserModel.fromFirebaseUser(Map<String, dynamic> userData) {
    return UserModel(
      id: userData['id'] ?? '',
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
      phoneNumber: userData['phoneNumber'] ?? '',
      province: userData['province'] ?? '',
      points: userData['points'] ?? 0,
      isAdmin: userData['isAdmin'] ?? false,
      isSuperAdmin: userData['isSuperAdmin'] ?? false,
      role: userData['role'] ?? 'user',
      createdAt: userData['createdAt']?.toDate(),
      updatedAt: userData['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? province,
    int? points,
    bool? isAdmin,
    bool? isSuperAdmin,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      province: province ?? this.province,
      points: points ?? this.points,
      isAdmin: isAdmin ?? this.isAdmin,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}