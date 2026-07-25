/// Compry — Auth Memory DataSource (Demo Mode)
/// Permite login sem Firebase usando usuários predefinidos.
/// Usuários demo: admin/admin123, joao/joao123, maria/maria123
library;

import 'dart:async';
import 'package:logger/logger.dart';

import '../models/user_model.dart';
import '../../../../core/errors/failures.dart';
import 'auth_remote_datasource.dart';

/// Usuários de demonstração predefinidos
final _demoUsers = {
  'admin': _DemoUser(
    id: 'demo-admin-001',
    name: 'Administrador',
    username: 'admin',
    password: 'admin123',
    role: 'ADMIN',
  ),
  'joao': _DemoUser(
    id: 'demo-user-001',
    name: 'João Silva',
    username: 'joao',
    password: 'joao123',
    role: 'EMPLOYEE',
  ),
  'maria': _DemoUser(
    id: 'demo-user-002',
    name: 'Maria Santos',
    username: 'maria',
    password: 'maria123',
    role: 'EMPLOYEE',
  ),
};

class _DemoUser {
  final String id;
  final String name;
  final String username;
  final String password;
  final String role;

  _DemoUser({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.role,
  });

  UserModel toModel() {
    final now = DateTime.now();
    return UserModel(
      id: id,
      name: name,
      username: username,
      role: role,
      active: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}

/// Auth DataSource em memória para modo demo
class AuthMemoryDataSource implements AuthRemoteDataSource {
  final Logger _logger;
  final _authController = StreamController<UserModel?>.broadcast();

  UserModel? _currentUser;

  AuthMemoryDataSource({required Logger logger}) : _logger = logger;

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 800));

    final demoUser = _demoUsers[username.toLowerCase()];

    if (demoUser == null) {
      _logger.w('Usuário não encontrado: $username');
      throw const InvalidCredentialsFailure();
    }

    if (demoUser.password != password) {
      _logger.w('Senha incorreta para: $username');
      throw const InvalidCredentialsFailure();
    }

    final model = demoUser.toModel();
    _currentUser = model;
    _authController.add(model);

    _logger.i('Login demo bem-sucedido: $username (${demoUser.role})');
    return model;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Stream<UserModel?> get authStateChanges => _authController.stream;

  @override
  Future<void> logout() async {
    _currentUser = null;
    _authController.add(null);
    _logger.i('Logout demo realizado.');
  }

  @override
  Future<void> updateFcmToken(String userId, String token) async {
    // No-op in demo mode
  }

  void dispose() {
    _authController.close();
  }
}
