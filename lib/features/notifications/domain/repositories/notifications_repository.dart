/// Compry — Notifications Repository Interface
/// Domain layer
library;

import '../entities/notification_entity.dart';

abstract interface class NotificationsRepository {
  /// Stream of notifications for a specific user
  Stream<List<NotificationEntity>> watchUserNotifications(String userId);

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId);
  
  /// Get unread count
  Stream<int> watchUnreadCount(String userId);
}
