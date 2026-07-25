/// Compry — Shopping List Model
/// Data layer — Firestore + Hive serialization
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/shopping_list_entity.dart';
import '../../../../core/constants/app_constants.dart';

part 'shopping_list_model.g.dart';

@HiveType(typeId: AppConstants.hiveTypeShoppingList)
class ShoppingListModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final String? notes;
  @HiveField(4)
  final String priority;
  @HiveField(5)
  final String status;
  @HiveField(6)
  final String createdBy;
  @HiveField(7)
  final String? createdByName;
  @HiveField(8)
  final String? assignedTo;
  @HiveField(9)
  final String? category;
  @HiveField(10)
  final List<String> tags;
  @HiveField(11)
  final DateTime? dueDate;
  @HiveField(12)
  final DateTime createdAt;
  @HiveField(13)
  final DateTime updatedAt;
  @HiveField(14)
  final DateTime? finishedAt;
  @HiveField(15)
  final DateTime? sentAt;
  @HiveField(16)
  final DateTime? startedAt;
  @HiveField(17)
  final int version;
  @HiveField(18)
  final bool offlineChanges;
  @HiveField(19)
  final int totalItems;
  @HiveField(20)
  final int checkedItems;

  ShoppingListModel({
    required this.id,
    required this.title,
    this.description,
    this.notes,
    required this.priority,
    required this.status,
    required this.createdBy,
    this.createdByName,
    this.assignedTo,
    this.category,
    this.tags = const [],
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.finishedAt,
    this.sentAt,
    this.startedAt,
    this.version = 1,
    this.offlineChanges = false,
    this.totalItems = 0,
    this.checkedItems = 0,
  });

  // ─── Firestore ─────────────────────────────────────────────────────────────

  factory ShoppingListModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingListModel.fromMap(data, doc.id);
  }

  factory ShoppingListModel.fromMap(Map<String, dynamic> data, String id) {
    return ShoppingListModel(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      notes: data['notes'] as String?,
      priority: data['priority'] as String? ?? AppPriority.medium,
      status: data['status'] as String? ?? AppStatus.draft,
      createdBy: data['createdBy'] as String? ?? '',
      createdByName: data['createdByName'] as String?,
      assignedTo: data['assignedTo'] as String?,
      category: data['category'] as String?,
      tags: List<String>.from(data['tags'] as List? ?? []),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      finishedAt: (data['finishedAt'] as Timestamp?)?.toDate(),
      sentAt: (data['sentAt'] as Timestamp?)?.toDate(),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      version: data['version'] as int? ?? 1,
      offlineChanges: data['offlineChanges'] as bool? ?? false,
      totalItems: data['totalItems'] as int? ?? 0,
      checkedItems: data['checkedItems'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'notes': notes,
        'priority': priority,
        'status': status,
        'createdBy': createdBy,
        'createdByName': createdByName,
        'assignedTo': assignedTo,
        'category': category,
        'tags': tags,
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'finishedAt': finishedAt != null ? Timestamp.fromDate(finishedAt!) : null,
        'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
        'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
        'version': version,
        'offlineChanges': offlineChanges,
        'totalItems': totalItems,
        'checkedItems': checkedItems,
      };

  // ─── Domain mapping ─────────────────────────────────────────────────────────

  ShoppingListEntity toEntity() => ShoppingListEntity(
        id: id,
        title: title,
        description: description,
        notes: notes,
        priority: ListPriority.fromString(priority),
        status: ListStatus.fromString(status),
        createdBy: createdBy,
        createdByName: createdByName,
        assignedTo: assignedTo,
        category: category,
        tags: tags,
        dueDate: dueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
        finishedAt: finishedAt,
        sentAt: sentAt,
        startedAt: startedAt,
        version: version,
        offlineChanges: offlineChanges,
        totalItems: totalItems,
        checkedItems: checkedItems,
      );

  factory ShoppingListModel.fromEntity(ShoppingListEntity entity) =>
      ShoppingListModel(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        notes: entity.notes,
        priority: entity.priority.value,
        status: entity.status.value,
        createdBy: entity.createdBy,
        createdByName: entity.createdByName,
        assignedTo: entity.assignedTo,
        category: entity.category,
        tags: entity.tags,
        dueDate: entity.dueDate,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        finishedAt: entity.finishedAt,
        sentAt: entity.sentAt,
        startedAt: entity.startedAt,
        version: entity.version,
        offlineChanges: entity.offlineChanges,
        totalItems: entity.totalItems,
        checkedItems: entity.checkedItems,
      );
}
