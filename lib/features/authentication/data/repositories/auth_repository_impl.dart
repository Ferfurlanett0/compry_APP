/// Compry — Auth Repository Implementation
/// Data layer — bridges remote + local data sources
library;

import 'package:logger/logger.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/connectivity_service.dart';

/// Implementação do repositório de autenticação
/// Orquestra comunicação entre remote e local data sources
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final ConnectivityService _connectivity;
  final Logger _logger;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required ConnectivityService connectivity,
    required Logger logger,
  })  : _remote = remote,
        _local = local,
        _connectivity = connectivity,
        _logger = logger;

  @override
  Future<UserEntity> login({
    required String username,
    required String password,
  }) async {
    final hasConnection = await _connectivity.hasConnection;

    if (!hasConnection) {
      // Tentar login offline com dados em cache
      final cached = await _local.getUser();
      if (cached != null && cached.username == username.toLowerCase()) {
        _logger.w('Login offline com dados em cache.');
        return cached.toEntity();
      }
      throw const NetworkFailure(
        message: 'Sem conexão. Conecte-se à internet para o primeiro acesso.',
      );
    }

    final userModel = await _remote.login(
      username: username,
      password: password,
    );

    // Persistir localmente para suporte offline
    await _local.saveUser(userModel);
    await _local.saveSession(userModel.id, userModel.role);

    return userModel.toEntity();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // Tentar buscar do servidor primeiro
    try {
      final remoteUser = await _remote.getCurrentUser();
      if (remoteUser != null) {
        await _local.saveUser(remoteUser);
        return remoteUser.toEntity();
      }
    } catch (e) {
      _logger.w('Não foi possível buscar usuário remoto: $e');
    }

    // Fallback para cache local
    final localUser = await _local.getUser();
    return localUser?.toEntity();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _remote.authStateChanges.map((model) => model?.toEntity());
  }

  @override
  Future<void> logout() async {
    await _remote.logout();
    await _local.clearUser();
    await _local.clearSession();
  }

  @override
  Future<bool> isAuthenticated() async {
    final session = await _local.getSession();
    return session['user_id'] != null;
  }

  @override
  Future<void> updateFcmToken(String userId, String token) async {
    await _remote.updateFcmToken(userId, token);
  }
}
