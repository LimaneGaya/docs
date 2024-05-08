import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:docs/app/providers.dart';
import 'package:docs/app/state/state.dart';
import 'package:docs/app/utils.dart';
import 'package:docs/models/models.dart';
import 'package:docs/repositories/repositories.dart';

final _authServiceProvider =
    StateNotifierProvider<AuthService, AuthState>((ref) => AuthService(ref));

class AuthService extends StateNotifier<AuthState> {
  AuthService(this._read)
      : super(const AuthState.unauthenticated(isLoading: true)) {
    refresh();
  }

  static StateNotifierProvider<AuthService, AuthState> get provider =>
      _authServiceProvider;

  final Ref _read;

  Future<void> refresh() async {
    try {
      final user = await _read.read(Repository.auth).get();
      setUser(user);
    } on RepositoryException catch (_) {
      logger.info('Not authenticated');
      state = const AuthState.unauthenticated();
    }
  }

  void setUser(User user) {
    logger.info('Authentication successful, setting $user');
    state = state.copyWith(user: user, isLoading: false);
  }

  Future<void> signOut() async {
    try {
      await _read.read(Repository.auth).deleteSession(sessionId: 'current');
      logger.info('Sign out successful');
      state = const AuthState.unauthenticated();
    } on RepositoryException catch (e) {
      state = state.copyWith(error: AppError(message: e.message));
    }
  }
}

class AuthState extends StateBase {
  final User? user;
  final bool isLoading;

  const AuthState({
    this.user,
    this.isLoading = false,
    super.error,
  });

  const AuthState.unauthenticated({this.isLoading = false})
      : user = null,
        super(error: null);

  @override
  List<Object?> get props => [user, isLoading, error];

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    AppError? error,
  }) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}
