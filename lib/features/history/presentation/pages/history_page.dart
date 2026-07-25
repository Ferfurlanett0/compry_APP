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
                itemCount: lists.length,
                itemBuilder: (context, index) => ListCard(
                  list: lists[index],
                  index: index,
                  onTap: () => context.push(
                    AppRoutes.listDetailPath(lists[index].id),
                  ),
                ),
              ),
      ),
    );
  }
}
