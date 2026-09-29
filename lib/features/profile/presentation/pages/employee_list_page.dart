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
import '../../../../shared/widgets/compry_components.dart';
import '../../../../shared/widgets/empty_state.dart';

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
        titleSpacing: 0,
        toolbarHeight: 78,
        title: const CompryPageHeader(
          label: 'Administração',
          title: 'Funcionários',
        ),
      ),
      body: employeesAsync.when(
        data: (employees) {
          if (employees.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline_rounded,
              title: 'Nenhum funcionário',
              message:
                  'Adicione a primeira pessoa para começar a criar listas.',
              actionLabel:
                  currentUser?.isAdmin == true ? 'Novo funcionário' : null,
              onAction: currentUser?.isAdmin == true
                  ? () => showDialog(
                        context: context,
                        builder: (_) => const CreateUserDialog(),
                      )
                  : null,
            );
          }

          return CompryResponsiveBody(
            child: ListView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 16,
              ),
              children: [
                if (currentUser?.isAdmin == true) ...[
                  FilledButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const CreateUserDialog(),
                    ),
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Novo funcionário'),
                  ),
                  const SizedBox(height: 20),
                ],
                ComprySectionHeader(
                  title: 'Equipe ativa',
                  count: '${employees.length} pessoas',
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border.symmetric(
                      horizontal: BorderSide(color: cs.outlineVariant),
                    ),
                  ),
                  child: Column(
                    children: [
                      for (var index = 0;
                          index < employees.length;
                          index++) ...[
                        _EmployeeCard(employee: employees[index]),
                        if (index != employees.length - 1)
                          Divider(
                              height: 1, indent: 66, color: cs.outlineVariant),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ao excluir um acesso, o mesmo usuário poderá ser criado novamente.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
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

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 72),
      child: Row(
        children: [
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 44,
            height: 44,
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
                  style: theme.textTheme.titleSmall,
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
          PopupMenuButton<String>(
            tooltip: 'Opções de ${employee.name}',
            onSelected: (value) {
              if (value == 'reset') _sendResetEmail(context);
              if (value == 'delete') _deleteEmployee(context, ref);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'reset', child: Text('Redefinir senha')),
              PopupMenuItem(value: 'delete', child: Text('Excluir acesso')),
            ],
          ),
          const SizedBox(width: 4),
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
