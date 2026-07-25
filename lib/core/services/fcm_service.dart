/// Compry — Firebase Cloud Messaging Service
/// Core service for Push Notifications
library;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../config/providers.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  // await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(
    messaging: FirebaseMessaging.instance,
    authRepo: ref.watch(authRepositoryProvider),
    logger: ref.watch(loggerProvider),
  );
});

class FcmService {
  final FirebaseMessaging _messaging;
  final AuthRepository _authRepo;
  final Logger _logger;

  FcmService({
    required FirebaseMessaging messaging,
    required AuthRepository authRepo,
    required Logger logger,
  })  : _messaging = messaging,
        _authRepo = authRepo,
        _logger = logger;

  Future<void> initialize() async {
    // 1. Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    _logger.i('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      
      // 2. Get FCM token
      try {
        final token = await _messaging.getToken();
        if (token != null) {
          _logger.i('FCM Token: $token');
          // We can save the token to the user document when they log in.
          // For now, authRepo manages the auth state, so it will update it.
        }
      } catch (e) {
        _logger.e('Failed to get FCM token: $e');
      }

      // 3. Listen to token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _logger.i('FCM Token Refreshed: $newToken');
        // _authRepo.updateFcmToken(newToken); // Assuming this method exists
      });

      // 4. Setup foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.i('Received foreground message: ${message.notification?.title}');
        // Here we could show a local notification or snackbar if we wanted
      });

      // 5. Setup background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }
  }
}
