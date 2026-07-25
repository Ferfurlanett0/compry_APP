/// Compry — Premium Empty State Widget
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_dimensions.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with glowing background
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surface,
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 48,
                color: cs.primary.withValues(alpha: 0.8),
              ),
            ),

            const Gap(AppDimensions.spaceXXL),

            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const Gap(AppDimensions.spaceSM),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceXL),
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            if (actionLabel != null && onAction != null) ...[
              const Gap(AppDimensions.spaceXXL),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceXL,
                    vertical: AppDimensions.spaceMD,
                  ),
                ),
              ),
            ],
          ],
        )
            .animate()
            .fadeIn(duration: 500.ms, curve: Curves.easeOut)
            .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
      ),
    );
  }
}

class NoListsEmptyState extends StatelessWidget {
  final VoidCallback? onCreateList;

  const NoListsEmptyState({super.key, this.onCreateList});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.assignment_rounded,
      title: 'Nenhuma lista ainda',
      message: 'Crie sua primeira lista de compras para começar a se organizar.',
      actionLabel: onCreateList != null ? 'Nova Lista' : null,
      onAction: onCreateList,
    );
  }
}

class NoItemsEmptyState extends StatelessWidget {
  final VoidCallback? onAddItem;

  const NoItemsEmptyState({super.key, this.onAddItem});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.shopping_basket_rounded,
      title: 'Lista Vazia',
      message: 'Esta lista ainda não possui itens. Adicione os produtos que deseja comprar.',
      actionLabel: onAddItem != null ? 'Adicionar Item' : null,
      onAction: onAddItem,
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Ocorreu um erro',
      message: message,
      actionLabel: onRetry != null ? 'Tentar novamente' : null,
      onAction: onRetry,
    );
  }
}
