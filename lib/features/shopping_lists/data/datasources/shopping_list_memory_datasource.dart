/// Compry — In-Memory DataSource (Demo Mode)
/// Substitui o Firestore quando Firebase não está configurado.
/// Permite testar e desenvolver sem Firebase real.
/// PRD: permite desenvolvimento offline completo.
library;

import 'dart:async';
import 'package:uuid/uuid.dart';

import '../models/shopping_item_model.dart';
import '../models/shopping_list_model.dart';
import '../../../../core/constants/app_constants.dart';
import 'shopping_list_remote_datasource.dart';

/// DataSource em memória — para desenvolvimento e demo sem Firebase
class ShoppingListMemoryDataSource implements ShoppingListRemoteDataSource {
  final Uuid _uuid;

  ShoppingListMemoryDataSource({required Uuid uuid}) : _uuid = uuid;

  // In-memory stores
  final Map<String, ShoppingListModel> _lists = {};
  final Map<String, Map<String, ShoppingItemModel>> _items = {};

  // Stream controllers for real-time simulation
  final _allListsController =
      StreamController<List<ShoppingListModel>>.broadcast();
  final Map<String, StreamController<ShoppingListModel>> _listControllers = {};
  final Map<String, StreamController<List<ShoppingItemModel>>>
      _itemsControllers = {};

  void _notifyAllLists() {
    final sorted = _lists.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _allListsController.add(sorted);
  }

  void _notifyList(String listId) {
    final list = _lists[listId];
    if (list != null && _listControllers[listId] != null) {
      _listControllers[listId]!.add(list);
    }
  }

  void _notifyItems(String listId) {
    final items = (_items[listId]?.values.toList() ?? [])
      ..sort((a, b) => a.position.compareTo(b.position));
    if (_itemsControllers[listId] != null) {
      _itemsControllers[listId]!.add(items);
    }
  }

  @override
  Future<ShoppingListModel> createList(ShoppingListModel list) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final newList = ShoppingListModel(
      id: id,
      title: list.title,
      description: list.description,
      notes: list.notes,
      priority: list.priority,
      status: AppStatus.draft,
      createdBy: list.createdBy,
      createdByName: list.createdByName,
      assignedTo: list.assignedTo,
      category: list.category,
      tags: list.tags,
      dueDate: list.dueDate,
      createdAt: now,
      updatedAt: now,
      finishedAt: null,
      sentAt: null,
      startedAt: null,
      version: 1,
      offlineChanges: false,
      totalItems: 0,
      checkedItems: 0,
    );
    _lists[id] = newList;
    _items[id] = {};
    _notifyAllLists();
    return newList;
  }

  @override
  Future<ShoppingListModel> updateList(ShoppingListModel list) async {
    final updated = ShoppingListModel(
      id: list.id,
      title: list.title,
      description: list.description,
      notes: list.notes,
      priority: list.priority,
      status: list.status,
      createdBy: list.createdBy,
      createdByName: list.createdByName,
      assignedTo: list.assignedTo,
      category: list.category,
      tags: list.tags,
      dueDate: list.dueDate,
      createdAt: list.createdAt,
      updatedAt: DateTime.now(),
      finishedAt: list.finishedAt,
      sentAt: list.sentAt,
      startedAt: list.startedAt,
      version: list.version + 1,
      offlineChanges: false,
      totalItems: list.totalItems,
      checkedItems: list.checkedItems,
    );
    _lists[list.id] = updated;
    _notifyAllLists();
    _notifyList(list.id);
    return updated;
  }

  @override
  Future<ShoppingListModel> sendList(String listId, String sentAt) async {
    final list = _lists[listId]!;
    final updated = ShoppingListModel(
      id: list.id,
      title: list.title,
      description: list.description,
      notes: list.notes,
      priority: list.priority,
      status: AppStatus.pending,
      createdBy: list.createdBy,
      createdByName: list.createdByName,
      assignedTo: list.assignedTo,
      category: list.category,
      tags: list.tags,
      dueDate: list.dueDate,
      createdAt: list.createdAt,
      updatedAt: DateTime.now(),
      finishedAt: null,
      sentAt: DateTime.now(),
      startedAt: list.startedAt,
      version: list.version + 1,
      offlineChanges: false,
      totalItems: list.totalItems,
      checkedItems: list.checkedItems,
    );
    _lists[listId] = updated;
    _notifyAllLists();
    _notifyList(listId);
    return updated;
  }

  @override
  Future<ShoppingListModel> cancelList(String listId) async {
    final list = _lists[listId]!;
    final updated = ShoppingListModel(
      id: list.id,
      title: list.title,
      description: list.description,
      notes: list.notes,
      priority: list.priority,
      status: AppStatus.cancelled,
      createdBy: list.createdBy,
      createdByName: list.createdByName,
      assignedTo: list.assignedTo,
      category: list.category,
      tags: list.tags,
      dueDate: list.dueDate,
      createdAt: list.createdAt,
      updatedAt: DateTime.now(),
      finishedAt: null,
      sentAt: list.sentAt,
      startedAt: list.startedAt,
      version: list.version + 1,
      offlineChanges: false,
      totalItems: list.totalItems,
      checkedItems: list.checkedItems,
    );
    _lists[listId] = updated;
    _notifyAllLists();
    _notifyList(listId);
    return updated;
  }

  @override
  Future<ShoppingListModel> finalizeList(
      String listId, String adminId, String finishedAt) async {
    final list = _lists[listId]!;
    final updated = ShoppingListModel(
      id: list.id,
      title: list.title,
      description: list.description,
      notes: list.notes,
      priority: list.priority,
      status: AppStatus.finished,
      createdBy: list.createdBy,
      createdByName: list.createdByName,
      assignedTo: adminId,
      category: list.category,
      tags: list.tags,
      dueDate: list.dueDate,
      createdAt: list.createdAt,
      updatedAt: DateTime.now(),
      finishedAt: DateTime.now(),
      sentAt: list.sentAt,
      startedAt: list.startedAt,
      version: list.version + 1,
      offlineChanges: false,
      totalItems: list.totalItems,
      checkedItems: list.checkedItems,
    );
    _lists[listId] = updated;
    _notifyAllLists();
    _notifyList(listId);
    return updated;
  }

  @override
  Future<ShoppingListModel> getListById(String listId) async {
    final list = _lists[listId];
    if (list == null) throw Exception('Lista não encontrada: $listId');
    return list;
  }

  @override
  Stream<List<ShoppingListModel>> watchEmployeeLists(String userId) {
    // Emit current state first, then stream updates filtered by userId
    Future.microtask(() {
      final current = _lists.values
          .where((l) => l.createdBy == userId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _allListsController.add(current);
    });

    return _allListsController.stream.map((lists) =>
        lists.where((l) => l.createdBy == userId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  @override
  Stream<List<ShoppingListModel>> watchAllLists() {
    // Emit current state immediately, then stream updates
    _notifyAllLists();
    return _allListsController.stream;
  }

  @override
  Stream<ShoppingListModel> watchListById(String listId) {
    _listControllers[listId] ??=
        StreamController<ShoppingListModel>.broadcast();

    final controller = _listControllers[listId]!;

    // Emit current state
    final current = _lists[listId];
    if (current != null) {
      Future.microtask(() => controller.add(current));
    }

    return controller.stream;
  }

  @override
  Future<List<ShoppingListModel>> getFilteredLists({
    String? userId,
    String? category,
    String? status,
    DateTime? from,
    DateTime? to,
    String? searchQuery,
  }) async {
    var results = _lists.values.toList();

    if (userId != null) results = results.where((l) => l.createdBy == userId).toList();
    if (category != null) results = results.where((l) => l.category == category).toList();
    if (status != null) results = results.where((l) => l.status == status).toList();
    if (from != null) results = results.where((l) => l.createdAt.isAfter(from)).toList();
    if (to != null) results = results.where((l) => l.createdAt.isBefore(to)).toList();
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results.where((l) => l.title.toLowerCase().contains(q)).toList();
    }

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  @override
  Future<void> deleteList(String listId) async {
    _lists.remove(listId);
    _items.remove(listId);
    _notifyAllLists();
  }

  @override
  Future<ShoppingItemModel> addItem(ShoppingItemModel item) async {
    final id = _uuid.v4();
    final newItem = ShoppingItemModel(
      id: id,
      listId: item.listId,
      name: item.name,
      quantity: item.quantity,
      unit: item.unit,
      brand: item.brand,
      category: item.category,
      expectedPrice: item.expectedPrice,
      notes: item.notes,
      checked: false,
      checkedBy: null,
      checkedAt: null,
      position: item.position,
      version: 1,
    );

    _items[item.listId] ??= {};
    _items[item.listId]![id] = newItem;

    // Update totalItems on list
    final list = _lists[item.listId];
    if (list != null) {
      _lists[item.listId] = ShoppingListModel(
        id: list.id,
        title: list.title,
        description: list.description,
        notes: list.notes,
        priority: list.priority,
        status: list.status,
        createdBy: list.createdBy,
        createdByName: list.createdByName,
        assignedTo: list.assignedTo,
        category: list.category,
        tags: list.tags,
        dueDate: list.dueDate,
        createdAt: list.createdAt,
        updatedAt: DateTime.now(),
        finishedAt: list.finishedAt,
        sentAt: list.sentAt,
        startedAt: list.startedAt,
        version: list.version + 1,
        offlineChanges: false,
        totalItems: list.totalItems + 1,
        checkedItems: list.checkedItems,
      );
      _notifyAllLists();
      _notifyList(item.listId);
    }

    _notifyItems(item.listId);
    return newItem;
  }

  @override
  Future<ShoppingItemModel> updateItem(ShoppingItemModel item) async {
    _items[item.listId]?[item.id] = item;
    _notifyItems(item.listId);
    return item;
  }

  @override
  Future<void> deleteItem(String listId, String itemId) async {
    _items[listId]?.remove(itemId);

    final list = _lists[listId];
    if (list != null) {
      _lists[listId] = ShoppingListModel(
        id: list.id,
        title: list.title,
        description: list.description,
        notes: list.notes,
        priority: list.priority,
        status: list.status,
        createdBy: list.createdBy,
        createdByName: list.createdByName,
        assignedTo: list.assignedTo,
        category: list.category,
        tags: list.tags,
        dueDate: list.dueDate,
        createdAt: list.createdAt,
        updatedAt: DateTime.now(),
        finishedAt: list.finishedAt,
        sentAt: list.sentAt,
        startedAt: list.startedAt,
        version: list.version + 1,
        offlineChanges: false,
        totalItems: (list.totalItems - 1).clamp(0, 9999),
        checkedItems: list.checkedItems,
      );
      _notifyAllLists();
      _notifyList(listId);
    }

    _notifyItems(listId);
  }

  @override
  Future<ShoppingItemModel> checkItem(
      String listId, String itemId, String checkedBy) async {
    final item = _items[listId]?[itemId];
    if (item == null) throw Exception('Item não encontrado: $itemId');

    final updated = ShoppingItemModel(
      id: item.id,
      listId: item.listId,
      name: item.name,
      quantity: item.quantity,
      unit: item.unit,
      brand: item.brand,
      category: item.category,
      expectedPrice: item.expectedPrice,
      notes: item.notes,
      checked: true,
      checkedBy: checkedBy,
      checkedAt: DateTime.now(),
      position: item.position,
      version: item.version + 1,
    );

    _items[listId]![itemId] = updated;

    // Update checkedItems on list
    final list = _lists[listId];
    if (list != null) {
      _lists[listId] = ShoppingListModel(
        id: list.id,
        title: list.title,
        description: list.description,
        notes: list.notes,
        priority: list.priority,
        status: list.status,
        createdBy: list.createdBy,
        createdByName: list.createdByName,
        assignedTo: list.assignedTo,
        category: list.category,
        tags: list.tags,
        dueDate: list.dueDate,
        createdAt: list.createdAt,
        updatedAt: DateTime.now(),
        finishedAt: list.finishedAt,
        sentAt: list.sentAt,
        startedAt: list.startedAt,
        version: list.version,
        offlineChanges: false,
        totalItems: list.totalItems,
        checkedItems: list.checkedItems + 1,
      );
      _notifyAllLists();
      _notifyList(listId);
    }

    _notifyItems(listId);
    return updated;
  }

  @override
  Future<ShoppingItemModel> uncheckItem(
      String listId, String itemId) async {
    final item = _items[listId]?[itemId];
    if (item == null) throw Exception('Item não encontrado: $itemId');

    final updated = ShoppingItemModel(
      id: item.id,
      listId: item.listId,
      name: item.name,
      quantity: item.quantity,
      unit: item.unit,
      brand: item.brand,
      category: item.category,
      expectedPrice: item.expectedPrice,
      notes: item.notes,
      checked: false,
      checkedBy: null,
      checkedAt: null,
      position: item.position,
      version: item.version + 1,
    );

    _items[listId]![itemId] = updated;

    final list = _lists[listId];
    if (list != null) {
      _lists[listId] = ShoppingListModel(
        id: list.id,
        title: list.title,
        description: list.description,
        notes: list.notes,
        priority: list.priority,
        status: list.status,
        createdBy: list.createdBy,
        createdByName: list.createdByName,
        assignedTo: list.assignedTo,
        category: list.category,
        tags: list.tags,
        dueDate: list.dueDate,
        createdAt: list.createdAt,
        updatedAt: DateTime.now(),
        finishedAt: list.finishedAt,
        sentAt: list.sentAt,
        startedAt: list.startedAt,
        version: list.version,
        offlineChanges: false,
        totalItems: list.totalItems,
        checkedItems: (list.checkedItems - 1).clamp(0, 9999),
      );
      _notifyAllLists();
      _notifyList(listId);
    }

    _notifyItems(listId);
    return updated;
  }

  @override
  Future<void> reorderItems(String listId, List<String> orderedIds) async {
    for (int i = 0; i < orderedIds.length; i++) {
      final item = _items[listId]?[orderedIds[i]];
      if (item != null) {
        _items[listId]![orderedIds[i]] = ShoppingItemModel(
          id: item.id,
          listId: item.listId,
          name: item.name,
          quantity: item.quantity,
          unit: item.unit,
          brand: item.brand,
          category: item.category,
          expectedPrice: item.expectedPrice,
          notes: item.notes,
          checked: item.checked,
          checkedBy: item.checkedBy,
          checkedAt: item.checkedAt,
          position: i,
          version: item.version,
        );
      }
    }
    _notifyItems(listId);
  }

  @override
  Stream<List<ShoppingItemModel>> watchItems(String listId) {
    _itemsControllers[listId] ??=
        StreamController<List<ShoppingItemModel>>.broadcast();

    final controller = _itemsControllers[listId]!;

    // Emit current state
    Future.microtask(() => _notifyItems(listId));

    return controller.stream;
  }

  @override
  Future<List<ShoppingItemModel>> getItems(String listId) async {
    final items = _items[listId]?.values.toList() ?? [];
    items.sort((a, b) => a.position.compareTo(b.position));
    return items;
  }

  void dispose() {
    _allListsController.close();
    for (final c in _listControllers.values) {
      c.close();
    }
    for (final c in _itemsControllers.values) {
      c.close();
    }
  }
}
