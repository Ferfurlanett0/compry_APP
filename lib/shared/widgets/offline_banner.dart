/// Compry — Offline Banner (RF-033)
/// Exibido quando sem internet — banner amarelo no topo
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/config/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(isConnectedProvider);

    return connectivityAsync.when(
      data: (isConnected) {
        if (isConnected) return const SizedBox.shrink();
        return _buildBanner(context);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppDimensions.offlineBannerHeight,
      color: AppColorsLight.offline,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: AppDimensions.iconSM,
            color: AppColorsLight.offlineText,
          ),
          const Gap(AppDimensions.spaceXS),
          Text(
            'Modo Offline — as alterações serão sincronizadas automaticamente',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColorsLight.offlineText,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -1, end: 0, curve: Curves.easeOutCubic);
  }
}

/// Banner de sincronização discreto no topo (RF-035)
class SyncingIndicator extends StatelessWidget {
  final bool isSyncing;

  const SyncingIndicator({super.key, required this.isSyncing});

  @override
  Widget build(BuildContext context) {
    if (!isSyncing) return const SizedBox.shrink();

    return Container(
      height: 2,
      child: LinearProgressIndicator(
        backgroundColor: Colors.transparent,
        color: Theme.of(context).colorScheme.primary,
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
