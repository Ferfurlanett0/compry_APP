/// Compry — Notifications Repository Implementation
/// Data layer
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../models/notification_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final FirebaseFirestore _firestore;
  final Logger _logger;

  NotificationsRepositoryImpl({
    required FirebaseFirestore firestore,
    required Logger logger,
  })  : _firestore = firestore,
        _logger = logger;

  @override
  Stream<List<NotificationEntity>> watchUserNotifications(String userId) {
    return _firestore
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection(AppConstants.colNotifications)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => NotificationModel.fromFirestore(doc).toEntity())
            .toList());
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    // Note: since notifications are in a subcollection under the user, 
    // we would ideally need the userId here or use a CollectionGroup query.
    // For simplicity, we can do a collectionGroup query to find and update it.
    try {
      final snap = await _firestore
          .collectionGroup(AppConstants.colNotifications)
          .where(FieldPath.documentId, isEqualTo: notificationId)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.update({'read': true});
      }
    } catch (e) {
      _logger.e('Failed to mark notification as read: $e');
    }
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return _firestore
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection(AppConstants.colNotifications)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}
