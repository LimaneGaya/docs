export 'utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:docs/app/navigation/routes.dart';
import 'package:docs/app/providers.dart';
import 'package:routemaster/routemaster.dart';

final _isAuthenticatedProvider =
    Provider<bool>((ref) => ref.watch(AppState.auth).isAuthenticated);

final _isAuthLoading =
    Provider<bool>((ref) => ref.watch(AppState.auth).isLoading);

class GoogleDocsApp extends ConsumerStatefulWidget {
  const GoogleDocsApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GoogleDocsAppState();
}

class _GoogleDocsAppState extends ConsumerState<GoogleDocsApp> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(_isAuthLoading);
    if (isLoading) {
      return Container(
        color: Colors.white,
      );
    }

    return MaterialApp.router(
      routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
        final isAuthenticated = ref.watch(_isAuthenticatedProvider);
        return isAuthenticated ? routesLoggedIn : routesLoggedOut;
      }),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}

abstract class AppColors {
  static const secondary = Color(0xFF216BDD);
}
