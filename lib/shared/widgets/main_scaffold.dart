/// Compry — Premium Main Scaffold with Bottom Navigation
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_routes.dart';
import '../../core/theme/app_dimensions.dart';
import '../../features/authentication/presentation/viewmodels/auth_viewmodel.dart';
import 'offline_banner.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = currentUser?.isAdmin ?? false;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: _PremiumBottomNav(isAdmin: isAdmin, isDark: isDark),
    );
  }
}

// ─── Premium Bottom Navigation ────────────────────────────────────────────────

class _PremiumBottomNav extends StatelessWidget {
  final bool isAdmin;
  final bool isDark;

  const _PremiumBottomNav({required this.isAdmin, required this.isDark});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.history)) return 1;
    if (location.startsWith(AppRoutes.notifications) && isAdmin) return 2;
    if (location.startsWith(AppRoutes.profile)) return isAdmin ? 3 : 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final destinations = isAdmin
        ? [
            _navDest(Icons.home_outlined, Icons.home_rounded, 'Início'),
            _navDest(Icons.history_outlined, Icons.history_rounded, 'Histórico'),
            _navDest(Icons.notifications_outlined, Icons.notifications_rounded, 'Notificações'),
            _navDest(Icons.person_outline_rounded, Icons.person_rounded, 'Perfil'),
          ]
        : [
            _navDest(Icons.home_outlined, Icons.home_rounded, 'Início'),
            _navDest(Icons.history_outlined, Icons.history_rounded, 'Histórico'),
            _navDest(Icons.person_outline_rounded, Icons.person_rounded, 'Perfil'),
          ];

    void onTap(int idx) {
      if (isAdmin) {
        switch (idx) {
          case 0: context.go(AppRoutes.home);
          case 1: context.go(AppRoutes.history);
          case 2: context.go(AppRoutes.notifications);
          case 3: context.go(AppRoutes.profile);
        }
      } else {
        switch (idx) {
          case 0: context.go(AppRoutes.home);
          case 1: context.go(AppRoutes.history);
          case 2: context.go(AppRoutes.profile);
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onTap,
        destinations: destinations,
        animationDuration: const Duration(milliseconds: 350),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        height: AppDimensions.bottomNavHeight,
        elevation: 0,
      ),
    );
  }

  NavigationDestination _navDest(IconData icon, IconData selectedIcon, String label) {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon),
      label: label,
    );
  }
}
