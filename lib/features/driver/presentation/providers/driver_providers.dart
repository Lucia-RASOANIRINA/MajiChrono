import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:majichrono/core/error/failure.dart';
import 'package:majichrono/core/network/api_endpoints.dart';
import 'package:majichrono/core/network/data_meter.dart';
import 'package:majichrono/core/providers/core_providers.dart';
import 'package:majichrono/core/storage/prefs_store.dart';
import 'package:majichrono/features/delivery/domain/entities/delivery.dart';
import 'package:majichrono/features/delivery/presentation/providers/delivery_providers.dart';
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
final activeDriverDeliveryProvider = Provider<Delivery?>((ref) {
  final all = ref.watch(deliveriesProvider).valueOrNull ?? const <Delivery>[];
  final active = all.where(
    (d) => d.driverId != null && d.status.isActive && !d.pendingSync,
  );
  return active.isEmpty ? null : active.first;
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

  /// Fait progresser la course d'une etape (EXI-L08).
  ///
  /// Le mobile propose, le serveur dispose (§8.3) : une transition refusee
  /// remonte telle quelle, avec l'etat courant du serveur, plutot que d'etre
  /// appliquee localement puis contredite.
  Future<void> advance(Delivery delivery, DriverAction action) async {
    final json = await _ref.read(apiClientProvider).post<Map<String, dynamic>>(
          '/deliveries/${delivery.id}/status',
          body: {'status': action.to.wireName},
        );
    final updated = Delivery.fromJson(json);
    if (updated != null) {
      await _ref
          .read(deliveryLocalDataSourceProvider)
          .upsertDelivery(updated, pendingSync: false);
    }
    _ref.invalidate(earningsProvider);
  }

  /// Signale un incident (EXI-L14).
  Future<void> reportIncident(String deliveryId, IncidentType type) async {
    try {
      await _ref.read(apiClientProvider).post<Map<String, dynamic>>(
            '/deliveries/$deliveryId/status',
            body: {'incident': type.wireName},
          );
    } on Failure {
      // TODO(module 6) : deposer l'incident dans la file de synchronisation.
      rethrow;
    }
  }
}
