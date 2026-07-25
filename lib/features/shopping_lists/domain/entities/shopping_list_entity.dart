/// Compry — Shopping List Entity
/// Domain layer — immutable
/// PRD Part 3, Section 17
library;

import 'package:equatable/equatable.dart';

/// Prioridade da lista (RF-007)
enum ListPriority {
  low('LOW', 'Baixa'),
  medium('MEDIUM', 'Média'),
  high('HIGH', 'Alta'),
  urgent('URGENT', 'Urgente');

  final String value;
  final String label;
  const ListPriority(this.value, this.label);

  static ListPriority fromString(String value) {
    return ListPriority.values.firstWhere(
      (p) => p.value == value,
      orElse: () => ListPriority.medium,
    );
  }
}

/// Status da lista (RF-029)
enum ListStatus {
  draft('DRAFT', 'Em Preenchimento'),
  pending('PENDING', 'Pronta para Compra'),
  inProgress('IN_PROGRESS', 'Comprando'),
  finished('FINISHED', 'Concluída'),
  cancelled('CANCELLED', 'Cancelada');

  final String value;
  final String label;
  const ListStatus(this.value, this.label);

  static ListStatus fromString(String value) {
    return ListStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ListStatus.draft,
    );
  }

  bool get isDraft => this == ListStatus.draft;
  bool get isPending => this == ListStatus.pending;
  bool get isInProgress => this == ListStatus.inProgress;
  bool get isFinished => this == ListStatus.finished;
  bool get isCancelled => this == ListStatus.cancelled;

  /// Lista pode ser editada pelo funcionário
  bool get isEditable => this == ListStatus.draft;

  /// Lista pode ser cancelada pelo funcionário (RF-019)
  bool get isCancellable => this == ListStatus.draft || this == ListStatus.pending;

  /// Lista está ativa (não finalizada nem cancelada)
  bool get isActive => !isFinished && !isCancelled;
}

/// Entidade de lista de compras — imutável
class ShoppingListEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? notes;
  final ListPriority priority;
  final ListStatus status;
  final String createdBy;       // userId
  final String? createdByName;  // para exibição
  final String? assignedTo;     // adminId
  final String? category;
  final List<String> tags;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? finishedAt;
  final DateTime? sentAt;
  final DateTime? startedAt;
  final int version;
  final bool offlineChanges;

  // Aggregated from items (may be populated separately)
  final int totalItems;
  final int checkedItems;

  const ShoppingListEntity({
    required this.id,
    required this.title,
    this.description,
    this.notes,
    required this.priority,
    required this.status,
    required this.createdBy,
    this.createdByName,
    this.assignedTo,
    this.category,
    this.tags = const [],
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.finishedAt,
    this.sentAt,
    this.startedAt,
    this.version = 1,
    this.offlineChanges = false,
    this.totalItems = 0,
    this.checkedItems = 0,
  });

  /// Progresso da lista (0.0 a 1.0)
  double get progress {
    if (totalItems == 0) return 0.0;
    return checkedItems / totalItems;
  }

  /// Porcentagem formatada
  String get progressPercent => '${(progress * 100).toInt()}%';

  /// Texto de progresso
  String get progressText => '$checkedItems / $totalItems';

  /// Lista pode ser finalizada (apenas admin, RF-030)
  bool get canBeFinalized => status.isInProgress || status.isPending;

  /// Lista pode receber marcações (admin em andamento)
  bool get canBeChecked => status.isInProgress || status.isPending;

  ShoppingListEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? notes,
    ListPriority? priority,
    ListStatus? status,
    String? createdBy,
    String? createdByName,
    String? assignedTo,
    String? category,
    List<String>? tags,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? finishedAt,
    DateTime? sentAt,
    DateTime? startedAt,
    int? version,
    bool? offlineChanges,
    int? totalItems,
    int? checkedItems,
  }) {
    return ShoppingListEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      assignedTo: assignedTo ?? this.assignedTo,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      sentAt: sentAt ?? this.sentAt,
      startedAt: startedAt ?? this.startedAt,
      version: version ?? this.version,
      offlineChanges: offlineChanges ?? this.offlineChanges,
      totalItems: totalItems ?? this.totalItems,
      checkedItems: checkedItems ?? this.checkedItems,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        notes,
        priority,
        status,
        createdBy,
        category,
        tags,
        dueDate,
        createdAt,
        updatedAt,
        finishedAt,
        version,
        offlineChanges,
        totalItems,
        checkedItems,
      ];

  @override
  String toString() =>
      'ShoppingListEntity(id: $id, title: $title, status: $status)';
}
