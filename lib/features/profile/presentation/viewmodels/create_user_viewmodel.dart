import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../authentication/domain/usecases/auth_usecases.dart';
import '../../../../core/config/providers.dart';

sealed class CreateUserState {
  const CreateUserState();
}

class CreateUserInitial extends CreateUserState {
  const CreateUserInitial();
}

class CreateUserLoading extends CreateUserState {
  const CreateUserLoading();
}

class CreateUserSuccess extends CreateUserState {
  const CreateUserSuccess();
}

class CreateUserError extends CreateUserState {
  final String message;
  const CreateUserError(this.message);
}

class CreateUserViewModel extends StateNotifier<CreateUserState> {
  final CreateUserAsAdminUseCase _createUserUseCase;
  final Logger _logger;

  CreateUserViewModel({
    required CreateUserAsAdminUseCase createUserUseCase,
    required Logger logger,
  })  : _createUserUseCase = createUserUseCase,
        _logger = logger,
        super(const CreateUserInitial());

  Future<void> createUser({
    required String username,
    required String password,
    required String name,
    required String role,
    String? avatar,
  }) async {
    state = const CreateUserLoading();
    try {
      await _createUserUseCase.call(
        CreateUserAsAdminParams(
          username: username,
          password: password,
          name: name,
          role: role,
          avatar: avatar,
        ),
      );
      state = const CreateUserSuccess();
      _logger.i('CreateUserViewModel: User $username created successfully');
    } catch (e) {
      _logger.e('CreateUserViewModel Error: $e');
      state = CreateUserError(e.toString().replaceAll('Exception: ', '').replaceAll('ArgumentError: ', ''));
    }
  }
}

final createUserViewModelProvider =
    StateNotifierProvider.autoDispose<CreateUserViewModel, CreateUserState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final logger = ref.watch(loggerProvider);

  return CreateUserViewModel(
    createUserUseCase: CreateUserAsAdminUseCase(repository),
    logger: logger,
  );
});
