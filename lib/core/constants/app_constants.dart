/// Compry — Application Constants
/// PRD Part 1 (Glossário) + Part 2 (Requisitos)
library;

abstract final class AppConstants {
  // App info
  static const String appName = 'Compry';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Firestore collections
  static const String colUsers = 'users';
  static const String colShoppingLists = 'shopping_lists';
  static const String colShoppingItems = 'items'; // subcollection
  static const String colNotifications = 'notifications';
  static const String colAuditLogs = 'audit_logs';

  // Hive boxes
  static const String hiveBoxUsers = 'users_box';
  static const String hiveBoxLists = 'shopping_lists_box';
  static const String hiveBoxItems = 'shopping_items_box';
  static const String hiveBoxOfflineQueue = 'offline_queue_box';
  static const String hiveBoxSettings = 'settings_box';

  // Secure storage keys
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyFcmToken = 'fcm_token';

  // Hive type IDs
  static const int hiveTypeUser = 0;
  static const int hiveTypeShoppingList = 1;
  static const int hiveTypeShoppingItem = 2;
  static const int hiveTypeOfflineOperation = 3;

  // FCM topics
  static const String fcmTopicAdmin = 'admin_notifications';
  static const String fcmTopicAll = 'all_notifications';

  // Performance targets (ms)
  static const int perfLoginMs = 2000;
  static const int perfHomeMs = 2000;
  static const int perfListMs = 1000;
  static const int perfMarkItemMs = 300;

  // Pagination
  static const int pageSize = 20;
  static const int maxItemsPerList = 500;

  // Offline queue
  static const int maxOfflineQueueSize = 1000;
  static const int syncRetryMaxAttempts = 3;
  static const Duration syncRetryDelay = Duration(seconds: 5);

  // UI
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration debounceDelay = Duration(milliseconds: 300);
}

/// List priority values matching Firestore
abstract final class AppPriority {
  static const String low = 'LOW';
  static const String medium = 'MEDIUM';
  static const String high = 'HIGH';
  static const String urgent = 'URGENT';
}

/// List status values matching Firestore
abstract final class AppStatus {
  static const String draft = 'DRAFT';
  static const String pending = 'PENDING';
  static const String inProgress = 'IN_PROGRESS';
  static const String finished = 'FINISHED';
  static const String cancelled = 'CANCELLED';
}

/// User roles matching Firestore
abstract final class AppRoles {
  static const String admin = 'ADMIN';
  static const String employee = 'EMPLOYEE';
}

/// Audit log actions
abstract final class AppAuditActions {
  static const String login = 'LOGIN';
  static const String logout = 'LOGOUT';
  static const String createList = 'CREATE_LIST';
  static const String editList = 'EDIT_LIST';
  static const String sendList = 'SEND_LIST';
  static const String cancelList = 'CANCEL_LIST';
  static const String finalizeList = 'FINALIZE_LIST';
  static const String addItem = 'ADD_ITEM';
  static const String editItem = 'EDIT_ITEM';
  static const String deleteItem = 'DELETE_ITEM';
  static const String checkItem = 'CHECK_ITEM';
  static const String uncheckItem = 'UNCHECK_ITEM';
  static const String syncSuccess = 'SYNC_SUCCESS';
  static const String syncError = 'SYNC_ERROR';
  static const String conflictResolved = 'CONFLICT_RESOLVED';
}

/// Item units matching Firestore
abstract final class AppItemUnits {
  static const String unit = 'UNIDADE';
  static const String kg = 'KG';
  static const String g = 'G';
  static const String l = 'L';
  static const String ml = 'ML';
  static const String box = 'CAIXA';
  static const String package = 'PACOTE';
  static const String bale = 'FARDO';
  static const String tray = 'BANDEJA';
  static const String bag = 'SACO';
  static const String other = 'OUTRO';
}

/// Default categories (PRD RF-008)
abstract final class AppCategories {
  static const List<String> defaults = [
    'Açougue',
    'Hortifruti',
    'Padaria',
    'Bebidas',
    'Limpeza',
    'Descartáveis',
    'Congelados',
    'Temperos',
    'Laticínios',
    'Mercearia',
    'Outros',
  ];
}
