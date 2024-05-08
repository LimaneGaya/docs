import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:docs/app/providers.dart';
import 'package:docs/components/controller_state_base.dart';
import 'package:docs/models/app_error.dart';
import 'package:docs/repositories/repositories.dart';

final _registerControllerProvider =
    StateNotifierProvider<RegisterController, ControllerStateBase>(
  (ref) => RegisterController(ref),
);

class RegisterController extends StateNotifier<ControllerStateBase> {
  RegisterController(this._read) : super(const ControllerStateBase());

  static StateNotifierProvider<RegisterController, ControllerStateBase>
      get provider => _registerControllerProvider;

  static AlwaysAliveRefreshable<RegisterController> get notifier =>
      provider.notifier;

  final Ref _read;

  Future<void> create({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await _read
          .read(Repository.auth)
          .create(email: email, password: password, name: name);

      await _read
          .read(Repository.auth)
          .createSession(email: email, password: password);

      /// Sets the global app state user.
      _read.read(AppState.auth.notifier).setUser(user);
    } on RepositoryException catch (e) {
      state = state.copyWith(error: AppError(message: e.message));
    }
  }
}
