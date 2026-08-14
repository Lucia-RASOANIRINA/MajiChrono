import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majichrono/core/providers/core_providers.dart';
import 'package:majichrono/core/storage/prefs_store.dart';

/// Les trois profils d'une application unique (§2.1).
///
/// Le role administrateur n'est jamais choisi par l'utilisateur : il est
/// attribue cote serveur (EXI-T02). Il figure ici parce que l'application doit
/// savoir l'afficher, pas le revendiquer.
enum UserRole {
  client('client'),
  driver('driver'),
  admin('admin');

  const UserRole(this.wireName);

  /// Valeur echangee avec le backend.
  final String wireName;

  static UserRole? fromWire(String? value) {
    for (final role in UserRole.values) {
      if (role.wireName == value) return role;
    }
    return null;
  }

  IconData get icon => switch (this) {
    UserRole.client => Icons.local_shipping_outlined,
    UserRole.driver => Icons.two_wheeler_outlined,
    UserRole.admin => Icons.admin_panel_settings_outlined,
  };
}

/// Role actif de la session.
///
/// Au module 0 il est choisi manuellement pour rendre la coquille navigable ;
/// au module 1 il sera derive du compte authentifie, sans changer ce provider
/// ni les redirections du routeur qui en dependent.
final activeRoleProvider = NotifierProvider<ActiveRoleController, UserRole?>(
  ActiveRoleController.new,
);

class ActiveRoleController extends Notifier<UserRole?> {
  @override
  UserRole? build() {
    final stored = ref.watch(prefsStoreProvider).getString(PrefsStore.keyActiveRole);
    return UserRole.fromWire(stored);
  }

  Future<void> select(UserRole role) async {
    state = role;
    await ref.read(prefsStoreProvider).setString(PrefsStore.keyActiveRole, role.wireName);
  }

  Future<void> clear() async {
    state = null;
    await ref.read(prefsStoreProvider).remove(PrefsStore.keyActiveRole);
  }
}
