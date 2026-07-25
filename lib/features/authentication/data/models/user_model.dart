/// Compry — User Model
/// Data layer — Firestore + Hive serialization
/// Maps to domain UserEntity
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/user_entity.dart';
import '../../../../core/constants/app_constants.dart';

part 'user_model.g.dart';

@HiveType(typeId: AppConstants.hiveTypeUser)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final bool active;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  // ─── Firestore ─────────────────────────────────────────────────────────────

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      username: data['username'] as String? ?? '',
      role: data['role'] as String? ?? AppRoles.employee,
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] as String? ?? '',
      username: data['username'] as String? ?? '',
      role: data['role'] as String? ?? AppRoles.employee,
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'username': username,
        'role': role,
        'active': active,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  // ─── Domain mapping ─────────────────────────────────────────────────────────

  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        username: username,
        role: UserRole.fromString(role),
        active: active,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        name: entity.name,
        username: entity.username,
        role: entity.role.value,
        active: entity.active,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  // ─── Copy with ──────────────────────────────────────────────────────────────

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? role,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      role: role ?? this.role,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
