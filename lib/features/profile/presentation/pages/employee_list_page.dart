import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../authentication/data/models/user_model.dart';
import '../../../../core/config/providers.dart';

import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../widgets/create_user_dialog.dart';

// 1. Definição do StreamProvider que busca os usuários que não são admin
final employeesStreamProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .where((user) => user.role != 'ADMIN' && user.role != 'admin')
            .toList();
      });
});

class EmployeeListPage extends ConsumerWidget {
  const EmployeeListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final employeesAsync = ref.watch(employeesStreamProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Funcionários'),
      ),
      floatingActionButton: currentUser?.isAdmin == true ? FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const CreateUserDialog(),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Novo Usuário'),
      ) : null,
      body: employeesAsync.when(
        data: (employees) {
          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline_rounded, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                  const Gap(AppDimensions.spaceMD),
                  Text(
                    'Nenhum funcionário cadastrado.',
                    style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            itemCount: employees.length,
            separatorBuilder: (_, __) => const Gap(AppDimensions.spaceMD),
            itemBuilder: (context, index) {
              final employee = employees[index];
              return _EmployeeCard(employee: employee);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Erro ao carregar funcionários', style: TextStyle(color: cs.error)),
        ),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final UserModel employee;

  const _EmployeeCard({required this.employee});

  void _sendResetEmail(BuildContext context) async {
    try {
      // Find the email for this employee. Typically we try the compry.app domain
      final email = '${employee.username}@compry.app'.toLowerCase();
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('E-mail de recuperação enviado para $email'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar e-mail: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/funcionario.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.person, color: cs.primary),
              ),
            ),
          ),
          const Gap(AppDimensions.spaceMD),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '@${employee.username}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // Action Button
          Tooltip(
            message: 'Resetar Senha',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _sendResetEmail(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.vpn_key_rounded,
                    color: cs.onPrimaryContainer,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
