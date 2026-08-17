import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:majichrono/core/error/failure.dart';
import 'package:majichrono/core/network/api_endpoints.dart';
import 'package:majichrono/core/network/data_meter.dart';
import 'package:majichrono/core/providers/core_providers.dart';
import 'package:majichrono/core/storage/prefs_store.dart';
import 'package:majichrono/core/sync/sync_item.dart';
import 'package:majichrono/features/delivery/domain/entities/delivery.dart';
import 'package:majichrono/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:majichrono/features/driver/domain/entities/delivery_group.dart';
import 'package:majichrono/features/driver/domain/entities/driver_entities.dart';

/// Interrupteur en ligne / hors ligne du livreur (EXI-L03).
///
/// L'etat est **persiste** : l'exigence demande qu'il survive au redemarrage du
/// telephone. Le motif est concret — un livreur dont la batterie lache en pleine
/// journee et qui redemarre ne doit pas se retrouver invisible sans s'en
/// apercevoir, ni recevoir des courses alors qu'il avait fini son service.
final driverOnlineProvider =
    NotifierProvider<DriverOnlineController, bool>(DriverOnlineController.new);

class DriverOnlineController extends Notifier<bool> {
  @override
  bool build() =>
      ref.watch(prefsStoreProvider).getBool(PrefsStore.keyDriverOnline);

  Future<void> set({required bool online}) async {
    state = online;
    await ref
        .read(prefsStoreProvider)
        .setBool(PrefsStore.keyDriverOnline, value: online);
  }

  Future<void> toggle() => set(online: !state);
}

/// File des courses disponibles (EXI-L04).
///
/// Servie uniquement lorsque le livreur est en ligne : interroger le serveur
/// hors service consommerait du forfait pour rien (§4.4).
final availableDeliveriesProvider =
    FutureProvider.autoDispose<List<AvailableDelivery>>((ref) async {
  if (!ref.watch(driverOnlineProvider)) return const [];

  final json = await ref.watch(apiClientProvider).get<Map<String, dynamic>>(
        ApiEndpoints.deliveriesAvailable,
        category: DataCategory.api,
      );

  return (json['items'] as List<dynamic>? ?? [])
      .whereType<Map<String, dynamic>>()
      .map(AvailableDelivery.fromJson)
      .whereType<AvailableDelivery>()
      .toList();
});

/// Course en cours du livreur, s'il y en a une.
///
/// Un livreur n'execute qu'une course a la fois tant que le groupage (EXI-L06,
/// module 9) n'est pas livre.
/// Courses actives du livreur.
///
/// Le pluriel est arrive avec le groupage (EXI-L06, D7) : jusqu'au module 9,
/// le socle supposait **une seule** course a la fois. Lever cette hypothese
/// etait la vraie difficulte du differenciant — pas l'ecran.
final activeDriverDeliveriesProvider = Provider<List<Delivery>>((ref) {
  final all = ref.watch(deliveriesProvider).valueOrNull ?? const <Delivery>[];
  return all
      .where((d) => d.driverId != null && d.status.isActive && !d.pendingSync)
      .toList();
});

/// Course courante, c'est-a-dire la premiere du groupe.
///
/// Conservee pour les ecrans qui n'en traitent qu'une : le bouton d'action
/// suivante, l'itineraire, le constat. Un groupe se parcourt arret par arret,
/// et chaque arret concerne une seule course.
final activeDriverDeliveryProvider = Provider<Delivery?>((ref) {
  final active = ref.watch(activeDriverDeliveriesProvider);
  return active.isEmpty ? null : active.first;
});

/// Groupe courant, lorsque le livreur porte plusieurs courses (EXI-L06).
final activeGroupProvider = Provider<DeliveryGroup?>((ref) {
  final active = ref.watch(activeDriverDeliveriesProvider);
  if (active.length < DeliveryGroup.minSize) return null;
  return DeliveryGroup(
    deliveries: active.take(DeliveryGroup.maxSize).toList(),
  );
});

final earningsProvider = FutureProvider.autoDispose<EarningsSummary>((ref) async {
  final json = await ref
      .watch(apiClientProvider)
      .get<Map<String, dynamic>>('/drivers/earnings');
  return EarningsSummary.fromJson(json);
});

final kycStatusProvider = FutureProvider.autoDispose<String>((ref) async {
  final json = await ref
      .watch(apiClientProvider)
      .get<Map<String, dynamic>>(ApiEndpoints.kycStatus);
  return '${json['status'] ?? 'draft'}';
});

/// Actions du livreur.
final driverActionsProvider = Provider<DriverActions>(
  (ref) => DriverActions(ref),
);

class DriverActions {
  DriverActions(this._ref);

  final Ref _ref;

  /// Accepte une course (EXI-L05).
  ///
  /// Une course deja prise par un autre livreur remonte en [ConflictFailure] :
  /// c'est un cas normal de la course a l'acceptation, pas une panne, et
  /// l'interface doit le dire sans dramatiser.
  Future<void> accept(String deliveryId) async {
    final json = await _ref.read(apiClientProvider).post<Map<String, dynamic>>(
          '/deliveries/$deliveryId/accept',
        );
    final delivery = Delivery.fromJson(json);
    if (delivery != null) {
      await _ref
          .read(deliveryLocalDataSourceProvider)
          .upsertDelivery(delivery, pendingSync: false);
    }
    _ref.invalidate(availableDeliveriesProvider);
  }

  /// Fait progresser la course d'une etape (EXI-L08, EXI-L15).
  ///
  /// Le mobile propose, le serveur dispose (§8.3) : une transition refusee
  /// remonte telle quelle, avec l'etat courant du serveur, plutot que d'etre
  /// appliquee localement puis contredite.
  ///
  /// Hors ligne, en revanche, la transition **n'echoue pas** : elle est
  /// appliquee localement et deposee dans la file. C'est ce qui rend le parcours
  /// livreur executable de bout en bout en zone blanche (EXI-L15, EXI-P07) — un
  /// livreur qui ne peut pas avancer parce qu'il n'a pas de reseau reste bloque
  /// devant une porte, le colis a la main.
  Future<void> advance(Delivery delivery, DriverAction action) async {
    final path = ApiEndpoints.deliveryStatus(delivery.id);
    final body = {'status': action.to.wireName};

    // La cle est derivee de la course et de l'etape visee : deux appuis sur le
    // meme bouton produisent la meme cle, donc une seule transition cote
    // serveur (EXI-S01).
    final key = 'status_${delivery.id}_${action.to.wireName}';

    try {
      final json = await _ref
          .read(apiClientProvider)
          .post<Map<String, dynamic>>(path, body: body, idempotencyKey: key);
      final updated = Delivery.fromJson(json);
      if (updated != null) {
        await _ref
            .read(deliveryLocalDataSourceProvider)
            .upsertDelivery(updated, pendingSync: false);
      }
    } on Failure catch (failure) {
      // Un refus du serveur est definitif : il connait l'etat reel de la course
      // et le mobile doit s'y plier (EXI-S04). Seule une coupure justifie de
      // poursuivre localement.
      if (!failure.isRetryable) rethrow;

      await _ref.read(syncQueueProvider).enqueue(
        method: 'POST',
        path: path,
        idempotencyKey: key,
        body: body,
        priority: SyncPriority.transition,
      );

      // L'etape est appliquee localement, marquee non transmise : l'interface
      // avance, et le bandeau dit qu'il reste quelque chose a envoyer.
      await _ref
          .read(deliveryLocalDataSourceProvider)
          .upsertDelivery(delivery.copyWith(status: action.to), pendingSync: true);
    }

    _ref.invalidate(earningsProvider);
  }

  /// Signale un incident (EXI-L14).
  ///
  /// Un incident survient rarement au meilleur endroit du reseau : il est
  /// depose en file plutot que perdu, mais sans bloquer le livreur.
  Future<void> reportIncident(String deliveryId, IncidentType type) async {
    final path = ApiEndpoints.deliveryStatus(deliveryId);
    final body = {'incident': type.wireName};
    final key = 'incident_${deliveryId}_${type.wireName}';

    try {
      await _ref
          .read(apiClientProvider)
          .post<Map<String, dynamic>>(path, body: body, idempotencyKey: key);
    } on Failure catch (failure) {
      if (!failure.isRetryable) rethrow;

      await _ref.read(syncQueueProvider).enqueue(
        method: 'POST',
        path: path,
        idempotencyKey: key,
        body: body,
        priority: SyncPriority.transition,
      );
    }
  }
}
