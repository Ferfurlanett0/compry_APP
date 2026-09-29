/// Compry — Firebase Cloud Messaging Service
/// Core service for Push Notifications
library;

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../config/providers.dart';

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(
    messaging: FirebaseMessaging.instance,
    logger: ref.watch(loggerProvider),
  );
});

class FcmService {
  final FirebaseMessaging _messaging;
  final Logger _logger;
  bool _listenersInitialized = false;
  bool _authListenerInitialized = false;

  FcmService({
    required FirebaseMessaging messaging,
    required Logger logger,
  })  : _messaging = messaging,
        _logger = logger;

  /// Initializes passive listeners without opening a permission prompt.
  Future<void> initialize() async {
    _setupListeners();
    _setupAuthListener();
    final settings = await _messaging.getNotificationSettings();
    await _configureAuthorizedState(settings);
  }

  /// Must be called from an explicit user action on Web/iOS.
  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    _logger.i('User granted permission: ${settings.authorizationStatus}');
    _setupListeners();
    await _configureAuthorizedState(settings);
    return settings;
  }

  Future<void> _configureAuthorizedState(NotificationSettings settings) async {
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      try {
        final token = await _messaging.getToken();
        if (token != null) {
          await _saveToken(token);
        }
      } catch (e) {
        _logger.e('Failed to get FCM token: $e');
      }
    }
  }

  void _setupListeners() {
    if (_listenersInitialized) return;
    _listenersInitialized = true;

    _messaging.onTokenRefresh.listen((newToken) {
      _saveToken(newToken);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i('Received foreground message: ${message.notification?.title}');
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _setupAuthListener() {
    if (_authListenerInitialized) return;
    _authListenerInitialized = true;
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) return;
      final settings = await _messaging.getNotificationSettings();
      await _configureAuthorizedState(settings);
    });
  }

  Future<void> _saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fcmToken': token,
        'fcmTokens': FieldValue.arrayUnion([token]),
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Token de notificação atualizado para ${user.uid}.');
    } catch (error) {
      _logger.w('Não foi possível salvar o token de notificação: $error');
    }
  }
}
