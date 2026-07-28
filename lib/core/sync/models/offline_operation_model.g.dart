// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_operation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineOperationModelAdapter extends TypeAdapter<OfflineOperationModel> {
  @override
  final int typeId = 3;

  @override
  OfflineOperationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineOperationModel(
      id: fields[0] as String,
      collection: fields[1] as String,
      documentId: fields[2] as String,
      operationType: fields[3] as String,
      payload: (fields[4] as Map).cast<String, dynamic>(),
      timestamp: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineOperationModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.collection)
      ..writeByte(2)
      ..write(obj.documentId)
      ..writeByte(3)
      ..write(obj.operationType)
      ..writeByte(4)
      ..write(obj.payload)
      ..writeByte(5)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineOperationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
