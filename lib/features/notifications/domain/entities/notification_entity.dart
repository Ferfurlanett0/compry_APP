/// Compry — Notification Entity
/// Domain layer
library;

class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final String type; // e.g., 'LIST_FINISHED', 'LIST_SENT'
  final bool read;
  final DateTime createdAt;
  final String? listId;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.createdAt,
    this.listId,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    bool? read,
    DateTime? createdAt,
    String? listId,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      listId: listId ?? this.listId,
    );
  }
}
