/// Compry — Home ViewModel
/// Presentation layer — manages home screen state for both roles
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/shopping_list_entity.dart';
import '../../domain/usecases/shopping_list_usecases.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../../../core/config/providers.dart';

// ─── Home State ───────────────────────────────────────────────────────────────

sealed class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<ShoppingListEntity> allLists;
  final String searchQuery;
  final ListStatus? statusFilter;

  const HomeLoaded({
    required this.allLists,
    this.searchQuery = '',
    this.statusFilter,
  });

  List<ShoppingListEntity> get filteredLists {
    // Esconde listas finalizadas ou canceladas da tela de início (aparecem só no Histórico)
    var lists = allLists.where((l) => l.status.isActive).toList();

    if (statusFilter != null) {
      lists = lists.where((l) => l.status == statusFilter).toList();
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      lists = lists
          .where((l) =>
              l.title.toLowerCase().contains(q) ||
              (l.category?.toLowerCase().contains(q) ?? false) ||
              (l.createdByName?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return lists;
  }

  List<ShoppingListEntity> get activeLists =>
      filteredLists.where((l) => l.status.isActive).toList();

  List<ShoppingListEntity> get finishedLists =>
      filteredLists.where((l) => l.status.isFinished).toList();

  List<ShoppingListEntity> get pendingLists =>
      filteredLists.where((l) => l.status.isPending).toList();

  List<ShoppingListEntity> get inProgressLists =>
      filteredLists.where((l) => l.status.isInProgress).toList();

  HomeLoaded copyWith({
    List<ShoppingListEntity>? allLists,
    String? searchQuery,
    ListStatus? statusFilter,
  }) {
    return HomeLoaded(
      allLists: allLists ?? this.allLists,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
}

// ─── Home ViewModel ───────────────────────────────────────────────────────────

class HomeViewModel extends StateNotifier<HomeState> {
  final WatchEmployeeListsUseCase _watchEmployeeLists;
  final WatchAllListsUseCase _watchAllLists;
  final Logger _logger;
  StreamSubscription? _subscription;

  HomeViewModel({
    required WatchEmployeeListsUseCase watchEmployeeLists,
    required WatchAllListsUseCase watchAllLists,
    required Logger logger,
  })  : _watchEmployeeLists = watchEmployeeLists,
        _watchAllLists = watchAllLists,
        _logger = logger,
        super(const HomeInitial());

  void startWatching({required bool isAdmin, String? userId}) {
    state = const HomeLoading();
    _subscription?.cancel();

    final stream = isAdmin
        ? _watchAllLists()
        : _watchEmployeeLists(userId!);

    _subscription = stream.listen(
      (lists) {
        if (state is HomeLoaded) {
          state = (state as HomeLoaded).copyWith(allLists: lists);
        } else {
          state = HomeLoaded(allLists: lists);
        }
      },
      onError: (error) {
        _logger.e('Erro ao observar listas: $error');
        state = HomeError(error.toString());
      },
    );
  }

  void search(String query) {
    if (state is HomeLoaded) {
      state = (state as HomeLoaded).copyWith(searchQuery: query);
    }
  }

  void filterByStatus(ListStatus? status) {
    if (state is HomeLoaded) {
      state = HomeLoaded(
        allLists: (state as HomeLoaded).allLists,
        searchQuery: (state as HomeLoaded).searchQuery,
        statusFilter: status,
      );
    }
  }

  void clearFilters() {
    if (state is HomeLoaded) {
      state = HomeLoaded(allLists: (state as HomeLoaded).allLists);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final homeViewModelProvider =
    StateNotifierProvider.autoDispose<HomeViewModel, HomeState>((ref) {
  final repository = ref.watch(shoppingListRepositoryProvider);
  final logger = ref.watch(loggerProvider);

  final vm = HomeViewModel(
    watchEmployeeLists: WatchEmployeeListsUseCase(repository),
    watchAllLists: WatchAllListsUseCase(repository),
    logger: logger,
  );

  // Start watching based on current user role
  final currentUser = ref.read(currentUserProvider);
  if (currentUser != null) {
    vm.startWatching(
      isAdmin: currentUser.isAdmin,
      userId: currentUser.id,
    );
  }

  return vm;
});
