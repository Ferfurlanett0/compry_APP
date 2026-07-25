/// Compry — Shopping Item Model
/// Data layer — Firestore + Hive serialization
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/shopping_item_entity.dart';
import '../../../../core/constants/app_constants.dart';

part 'shopping_item_model.g.dart';

@HiveType(typeId: AppConstants.hiveTypeShoppingItem)
class ShoppingItemModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String listId;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final double quantity;
  @HiveField(4)
  final String unit;
  @HiveField(5)
  final String? brand;
  @HiveField(6)
  final String? category;
  @HiveField(7)
  final double? expectedPrice;
  @HiveField(8)
  final String? notes;
  @HiveField(9)
  final bool checked;
  @HiveField(10)
  final String? checkedBy;
  @HiveField(11)
  final DateTime? checkedAt;
  @HiveField(12)
  final int position;
  @HiveField(13)
  final int version;

  ShoppingItemModel({
    required this.id,
    required this.listId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.brand,
    this.category,
    this.expectedPrice,
    this.notes,
    this.checked = false,
    this.checkedBy,
    this.checkedAt,
    required this.position,
    this.version = 1,
  });

  // ─── Firestore ─────────────────────────────────────────────────────────────

  factory ShoppingItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingItemModel.fromMap(data, doc.id);
  }

  factory ShoppingItemModel.fromMap(Map<String, dynamic> data, String id) {
    return ShoppingItemModel(
      id: id,
      listId: data['listId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: data['unit'] as String? ?? AppItemUnits.unit,
      brand: data['brand'] as String?,
      category: data['category'] as String?,
      expectedPrice: (data['expectedPrice'] as num?)?.toDouble(),
      notes: data['notes'] as String?,
      checked: data['checked'] as bool? ?? false,
      checkedBy: data['checkedBy'] as String?,
      checkedAt: (data['checkedAt'] as Timestamp?)?.toDate(),
      position: data['position'] as int? ?? 0,
      version: data['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'listId': listId,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'brand': brand,
        'category': category,
        'expectedPrice': expectedPrice,
        'notes': notes,
        'checked': checked,
        'checkedBy': checkedBy,
        'checkedAt': checkedAt != null ? Timestamp.fromDate(checkedAt!) : null,
        'position': position,
        'version': version,
      };

  // ─── Domain mapping ─────────────────────────────────────────────────────────

  ShoppingItemEntity toEntity() => ShoppingItemEntity(
        id: id,
        listId: listId,
        name: name,
        quantity: quantity,
        unit: ItemUnit.fromString(unit),
        brand: brand,
        category: category,
        expectedPrice: expectedPrice,
        notes: notes,
        checked: checked,
        checkedBy: checkedBy,
        checkedAt: checkedAt,
        position: position,
        version: version,
      );

  factory ShoppingItemModel.fromEntity(ShoppingItemEntity entity) =>
      ShoppingItemModel(
        id: entity.id,
        listId: entity.listId,
        name: entity.name,
        quantity: entity.quantity,
        unit: entity.unit.value,
        brand: entity.brand,
        category: entity.category,
        expectedPrice: entity.expectedPrice,
        notes: entity.notes,
        checked: entity.checked,
        checkedBy: entity.checkedBy,
        checkedAt: entity.checkedAt,
        position: entity.position,
        version: entity.version,
      );
}
