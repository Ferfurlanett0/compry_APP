// Compry — Widget Tests
// Para executar: flutter test

import 'package:flutter_test/flutter_test.dart';
import 'package:lista_pro/core/theme/app_colors.dart';
import 'package:lista_pro/core/theme/app_theme.dart';
import 'package:lista_pro/features/authentication/data/models/user_model.dart';

import 'dart:io';

void main() {
  // Tests will be added after Firebase setup
  group('Compry Tests', () {
    test('login is not distributed with credentials filled in', () {
      final source = File(
        'lib/features/authentication/presentation/pages/login_page.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('TextEditingController(text:')));
      expect(source, isNot(contains("'edemar'")));
      expect(source, isNot(contains("'admin123'")));
    });

    test('employee authentication email uses Firestore value with fallback',
        () {
      final now = DateTime(2026);
      final storedEmailEmployee = UserModel(
        id: '1',
        name: 'Funcionário',
        username: 'funcionario',
        role: 'EMPLOYEE',
        email: 'conta@dominio.com',
        active: true,
        createdAt: now,
        updatedAt: now,
      );
      final legacyEmployee = UserModel(
        id: '2',
        name: 'Legado',
        username: 'legado',
        role: 'EMPLOYEE',
        active: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(storedEmailEmployee.authEmail, 'conta@dominio.com');
      expect(legacyEmployee.authEmail, 'legado@compry.com.br');
    });

    test('orphaned authentication account does not block username reuse', () {
      final source = File(
        'lib/features/authentication/data/datasources/auth_remote_datasource.dart',
      ).readAsStringSync();

      expect(source, contains('+active@compry.com.br'));
      expect(source, isNot(contains('Informe a mesma senha anterior')));
    });

    test('home header renders the saved user avatar', () {
      final source = File(
        'lib/features/shopping_lists/presentation/pages/home_page.dart',
      ).readAsStringSync();

      expect(source, contains('user?.avatarPath'));
      expect(source, contains('Image.asset('));
      expect(source, contains('errorBuilder:'));
    });

    test('confirmation dialogs keep readable colors in both themes', () {
      expect(
        AppTheme.light.dialogTheme.titleTextStyle?.color,
        AppColorsLight.textPrimary,
      );
      expect(
        AppTheme.light.dialogTheme.contentTextStyle?.color,
        AppColorsLight.textSecondary,
      );
      expect(
        AppTheme.dark.dialogTheme.titleTextStyle?.color,
        AppColorsDark.textPrimary,
      );
      expect(
        AppTheme.dark.dialogTheme.contentTextStyle?.color,
        AppColorsDark.textSecondary,
      );
    });

    test('online startup never authenticates from stale local cache', () {
      final source = File(
        'lib/features/authentication/data/repositories/auth_repository_impl.dart',
      ).readAsStringSync();

      expect(source, contains('if (hasConnection)'));
      expect(source, contains('_clearStaleLocalSession()'));
      expect(
        source,
        contains('Sem conexão, mantém o suporte offline'),
      );
    });
  });
}
