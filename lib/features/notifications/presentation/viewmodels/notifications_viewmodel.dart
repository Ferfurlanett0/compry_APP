/// Compry — Notifications ViewModel
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/providers.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../domain/entities/notification_entity.dart';

final notificationsProvider = StreamProvider<List<NotificationEntity>>((ref) {
  final authState = ref.watch(authViewModelProvider);
  final repo = ref.watch(notificationsRepositoryProvider);
  
  if (authState is AuthAuthenticated) {
    return repo.watchUserNotifications(authState.user.id);
  }
  
  return Stream.value([]);
});

final unreadCountProvider = StreamProvider<int>((ref) {
  final authState = ref.watch(authViewModelProvider);
  final repo = ref.watch(notificationsRepositoryProvider);
  
  if (authState is AuthAuthenticated) {
    return repo.watchUnreadCount(authState.user.id);
  }
  
  return Stream.value(0);
});
