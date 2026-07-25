/// Compry — Shopping List Repository Interface
/// Domain layer
library;

import '../entities/shopping_item_entity.dart';
import '../entities/shopping_list_entity.dart';

/// Contrato para listas de compras
abstract interface class ShoppingListRepository {
  // ─── Lists ─────────────────────────────────────────────────────────────────

  /// Cria nova lista (RF-006)
  Future<ShoppingListEntity> createList(ShoppingListEntity list);

  /// Atualiza lista existente (RF-015, UC-004)
  Future<ShoppingListEntity> updateList(ShoppingListEntity list);

  /// Envia lista para o administrador (RF-018)
  Future<ShoppingListEntity> sendList(String listId);

  /// Cancela lista (RF-019)
  Future<ShoppingListEntity> cancelList(String listId);

  /// Finaliza compra — somente admin (RF-030)
  Future<ShoppingListEntity> finalizeList(String listId, String adminId);

  /// Busca lista por ID
  Future<ShoppingListEntity> getListById(String listId);

  /// Stream de listas do funcionário (RF-004)
  Stream<List<ShoppingListEntity>> watchEmployeeLists(String userId);

  /// Stream de todas as listas — admin (RF-004)
  Stream<List<ShoppingListEntity>> watchAllLists();

  /// Stream de uma lista específica — tempo real (RF-026)
  Stream<ShoppingListEntity> watchListById(String listId);

  /// Busca listas com filtros para histórico (RF-028)
  Future<List<ShoppingListEntity>> getFilteredLists({
    String? userId,
    String? category,
    ListStatus? status,
    DateTime? from,
    DateTime? to,
    String? searchQuery,
  });

  /// Deleta lista (somente rascunho)
  Future<void> deleteList(String listId);

  // ─── Items ─────────────────────────────────────────────────────────────────

  /// Adiciona item à lista (RF-009)
  Future<ShoppingItemEntity> addItem(ShoppingItemEntity item);

  /// Atualiza item (RF-015)
  Future<ShoppingItemEntity> updateItem(ShoppingItemEntity item);

  /// Remove item (RF-015 — antes do envio)
  Future<void> deleteItem(String listId, String itemId);

  /// Marca item como comprado (RF-023)
  Future<ShoppingItemEntity> checkItem(
    String listId,
    String itemId,
    String checkedBy,
  );

  /// Desmarca item (RF-024)
  Future<ShoppingItemEntity> uncheckItem(String listId, String itemId);

  /// Reordena itens (RF-016)
  Future<void> reorderItems(String listId, List<String> orderedIds);

  /// Stream de itens de uma lista — tempo real (RF-026)
  Stream<List<ShoppingItemEntity>> watchItems(String listId);

  /// Busca itens de uma lista
  Future<List<ShoppingItemEntity>> getItems(String listId);
}
