import 'package:flutter/material.dart';

import '../../../../core/extensions/priority_extensions.dart';
import '../../../../shared/widgets/compry_components.dart';
import '../../domain/entities/shopping_list_entity.dart';

class ListCard extends StatelessWidget {
  final ShoppingListEntity list;
  final VoidCallback onTap;
  final int index;

  const ListCard({
    super.key,
    required this.list,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor =
        isDark ? list.priority.colorDark() : list.priority.colorLight();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 92),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          list.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          list.priority.label,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: priorityColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded,
                          color: cs.onSurfaceVariant),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 12,
                    runSpacing: 3,
                    children: [
                      _Meta(
                        icon: Icons.list_alt_rounded,
                        label: '${list.totalItems} itens',
                      ),
                      if (list.createdByName?.isNotEmpty == true)
                        _Meta(
                          icon: Icons.person_outline_rounded,
                          label: list.createdByName!,
                        ),
                      if (list.status.isInProgress)
                        _Meta(
                          icon: Icons.check_circle_outline_rounded,
                          label: list.progressText,
                        ),
                    ],
                  ),
                  if (list.sentAt != null || list.receivedAt != null) ...[
                    const SizedBox(height: 5),
                    CompryTimestampPair(
                      sentAt: list.sentAt,
                      receivedAt: list.receivedAt,
                      compact: true,
                    ),
                  ],
                  const SizedBox(height: 9),
                  CompryHandoffTimeline(status: list.status),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Meta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
