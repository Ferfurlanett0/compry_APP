import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_routes.dart';
import '../../../../shared/widgets/compry_components.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/skeleton_loaders.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/list_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final state = ref.watch(homeViewModelProvider);
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: 78,
        title: CompryPageHeader(
          label: isAdmin ? 'Visão do responsável' : _todayLabel(),
          title: isAdmin ? 'Central de compras' : 'Minhas listas',
          trailing: _HomeAvatar(user: user),
        ),
      ),
      body: switch (state) {
        HomeInitial() || HomeLoading() => const ListCardSkeletonList(count: 4),
        HomeError(:final message) => EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Listas indisponíveis',
            message: message,
          ),
        HomeLoaded() =>
          isAdmin ? _AdminCentral(state: state) : _EmployeeLists(state: state),
      },
    );
  }

  static String _todayLabel() {
    const weekdays = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${now.day}';
  }
}

class _HomeAvatar extends StatelessWidget {
  final UserEntity? user;

  const _HomeAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final avatarPath = user?.avatarPath;
    final initials = user?.initials ?? 'C';

    Widget fallback() => ColoredBox(
          color: cs.primaryContainer,
          child: Center(
            child: Text(
              initials,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        );

    return Semantics(
      image: true,
      label: 'Foto de perfil de ${user?.name ?? 'Compry'}',
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.surface,
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.28),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: avatarPath == null
              ? fallback()
              : Image.asset(
                  avatarPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => fallback(),
                ),
        ),
      ),
    );
  }
}

class _EmployeeLists extends ConsumerWidget {
  final HomeLoaded state;
  const _EmployeeLists({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts =
        state.filteredLists.where((list) => list.status.isDraft).toList();
    final active =
        state.filteredLists.where((list) => !list.status.isDraft).toList();

    return CompryResponsiveBody(
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 88,
      ),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: () => context.push(AppRoutes.createList),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nova lista'),
            ),
          ),
          const SizedBox(height: 18),
          if (drafts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ComprySectionHeader(
                title: 'Continue preenchendo',
                count:
                    '${drafts.length} ${drafts.length == 1 ? 'rascunho' : 'rascunhos'}',
              ),
            ),
            for (var index = 0; index < drafts.length; index++)
              ListCard(
                list: drafts[index],
                index: index,
                onTap: () => context.push('/lists/${drafts[index].id}'),
              ),
          ],
          if (active.isNotEmpty) ...[
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ComprySectionHeader(
                title: 'Acompanhe o andamento',
                count: '${active.length} ativas',
              ),
            ),
            for (var index = 0; index < active.length; index++)
              ListCard(
                list: active[index],
                index: index,
                onTap: () => context.push('/lists/${active[index].id}'),
              ),
          ],
          if (drafts.isEmpty && active.isEmpty)
            EmptyState(
              icon: Icons.playlist_add_rounded,
              title: 'Comece sua primeira lista',
              message: 'Adicione os produtos e envie quando estiver pronta.',
              actionLabel: 'Criar lista',
              onAction: () => context.push(AppRoutes.createList),
            ),
        ],
      ),
    );
  }
}

class _AdminCentral extends StatelessWidget {
  final HomeLoaded state;
  const _AdminCentral({required this.state});

  @override
  Widget build(BuildContext context) {
    final pending = state.pendingLists;
    final inProgress = state.inProgressLists;
    final itemCount =
        pending.fold<int>(0, (sum, list) => sum + list.totalItems);
    final cs = Theme.of(context).colorScheme;

    return CompryResponsiveBody(
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 88,
      ),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF163E26),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${pending.length} ${pending.length == 1 ? 'lista esperando' : 'listas esperando'} você',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$itemCount itens prontos para iniciar',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFFC8DECF),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    child: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (pending.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _LaneTitle(
                title: 'Prontas para compra',
                color: cs.tertiary,
              ),
            ),
            for (var index = 0; index < pending.length; index++)
              ListCard(
                list: pending[index],
                index: index,
                onTap: () => context.push('/lists/${pending[index].id}'),
              ),
          ],
          if (inProgress.isNotEmpty) ...[
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _LaneTitle(title: 'Em compra agora', color: cs.primary),
            ),
            for (var index = 0; index < inProgress.length; index++)
              ListCard(
                list: inProgress[index],
                index: index,
                onTap: () => context.push('/lists/${inProgress[index].id}'),
              ),
          ],
          if (pending.isEmpty && inProgress.isEmpty)
            const EmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: 'Nenhuma compra pendente',
              message: 'As próximas listas enviadas aparecerão nesta central.',
            ),
        ],
      ),
    );
  }
}

class _LaneTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _LaneTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 7),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      );
}
