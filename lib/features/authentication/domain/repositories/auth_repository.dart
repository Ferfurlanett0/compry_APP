/// Compry — Auth Repository Interface
/// Domain layer
library;

import '../entities/user_entity.dart';

/// Contrato para autenticação — implementado na camada de dados
abstract interface class AuthRepository {
  /// Realiza login com usuário e senha (RF-001)
  Future<UserEntity> login({
    required String username,
    required String password,
  });

  /// Retorna o usuário atualmente autenticado, ou null
  Future<UserEntity?> getCurrentUser();

  /// Stream do usuário atual (para reatividade)
  Stream<UserEntity?> get authStateChanges;

  /// Realiza logout (RF-003)
  Future<void> logout();

  /// Verifica se há sessão ativa (RF-002)
  Future<bool> isAuthenticated();

  /// Atualiza o token FCM do usuário
  Future<void> updateFcmToken(String userId, String token);

  /// Cria um novo usuário pelo Administrador
  Future<void> createUserAsAdmin({
    required String username,
    required String password,
    required String name,
    required String role,
  });
}
