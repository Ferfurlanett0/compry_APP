/// Compry — Premium Profile Page (UC-010)
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/config/providers.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/services/pwa_install_service.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final authState = ref.watch(authViewModelProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (currentUser == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePadding,
          vertical: AppDimensions.spaceMD,
        ),
        children: [
          // ─── Premium Avatar Section ───────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withValues(alpha: 0.15),
                        cs.primary.withValues(alpha: 0.02),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.4),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                      child: ClipOval(
                        child: Image.asset(
                          currentUser.isAdmin ? 'assets/images/administrador.png' : 'assets/images/funcionario.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: cs.primary.withValues(alpha: 0.1),
                            child: Center(
                              child: Icon(
                                currentUser.isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                                color: cs.primary,
                                size: 60,
                              ),
                            ),
                          ),
                        ),
                      ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                
                const Gap(AppDimensions.spaceLG),
                
                Text(
                  currentUser.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                
                const Gap(AppDimensions.spaceXXS),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        currentUser.isAdmin ? Icons.admin_panel_settings_rounded : Icons.badge_rounded,
                        size: 14,
                        color: cs.onPrimaryContainer,
                      ),
                      const Gap(6),
                      Text(
                        currentUser.isAdmin ? 'Administrador' : 'Funcionário',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              ],
            ),
          ),

          const Gap(AppDimensions.spaceXXXL),

          // ─── Info Section ───────────────────────────────────────────────────
          Text(
            'Informações',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const Gap(AppDimensions.spaceSM),
          
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              children: [
                _PremiumInfoTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Usuário',
                  value: currentUser.username,
                ),
                Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
                _PremiumInfoTile(
                  icon: Icons.badge_outlined,
                  title: 'Perfil',
                  value: currentUser.isAdmin ? 'Administrador' : 'Funcionário',
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

          const Gap(AppDimensions.spaceXL),

          // ─── Settings Section ───────────────────────────────────────────────
          Text(
            'Configurações',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 500.ms),
          const Gap(AppDimensions.spaceSM),

          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              children: [
                if (currentUser.isAdmin) ...[
                  _PremiumActionTile(
                    icon: Icons.people_outline_rounded,
                    title: 'Gerenciar Funcionários',
                    onTap: () => context.push('/employees'),
                  ),
                  Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
                ],
                _PremiumActionTile(
                  icon: Icons.add_to_home_screen_rounded,
                  title: 'Instalar App',
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Instalar o Compry'),
                        content: const Text('Deseja instalar o aplicativo na sua tela inicial para acesso rápido e em tela cheia?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Sim, Instalar'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      final installedInstantly = PwaInstallService.tryInstall();
                      if (!installedInstantly) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'No iPhone/iOS: Toque em Compartilhar 📤 e selecione "Adicionar à Tela de Início" ➕.',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: cs.primary,
                            duration: const Duration(seconds: 6),
                          ),
                        );
                      }
                    }
                  },
                ),
                Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
                _ThemeToggleTile(ref: ref),
              ],
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

          const Gap(AppDimensions.spaceXXXL),

          // ─── Logout ─────────────────────────────────────────────────────────
          AppButton(
            id: 'btn-logout',
            label: 'Sair da Conta',
            onPressed: authState is AuthLoading
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sair da conta'),
                        content: const Text('Deseja realmente sair do aplicativo?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: cs.error,
                              foregroundColor: cs.onError,
                            ),
                            child: const Text('Sair'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(authViewModelProvider.notifier).logout();
                    }
                  },
            outlined: true,
            danger: true,
            icon: Icons.logout_rounded,
          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),

          const Gap(AppDimensions.spaceXXL),

          Center(
            child: Text(
              'Compry v1.0.0',
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ).animate().fadeIn(delay: 800.ms),
        ],
      ),
    );
  }
}

class _PremiumInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _PremiumInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMD,
            vertical: AppDimensions.spaceMD,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Icon(icon, color: cs.primary, size: 20),
              ),
              const Gap(AppDimensions.spaceMD),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleTile extends StatelessWidget {
  final WidgetRef ref;

  const _ThemeToggleTile({required this.ref});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentMode = ref.watch(themeModeProvider);
    final isDark = currentMode == ThemeMode.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
          ref.read(themeModeProvider.notifier).state = nextMode;
          final box = Hive.box(AppConstants.hiveBoxSettings);
          await box.put('themeMode', nextMode.name);
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMD,
            vertical: AppDimensions.spaceMD,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: isDark ? Colors.indigoAccent : Colors.orange,
                  size: 20,
                ).animate(target: isDark ? 1 : 0).rotate(duration: 300.ms),
              ),
              const Gap(AppDimensions.spaceMD),
              Text(
                'Tema Escuro',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Switch(
                value: isDark,
                onChanged: (val) async {
                  final nextMode = val ? ThemeMode.dark : ThemeMode.light;
                  ref.read(themeModeProvider.notifier).state = nextMode;
                  final box = Hive.box(AppConstants.hiveBoxSettings);
                  await box.put('themeMode', nextMode.name);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _PremiumActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMD,
            vertical: AppDimensions.spaceMD,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Icon(icon, color: cs.primary, size: 24),
              ),
              const Gap(AppDimensions.spaceMD),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
