import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/providers.dart';
import '../../../../core/utils/app_date_time.dart';
import '../../../../shared/widgets/compry_components.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../domain/entities/notification_entity.dart';
import '../viewmodels/notifications_viewmodel.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: CompryPageHeader(
          label: 'Atualizações',
          title: 'Avisos',
          trailing:
              notificationsAsync.valueOrNull?.any((item) => !item.read) == true
                  ? TextButton(
                      onPressed: user == null
                          ? null
                          : () => ref
                              .read(notificationsRepositoryProvider)
                              .markAllAsRead(user.id),
                      child: const Text('Marcar como lidos'),
                    )
                  : null,
        ),
        toolbarHeight: 78,
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'Tudo acompanhado',
              message:
                  'Envios, compras iniciadas e conclusões aparecerão aqui.',
            );
          }

          final today = notifications
              .where((item) =>
                  AppDateTime.isSameLocalDay(item.createdAt, DateTime.now()))
              .toList();
          final previous = notifications
              .where((item) =>
                  !AppDateTime.isSameLocalDay(item.createdAt, DateTime.now()))
              .toList();

          return CompryResponsiveBody(
            child: ListView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 88,
              ),
              children: [
                ComprySectionHeader(
                  title: 'O que precisa de atenção',
                  count:
                      '${notifications.where((item) => !item.read).length} novos',
                ),
                if (today.isNotEmpty) ...[
                  const _GroupLabel('Hoje'),
                  _NotificationGroup(items: today),
                ],
                if (previous.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const _GroupLabel('Anteriores'),
                  _NotificationGroup(items: previous),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Avisos indisponíveis',
          message: 'Não foi possível carregar agora. $error',
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;
  const _GroupLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
}

class _NotificationGroup extends ConsumerWidget {
  final List<NotificationEntity> items;
  const _NotificationGroup({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.symmetric(
          horizontal: BorderSide(color: cs.outlineVariant),
        ),
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _NotificationRow(
              notification: items[index],
              onTap: () async {
                if (!items[index].read) {
                  await ref
                      .read(notificationsRepositoryProvider)
                      .markAsRead(items[index].id);
                }
                if (context.mounted && items[index].listId != null) {
                  context.push('/lists/${items[index].listId}');
                }
              },
            ),
            if (index != items.length - 1)
              Divider(height: 1, indent: 58, color: cs.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationRow({required this.notification, required this.onTap});

  IconData get _icon => switch (notification.type) {
        'LIST_SENT' => Icons.shopping_basket_outlined,
        'LIST_FINISHED' => Icons.check_circle_outline_rounded,
        'LIST_STARTED' => Icons.play_circle_outline_rounded,
        _ => Icons.notifications_none_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 76),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(_icon, size: 20, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: notification.read
                                ? FontWeight.w500
                                : FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(notification.body,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 3),
                    Text(
                      AppDateTime.relative(notification.createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.read)
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
