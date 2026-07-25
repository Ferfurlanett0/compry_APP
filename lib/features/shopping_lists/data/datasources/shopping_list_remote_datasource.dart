/// Compry — Shopping List Remote DataSource
/// Data layer — Cloud Firestore
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';


import '../models/shopping_list_model.dart';
import '../models/shopping_item_model.dart';
import '../../../../core/constants/app_constants.dart';

abstract interface class ShoppingListRemoteDataSource {
  Future<ShoppingListModel> createList(ShoppingListModel list);
  Future<ShoppingListModel> updateList(ShoppingListModel list);
  Future<ShoppingListModel> sendList(String listId, String sentAt);
  Future<ShoppingListModel> cancelList(String listId);
  Future<ShoppingListModel> finalizeList(String listId, String adminId, String finishedAt);
  Future<ShoppingListModel> getListById(String listId);
  Stream<List<ShoppingListModel>> watchEmployeeLists(String userId);
  Stream<List<ShoppingListModel>> watchAllLists();
  Stream<ShoppingListModel> watchListById(String listId);
  Future<List<ShoppingListModel>> getFilteredLists({
    String? userId,
    String? category,
    String? status,
    DateTime? from,
    DateTime? to,
    String? searchQuery,
  });
  Future<void> deleteList(String listId);

  // Items
  Future<ShoppingItemModel> addItem(ShoppingItemModel item);
  Future<ShoppingItemModel> updateItem(ShoppingItemModel item);
  Future<void> deleteItem(String listId, String itemId);
  Future<ShoppingItemModel> checkItem(String listId, String itemId, String checkedBy);
  Future<ShoppingItemModel> uncheckItem(String listId, String itemId);
  Future<void> reorderItems(String listId, List<String> orderedIds);
  Stream<List<ShoppingItemModel>> watchItems(String listId);
  Future<List<ShoppingItemModel>> getItems(String listId);
}

class ShoppingListRemoteDataSourceImpl implements ShoppingListRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;
  final Logger _logger;

  ShoppingListRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required Uuid uuid,
    required Logger logger,
  })  : _firestore = firestore,
        _uuid = uuid,
        _logger = logger;

  CollectionReference<Map<String, dynamic>> get _listsRef =>
      _firestore.collection(AppConstants.colShoppingLists);

  CollectionReference<Map<String, dynamic>> _itemsRef(String listId) =>
      _listsRef.doc(listId).collection(AppConstants.colShoppingItems);

  @override
  Future<ShoppingListModel> createList(ShoppingListModel list) async {
    final id = _uuid.v4();
    final now = FieldValue.serverTimestamp();
    final data = list.toFirestore()
      ..['createdAt'] = now
      ..['updatedAt'] = now;

    await _listsRef.doc(id).set(data);
    final doc = await _listsRef.doc(id).get();
    _logger.i('Lista criada: $id');
    return ShoppingListModel.fromFirestore(doc);
  }

  @override
  Future<ShoppingListModel> updateList(ShoppingListModel list) async {
    final data = list.toFirestore()
      ..['updatedAt'] = FieldValue.serverTimestamp()
      ..['version'] = FieldValue.increment(1);

    await _listsRef.doc(list.id).update(data);
    final doc = await _listsRef.doc(list.id).get();
    return ShoppingListModel.fromFirestore(doc);
  }

  @override
  Future<ShoppingListModel> sendList(String listId, String sentAt) async {
    await _listsRef.doc(listId).update({
      'status': AppStatus.pending,
      'sentAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'version': FieldValue.increment(1),
    });
    final doc = await _listsRef.doc(listId).get();
    return ShoppingListModel.fromFirestore(doc);
  }

  @override
  Future<ShoppingListModel> cancelList(String listId) async {
    await _listsRef.doc(listId).update({
      'status': AppStatus.cancelled,
      'updatedAt': FieldValue.serverTimestamp(),
      'version': FieldValue.increment(1),
    });
    final doc = await _listsRef.doc(listId).get();
    return ShoppingListModel.fromFirestore(doc);
  }

  @override
  Future<ShoppingListModel> finalizeList(
    String listId,
    String adminId,
    String finishedAt,
  ) async {
    await _listsRef.doc(listId).update({
      'status': AppStatus.finished,
      'assignedTo': adminId,
      'finishedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'version': FieldValue.increment(1),
    });
    final doc = await _listsRef.doc(listId).get();
    return ShoppingListModel.fromFirestore(doc);
  }

  @override
  Future<ShoppingListModel> getListById(String listId) async {
    final doc = await _listsRef.doc(listId).get();
    if (!doc.exists) throw Exception('Lista não encontrada: $listId');
    return ShoppingListModel.fromFirestore(doc);
  }

  @override
  Stream<List<ShoppingListModel>> watchEmployeeLists(String userId) {
    return _listsRef
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ShoppingListModel.fromFirestore).toList());
  }

  @override
  Stream<List<ShoppingListModel>> watchAllLists() {
    return _listsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ShoppingListModel.fromFirestore).toList());
  }

  @override
  Stream<ShoppingListModel> watchListById(String listId) {
    return _listsRef.doc(listId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Lista não encontrada: $listId');
      return ShoppingListModel.fromFirestore(doc);
    });
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
    Query<Map<String, dynamic>> query =
        _listsRef.orderBy('createdAt', descending: true);

    if (userId != null) query = query.where('createdBy', isEqualTo: userId);
    if (category != null) query = query.where('category', isEqualTo: category);
    if (status != null) query = query.where('status', isEqualTo: status);
    if (from != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from));
    }
    if (to != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to));
    }

    final snap = await query.get();
    var results = snap.docs.map(ShoppingListModel.fromFirestore).toList();

    // Client-side filtering for search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results.where((l) => l.title.toLowerCase().contains(q)).toList();
    }

    return results;
  }

  @override
  Future<void> deleteList(String listId) async {
    await _listsRef.doc(listId).delete();
    _logger.i('Lista deletada: $listId');
  }

  // ─── Items ─────────────────────────────────────────────────────────────────

  @override
  Future<ShoppingItemModel> addItem(ShoppingItemModel item) async {
    final id = _uuid.v4();
    final data = item.toFirestore()
      ..['createdAt'] = FieldValue.serverTimestamp();

    await _itemsRef(item.listId).doc(id).set(data);

    // Update totalItems count on the list
    await _listsRef.doc(item.listId).update({
      'totalItems': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
      'version': FieldValue.increment(1),
    });

    final doc = await _itemsRef(item.listId).doc(id).get();
    return ShoppingItemModel.fromFirestore(doc);
  }

  @override
  Future<ShoppingItemModel> updateItem(ShoppingItemModel item) async {
    await _itemsRef(item.listId).doc(item.id).update(item.toFirestore());
    final doc = await _itemsRef(item.listId).doc(item.id).get();
    return ShoppingItemModel.fromFirestore(doc);
  }

  @override
  Future<void> deleteItem(String listId, String itemId) async {
    await _itemsRef(listId).doc(itemId).delete();

    // Update totalItems count
    await _listsRef.doc(listId).update({
      'totalItems': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
      'version': FieldValue.increment(1),
    });
  }

  @override
  Future<ShoppingItemModel> checkItem(
    String listId,
    String itemId,
    String checkedBy,
  ) async {
    await _itemsRef(listId).doc(itemId).update({
      'checked': true,
      'checkedBy': checkedBy,
      'checkedAt': FieldValue.serverTimestamp(),
      'version': FieldValue.increment(1),
    });

    // Update checkedItems count on the list
    await _listsRef.doc(listId).update({
      'checkedItems': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final doc = await _itemsRef(listId).doc(itemId).get();
    return ShoppingItemModel.fromFirestore(doc);
  }

  @override
  Future<ShoppingItemModel> uncheckItem(String listId, String itemId) async {
    await _itemsRef(listId).doc(itemId).update({
      'checked': false,
      'checkedBy': null,
      'checkedAt': null,
      'version': FieldValue.increment(1),
    });

    await _listsRef.doc(listId).update({
      'checkedItems': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final doc = await _itemsRef(listId).doc(itemId).get();
    return ShoppingItemModel.fromFirestore(doc);
  }

  @override
  Future<void> reorderItems(String listId, List<String> orderedIds) async {
    final batch = _firestore.batch();
    for (int i = 0; i < orderedIds.length; i++) {
      batch.update(_itemsRef(listId).doc(orderedIds[i]), {'position': i});
    }
    await batch.commit();
  }

  @override
  Stream<List<ShoppingItemModel>> watchItems(String listId) {
    return _itemsRef(listId)
        .orderBy('position')
        .snapshots()
        .map((snap) => snap.docs.map(ShoppingItemModel.fromFirestore).toList());
  }

  @override
  Future<List<ShoppingItemModel>> getItems(String listId) async {
    final snap = await _itemsRef(listId).orderBy('position').get();
    return snap.docs.map(ShoppingItemModel.fromFirestore).toList();
  }
}
