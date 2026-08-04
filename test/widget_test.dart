// Compry — Widget Tests
// Para executar: flutter test

import 'package:flutter_test/flutter_test.dart';
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
  });
}
