// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShoppingListModelAdapter extends TypeAdapter<ShoppingListModel> {
  @override
  final int typeId = 1;

  @override
  ShoppingListModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShoppingListModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      notes: fields[3] as String?,
      priority: fields[4] as String,
      status: fields[5] as String,
      createdBy: fields[6] as String,
      createdByName: fields[7] as String?,
      assignedTo: fields[8] as String?,
      category: fields[9] as String?,
      tags: (fields[10] as List).cast<String>(),
      dueDate: fields[11] as DateTime?,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
      finishedAt: fields[14] as DateTime?,
      sentAt: fields[15] as DateTime?,
      startedAt: fields[16] as DateTime?,
      version: fields[17] as int,
      offlineChanges: fields[18] as bool,
      totalItems: fields[19] as int,
      checkedItems: fields[20] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ShoppingListModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.createdBy)
      ..writeByte(7)
      ..write(obj.createdByName)
      ..writeByte(8)
      ..write(obj.assignedTo)
      ..writeByte(9)
      ..write(obj.category)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.dueDate)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.finishedAt)
      ..writeByte(15)
      ..write(obj.sentAt)
      ..writeByte(16)
      ..write(obj.startedAt)
      ..writeByte(17)
      ..write(obj.version)
      ..writeByte(18)
      ..write(obj.offlineChanges)
      ..writeByte(19)
      ..write(obj.totalItems)
      ..writeByte(20)
      ..write(obj.checkedItems);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingListModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
