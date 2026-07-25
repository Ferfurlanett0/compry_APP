/// Compry — App Routes
/// Navigation structure using GoRouter
/// PRD Part 4, Section 31
library;

abstract final class AppRoutes {
  // Auth
  static const String login = '/login';
  static const String changePassword = '/change-password';

  // Root
  static const String home = '/home';

  // Lists
  static const String createList = '/lists/create';
  static const String listDetail = '/lists/:listId';
  static const String editList = '/lists/:listId/edit';

  // Items
  static const String addItem = '/lists/:listId/items/add';
  static const String editItem = '/lists/:listId/items/:itemId/edit';

  // History
  static const String history = '/history';
  static const String historyDetail = '/history/:listId';

  // Notifications
  static const String notifications = '/notifications';

  // Profile
  static const String profile = '/profile';
  static const String employees = '/employees';

  // Helpers
  static String listDetailPath(String listId) => '/lists/$listId';
  static String editListPath(String listId) => '/lists/$listId/edit';
  static String addItemPath(String listId) => '/lists/$listId/items/add';
  static String editItemPath(String listId, String itemId) =>
      '/lists/$listId/items/$itemId/edit';
  static String historyDetailPath(String listId) => '/history/$listId';
}
