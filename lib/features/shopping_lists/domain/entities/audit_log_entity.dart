/// Compry — Audit Log Entity
/// Domain layer — PRD Part 3, Section 17 + RF-039, RF-040
library;

import 'package:equatable/equatable.dart';

/// Ações registradas no log de auditoria (RF-040)
enum AuditAction {
  login('LOGIN'),
  logout('LOGOUT'),
  createList('CREATE_LIST'),
  editList('EDIT_LIST'),
  sendList('SEND_LIST'),
  cancelList('CANCEL_LIST'),
  finalizeList('FINALIZE_LIST'),
  addItem('ADD_ITEM'),
  editItem('EDIT_ITEM'),
  deleteItem('DELETE_ITEM'),
  checkItem('CHECK_ITEM'),
  uncheckItem('UNCHECK_ITEM'),
  syncSuccess('SYNC_SUCCESS'),
  syncError('SYNC_ERROR'),
  conflictResolved('CONFLICT_RESOLVED');

  final String value;
  const AuditAction(this.value);

  static AuditAction fromString(String value) {
    return AuditAction.values.firstWhere(
      (a) => a.value == value,
      orElse: () => AuditAction.syncError,
    );
  }
}

/// Tipos de entidade auditadas
enum AuditEntity {
  shoppingList('SHOPPING_LIST'),
  shoppingItem('SHOPPING_ITEM'),
  user('USER'),
  system('SYSTEM');

  final String value;
  const AuditEntity(this.value);

  static AuditEntity fromString(String value) {
    return AuditEntity.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AuditEntity.system,
    );
  }
}

/// Entidade de log de auditoria — imutável, somente escrita (RF-039)
class AuditLogEntity extends Equatable {
  final String id;
  final String userId;
  final AuditAction action;
  final AuditEntity entity;
  final String? entityId;
  final String device;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const AuditLogEntity({
    required this.id,
    required this.userId,
    required this.action,
    required this.entity,
    this.entityId,
    required this.device,
    required this.timestamp,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [id, userId, action, entity, entityId, timestamp];

  @override
  String toString() =>
      'AuditLogEntity(id: $id, action: $action, entity: $entity)';
}
