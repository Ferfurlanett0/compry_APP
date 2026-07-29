/// Compry — App Router
/// Navigation using GoRouter — PRD Part 4, Section 31
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/app_routes.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/shopping_lists/presentation/pages/home_page.dart';
import '../../features/shopping_lists/presentation/pages/create_list_page.dart';
import '../../features/shopping_lists/presentation/pages/list_detail_page.dart';
import '../../features/shopping_lists/presentation/pages/add_item_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/employee_list_page.dart';
import '../../features/authentication/presentation/pages/change_password_page.dart';
import '../../shared/widgets/main_scaffold.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authViewModelProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authViewModelProvider);
      final isAuthenticated = authState is AuthAuthenticated;
      final requiresPasswordChange = authState is AuthRequiresPasswordChange;
      final isLoading = authState is AuthLoading || authState is AuthInitial;
      
      final isLoginRoute = state.matchedLocation == AppRoutes.login;
      final isChangePasswordRoute = state.matchedLocation == AppRoutes.changePassword;

      if (isLoading) return null;

      if (requiresPasswordChange && !isChangePasswordRoute) {
        return AppRoutes.changePassword;
      }

      if (!isAuthenticated && !requiresPasswordChange && !isLoginRoute) {
        return AppRoutes.login;
      }

      if (isAuthenticated && (isLoginRoute || isChangePasswordRoute)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // Login
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Change Password
      GoRoute(
        path: AppRoutes.changePassword,
        name: 'change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),

      // Employees List
      GoRoute(
        path: AppRoutes.employees,
        name: 'employees',
        builder: (context, state) => const EmployeeListPage(),
      ),

      // Main scaffold with bottom navigation using StatefulShellRoute for instant zero-latency tab switching
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Home Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // History Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                name: 'history',
                builder: (context, state) => const HistoryPage(),
              ),
            ],
          ),
          // Notifications Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.notifications,
                name: 'notifications',
                builder: (context, state) => const NotificationsPage(),
              ),
            ],
          ),
          // Profile Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // Create list (full screen, outside shell)
      GoRoute(
        path: AppRoutes.createList,
        name: 'create-list',
        builder: (context, state) => const CreateListPage(),
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const CreateListPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(0, 1), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOutCubic)),
              ),
              child: child,
            );
          },
        ),
      ),

      // List detail
      GoRoute(
        path: AppRoutes.listDetail,
        name: 'list-detail',
        builder: (context, state) {
          final listId = state.pathParameters['listId']!;
          return ListDetailPage(listId: listId);
        },
      ),

      // Add item
      GoRoute(
        path: AppRoutes.addItem,
        name: 'add-item',
        builder: (context, state) {
          final listId = state.pathParameters['listId']!;
          return AddItemPage(listId: listId);
        },
        pageBuilder: (context, state) {
          final listId = state.pathParameters['listId']!;
          return CustomTransitionPage(
            child: AddItemPage(listId: listId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0, 1), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              );
            },
          );
        },
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Página não encontrada', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Voltar para Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
