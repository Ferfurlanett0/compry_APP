import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../viewmodels/create_user_viewmodel.dart';
import '../../../authentication/domain/entities/user_entity.dart';

class CreateUserDialog extends ConsumerStatefulWidget {
  const CreateUserDialog({super.key});

  @override
  ConsumerState<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends ConsumerState<CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  UserRole _selectedRole = UserRole.employee;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    
    ref.read(createUserViewModelProvider.notifier).createUser(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim().toLowerCase(),
      password: _passwordController.text,
      role: _selectedRole.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final state = ref.watch(createUserViewModelProvider);
    final isLoading = state is CreateUserLoading;

    ref.listen(createUserViewModelProvider, (prev, next) {
      if (next is CreateUserSuccess) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Usuário criado com sucesso!'),
            backgroundColor: cs.primary,
          ),
        );
      } else if (next is CreateUserError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: cs.error,
          ),
        );
      }
    });

    final avatarPath = _selectedRole == UserRole.admin 
        ? 'assets/images/administrador.png' 
        : 'assets/images/funcionario.png';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLG)),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceLG),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Novo Usuário',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Gap(AppDimensions.spaceLG),
                
                // Avatar Preview
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.primary.withValues(alpha: 0.2), width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        avatarPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.person, size: 40, color: cs.primary),
                      ),
                    ),
                  ),
                ),
                const Gap(AppDimensions.spaceMD),
                Center(
                  child: Text(
                    'Avatar selecionado automaticamente',
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
                const Gap(AppDimensions.spaceLG),

                AppTextField(
                  id: 'name',
                  controller: _nameController,
                  label: 'Nome Completo',
                  prefixIcon: Icons.person_outline,
                  enabled: !isLoading,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
                    return null;
                  },
                ),
                const Gap(AppDimensions.spaceMD),

                AppTextField(
                  id: 'username',
                  controller: _usernameController,
                  label: 'Nome de Usuário (Login)',
                  prefixIcon: Icons.alternate_email,
                  enabled: !isLoading,
                  textInputAction: TextInputAction.next,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('@compry.com.br', style: TextStyle(color: cs.onSurfaceVariant))],
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
                    if (value.contains(' ')) return 'Não pode conter espaços';
                    return null;
                  },
                ),
                const Gap(AppDimensions.spaceMD),

                AppTextField(
                  id: 'password',
                  controller: _passwordController,
                  label: 'Senha Inicial',
                  prefixIcon: Icons.lock_outline,
                  enabled: !isLoading,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Campo obrigatório';
                    if (value.length < 6) return 'No mínimo 6 caracteres';
                    return null;
                  },
                ),
                const Gap(AppDimensions.spaceMD),

                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Função',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: UserRole.employee, child: Text('Funcionário')),
                    DropdownMenuItem(value: UserRole.admin, child: Text('Administrador')),
                  ],
                  onChanged: isLoading ? null : (role) {
                    if (role != null) setState(() => _selectedRole = role);
                  },
                ),
                const Gap(AppDimensions.spaceXL),

                AppButton(
                  id: 'submit_btn',
                  label: 'Criar Usuário',
                  onPressed: isLoading ? null : _handleSubmit,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
