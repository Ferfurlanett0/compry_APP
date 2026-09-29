/// Compry — Premium Main Scaffold with Bottom Navigation
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_dimensions.dart';
import '../../features/authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/notifications/presentation/viewmodels/notifications_viewmodel.dart';
import 'offline_banner.dart';

class MainScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = currentUser?.isAdmin ?? false;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unreadCount = ref.watch(unreadCountProvider).valueOrNull ?? 0;

    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: _PremiumBottomNav(
        navigationShell: navigationShell,
        isAdmin: isAdmin,
        isDark: isDark,
        unreadCount: unreadCount,
      ),
    );
  }
}

// ─── Premium Bottom Navigation ────────────────────────────────────────────────

class _PremiumBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final bool isAdmin;
  final bool isDark;
  final int unreadCount;

  const _PremiumBottomNav({
    required this.navigationShell,
    required this.isAdmin,
    required this.isDark,
    required this.unreadCount,
  });

  int _currentIndex() {
    final branch = navigationShell.currentIndex;
    if (isAdmin) return branch;
    if (branch == 3) {
      return 2; // Map profile branch (3) to tab index (2) for non-admin
    }
    return branch;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex();
    final destinations = isAdmin
        ? [
            _navDest(
                Icons.dashboard_outlined, Icons.dashboard_rounded, 'Central'),
            _navDest(
                Icons.history_outlined, Icons.history_rounded, 'Histórico'),
            _navDest(
              Icons.notifications_outlined,
              Icons.notifications_rounded,
              'Avisos',
              badge: unreadCount,
            ),
            _navDest(
                Icons.person_outline_rounded, Icons.person_rounded, 'Perfil'),
          ]
        : [
            _navDest(Icons.list_alt_outlined, Icons.list_alt_rounded, 'Listas'),
            _navDest(
                Icons.history_outlined, Icons.history_rounded, 'Histórico'),
            _navDest(
                Icons.person_outline_rounded, Icons.person_rounded, 'Perfil'),
          ];

    void onTap(int idx) {
      if (isAdmin) {
        navigationShell.goBranch(idx,
            initialLocation: idx == navigationShell.currentIndex);
      } else {
        final targetBranch = idx == 2 ? 3 : idx;
        navigationShell.goBranch(targetBranch,
            initialLocation: targetBranch == navigationShell.currentIndex);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17251B),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.spaceSM),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? Colors.white : Colors.white60,
                    );
              }),
            ),
            child: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: onTap,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: Colors.white.withValues(alpha: 0.12),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: destinations,
            ),
          ),
        ),
      ),
    );
  }

  NavigationDestination _navDest(
    IconData icon,
    IconData activeIcon,
    String label, {
    int badge = 0,
  }) {
    Widget wrap(Widget child) => badge > 0
        ? Badge(label: Text(badge > 99 ? '99+' : '$badge'), child: child)
        : child;
    return NavigationDestination(
      icon: wrap(Icon(icon, color: Colors.white70)),
      selectedIcon: wrap(Icon(activeIcon, color: Colors.white)),
      label: label,
    );
  }
}
