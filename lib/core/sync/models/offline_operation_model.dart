/// Compry — Offline Operation Model
/// Models a deferred mutation for the offline queue.
library;

import 'package:hive/hive.dart';
import '../../constants/app_constants.dart';

part 'offline_operation_model.g.dart';

@HiveType(typeId: AppConstants.hiveTypeOfflineOperation)
class OfflineOperationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String collection; // e.g., 'shopping_lists' or 'items'

  @HiveField(2)
  final String documentId;

  @HiveField(3)
  final String operationType; // 'CREATE', 'UPDATE', 'DELETE'

  @HiveField(4)
  final Map<String, dynamic> payload; // JSON data

  @HiveField(5)
  final DateTime timestamp;

  OfflineOperationModel({
    required this.id,
    required this.collection,
    required this.documentId,
    required this.operationType,
    required this.payload,
    required this.timestamp,
  });
}
