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
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/services/pwa_install_service.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  void _showAvatarPicker(BuildContext context, WidgetRef ref, UserEntity user) {
    final availableAvatars = [
      'Perfil administrador',
      'Perfil churrasqueiro',
      'Perfil cozinheira',
      'Perfil garconete',
    ];

    final Map<String, String> avatarLabels = {
      'Perfil administrador': 'Administrador',
      'Perfil churrasqueiro': 'Churrasqueiro',
      'Perfil cozinheira': 'Cozinheira',
      'Perfil garconete': 'Garçonete',
    };

    showDialog(
      context: context,
      builder: (dialogContext) {
        String selected = user.avatar ??
            (user.isAdmin ? 'Perfil administrador' : 'Perfil churrasqueiro');
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(dialogContext);
            final cs = theme.colorScheme;

            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(AppDimensions.spaceXL),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Foto de Perfil',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              'Escolha seu personagem de perfil',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: IconButton.styleFrom(
                            backgroundColor: cs.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppDimensions.spaceXL),

                    // Avatars Grid/Row
                    Wrap(
                      spacing: AppDimensions.spaceLG,
                      runSpacing: AppDimensions.spaceLG,
                      alignment: WrapAlignment.center,
                      children: availableAvatars.map((avatar) {
                        final isSelected = avatar == selected;
                        final label = avatarLabels[avatar] ?? '';
                        return GestureDetector(
                          onTap: () => setState(() => selected = avatar),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cs.primaryContainer,
                                  border: Border.all(
                                    color: isSelected
                                        ? cs.primary
                                        : Colors.transparent,
                                    width: isSelected ? 3.5 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: cs.primary
                                                .withValues(alpha: 0.4),
                                            blurRadius: 14,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : [],
                                ),
                                child: Stack(
                                  children: [
                                    ClipOval(
                                      child: Image.asset(
                                        'assets/images/$avatar.png',
                                        fit: BoxFit.cover,
                                        width: 76,
                                        height: 76,
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        right: 2,
                                        top: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: cs.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: cs.surface, width: 2),
                                          ),
                                          child: Icon(
                                            Icons.check_rounded,
                                            size: 14,
                                            color: cs.onPrimary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Gap(AppDimensions.spaceXS),
                              Text(
                                label,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? cs.primary
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const Gap(AppDimensions.spaceXXL),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMD),
                              ),
                              side: BorderSide(color: cs.outlineVariant),
                            ),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: Text(
                              'Cancelar',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const Gap(AppDimensions.spaceMD),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMD),
                              ),
                            ),
                            onPressed: () {
                              ref
                                  .read(authViewModelProvider.notifier)
                                  .updateAvatar(selected);
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Foto de perfil atualizada com sucesso!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Text(
                              'Salvar',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: cs.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

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
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
                GestureDetector(
                  onTap: () => _showAvatarPicker(context, ref, currentUser),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primaryContainer,
                          gradient: LinearGradient(
                            colors: [
                              cs.primary.withValues(alpha: 0.25),
                              cs.primary.withValues(alpha: 0.1),
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
                            currentUser.avatarPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: cs.primary.withValues(alpha: 0.1),
                              child: Center(
                                child: Icon(
                                  currentUser.isAdmin
                                      ? Icons.admin_panel_settings_rounded
                                      : Icons.person_rounded,
                                  color: cs.primary,
                                  size: 60,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.surface, width: 2),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: cs.onPrimary,
                          ),
                        ),
                      ),
                    ],
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                    border:
                        Border.all(color: cs.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        currentUser.isAdmin
                            ? Icons.admin_panel_settings_rounded
                            : Icons.badge_rounded,
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
              border:
                  Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
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
                Divider(
                    height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
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
              border:
                  Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
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
                  Divider(
                      height: 1,
                      color: cs.outlineVariant.withValues(alpha: 0.5)),
                ],
                _PremiumActionTile(
                  icon: Icons.add_to_home_screen_rounded,
                  title: 'Instalar App',
                  onTap: () {
                    final installed = PwaInstallService.tryInstall();
                    if (!installed) {
                      _showQuickInstallGuide(context);
                    }
                  },
                ),
                Divider(
                    height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
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
                        content:
                            const Text('Deseja realmente sair do aplicativo?'),
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
              'Compry v${AppConstants.appVersion}',
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

  void _showQuickInstallGuide(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottomPadding = MediaQuery.of(ctx).viewInsets.bottom +
            MediaQuery.of(ctx).padding.bottom +
            24;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Handle ─────────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Gap(20),

                // ─── Header ─────────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.add_to_home_screen_rounded,
                          color: cs.primary, size: 28),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Instalar no iPhone / iPad',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'Safari, Chrome e outros navegadores',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.primary, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(16),

                // ─── Instruções ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A Apple não permite instalação automática no iPhone. Para instalar:',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(height: 1.4, color: cs.onSurface),
                      ),
                      const Gap(12),
                      _InstallStep(
                        cs: cs,
                        theme: theme,
                        emoji: '📤',
                        label: 'No Safari',
                        instruction: 'Toque em Compartilhar na barra inferior',
                      ),
                      const Gap(8),
                      _InstallStep(
                        cs: cs,
                        theme: theme,
                        emoji: '⋯',
                        label: 'No Chrome',
                        instruction:
                            'Toque em Compartilhar (topo) ou menu (...)',
                      ),
                      const Gap(12),
                      Row(
                        children: [
                          Icon(Icons.add_box_rounded,
                              color: cs.primary, size: 18),
                          const Gap(6),
                          Expanded(
                            child: Text(
                              'Selecione "Adicionar à Tela de Início"',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(20),

                // ─── Botão ──────────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Entendi, vou adicionar',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Install Step Widget ───────────────────────────────────────────────────────

class _InstallStep extends StatelessWidget {
  final ColorScheme cs;
  final ThemeData theme;
  final String emoji;
  final String label;
  final String instruction;

  const _InstallStep({
    required this.cs,
    required this.theme,
    required this.emoji,
    required this.label,
    required this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 14)),
        ),
        const Gap(10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium
                  ?.copyWith(height: 1.4, color: cs.onSurface),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                TextSpan(text: instruction),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Premium Info Tile ────────────────────────────────────────────────────────

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
