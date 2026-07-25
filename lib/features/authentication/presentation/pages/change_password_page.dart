import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final newPassword = _passwordController.text;
    
    if (newPassword.trim() == 'senha123' || newPassword.trim() == '123456') {
      setState(() {
        _errorMessage = 'A nova senha não pode ser a senha padrão.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        // Password updated successfully. Tell AuthViewModel that the change is done.
        ref.read(authViewModelProvider.notifier).completePasswordChange();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Erro ao atualizar a senha.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_reset_rounded,
                    size: 64,
                    color: cs.primary,
                  ),
                  const Gap(AppDimensions.spaceMD),
                  Text(
                    'Troca de Senha Obrigatória',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(AppDimensions.spaceSM),
                  Text(
                    'Como este é o seu primeiro acesso, ou sua senha foi redefinida para o padrão, você deve cadastrar uma nova senha para continuar.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(AppDimensions.spaceXL),
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spaceSM),
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: cs.error),
                          const Gap(AppDimensions.spaceSM),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: cs.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(AppDimensions.spaceMD),
                  ],
                  AppTextField(
                    id: 'new_password',
                    label: 'Nova Senha',
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Informe a nova senha';
                      }
                      if (val.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const Gap(AppDimensions.spaceMD),
                  AppTextField(
                    id: 'confirm_password',
                    label: 'Confirmar Nova Senha',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    validator: (val) {
                      if (val != _passwordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const Gap(AppDimensions.spaceXL),
                  AppButton(
                    id: 'btn-update-password',
                    label: 'Salvar e Continuar',
                    onPressed: _isLoading ? null : _updatePassword,
                    icon: Icons.check_circle_outline,
                  ),
                  const Gap(AppDimensions.spaceMD),
                  TextButton(
                    onPressed: () {
                       ref.read(authViewModelProvider.notifier).logout();
                    },
                    child: Text(
                      'Sair e trocar depois',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
