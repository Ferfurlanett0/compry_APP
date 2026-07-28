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
      var query = await _firestore
          .collection(AppConstants.colUsers)
          .where('username', isEqualTo: cleanUsername)
          .limit(1)
          .get();

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

      // Se o usuário não existe no Firestore, vamos tentar autenticar no Firebase Auth primeiro.
      // Se a senha estiver correta, criamos o usuário no Firestore automaticamente!
      if (query.docs.isEmpty) {
        for (final email in emailsToTry) {
          try {
            credential = await _firebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: cleanPassword,
            );
            break; // Login bem sucedido!
          } on FirebaseAuthException catch (e) {
            lastAuthError = e;
          }
        }

        if (credential != null && credential.user != null) {
          try {
            // O usuário existe no Auth e a senha está correta! Vamos criá-lo no Firestore.
            final isAdmin = cleanUsername.contains('admin') || cleanUsername == 'edemar';
            final capName = cleanUsername.isNotEmpty 
                ? cleanUsername[0].toUpperCase() + cleanUsername.substring(1) 
                : 'Usuário';

            final uid = credential.user!.uid;

            await _firestore.collection(AppConstants.colUsers).doc(uid).set({
              'username': cleanUsername,
              'name': capName,
              'email': credential.user!.email ?? '$cleanUsername@compry.com.br',
              'isAdmin': isAdmin,
              'active': true,
            });

            // Busca novamente o documento que acabou de ser criado
            query = await _firestore
                .collection(AppConstants.colUsers)
                .where('username', isEqualTo: cleanUsername)
                .limit(1)
                .get();
          } catch (e) {
             _logger.e('Erro ao criar documento do usuário no Firestore: $e');
             throw AuthFailure('Erro de permissão no Firestore. Contate o suporte.');
          }
        } else {
          throw const UserNotFoundFailure();
        }
      }

      final userDoc = query.docs.first;
      final userData = userDoc.data();

      // Força permissão de Admin para o Edemar ou usuários com "admin" no nome
      if (cleanUsername == 'edemar' || cleanUsername.contains('admin')) {
        if (userData['isAdmin'] != true) {
          await _firestore.collection(AppConstants.colUsers).doc(cleanUsername).update({
            'isAdmin': true,
          });
          userData['isAdmin'] = true;
        }
      }

      // Já autenticamos ao criar o doc? Se não (usuário já existia), autenticamos agora
      if (credential == null || credential.user == null) {
        for (final email in emailsToTry) {
          try {
            credential = await _firebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: cleanPassword,
            );
            break; // Login bem sucedido!
          } on FirebaseAuthException catch (e) {
            lastAuthError = e;
            if (e.code != 'invalid-credential' && e.code != 'user-not-found' && e.code != 'wrong-password') {
              rethrow;
            }
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
