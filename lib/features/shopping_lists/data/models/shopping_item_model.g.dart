// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_item_model.dart';

class ShoppingItemModelAdapter extends TypeAdapter<ShoppingItemModel> {
  @override
  final int typeId = 2;

  @override
  ShoppingItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShoppingItemModel(
      id: fields[0] as String,
      listId: fields[1] as String,
      name: fields[2] as String,
      quantity: fields[3] as double,
      unit: fields[4] as String,
      brand: fields[5] as String?,
      category: fields[6] as String?,
      expectedPrice: fields[7] as double?,
      notes: fields[8] as String?,
      checked: fields[9] as bool,
      checkedBy: fields[10] as String?,
      checkedAt: fields[11] as DateTime?,
      position: fields[12] as int,
      version: fields[13] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ShoppingItemModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.listId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.brand)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.expectedPrice)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.checked)
      ..writeByte(10)
      ..write(obj.checkedBy)
      ..writeByte(11)
      ..write(obj.checkedAt)
      ..writeByte(12)
      ..write(obj.position)
      ..writeByte(13)
      ..write(obj.version);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
