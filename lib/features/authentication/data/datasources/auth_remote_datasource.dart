/// Compry — Auth Remote DataSource
/// Data layer — Firebase Authentication + Firestore
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

import '../models/user_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';

/// Interface para acesso remoto de autenticação
abstract interface class AuthRemoteDataSource {
  Future<UserModel> login({required String username, required String password});
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
  Future<void> logout();
  Future<void> updateFcmToken(String userId, String token);
  Future<void> createUserAsAdmin({
    required String username,
    required String password,
    required String name,
    required String role,
    String? avatar,
  });
  Future<void> deleteEmployee({
    required String userId,
    required String email,
    required String password,
  });
  Future<void> updateAvatar({required String userId, required String avatar});
}

/// Implementação com Firebase Auth + Firestore
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final Logger _logger;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required Logger logger,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _logger = logger;

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim().toLowerCase();
    final cleanPassword = password.trim();
    final emailsToTry = <String>{
      '$cleanUsername@compry.com.br',
      '$cleanUsername@compry.app',
      '$cleanUsername@listapro.com.br',
      '$cleanUsername@listapro.app',
      '$cleanUsername@listapro.com',
    };

    UserCredential? credential;
    FirebaseAuthException? lastAuthError;

    try {
      // Firestore only allows authenticated users to read their own profile.
      // Authenticate first and then load users/{uid}.
      for (final email in emailsToTry) {
        try {
          credential = await _firebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: cleanPassword,
          );
          break;
        } on FirebaseAuthException catch (e) {
          lastAuthError = e;
          if (e.code != 'invalid-credential' &&
              e.code != 'user-not-found' &&
              e.code != 'wrong-password') {
            rethrow;
          }
        }
      }

      final firebaseUser = credential?.user;
      if (firebaseUser == null) {
        if (lastAuthError != null) throw lastAuthError;
        throw const InvalidCredentialsFailure();
      }

      final userDoc = await _firestore
          .collection(AppConstants.colUsers)
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        await _firebaseAuth.signOut();
        throw const AuthFailure(
          message: 'Perfil do usuário não encontrado. Contate o administrador.',
          code: 'profile-not-found',
        );
      }

      final userModel = UserModel.fromMap(userDoc.data()!, userDoc.id);

      if (userModel.username.toLowerCase() != cleanUsername) {
        await _firebaseAuth.signOut();
        throw const InvalidCredentialsFailure();
      }

      if (!userModel.active) {
        await _firebaseAuth.signOut();
        throw const UserInactiveFailure();
      }

      _logger.i('Login bem-sucedido: ${userModel.username}');
      return userModel;
    } on FirebaseAuthException catch (e) {
      _logger.w('FirebaseAuthException: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          throw const InvalidCredentialsFailure();
        case 'user-disabled':
          throw const UserInactiveFailure();
        case 'network-request-failed':
          throw const NetworkFailure();
        case 'too-many-requests':
          throw const AuthFailure(
            message: 'Muitas tentativas. Tente novamente em alguns minutos.',
            code: 'too-many-requests',
          );
        default:
          throw AuthFailure(
              message: e.message ?? 'Erro de autenticação.', code: e.code);
      }
    } on FirebaseException catch (e) {
      await _firebaseAuth.signOut();
      _logger.e('FirebaseException ao carregar perfil: ${e.code}');
      if (e.code == 'permission-denied') {
        throw const AuthFailure(
          message: 'Não foi possível acessar o perfil deste usuário.',
          code: 'profile-permission-denied',
        );
      }
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc = await _firestore
          .collection(AppConstants.colUsers)
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } on AuthFailure {
      rethrow;
    } catch (e) {
      _logger.e('Erro ao buscar usuário atual: $e');
      return null;
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return getCurrentUser();
    });
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _logger.i('Logout realizado.');
  }

  @override
  Future<void> updateFcmToken(String userId, String token) async {
    try {
      await _firestore.collection(AppConstants.colUsers).doc(userId).update(
          {'fcmToken': token, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      _logger.w('Falha ao atualizar FCM token: $e');
    }
  }

  @override
  Future<void> createUserAsAdmin({
    required String username,
    required String password,
    required String name,
    required String role,
    String? avatar,
  }) async {
    final cleanUsername = username.trim().toLowerCase();
    final email = '$cleanUsername@compry.com.br';

    try {
      String uid;
      try {
        uid = await _createAuthAccount(email: email, password: password);
      } on DioException catch (e) {
        final message = _firebaseRestError(e);
        if (!message.contains('EMAIL_EXISTS')) rethrow;

        // A previous app version deleted only Firestore. If no profile exists,
        // remove that orphaned Auth identity with the password supplied by the
        // administrator and then create a clean account.
        final existingProfile = await _firestore
            .collection(AppConstants.colUsers)
            .where('username', isEqualTo: cleanUsername)
            .limit(1)
            .get();
        if (existingProfile.docs.isNotEmpty) {
          throw const AuthFailure(
              message: 'Este nome de usuário já está em uso.');
        }

        try {
          await _deleteAuthAccount(email: email, password: password);
          uid = await _createAuthAccount(email: email, password: password);
        } on DioException catch (cleanupError) {
          _logger
              .e('Falha ao remover conta órfã: ${cleanupError.response?.data}');
          throw const AuthFailure(
            message:
                'Este usuário pertence a um cadastro antigo. Informe a mesma senha anterior para recriá-lo.',
          );
        }
      }

      // Adiciona ao Firestore
      await _firestore.collection(AppConstants.colUsers).doc(uid).set({
        'username': cleanUsername,
        'name': name,
        'email': email,
        'role': role,
        if (avatar != null) 'avatar': avatar,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logger.i(
          'Usuário $username criado com sucesso pelo Administrador via REST API.');
    } on AuthFailure {
      rethrow;
    } on DioException catch (e) {
      _logger.e('Erro ao criar usuário (REST API): ${e.response?.data}');
      final message = _firebaseRestError(e);
      if (message.contains('EMAIL_EXISTS')) {
        throw AuthFailure(message: 'Este nome de usuário já está em uso.');
      } else if (message.contains('WEAK_PASSWORD')) {
        throw AuthFailure(
            message: 'A senha é muito fraca. Escolha uma senha mais forte.');
      } else {
        throw AuthFailure(message: 'Erro ao criar conta de usuário.');
      }
    } catch (e) {
      _logger.e('Erro inesperado ao criar usuário: $e');
      throw AuthFailure(
          message: 'Ocorreu um erro inesperado ao criar o usuário.');
    }
  }

  Future<String> _createAuthAccount({
    required String email,
    required String password,
  }) async {
    final apiKey = Firebase.app().options.apiKey;
    final response = await Dio().post(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
      data: {
        'email': email,
        'password': password,
        'returnSecureToken': false,
      },
    );
    return response.data['localId'] as String;
  }

  Future<String> _deleteAuthAccount({
    required String email,
    required String password,
    String? expectedUserId,
  }) async {
    final apiKey = Firebase.app().options.apiKey;
    final signInResponse = await Dio().post(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey',
      data: {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      },
    );
    final idToken = signInResponse.data['idToken'] as String;
    final localId = signInResponse.data['localId'] as String;
    if (expectedUserId != null && localId != expectedUserId) {
      throw const AuthFailure(
          message: 'A conta autenticada não corresponde ao funcionário.');
    }
    await Dio().post(
      'https://identitytoolkit.googleapis.com/v1/accounts:delete?key=$apiKey',
      data: {'idToken': idToken},
    );
    return localId;
  }

  String _firebaseRestError(DioException error) =>
      error.response?.data?['error']?['message']?.toString() ?? '';

  @override
  Future<void> deleteEmployee({
    required String userId,
    required String email,
    required String password,
  }) async {
    try {
      await _deleteAuthAccount(
        email: email,
        password: password,
        expectedUserId: userId,
      );
    } on DioException catch (e) {
      final message = _firebaseRestError(e);
      if (!message.contains('EMAIL_NOT_FOUND') &&
          !message.contains('USER_NOT_FOUND')) {
        if (message.contains('INVALID_LOGIN_CREDENTIALS') ||
            message.contains('INVALID_PASSWORD')) {
          throw const AuthFailure(message: 'Senha do funcionário incorreta.');
        }
        _logger
            .e('Erro ao excluir conta do Firebase Auth: ${e.response?.data}');
        throw const AuthFailure(
            message: 'Não foi possível excluir a conta do funcionário.');
      }
    }

    await _firestore.collection(AppConstants.colUsers).doc(userId).delete();
    _logger.i('Funcionário $userId excluído do Auth e do Firestore.');
  }

  @override
  Future<void> updateAvatar(
      {required String userId, required String avatar}) async {
    try {
      await _firestore.collection(AppConstants.colUsers).doc(userId).update({
        'avatar': avatar,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Avatar do usuário $userId atualizado para $avatar.');
    } catch (e) {
      _logger.e('Erro ao atualizar avatar do usuário: $e');
      throw const AuthFailure(message: 'Erro ao atualizar foto de perfil.');
    }
  }
}
