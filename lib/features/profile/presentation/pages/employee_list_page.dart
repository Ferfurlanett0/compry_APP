import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/errors/failures.dart';
import '../../../authentication/data/models/user_model.dart';
import '../../../../core/config/providers.dart';

import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../widgets/create_user_dialog.dart';

// 1. Definição do StreamProvider que busca os usuários que não são admin
final employeesStreamProvider =
    StreamProvider.autoDispose<List<UserModel>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('users').snapshots().map((snapshot) {
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
      floatingActionButton: currentUser?.isAdmin == true
          ? FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const CreateUserDialog(),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Novo Usuário'),
            )
          : null,
      body: employeesAsync.when(
        data: (employees) {
          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline_rounded,
                      size: 64,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                  const Gap(AppDimensions.spaceMD),
                  Text(
                    'Nenhum funcionário cadastrado.',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: cs.onSurfaceVariant),
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
          child: Text('Erro ao carregar funcionários',
              style: TextStyle(color: cs.error)),
        ),
      ),
    );
  }
}

class _EmployeeCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
              color: cs.primaryContainer,
              border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
            ),
            child: ClipOval(
              child: Image.asset(
                employee.avatarPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.person, color: cs.primary),
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

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const Gap(AppDimensions.spaceXS),
              Tooltip(
                message: 'Excluir Usuário',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _deleteEmployee(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: cs.onErrorContainer,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEmployee(BuildContext context, WidgetRef ref) async {
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Usuário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Tem certeza que deseja excluir ${employee.name} (@${employee.username})? A conta será removida permanentemente.'),
            const Gap(AppDimensions.spaceMD),
            TextField(
              controller: passwordController,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Senha do funcionário',
                hintText: 'Confirme a senha para excluir',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(passwordController.text),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    passwordController.dispose();

    if (password != null && context.mounted) {
      if (password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe a senha do funcionário.')),
        );
        return;
      }
      try {
        await ref.read(authRepositoryProvider).deleteEmployee(
              userId: employee.id,
              email: employee.authEmail,
              password: password,
            );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuário ${employee.name} excluído com sucesso.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } on Failure catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro inesperado ao excluir o usuário.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
