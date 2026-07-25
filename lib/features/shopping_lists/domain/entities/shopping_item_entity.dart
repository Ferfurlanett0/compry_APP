/// Compry — Shopping Item Entity
/// Domain layer — immutable
/// PRD Part 3, Section 17 + RF-009 to RF-014
library;

import 'package:equatable/equatable.dart';

/// Unidades de medida (RF-010)
enum ItemUnit {
  unidade('UNIDADE', 'Un'),
  kg('KG', 'Kg'),
  g('G', 'g'),
  l('L', 'L'),
  ml('ML', 'ml'),
  caixa('CAIXA', 'Cx'),
  pacote('PACOTE', 'Pct'),
  fardo('FARDO', 'Fardo'),
  bandeja('BANDEJA', 'Bdj'),
  saco('SACO', 'Saco'),
  outro('OUTRO', 'Outro');

  final String value;
  final String abbreviation;
  const ItemUnit(this.value, this.abbreviation);

  static ItemUnit fromString(String value) {
    return ItemUnit.values.firstWhere(
      (u) => u.value == value,
      orElse: () => ItemUnit.unidade,
    );
  }

  String get label => switch (this) {
        ItemUnit.unidade => 'Unidade',
        ItemUnit.kg => 'Quilograma (Kg)',
        ItemUnit.g => 'Grama (g)',
        ItemUnit.l => 'Litro (L)',
        ItemUnit.ml => 'Mililitro (ml)',
        ItemUnit.caixa => 'Caixa',
        ItemUnit.pacote => 'Pacote',
        ItemUnit.fardo => 'Fardo',
        ItemUnit.bandeja => 'Bandeja',
        ItemUnit.saco => 'Saco',
        ItemUnit.outro => 'Outro',
      };
}

/// Entidade de item de compra — imutável
class ShoppingItemEntity extends Equatable {
  final String id;
  final String listId;
  final String name;
  final double quantity;       // RF-011: inteiros e decimais
  final ItemUnit unit;
  final String? brand;         // RF-012: opcional
  final String? category;
  final double? expectedPrice; // RF-013: opcional, em R$
  final String? notes;         // RF-014: campo livre
  final bool checked;
  final String? checkedBy;     // userId
  final DateTime? checkedAt;
  final int position;          // RF-016: ordenação
  final int version;

  const ShoppingItemEntity({
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

  /// Formatted quantity for display
  String get quantityDisplay {
    if (quantity == quantity.truncateToDouble()) {
      return '${quantity.toInt()} ${unit.abbreviation}';
    }
    return '${quantity.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '').replaceAll('.', ',')} ${unit.abbreviation}';
  }

  /// Formatted price for display
  String? get expectedPriceDisplay {
    if (expectedPrice == null) return null;
    return 'R\$ ${expectedPrice!.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  ShoppingItemEntity copyWith({
    String? id,
    String? listId,
    String? name,
    double? quantity,
    ItemUnit? unit,
    String? brand,
    String? category,
    double? expectedPrice,
    String? notes,
    bool? checked,
    String? checkedBy,
    DateTime? checkedAt,
    int? position,
    int? version,
  }) {
    return ShoppingItemEntity(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      expectedPrice: expectedPrice ?? this.expectedPrice,
      notes: notes ?? this.notes,
      checked: checked ?? this.checked,
      checkedBy: checkedBy ?? this.checkedBy,
      checkedAt: checkedAt ?? this.checkedAt,
      position: position ?? this.position,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [
        id,
        listId,
        name,
        quantity,
        unit,
        brand,
        category,
        expectedPrice,
        notes,
        checked,
        checkedBy,
        checkedAt,
        position,
        version,
      ];

  @override
  String toString() =>
      'ShoppingItemEntity(id: $id, name: $name, checked: $checked)';
}
