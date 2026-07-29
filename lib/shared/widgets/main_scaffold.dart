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
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

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
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: _PremiumBottomNav(
        navigationShell: navigationShell,
        isAdmin: isAdmin,
        isDark: isDark,
      ),
    );
  }
}

// ─── Premium Bottom Navigation ────────────────────────────────────────────────

class _PremiumBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final bool isAdmin;
  final bool isDark;

  const _PremiumBottomNav({
    required this.navigationShell,
    required this.isAdmin,
    required this.isDark,
  });

  int _currentIndex() {
    final branch = navigationShell.currentIndex;
    if (isAdmin) return branch;
    if (branch == 3) return 2; // Map profile branch (3) to tab index (2) for non-admin
    return branch;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex();
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
        navigationShell.goBranch(idx, initialLocation: idx == navigationShell.currentIndex);
      } else {
        final targetBranch = idx == 2 ? 3 : idx;
        navigationShell.goBranch(targetBranch, initialLocation: targetBranch == navigationShell.currentIndex);
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
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceSM),
          child: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: onTap,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: cs.primaryContainer,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: destinations,
          ),
        ),
      ),
    );
  }

  NavigationDestination _navDest(IconData icon, IconData activeIcon, String label) {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(activeIcon),
      label: label,
    );
  }
}
