/// Compry — Auth Use Cases
/// Domain layer — business rules for authentication
/// PRD Part 5, UC-001, UC-010
library;

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/usecases/use_case.dart';

// ─── Login Use Case ──────────────────────────────────────────────────────────

/// Parâmetros para o caso de uso de login
class LoginParams {
  final String username;
  final String password;

  const LoginParams({
    required this.username,
    required this.password,
  });
}

/// Realiza autenticação do usuário (RF-001)
/// Regras:
/// - Usuário e senha obrigatórios
/// - Conta deve estar ativa
/// - Sessão persiste até logout (RF-002)
class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  @override
  Future<UserEntity> call(LoginParams params) async {
    // Validar campos vazios (RF-001)
    if (params.username.trim().isEmpty) {
      throw ArgumentError('Usuário é obrigatório.');
    }
    if (params.password.isEmpty) {
      throw ArgumentError('Senha é obrigatória.');
    }

    final user = await _repository.login(
      username: params.username.trim(),
      password: params.password,
    );

    // Verificar se conta está ativa (RG-002)
    if (!user.active) {
      await _repository.logout();
      throw StateError('Usuário inativo.');
    }

    return user;
  }
}

// ─── Logout Use Case ─────────────────────────────────────────────────────────

/// Realiza logout do usuário (RF-003, UC-010)
/// Regras:
/// - Apaga cache da sessão
/// - Remove credenciais locais
class LogoutUseCase implements UseCaseNoParams<void> {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  @override
  Future<void> call() async {
    await _repository.logout();
  }
}

// ─── Get Current User Use Case ───────────────────────────────────────────────

/// Retorna o usuário atualmente autenticado (RF-002)
class GetCurrentUserUseCase implements UseCaseNoParams<UserEntity?> {
  final AuthRepository _repository;

  const GetCurrentUserUseCase(this._repository);

  @override
  Future<UserEntity?> call() async {
    return _repository.getCurrentUser();
  }
}

// ─── Watch Auth State Use Case ───────────────────────────────────────────────

/// Stream do estado de autenticação
class WatchAuthStateUseCase implements StreamUseCaseNoParams<UserEntity?> {
  final AuthRepository _repository;

  const WatchAuthStateUseCase(this._repository);

  @override
  Stream<UserEntity?> call() => _repository.authStateChanges;
}

// ─── Create User As Admin Use Case ───────────────────────────────────────────

class CreateUserAsAdminParams {
  final String username;
  final String password;
  final String name;
  final String role;
  final String? avatar;

  const CreateUserAsAdminParams({
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    this.avatar,
  });
}

/// Cria um novo usuário pelo Administrador
class CreateUserAsAdminUseCase implements UseCase<void, CreateUserAsAdminParams> {
  final AuthRepository _repository;

  const CreateUserAsAdminUseCase(this._repository);

  @override
  Future<void> call(CreateUserAsAdminParams params) async {
    if (params.username.trim().isEmpty) throw ArgumentError('Usuário é obrigatório.');
    if (params.password.isEmpty) throw ArgumentError('Senha é obrigatória.');
    if (params.name.trim().isEmpty) throw ArgumentError('Nome é obrigatório.');

    await _repository.createUserAsAdmin(
      username: params.username.trim(),
      password: params.password,
      name: params.name.trim(),
      role: params.role,
      avatar: params.avatar,
    );
  }
}
