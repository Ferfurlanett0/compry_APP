/// Compry — Shopping List Use Cases
/// Domain layer — business rules for list management
/// PRD Part 5, UC-002 to UC-009
library;

import '../entities/shopping_list_entity.dart';
import '../entities/shopping_item_entity.dart';
import '../repositories/shopping_list_repository.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/errors/failures.dart';

// ─── Create List ─────────────────────────────────────────────────────────────

class CreateListParams {
  final String title;
  final String? description;
  final String? notes;
  final ListPriority priority;
  final String? category;
  final List<String> tags;
  final DateTime? dueDate;
  final String createdBy;

  const CreateListParams({
    required this.title,
    this.description,
    this.notes,
    this.priority = ListPriority.medium,
    this.category,
    this.tags = const [],
    this.dueDate,
    required this.createdBy,
  });
}

/// Cria nova lista de compras (RF-006, UC-002)
/// Regras:
/// - Título obrigatório (RG-003)
/// - Somente funcionários podem criar (RF-006)
class CreateListUseCase implements UseCase<ShoppingListEntity, CreateListParams> {
  final ShoppingListRepository _repository;

  const CreateListUseCase(this._repository);

  @override
  Future<ShoppingListEntity> call(CreateListParams params) async {
    if (params.title.trim().isEmpty) {
      throw const ValidationFailure(
        message: 'O título da lista é obrigatório.',
        fieldErrors: {'title': 'Título obrigatório'},
      );
    }

    final now = DateTime.now();
    final list = ShoppingListEntity(
      id: '', // gerado pelo repository
      title: params.title.trim(),
      description: params.description?.trim(),
      notes: params.notes?.trim(),
      priority: params.priority,
      status: ListStatus.draft,
      createdBy: params.createdBy,
      category: params.category,
      tags: params.tags,
      dueDate: params.dueDate,
      createdAt: now,
      updatedAt: now,
      version: 1,
    );

    return _repository.createList(list);
  }
}

// ─── Send List ───────────────────────────────────────────────────────────────

/// Envia lista para o administrador (RF-018, UC-005)
/// Regras:
/// - Lista deve ter pelo menos um item (RG-004)
/// - Status muda para PENDING
class SendListUseCase implements UseCase<ShoppingListEntity, String> {
  final ShoppingListRepository _repository;

  const SendListUseCase(this._repository);

  @override
  Future<ShoppingListEntity> call(String listId) async {
    final list = await _repository.getListById(listId);

    if (!list.status.isDraft) {
      throw const ListAlreadySentFailure();
    }

    if (list.totalItems == 0) {
      throw const EmptyListFailure();
    }

    return _repository.sendList(listId);
  }
}

// ─── Cancel List ─────────────────────────────────────────────────────────────

/// Cancela lista (RF-019)
/// Regras:
/// - Somente antes de ser visualizada pelo admin (status PENDING ou DRAFT)
class CancelListUseCase implements UseCase<ShoppingListEntity, String> {
  final ShoppingListRepository _repository;

  const CancelListUseCase(this._repository);

  @override
  Future<ShoppingListEntity> call(String listId) async {
    final list = await _repository.getListById(listId);

    if (!list.status.isCancellable) {
      throw const PermissionFailure();
    }

    return _repository.cancelList(listId);
  }
}

// ─── Delete List ─────────────────────────────────────────────────────────────

class DeleteListParams {
  final String listId;
  final bool isAdmin;
  
  const DeleteListParams({
    required this.listId,
    required this.isAdmin,
  });
}

/// Exclui lista definitivamente do sistema
/// Regras:
/// - Admin pode apagar qualquer lista
/// - Funcionário só pode apagar lista em rascunho (draft)
class DeleteListUseCase implements UseCase<void, DeleteListParams> {
  final ShoppingListRepository _repository;

  const DeleteListUseCase(this._repository);

  @override
  Future<void> call(DeleteListParams params) async {
    final list = await _repository.getListById(params.listId);

    if (!params.isAdmin && !list.status.isDraft) {
      throw const PermissionFailure();
    }

    return _repository.deleteList(params.listId);
  }
}

// ─── Finalize List ───────────────────────────────────────────────────────────

class FinalizeListParams {
  final String listId;
  final String adminId;

  const FinalizeListParams({
    required this.listId,
    required this.adminId,
  });
}

/// Finaliza compra (RF-030, UC-007)
/// Regras:
/// - Somente administrador pode finalizar (RG-005)
/// - Lista deve estar em andamento
/// - Após finalização: itens bloqueados, edição proibida
class FinalizeListUseCase
    implements UseCase<ShoppingListEntity, FinalizeListParams> {
  final ShoppingListRepository _repository;

  const FinalizeListUseCase(this._repository);

  @override
  Future<ShoppingListEntity> call(FinalizeListParams params) async {
    final list = await _repository.getListById(params.listId);

    if (!list.canBeFinalized) {
      throw const ListAlreadyFinishedFailure();
    }

    return _repository.finalizeList(params.listId, params.adminId);
  }
}

// ─── Check/Uncheck Item ──────────────────────────────────────────────────────

class CheckItemParams {
  final String listId;
  final String itemId;
  final String checkedBy;

  const CheckItemParams({
    required this.listId,
    required this.itemId,
    required this.checkedBy,
  });
}

/// Marca item como comprado (RF-023)
class CheckItemUseCase implements UseCase<ShoppingItemEntity, CheckItemParams> {
  final ShoppingListRepository _repository;

  const CheckItemUseCase(this._repository);

  @override
  Future<ShoppingItemEntity> call(CheckItemParams params) async {
    return _repository.checkItem(
      params.listId,
      params.itemId,
      params.checkedBy,
    );
  }
}

class UncheckItemParams {
  final String listId;
  final String itemId;

  const UncheckItemParams({
    required this.listId,
    required this.itemId,
  });
}

/// Desmarca item (RF-024)
/// Regras:
/// - Somente enquanto lista não finalizada
class UncheckItemUseCase
    implements UseCase<ShoppingItemEntity, UncheckItemParams> {
  final ShoppingListRepository _repository;

  const UncheckItemUseCase(this._repository);

  @override
  Future<ShoppingItemEntity> call(UncheckItemParams params) async {
    final list = await _repository.getListById(params.listId);

    if (list.status.isFinished) {
      throw const ListAlreadyFinishedFailure();
    }

    return _repository.uncheckItem(params.listId, params.itemId);
  }
}

// ─── Watch Lists ─────────────────────────────────────────────────────────────

/// Stream das listas de um funcionário (RF-004)
class WatchEmployeeListsUseCase
    implements StreamUseCase<List<ShoppingListEntity>, String> {
  final ShoppingListRepository _repository;

  const WatchEmployeeListsUseCase(this._repository);

  @override
  Stream<List<ShoppingListEntity>> call(String userId) =>
      _repository.watchEmployeeLists(userId);
}

/// Stream de todas as listas — admin (RF-004)
class WatchAllListsUseCase
    implements StreamUseCaseNoParams<List<ShoppingListEntity>> {
  final ShoppingListRepository _repository;

  const WatchAllListsUseCase(this._repository);

  @override
  Stream<List<ShoppingListEntity>> call() => _repository.watchAllLists();
}

/// Stream de uma lista específica — tempo real (RF-026)
class WatchListUseCase
    implements StreamUseCase<ShoppingListEntity, String> {
  final ShoppingListRepository _repository;

  const WatchListUseCase(this._repository);

  @override
  Stream<ShoppingListEntity> call(String listId) =>
      _repository.watchListById(listId);
}

/// Stream de itens de uma lista (RF-026)
class WatchItemsUseCase
    implements StreamUseCase<List<ShoppingItemEntity>, String> {
  final ShoppingListRepository _repository;

  const WatchItemsUseCase(this._repository);

  @override
  Stream<List<ShoppingItemEntity>> call(String listId) =>
      _repository.watchItems(listId);
}

// ─── Add Item ────────────────────────────────────────────────────────────────

class AddItemParams {
  final String listId;
  final String name;
  final double quantity;
  final ItemUnit unit;
  final String? brand;
  final String? category;
  final double? expectedPrice;
  final String? notes;
  final int position;

  const AddItemParams({
    required this.listId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.brand,
    this.category,
    this.expectedPrice,
    this.notes,
    required this.position,
  });
}

/// Adiciona item à lista (RF-009, UC-003)
class AddItemUseCase implements UseCase<ShoppingItemEntity, AddItemParams> {
  final ShoppingListRepository _repository;

  const AddItemUseCase(this._repository);

  @override
  Future<ShoppingItemEntity> call(AddItemParams params) async {
    if (params.name.trim().isEmpty) {
      throw const ValidationFailure(
        message: 'Nome do item é obrigatório.',
        fieldErrors: {'name': 'Nome obrigatório'},
      );
    }

    if (params.quantity <= 0) {
      throw const ValidationFailure(
        message: 'Quantidade deve ser maior que zero.',
        fieldErrors: {'quantity': 'Quantidade inválida'},
      );
    }

    final item = ShoppingItemEntity(
      id: '',
      listId: params.listId,
      name: params.name.trim(),
      quantity: params.quantity,
      unit: params.unit,
      brand: params.brand?.trim(),
      category: params.category,
      expectedPrice: params.expectedPrice,
      notes: params.notes?.trim(),
      position: params.position,
    );

    return _repository.addItem(item);
  }
}

// ─── Get Filtered Lists (History) ────────────────────────────────────────────

class GetFilteredListsParams {
  final String? userId;
  final String? category;
  final ListStatus? status;
  final DateTime? from;
  final DateTime? to;
  final String? searchQuery;

  const GetFilteredListsParams({
    this.userId,
    this.category,
    this.status,
    this.from,
    this.to,
    this.searchQuery,
  });
}

/// Busca listas com filtros para histórico (RF-027, RF-028, UC-008)
class GetFilteredListsUseCase
    implements UseCase<List<ShoppingListEntity>, GetFilteredListsParams> {
  final ShoppingListRepository _repository;

  const GetFilteredListsUseCase(this._repository);

  @override
  Future<List<ShoppingListEntity>> call(GetFilteredListsParams params) async {
    return _repository.getFilteredLists(
      userId: params.userId,
      category: params.category,
      status: params.status,
      from: params.from,
      to: params.to,
      searchQuery: params.searchQuery,
    );
  }
}
