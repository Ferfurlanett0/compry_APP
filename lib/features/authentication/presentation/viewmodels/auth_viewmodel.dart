/// Compry — Auth ViewModel
/// Presentation layer — manages authentication state
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/user_entity.dart';
import '../../../authentication/domain/usecases/auth_usecases.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/config/providers.dart';
import '../../../../core/errors/failures.dart';

// ─── Auth State ───────────────────────────────────────────────────────────────

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
}

class AuthRequiresPasswordChange extends AuthState {
  final UserEntity user;
  const AuthRequiresPasswordChange(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ─── Auth ViewModel ───────────────────────────────────────────────────────────

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AuthRepository _repository;
  final Logger _logger;

  AuthViewModel({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required AuthRepository repository,
    required Logger logger,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _repository = repository,
        _logger = logger,
        super(const AuthInitial()) {
    _checkCurrentUser();
  }

  UserEntity? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;

  bool get isAuthenticated => state is AuthAuthenticated;

  /// Verifica usuário na inicialização do app (RF-002)
  Future<void> _checkCurrentUser() async {
    state = const AuthLoading();
    try {
      final user = await _getCurrentUserUseCase.call();
      if (user != null && user.active) {
        state = AuthAuthenticated(user);
      } else {
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      _logger.e('Erro ao verificar sessão: $e');
      state = const AuthUnauthenticated();
    }
  }

  /// Realiza login (RF-001)
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _loginUseCase.call(
        LoginParams(username: username, password: password),
      );
      
      if (password.trim() == 'senha123' || password.trim() == '123456') {
        state = AuthRequiresPasswordChange(user);
        _logger.i('Login requer troca de senha: ${user.username}');
      } else {
        state = AuthAuthenticated(user);
        _logger.i('Login: ${user.username} (${user.role})');
      }
    } on InvalidCredentialsFailure catch (e) {
      state = AuthError(e.message);
    } on UserNotFoundFailure catch (e) {
      state = AuthError(e.message);
    } on UserInactiveFailure catch (e) {
      state = AuthError(e.message);
    } on NetworkFailure catch (e) {
      state = AuthError(e.message);
    } on ArgumentError catch (e) {
      state = AuthError(e.message.toString());
    } on StateError catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      _logger.e('Erro inesperado no login: $e');
      state = const AuthError('Ocorreu um erro inesperado. Tente novamente.');
    }
  }

  /// Realiza logout (RF-003)
  Future<void> logout() async {
    try {
      await _logoutUseCase.call();
      state = const AuthUnauthenticated();
      _logger.i('Logout realizado.');
    } catch (e) {
      _logger.e('Erro no logout: $e');
      // Force unauthenticated state even on error
      state = const AuthUnauthenticated();
    }
  }

  void completePasswordChange() {
    if (state is AuthRequiresPasswordChange) {
      final user = (state as AuthRequiresPasswordChange).user;
      state = AuthAuthenticated(user);
    }
  }

  /// Limpa erro da UI
  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }

  /// Atualiza o avatar do usuário logado
  Future<void> updateAvatar(String avatar) async {
    if (state is AuthAuthenticated) {
      final user = (state as AuthAuthenticated).user;
      final updatedUser = user.copyWith(avatar: avatar);
      try {
        await _repository.updateAvatar(userId: user.id, avatar: avatar);
        state = AuthAuthenticated(updatedUser);
        _logger.i('Avatar atualizado no AuthViewModel para: $avatar');
      } catch (e) {
        _logger.e('Erro ao atualizar avatar no AuthViewModel: $e');
      }
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final logger = ref.watch(loggerProvider);

  return AuthViewModel(
    loginUseCase: LoginUseCase(repository),
    logoutUseCase: LogoutUseCase(repository),
    getCurrentUserUseCase: GetCurrentUserUseCase(repository),
    repository: repository,
    logger: logger,
  );
});

/// Provider conveniente para o usuário atual
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authViewModelProvider);
  return authState is AuthAuthenticated ? authState.user : null;
});
