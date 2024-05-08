import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:docs/app/providers.dart';
import 'package:docs/components/controller_state_base.dart';
import 'package:docs/models/models.dart';
import 'package:docs/repositories/repositories.dart';

final _loginControllerProvider =
    StateNotifierProvider<LoginController, ControllerStateBase>(
  (ref) => LoginController(ref),
);

class LoginController extends StateNotifier<ControllerStateBase> {
  LoginController(this._read) : super(const ControllerStateBase());

  static StateNotifierProvider<LoginController, ControllerStateBase>
      get provider => _loginControllerProvider;

  static AlwaysAliveRefreshable<LoginController> get notifier =>
      provider.notifier;

  final Ref _read;

  Future<void> createSession({
    required String email,
    required String password,
  }) async {
    try {
      await _read
          .read(Repository.auth)
          .createSession(email: email, password: password);

      final user = await _read.read(Repository.auth).get();

      /// Sets the global app state user.
      _read.read(AppState.auth.notifier).setUser(user);
    } on RepositoryException catch (e) {
      state = state.copyWith(error: AppError(message: e.message));
    }
  }
}
