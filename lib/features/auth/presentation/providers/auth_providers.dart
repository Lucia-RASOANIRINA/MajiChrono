import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import 'package:majichrono/core/providers/core_providers.dart';
import 'package:majichrono/core/session/user_role.dart';
import 'package:majichrono/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:majichrono/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:majichrono/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:majichrono/features/auth/domain/repositories/auth_repository.dart';
import 'package:majichrono/features/auth/presentation/controllers/auth_controller.dart';
import 'package:majichrono/features/auth/presentation/controllers/auth_state.dart';

final localAuthProvider = Provider<LocalAuthentication>(
  (ref) => LocalAuthentication(),
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(apiClientProvider)),
);

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSource(ref.watch(secureStoreProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(apiClientProvider);

  final repository = AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    local: ref.watch(authLocalDataSourceProvider),
    onAccessTokenChanged: (token) =>
        ref.read(accessTokenProvider.notifier).state = token,
  );

  // Bouclage differe : le client a besoin du repository pour rafraichir, et le
  // repository a besoin du client pour appeler `/auth/refresh`.
  client.attachRefreshHandler(() async {
    final session = await repository.refresh();
    return session.accessToken;
  });

  return repository;
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

/// Profil actif, derive du compte authentifie.
///
/// Au module 0 il etait choisi a la main et persiste en preferences. Il est
/// desormais une **consequence** de la session : un profil ne peut plus etre
/// change en vidant une preference locale, ce qui aurait donne acces aux ecrans
/// d'un autre role sans que le serveur n'en sache rien.
final activeRoleProvider = Provider<UserRole?>((ref) {
  final auth = ref.watch(authControllerProvider).valueOrNull;
  return switch (auth) {
    AuthAuthenticated(:final account) => account.role,
    AuthLocked(:final account) => account.role,
    _ => null,
  };
});
