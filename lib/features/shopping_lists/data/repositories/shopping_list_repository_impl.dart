/// Compry — Shopping List Repository Implementation
/// Data layer — orchestrates remote + local data sources
library;

import 'package:logger/logger.dart';

import '../../domain/entities/shopping_list_entity.dart';
import '../../domain/entities/shopping_item_entity.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../datasources/shopping_list_remote_datasource.dart';
import '../models/shopping_item_model.dart';
import '../models/shopping_list_model.dart';


import '../../../../core/sync/services/sync_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/constants/app_constants.dart';

class ShoppingListRepositoryImpl implements ShoppingListRepository {
  final ShoppingListRemoteDataSource _remote;
  final SyncService _syncService;
  final ConnectivityService _connectivity;
  final Logger _logger;

  const ShoppingListRepositoryImpl({
    required ShoppingListRemoteDataSource remote,
    required SyncService syncService,
    required ConnectivityService connectivity,
    required Logger logger,
  })  : _remote = remote,
        _syncService = syncService,
        _connectivity = connectivity,
        _logger = logger;

  // ─── Lists ─────────────────────────────────────────────────────────────────

  @override
  Future<ShoppingListEntity> createList(ShoppingListEntity list) async {
    final model = ShoppingListModel.fromEntity(list);
    final isOnline = await _connectivity.hasConnection;

    if (!isOnline) {
      await _syncService.enqueueOperation(
        collection: AppConstants.colShoppingLists,
        documentId: model.id,
        operationType: 'CREATE',
        payload: model.toFirestore()..['createdAt'] = DateTime.now().toIso8601String()..['updatedAt'] = DateTime.now().toIso8601String(),
      );
      _logger.w('Offline: Lista ${model.id} adicionada à fila de sincronização.');
      return list; // Retorna com o ID gerado localmente
    }

    final result = await _remote.createList(model);
    _logger.i('Lista criada: ${result.id}');
    return result.toEntity();
  }

  @override
  Future<ShoppingListEntity> updateList(ShoppingListEntity list) async {
    final model = ShoppingListModel.fromEntity(list);
    final isOnline = await _connectivity.hasConnection;

    if (!isOnline) {
      await _syncService.enqueueOperation(
        collection: AppConstants.colShoppingLists,
        documentId: model.id,
        operationType: 'UPDATE',
        payload: model.toFirestore()..['updatedAt'] = DateTime.now().toIso8601String(),
      );
      _logger.w('Offline: Atualização da lista ${model.id} na fila.');
      return list;
    }

    final result = await _remote.updateList(model);
    return result.toEntity();
  }

  @override
  Future<ShoppingListEntity> sendList(String listId) async {
    final result = await _remote.sendList(listId, DateTime.now().toIso8601String());
    _logger.i('Lista enviada: $listId');
    return result.toEntity();
  }

  @override
  Future<ShoppingListEntity> cancelList(String listId) async {
    final result = await _remote.cancelList(listId);
    return result.toEntity();
  }

  @override
  Future<ShoppingListEntity> finalizeList(String listId, String adminId) async {
    final result = await _remote.finalizeList(
      listId,
      adminId,
      DateTime.now().toIso8601String(),
    );
    _logger.i('Lista finalizada: $listId por $adminId');
    return result.toEntity();
  }

  @override
  Future<ShoppingListEntity> getListById(String listId) async {
    final result = await _remote.getListById(listId);
    return result.toEntity();
  }

  @override
  Stream<List<ShoppingListEntity>> watchEmployeeLists(String userId) {
    return _remote.watchEmployeeLists(userId).map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Stream<List<ShoppingListEntity>> watchAllLists() {
    return _remote.watchAllLists().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Stream<ShoppingListEntity> watchListById(String listId) {
    return _remote.watchListById(listId).map((m) => m.toEntity());
  }

  @override
  Future<List<ShoppingListEntity>> getFilteredLists({
    String? userId,
    String? category,
    ListStatus? status,
    DateTime? from,
    DateTime? to,
    String? searchQuery,
  }) async {
    final results = await _remote.getFilteredLists(
      userId: userId,
      category: category,
      status: status?.value,
      from: from,
      to: to,
      searchQuery: searchQuery,
    );
    return results.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> deleteList(String listId) async {
    await _remote.deleteList(listId);
  }

  // ─── Items ─────────────────────────────────────────────────────────────────

  @override
  Future<ShoppingItemEntity> addItem(ShoppingItemEntity item) async {
    final model = ShoppingItemModel.fromEntity(item);
    final isOnline = await _connectivity.hasConnection;

    if (!isOnline) {
      await _syncService.enqueueOperation(
        collection: '${AppConstants.colShoppingLists}/${model.listId}/${AppConstants.colShoppingItems}',
        documentId: model.id,
        operationType: 'CREATE',
        payload: model.toFirestore()..['createdAt'] = DateTime.now().toIso8601String(),
      );
      // Fila pra atualizar o totalItems da lista
      await _syncService.enqueueOperation(
        collection: AppConstants.colShoppingLists,
        documentId: model.listId,
        operationType: 'UPDATE',
        payload: {'updatedAt': DateTime.now().toIso8601String()}, // simplified offline count
      );
      return item;
    }

    final result = await _remote.addItem(model);
    return result.toEntity();
  }

  @override
  Future<ShoppingItemEntity> updateItem(ShoppingItemEntity item) async {
    final model = ShoppingItemModel.fromEntity(item);
    final isOnline = await _connectivity.hasConnection;

    if (!isOnline) {
      await _syncService.enqueueOperation(
        collection: '${AppConstants.colShoppingLists}/${model.listId}/${AppConstants.colShoppingItems}',
        documentId: model.id,
        operationType: 'UPDATE',
        payload: model.toFirestore(),
      );
      return item;
    }

    final result = await _remote.updateItem(model);
    return result.toEntity();
  }

  @override
  Future<void> deleteItem(String listId, String itemId) async {
    await _remote.deleteItem(listId, itemId);
  }

  @override
  Future<ShoppingItemEntity> checkItem(
    String listId,
    String itemId,
    String checkedBy,
  ) async {
    final isOnline = await _connectivity.hasConnection;

    if (!isOnline) {
      await _syncService.enqueueOperation(
        collection: '${AppConstants.colShoppingLists}/$listId/${AppConstants.colShoppingItems}',
        documentId: itemId,
        operationType: 'UPDATE',
        payload: {
          'checked': true,
          'checkedBy': checkedBy,
          'checkedAt': DateTime.now().toIso8601String(),
        },
      );
      return ShoppingItemEntity(
        id: itemId,
        listId: listId,
        name: '',
        quantity: 1,
        unit: ItemUnit.outro,
        checked: true,
        checkedBy: checkedBy,
        checkedAt: DateTime.now(),
        position: 0,
      );
    }

    final result = await _remote.checkItem(listId, itemId, checkedBy);
    return result.toEntity();
  }

  @override
  Future<ShoppingItemEntity> uncheckItem(String listId, String itemId) async {
    final isOnline = await _connectivity.hasConnection;

    if (!isOnline) {
      await _syncService.enqueueOperation(
        collection: '${AppConstants.colShoppingLists}/$listId/${AppConstants.colShoppingItems}',
        documentId: itemId,
        operationType: 'UPDATE',
        payload: {
          'checked': false,
          'checkedBy': null,
          'checkedAt': null,
        },
      );
      return ShoppingItemEntity(
        id: itemId,
        listId: listId,
        name: '',
        quantity: 1,
        unit: ItemUnit.outro,
        checked: false,
        position: 0,
      );
    }

    final result = await _remote.uncheckItem(listId, itemId);
    return result.toEntity();
  }

  @override
  Future<void> reorderItems(String listId, List<String> orderedIds) async {
    await _remote.reorderItems(listId, orderedIds);
  }

  @override
  Stream<List<ShoppingItemEntity>> watchItems(String listId) {
    return _remote.watchItems(listId).map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Future<List<ShoppingItemEntity>> getItems(String listId) async {
    final results = await _remote.getItems(listId);
    return results.map((m) => m.toEntity()).toList();
  }
}
