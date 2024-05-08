import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:docs/app/providers.dart';
import 'package:docs/repositories/repository_exception.dart';

final _authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref));

class AuthRepository with RepositoryExceptionMixin {
  const AuthRepository(this._ref);

  static Provider<AuthRepository> get provider => _authRepositoryProvider;

  final Ref _ref;

  Account get _account => _ref.read(Dependency.account);

  Future<User> create({
    required String email,
    required String password,
    required String name,
  }) {
    return exceptionHandler(
      _account.create(
        userId: 'unique()',
        email: email,
        password: password,
        name: name,
      ),
    );
  }

  Future<Session> createSession({
    required String email,
    required String password,
  }) {
    return exceptionHandler(
      _account.createEmailPasswordSession(email: email, password: password),
    );
  }

  Future<User> get() {
    return exceptionHandler(
      _account.get(),
    );
  }

  Future<void> deleteSession({required String sessionId}) {
    return exceptionHandler(
      _account.deleteSession(sessionId: sessionId),
    );
  }
}
