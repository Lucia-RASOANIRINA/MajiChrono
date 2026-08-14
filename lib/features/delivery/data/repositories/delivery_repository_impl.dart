import 'package:majichrono/core/error/failure.dart';
import 'package:majichrono/core/logging/app_logger.dart';
import 'package:majichrono/core/network/api_client.dart';
import 'package:majichrono/core/network/api_endpoints.dart';
import 'package:majichrono/features/delivery/data/datasources/delivery_local_data_source.dart';
import 'package:majichrono/features/delivery/domain/entities/address.dart';
import 'package:majichrono/features/delivery/domain/entities/delivery.dart';
import 'package:majichrono/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:uuid/uuid.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  DeliveryRepositoryImpl({
    required ApiClient client,
    required DeliveryLocalDataSource local,
    Uuid? uuid,
  })  : _client = client,
        _local = local,
        _uuid = uuid ?? const Uuid();

  final ApiClient _client;
  final DeliveryLocalDataSource _local;
  final Uuid _uuid;

  @override
  Stream<List<SavedAddress>> watchAddressBook() => _local.watchAddressBook();

  @override
  Future<SavedAddress> saveAddress({
    required String label,
    required Address address,
  }) async {
    final entry = SavedAddress(id: _uuid.v4(), label: label, address: address);
    await _local.upsertAddress(entry);
    return entry;
  }

  @override
  Future<void> deleteAddress(String id) => _local.deleteAddress(id);

  @override
  Future<void> touchAddress(String id) => _local.touchAddress(id);

  @override
  Stream<List<Delivery>> watchDeliveries() => _local.watchDeliveries();

  @override
  Future<Delivery?> deliveryById(String id) => _local.deliveryById(id);

  /// Creation locale d'abord, envoi ensuite (EXI-C13).
  ///
  /// L'ordre est l'exigence : une course creee dans un tunnel doit exister pour
  /// l'utilisateur avant toute tentative reseau. Si l'envoi echoue, la course
  /// reste marquee « en attente » et l'interface le montre — elle n'est ni
  /// perdue, ni faussement presentee comme diffusee aux livreurs.
  ///
  /// La cle d'idempotence est generee ici, et **conservee** pour les reprises :
  /// c'est elle qui garantit qu'une course envoyee deux fois n'en cree qu'une
  /// (EXI-S01, EXI-B01).
  @override
  Future<Delivery> createDelivery(DeliveryDraft draft) async {
    final localId = 'local_${_uuid.v4()}';
    final idempotencyKey = _uuid.v4();

    final local = Delivery(
      id: localId,
      status: DeliveryStatus.pending,
      kind: draft.kind,
      pickup: draft.pickup,
      dropoff: draft.dropoff,
      package: draft.package,
      slot: draft.slot,
      paymentMethod: draft.paymentMethod,
      createdAt: DateTime.now(),
      pendingSync: true,
    );

    await _local.upsertDelivery(local, pendingSync: true);

    try {
      final json = await _client.post<Map<String, dynamic>>(
        ApiEndpoints.deliveries,
        body: local.toJson()..remove('id'),
        idempotencyKey: idempotencyKey,
      );

      final confirmed = Delivery.fromJson(json);
      if (confirmed == null) throw const ServerFailure(statusCode: 500);

      await _local.replaceDelivery(localId, confirmed);
      return confirmed;
    } on Failure catch (failure) {
      AppLogger.instance.info('delivery_queued', data: {
        'reason': failure.runtimeType.toString(),
      });
      // TODO(module 6) : deposer l'element dans la file de synchronisation avec
      // sa cle d'idempotence, pour que l'ordonnanceur le rejoue. En attendant,
      // la course reste locale et visible comme non transmise.
      return local;
    }
  }

  @override
  Future<void> refreshDeliveries() async {
    final json = await _client.get<Map<String, dynamic>>(ApiEndpoints.deliveries);
    final items = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Delivery.fromJson)
        .whereType<Delivery>()
        .toList();
    await _local.replaceAll(items);
  }

  @override
  Future<void> cancelDelivery(String id) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.deliveryCancel(id),
    );
    final updated = Delivery.fromJson(json);
    if (updated != null) {
      await _local.upsertDelivery(updated, pendingSync: false);
    }
  }
}
