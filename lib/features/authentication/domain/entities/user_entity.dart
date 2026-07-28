/// Compry — User Entity
/// Domain layer — immutable, no dependencies on external layers
/// PRD Part 3, Section 17
library;

import 'package:equatable/equatable.dart';

/// Roles de usuário conforme PRD (RG-002)
enum UserRole {
  admin('ADMIN'),
  employee('EMPLOYEE');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.employee,
    );
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isEmployee => this == UserRole.employee;
}

/// Entidade de usuário — imutável
/// Nunca deve conter lógica de UI ou dependências de dados
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String username;
  final UserRole role;
  final String? avatar;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    this.avatar,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role.isAdmin;
  bool get isEmployee => role.isEmployee;

  /// Display name para UI
  String get displayName => name;

  /// Iniciais para avatar
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Caminho do avatar local (imagem)
  String get avatarPath {
    if (avatar != null && avatar!.isNotEmpty) {
      return 'assets/images/$avatar.png';
    }
    if (isAdmin) return 'assets/images/Perfil administrador.png';
    return 'assets/images/Perfil churrasqueiro.png';
  }

  UserEntity copyWith({
    String? id,
    String? name,
    String? username,
    UserRole? role,
    String? avatar,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, username, role, avatar, active, createdAt, updatedAt];

  @override
  String toString() => 'UserEntity(id: $id, name: $name, role: $role)';
}
