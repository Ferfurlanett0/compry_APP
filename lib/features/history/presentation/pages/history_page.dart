/// Compry — History Page (RF-027, RF-028)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_routes.dart';
import '../../../../core/config/providers.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../../shopping_lists/domain/entities/shopping_list_entity.dart';
import '../../../shopping_lists/domain/usecases/shopping_list_usecases.dart';
import '../../../shopping_lists/presentation/widgets/list_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/skeleton_loaders.dart';

final historyProvider =
    FutureProvider.autoDispose<List<ShoppingListEntity>>((ref) async {
  final repository = ref.watch(shoppingListRepositoryProvider);
  final currentUser = ref.read(currentUserProvider);

  return GetFilteredListsUseCase(repository).call(GetFilteredListsParams(
    userId: currentUser?.isAdmin == true ? null : currentUser?.id,
    status: ListStatus.finished,
  ));
});

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              // TODO: implement filter bottom sheet
            },
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const SingleChildScrollView(child: ListCardSkeletonList()),
        error: (err, _) => ErrorState(message: err.toString()),
        data: (lists) => lists.isEmpty
            ? const EmptyState(
                icon: Icons.history_rounded,
                title: 'Sem histórico',
                message:
                    'Listas finalizadas aparecerão aqui.',
              )
            : ListView.builder(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 76 + 12,
                ),
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  final list = lists[index];
                  final currentUser = ref.read(currentUserProvider);
                  final isAdmin = currentUser?.isAdmin ?? false;

                  return isAdmin
                      ? Dismissible(
                          key: ValueKey(list.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                          ),
                          confirmDismiss: (_) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Excluir Lista'),
                                content: const Text('Tem certeza que deseja excluir esta lista? Esta ação não pode ser desfeita.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true), 
                                    style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (_) async {
                            try {
                              final repository = ref.read(shoppingListRepositoryProvider);
                              await DeleteListUseCase(repository).call(
                                DeleteListParams(listId: list.id, isAdmin: isAdmin),
                              );
                              ref.invalidate(historyProvider);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('🗑️ Lista excluída com sucesso!')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro: $e')),
                              );
                            }
                          },
                          child: ListCard(
                            list: list,
                            index: index,
                            onTap: () => context.push(AppRoutes.listDetailPath(list.id)),
                          ),
                        )
                      : ListCard(
                          list: list,
                          index: index,
                          onTap: () => context.push(AppRoutes.listDetailPath(list.id)),
                        );
                },
              ),
      ),
    );
  }
}
