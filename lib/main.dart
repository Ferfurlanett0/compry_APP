/// Compry — Application Entry Point
/// Modo Demo: funciona sem Firebase configurado.
/// Para ativar Firebase: rodar `flutterfire configure` e atualizar firebase_options.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/config/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/services/fcm_service.dart';
import 'features/authentication/data/models/user_model.dart';
import 'features/shopping_lists/data/models/shopping_item_model.dart';
import 'features/shopping_lists/data/models/shopping_list_model.dart';
import 'core/sync/models/offline_operation_model.dart';
import 'core/config/providers.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // ─── Firebase Initialization ──────────────────────────────────────────────────
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  // ─── Orientação ──────────────────────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ─── Hive initialization ─────────────────────────────────────────────────────
  await Hive.initFlutter();

  // Register Hive adapters
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserModelAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ShoppingListModelAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ShoppingItemModelAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(OfflineOperationModelAdapter());

  // Open Hive boxes
  await Hive.openBox<UserModel>(AppConstants.hiveBoxUsers);
  await Hive.openBox<ShoppingListModel>(AppConstants.hiveBoxLists);
  await Hive.openBox<ShoppingItemModel>(AppConstants.hiveBoxItems);
  await Hive.openBox<OfflineOperationModel>(AppConstants.hiveBoxOfflineQueue);
  await Hive.openBox(AppConstants.hiveBoxSettings);

  // ─── Sistema de UI ───────────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  // ─── Provider Container ─────────────────────────────────────────────────────
  final container = ProviderContainer();

  // Initialize FCM
  try {
    final fcmService = container.read(fcmServiceProvider);
    await fcmService.initialize();
  } catch (e) {
    debugPrint('FCM initialization failed: $e');
  }

  // ─── Run app ──────────────────────────────────────────────────────────────────
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const CompryApp(),
    ),
  );
}

class CompryApp extends ConsumerWidget {
  const CompryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Material Design 3 themes
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),

      // GoRouter
      routerConfig: router,

      // Locale
      locale: const Locale('pt', 'BR'),

      // Builder
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(
              mediaQuery.textScaler.scale(1.0).clamp(0.8, 1.4),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
