/// Compry — Sync Service
/// Processes the offline queue when connectivity is restored.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

import '../../constants/app_constants.dart';
import '../../services/connectivity_service.dart';
import '../models/offline_operation_model.dart';
import '../../config/providers.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  final logger = ref.watch(loggerProvider);
  final firestore = ref.watch(firestoreProvider);
  
  final service = SyncService(
    connectivity: connectivity,
    logger: logger,
    firestore: firestore,
  );
  
  // Initialize the listener
  connectivity.onConnectivityChanged.listen((isConnected) {
    if (isConnected) {
      service.syncOfflineOperations();
    }
  });

  return service;
});

class SyncService {
  final ConnectivityService _connectivity;
  final Logger _logger;
  final FirebaseFirestore _firestore;
  bool _isSyncing = false;

  SyncService({
    required ConnectivityService connectivity,
    required Logger logger,
    required FirebaseFirestore firestore,
  })  : _connectivity = connectivity,
        _logger = logger,
        _firestore = firestore;

  /// Starts the synchronization process of queued operations
  Future<void> syncOfflineOperations() async {
    final isConnected = await _connectivity.hasConnection;
    if (!isConnected) {
      return;
    }
    
    if (_isSyncing) return;

    final box = Hive.box<OfflineOperationModel>(AppConstants.hiveBoxOfflineQueue);
    if (box.isEmpty) return;

    _isSyncing = true;
    _logger.i('Starting offline queue synchronization. Pending items: ${box.length}');

    final operations = box.values.toList();
    // Sort by timestamp to ensure chronological execution
    operations.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int successCount = 0;
    int errorCount = 0;

    for (final op in operations) {
      try {
        await _processOperation(op);
        await op.delete(); // Remove from queue after success
        successCount++;
      } catch (e) {
        _logger.e('Failed to sync operation ${op.id} (${op.operationType} on ${op.collection}): $e');
        errorCount++;
        // Stop syncing to preserve chronological order for the remaining items on this document
        break;
      }
    }

    _logger.i('Sync completed. Success: $successCount, Errors: $errorCount. Remaining in queue: ${box.length}');
    _isSyncing = false;
  }

  Future<void> _processOperation(OfflineOperationModel op) async {
    final docRef = _firestore.collection(op.collection).doc(op.documentId);

    // Conflict Resolution: Check remote timestamp (Last Write Wins)
    if (op.operationType == 'UPDATE') {
      try {
        final docSnap = await docRef.get();
        if (docSnap.exists) {
          final remoteData = docSnap.data();
          if (remoteData != null && remoteData.containsKey('updatedAt')) {
            final remoteTimestamp = (remoteData['updatedAt'] as Timestamp).toDate();
            // If the remote version is newer than the local operation's timestamp, server wins
            if (remoteTimestamp.isAfter(op.timestamp)) {
              _logger.w('Conflict detected on ${op.documentId}. Server wins. Operation ignored.');
              // Log the conflict resolution for auditing
              await _firestore.collection(AppConstants.colAuditLogs).add({
                'action': 'CONFLICT_RESOLVED',
                'documentId': op.documentId,
                'resolvedInFavorOf': 'SERVER',
                'timestamp': FieldValue.serverTimestamp(),
              });
              return;
            }
          }
        }
      } catch (e) {
        _logger.w('Could not fetch remote doc for conflict check: $e. Proceeding with operation.');
      }
    }

    switch (op.operationType) {
      case 'CREATE':
      case 'UPDATE': // In Firestore, set with merge is practically an upsert
        await docRef.set(op.payload, SetOptions(merge: true));
        break;
      case 'DELETE':
        await docRef.delete();
        break;
      default:
        _logger.e('Unknown offline operation type: ${op.operationType}');
    }
  }

  /// Adds a new operation to the offline queue
  Future<void> enqueueOperation({
    required String collection,
    required String documentId,
    required String operationType,
    required Map<String, dynamic> payload,
  }) async {
    final box = Hive.box<OfflineOperationModel>(AppConstants.hiveBoxOfflineQueue);
    
    // Prevent queue overflow
    if (box.length >= AppConstants.maxOfflineQueueSize) {
      _logger.w('Offline queue size limit reached. Discarding oldest operation.');
      // Find oldest and delete
      final oldestKey = box.keys.first;
      await box.delete(oldestKey);
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final op = OfflineOperationModel(
      id: id,
      collection: collection,
      documentId: documentId,
      operationType: operationType,
      payload: payload,
      timestamp: DateTime.now(),
    );

    await box.put(id, op);
    _logger.i('Operation queued for offline sync: $operationType on $collection/$documentId');
  }
}
