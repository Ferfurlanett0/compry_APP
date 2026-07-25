/// Compry — Failure types (Clean Architecture)
/// Domain layer error handling
library;

import 'package:equatable/equatable.dart';

/// Base failure class for all domain errors
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const Failure({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, code];
}

// ─── Auth Failures ──────────────────────────────────────────────────────────

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code, super.stackTrace});
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure()
      : super(
          message: 'Usuário ou senha incorretos.',
          code: 'invalid-credentials',
        );
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure()
      : super(
          message: 'Usuário não encontrado.',
          code: 'user-not-found',
        );
}

class UserInactiveFailure extends AuthFailure {
  const UserInactiveFailure()
      : super(
          message: 'Usuário inativo. Entre em contato com o administrador.',
          code: 'user-inactive',
        );
}

class SessionExpiredFailure extends AuthFailure {
  const SessionExpiredFailure()
      : super(
          message: 'Sessão expirada. Faça login novamente.',
          code: 'session-expired',
        );
}

// ─── Network Failures ───────────────────────────────────────────────────────

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Sem conexão com a internet.',
    super.code = 'network-error',
    super.stackTrace,
  });
}

class TimeoutFailure extends Failure {
  const TimeoutFailure()
      : super(
          message: 'Tempo limite excedido. Tente novamente.',
          code: 'timeout',
        );
}

// ─── Server Failures ────────────────────────────────────────────────────────

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Erro no servidor. Tente novamente.',
    super.code,
    super.stackTrace,
  });
}

class PermissionFailure extends Failure {
  const PermissionFailure()
      : super(
          message: 'Você não tem permissão para realizar esta ação.',
          code: 'permission-denied',
        );
}

// ─── Data Failures ──────────────────────────────────────────────────────────

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Recurso não encontrado.',
    super.code = 'not-found',
  });
}

class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors = const {},
    super.code = 'validation-error',
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Erro ao acessar dados locais.',
    super.code = 'cache-error',
    super.stackTrace,
  });
}

class SyncFailure extends Failure {
  const SyncFailure({
    super.message = 'Erro durante a sincronização.',
    super.code = 'sync-error',
    super.stackTrace,
  });
}

class ConflictFailure extends Failure {
  final String entityId;
  final String entityType;

  const ConflictFailure({
    required this.entityId,
    required this.entityType,
    super.message = 'Conflito detectado. Última alteração aplicada.',
    super.code = 'conflict',
  });

  @override
  List<Object?> get props => [message, code, entityId, entityType];
}

// ─── Business Rule Failures ─────────────────────────────────────────────────

class ListAlreadySentFailure extends Failure {
  const ListAlreadySentFailure()
      : super(
          message: 'Esta lista já foi enviada e não pode ser editada.',
          code: 'list-already-sent',
        );
}

class ListAlreadyFinishedFailure extends Failure {
  const ListAlreadyFinishedFailure()
      : super(
          message: 'Esta lista já foi finalizada.',
          code: 'list-already-finished',
        );
}

class EmptyListFailure extends Failure {
  const EmptyListFailure()
      : super(
          message: 'A lista deve conter pelo menos um item.',
          code: 'empty-list',
        );
}

class UnauthorizedFinalizationFailure extends Failure {
  const UnauthorizedFinalizationFailure()
      : super(
          message: 'Somente o administrador pode finalizar uma lista.',
          code: 'unauthorized-finalization',
        );
}
