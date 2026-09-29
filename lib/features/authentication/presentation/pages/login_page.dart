import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/autofill_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late final bool _allowAutofill;
  bool _usernameTouched = false;
  bool _passwordTouched = false;

  @override
  void initState() {
    super.initState();
    _allowAutofill = AutofillService.hasCompletedManualLogin;
    if (!_allowAutofill) {
      _usernameController.addListener(_discardRestoredUsername);
      _passwordController.addListener(_discardRestoredPassword);
    }
  }

  void _discardRestoredUsername() {
    if (!_usernameTouched && _usernameController.text.isNotEmpty) {
      _usernameController.clear();
    }
  }

  void _discardRestoredPassword() {
    if (!_passwordTouched && _passwordController.text.isNotEmpty) {
      _passwordController.clear();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authViewModelProvider.notifier).login(
          username: _usernameController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.message)));
        ref.read(authViewModelProvider.notifier).clearError();
      } else if (next is AuthAuthenticated ||
          next is AuthRequiresPasswordChange) {
        if (!_allowAutofill) {
          AutofillService.markManualLoginCompleted();
          TextInput.finishAutofillContext(shouldSave: true);
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 760;
                  final content = wide
                      ? Row(
                          children: [
                            Expanded(child: _brand(context)),
                            Expanded(child: _form(context, isLoading)),
                          ],
                        )
                      : Column(
                          children: [
                            Flexible(
                              flex: constraints.maxHeight < 650 ? 4 : 5,
                              child: _brand(context),
                            ),
                            Flexible(
                              flex: constraints.maxHeight < 650 ? 7 : 6,
                              child: _form(context, isLoading),
                            ),
                          ],
                        );
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: content,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _brand(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF163E26),
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF3E6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.checklist_rounded,
                    color: Color(0xFF163E26)),
              ),
              const SizedBox(height: 24),
              Text(
                'Listas que chegam prontas para agir.',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      height: 1.12,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Monte, envie, acompanhe e conclua sem perder nenhuma etapa.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFC8DECF),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _form(BuildContext context, bool isLoading) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Entrar',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Use o acesso criado pelo administrador da empresa.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      id: 'login-username',
                      controller: _usernameController,
                      label: 'Usuário',
                      hint: 'Digite seu usuário',
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      onTap: () => _usernameTouched = true,
                      autofillHints: _allowAutofill
                          ? const [AutofillHints.username]
                          : const [],
                      enabled: !isLoading,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Digite seu usuário'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      id: 'login-password',
                      controller: _passwordController,
                      label: 'Senha',
                      hint: 'Digite sua senha',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      autofillHints: _allowAutofill
                          ? const [AutofillHints.password]
                          : const [],
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      onTap: () => _passwordTouched = true,
                      onSubmitted: (_) => _handleLogin(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Digite sua senha'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      id: 'btn-login',
                      label: 'Entrar',
                      onPressed: isLoading ? null : _handleLogin,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Os dados ficam vazios até o primeiro preenchimento manual.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
