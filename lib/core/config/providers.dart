/// Compry — Dependency Injection Providers (Riverpod)
/// MODO DEMO: usa datasources em memória (sem Firebase).
/// Para mudar para Firebase real: altere kDemoMode = false
/// e rode `flutterfire configure` para gerar firebase_options.dart
library;

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_constants.dart';
import '../services/connectivity_service.dart';
import '../services/fcm_service.dart';
import '../sync/services/sync_service.dart';
import '../../features/authentication/data/datasources/auth_local_datasource.dart';
import '../../features/authentication/data/datasources/auth_memory_datasource.dart';
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/models/user_model.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';

import '../../features/shopping_lists/data/datasources/shopping_list_memory_datasource.dart';
import '../../features/shopping_lists/data/datasources/shopping_list_remote_datasource.dart';
import '../../features/shopping_lists/data/repositories/shopping_list_repository_impl.dart';
import '../../features/shopping_lists/domain/repositories/shopping_list_repository.dart';

import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';

// ─── MODO DEMO ────────────────────────────────────────────────────────────────
// Altere para false quando o Firebase estiver configurado
const kDemoMode = false;

// ─── Infrastructure ──────────────────────────────────────────────────────────

final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 100,
      colors: true,
      printEmojis: true,
    ),
    level: Level.debug,
  );
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final uuidProvider = Provider<Uuid>((ref) => const Uuid());

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final userBoxProvider = Provider<Box<UserModel>>((ref) {
  return Hive.box<UserModel>(AppConstants.hiveBoxUsers);
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ─── Services ────────────────────────────────────────────────────────────────

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService(
    connectivity: ref.watch(connectivityProvider),
    logger: ref.watch(loggerProvider),
  );
});

/// Stream de conectividade para toda a app
final isConnectedProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).onConnectivityChanged;
});

// ─── Auth DataSources ────────────────────────────────────────────────────────

/// Datasource de autenticação — demo ou Firebase real
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  if (kDemoMode) {
    return AuthMemoryDataSource(logger: ref.watch(loggerProvider));
  }
  return AuthRemoteDataSourceImpl(
    firebaseAuth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    logger: ref.watch(loggerProvider),
  );
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(
    secureStorage: ref.watch(secureStorageProvider),
    userBox: ref.watch(userBoxProvider),
    logger: ref.watch(loggerProvider),
  );
});

// ─── Auth Repository ─────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    local: ref.watch(authLocalDataSourceProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    logger: ref.watch(loggerProvider),
  );
});

// ─── Shopping List DataSource ─────────────────────────────────────────────────

/// DataSource de listas — demo (memória) ou Firebase real
final shoppingListRemoteDataSourceProvider =
    Provider<ShoppingListRemoteDataSource>((ref) {
  if (kDemoMode) {
    return ShoppingListMemoryDataSource(uuid: ref.watch(uuidProvider));
  }
  return ShoppingListRemoteDataSourceImpl(
    firestore: FirebaseFirestore.instance,
    uuid: ref.watch(uuidProvider),
    logger: ref.watch(loggerProvider),
  );
});

// ─── Shopping List Repository ────────────────────────────────────────────────

final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  return ShoppingListRepositoryImpl(
    remote: ref.watch(shoppingListRemoteDataSourceProvider),
    syncService: ref.watch(syncServiceProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    logger: ref.watch(loggerProvider),
  );
});

// ─── Notifications Repository ────────────────────────────────────────────────

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
    logger: ref.watch(loggerProvider),
  );
});

// ─── Theme Provider ────────────────────────────────────────────────────────────

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final box = Hive.box(AppConstants.hiveBoxSettings);
  final saved = box.get('themeMode', defaultValue: 'light');
  switch (saved) {
    case 'dark': return ThemeMode.dark;
    case 'light':
    default: return ThemeMode.light;
  }
});


