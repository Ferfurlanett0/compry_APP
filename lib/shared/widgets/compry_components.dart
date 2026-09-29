import 'package:flutter/material.dart';

import '../../core/theme/app_dimensions.dart';
import '../../core/utils/app_date_time.dart';
import '../../features/shopping_lists/domain/entities/shopping_list_entity.dart';

class CompryResponsiveBody extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CompryResponsiveBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.spaceMD),
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class CompryPageHeader extends StatelessWidget {
  final String title;
  final String? label;
  final Widget? trailing;

  const CompryPageHeader({
    super.key,
    required this.title,
    this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null) ...[
                  Text(
                    label!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class ComprySectionHeader extends StatelessWidget {
  final String title;
  final String? count;

  const ComprySectionHeader({super.key, required this.title, this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (count != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                count!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onPrimaryContainer,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class CompryHandoffTimeline extends StatelessWidget {
  final ListStatus status;

  const CompryHandoffTimeline({super.key, required this.status});

  int get _activeIndex => switch (status) {
        ListStatus.draft => 0,
        ListStatus.pending => 1,
        ListStatus.inProgress => 2,
        ListStatus.finished => 3,
        ListStatus.cancelled => 0,
      };

  @override
  Widget build(BuildContext context) {
    const labels = ['Montando', 'Enviada', 'Em compra', 'Concluída'];
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(labels.length, (index) {
        final completed = index <= _activeIndex;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index == 0
                          ? Colors.transparent
                          : (index <= _activeIndex
                              ? cs.primary
                              : cs.outlineVariant),
                    ),
                  ),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completed ? cs.primary : cs.outlineVariant,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index == labels.length - 1
                          ? Colors.transparent
                          : (index < _activeIndex
                              ? cs.primary
                              : cs.outlineVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  labels[index],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: index == _activeIndex
                            ? cs.primary
                            : cs.onSurfaceVariant,
                        fontWeight: index == _activeIndex
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class CompryTimestampPair extends StatelessWidget {
  final DateTime? sentAt;
  final DateTime? receivedAt;
  final bool compact;

  const CompryTimestampPair({
    super.key,
    required this.sentAt,
    required this.receivedAt,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (sentAt == null && receivedAt == null) return const SizedBox.shrink();
    // Legacy records predate `receivedAt`; their server send time is the
    // safest available fallback. New records persist both timestamps.
    final effectiveReceivedAt = receivedAt ?? sentAt;
    final cs = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: cs.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    if (compact) {
      final value = effectiveReceivedAt!;
      return Text(
        'Recebida ${AppDateTime.relative(value)}',
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sentAt != null)
          Text('Enviada: ${AppDateTime.full(sentAt!)}', style: style),
        if (effectiveReceivedAt != null) ...[
          const SizedBox(height: 3),
          Text(
            'Recebida: ${AppDateTime.full(effectiveReceivedAt)}',
            style: style,
          ),
        ],
      ],
    );
  }
}
