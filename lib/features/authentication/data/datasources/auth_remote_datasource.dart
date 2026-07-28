/// Compry — Auth Remote DataSource
/// Data layer — Firebase Authentication + Firestore
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

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
    try {
      // Busca o usuário pelo username no Firestore
      final query = await _firestore
          .collection(AppConstants.colUsers)
          .where('username', isEqualTo: cleanUsername)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw const UserNotFoundFailure();
      }

      final userDoc = query.docs.first;
      final userData = userDoc.data();

      // Obtém o email do usuário para autenticar no Firebase Auth
      // Tenta o domínio novo (Compry) e os domínios antigos (ListaPro)
      final emailsToTry = [
        '$cleanUsername@compry.com.br',
        '$cleanUsername@compry.app',
        '$cleanUsername@Compry.app',
        '$cleanUsername@listapro.com.br',
        '$cleanUsername@listapro.app',
        '$cleanUsername@listapro.com'
      ];

      UserCredential? credential;
      FirebaseAuthException? lastAuthError;

      for (final email in emailsToTry) {
        try {
          credential = await _firebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: cleanPassword,
          );
          break; // Login bem sucedido!
        } on FirebaseAuthException catch (e) {
          lastAuthError = e;
          // Se o erro for de credencial inválida, continua o loop e tenta o próximo email
          if (e.code != 'invalid-credential' && e.code != 'user-not-found' && e.code != 'wrong-password') {
            rethrow; // Lança outros erros (ex: bloqueio, sem rede) imediatamente
          }
        }
      }

      if (credential == null || credential.user == null) {
        if (lastAuthError != null) throw lastAuthError;
        throw const InvalidCredentialsFailure();
      }

      final userModel = UserModel.fromMap(userData, userDoc.id);

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
          throw AuthFailure(message: e.message ?? 'Erro de autenticação.', code: e.code);
      }
    } on UserNotFoundFailure {
      throw const InvalidCredentialsFailure();
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
      await _firestore
          .collection(AppConstants.colUsers)
          .doc(userId)
          .update({'fcmToken': token, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      _logger.w('Falha ao atualizar FCM token: $e');
    }
  }
}
