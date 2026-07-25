/// Compry — Auth Local DataSource
/// Data layer — Hive + flutter_secure_storage for session persistence
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../models/user_model.dart';
import '../../../../core/constants/app_constants.dart';

/// Interface para acesso local de autenticação
abstract interface class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
  Future<void> saveSession(String userId, String role);
  Future<Map<String, String?>> getSession();
  Future<void> clearSession();
}

/// Implementação com Hive + flutter_secure_storage
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final Box<UserModel> _userBox;
  final Logger _logger;

  AuthLocalDataSourceImpl({
    required FlutterSecureStorage secureStorage,
    required Box<UserModel> userBox,
    required Logger logger,
  })  : _secureStorage = secureStorage,
        _userBox = userBox,
        _logger = logger;

  static const String _userKey = 'current_user';

  @override
  Future<void> saveUser(UserModel user) async {
    await _userBox.put(_userKey, user);
    _logger.d('Usuário salvo localmente: ${user.username}');
  }

  @override
  Future<UserModel?> getUser() async {
    final user = _userBox.get(_userKey);
    return user;
  }

  @override
  Future<void> clearUser() async {
    await _userBox.delete(_userKey);
    _logger.d('Usuário removido do cache local.');
  }

  @override
  Future<void> saveSession(String userId, String role) async {
    await _secureStorage.write(key: AppConstants.keyUserId, value: userId);
    await _secureStorage.write(key: AppConstants.keyUserRole, value: role);
    _logger.d('Sessão salva: userId=$userId, role=$role');
  }

  @override
  Future<Map<String, String?>> getSession() async {
    final userId = await _secureStorage.read(key: AppConstants.keyUserId);
    final role = await _secureStorage.read(key: AppConstants.keyUserRole);
    return {
      AppConstants.keyUserId: userId,
      AppConstants.keyUserRole: role,
    };
  }

  @override
  Future<void> clearSession() async {
    await _secureStorage.delete(key: AppConstants.keyUserId);
    await _secureStorage.delete(key: AppConstants.keyUserRole);
    _logger.d('Sessão limpa.');
  }
}
