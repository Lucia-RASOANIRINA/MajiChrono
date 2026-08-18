import 'dart:math';

import 'package:majichrono/core/network/api_endpoints.dart';
import 'package:majichrono/core/network/mock/mock_backend.dart';
import 'package:majichrono/features/delivery/domain/entities/delivery.dart';
import 'package:majichrono/features/delivery/domain/entities/price_estimate.dart';
import 'package:majichrono/features/delivery/domain/value_objects/geo_point.dart';

/// Routes simulees des courses (§12.2).
///
/// Contrairement au simulateur d'authentification, celui-ci **tient un etat** :
/// une course creee doit se retrouver dans la liste, changer de statut, et etre
/// annulable. L'etat vit en memoire — il se perd au redemarrage du processus,
/// ce qui est acceptable : le cache local de l'application, lui, persiste, et
/// c'est justement ce que la recette hors ligne doit verifier.
class DeliveryMockModule extends MockModule {
  DeliveryMockModule({Random? random}) : _random = random ?? Random();

  final Random _random;
  final Map<String, Map<String, dynamic>> _deliveries = {};

  /// Cles d'idempotence deja traitees (EXI-B01).
  ///
  /// Sans ce registre, une reprise apres coupure creerait une seconde course
  /// identique — le defaut que le scenario §16.2-3 cherche precisement.
  final Map<String, String> _idempotency = {};

  /// Registre des courses, partage avec le module de suivi : le suivi porte sur
  /// les memes courses, il n'en tient pas une seconde copie qui divergerait.
  Map<String, Map<String, dynamic>> get store => _deliveries;

  @override
  void register(MockBackend backend) {
    backend.post(ApiEndpoints.deliveries, _create);
    backend.get(ApiEndpoints.deliveries, _list);
    backend.get('/deliveries/{id}', _detail);
    backend.post('/deliveries/{id}/cancel', _cancel);
    backend.post('/deliveries/estimate', _estimate);
  }

  @override
  Future<void> reset() async {
    _deliveries.clear();
    _idempotency.clear();
  }

  Future<MockResponse> _create(MockRequest req, Map<String, String> _) async {
    final key = req.idempotencyKey;
    if (key != null && _idempotency.containsKey(key)) {
      // Meme requete rejouee : on renvoie la course deja creee, sans en creer
      // une seconde. Le client ne peut pas distinguer ce cas d'un succes, et
      // c'est exactement le but (EXI-S01).
      return MockResponse.ok(_deliveries[_idempotency[key]]);
    }

    final body = req.json;
    final id = 'dlv_${_random.nextInt(1 << 32)}';
    final now = DateTime.now();

    final delivery = <String, dynamic>{
      ...body,
      'id': id,
      'status': DeliveryStatus.pending.wireName,
      'createdAt': now.toUtc().toIso8601String(),
      'price': body['price'] ?? _price(body),
      'trackingToken': 'trk_${_random.nextInt(1 << 32)}',
    };

    _deliveries[id] = delivery;
    if (key != null) _idempotency[key] = id;

    return MockResponse.created(delivery);
  }

  Future<MockResponse> _list(MockRequest req, Map<String, String> _) async {
    final items = _deliveries.values.toList()
      ..sort((a, b) => '${b['createdAt']}'.compareTo('${a['createdAt']}'));
    return MockResponse.ok({'items': items});
  }

  Future<MockResponse> _detail(
    MockRequest req,
    Map<String, String> params,
  ) async {
    final delivery = _deliveries[params['id']];
    if (delivery == null) {
      return MockResponse.error(404, 'not_found', 'Course inconnue');
    }
    return MockResponse.ok(delivery);
  }

  Future<MockResponse> _cancel(
    MockRequest req,
    Map<String, String> params,
  ) async {
    final delivery = _deliveries[params['id']];
    if (delivery == null) {
      return MockResponse.error(404, 'not_found', 'Course inconnue');
    }

    final status = DeliveryStatus.fromWire(delivery['status'] as String?);
    if (!status.isCancellableByClient) {
      // EXI-B02 : une transition illegale retourne 409 avec l'etat courant, que
      // le client affichera plutot que de laisser l'utilisateur reessayer.
      return MockResponse.error(
        409,
        'illegal_transition',
        'La course ne peut plus etre annulee',
        details: {'currentState': status.wireName},
      );
    }

    delivery['status'] = DeliveryStatus.cancelled.wireName;
    return MockResponse.ok(delivery);
  }

  Future<MockResponse> _estimate(MockRequest req, Map<String, String> _) async {
    final body = req.json;
    return MockResponse.ok({'price': _price(body), 'provisional': true});
  }

  /// Reproduit la grille provisoire pour que le prix serveur et le prix local
  /// coincident tant que DO-3 n'est pas arbitre.
  int _price(Map<String, dynamic> body) {
    final pickup = GeoPoint.fromJson(
      (body['pickup'] as Map<String, dynamic>?)?['point']
          as Map<String, dynamic>?,
    );
    final dropoff = GeoPoint.fromJson(
      (body['dropoff'] as Map<String, dynamic>?)?['point']
          as Map<String, dynamic>?,
    );
    if (pickup == null || dropoff == null) {
      return TariffGrid.provisional.minimumAriary;
    }

    final estimate = TariffGrid.provisional.estimate(
      straightLineKm: pickup.distanceKmTo(dropoff),
      kind: DeliveryKind.fromWire(body['kind'] as String?),
      weight: WeightCategory.fromWire(
        (body['package'] as Map<String, dynamic>?)?['weight'] as String?,
      ),
      slot: PickupSlot.fromJson(body['slot'] as Map<String, dynamic>?),
    );
    return estimate.totalAriary;
  }
}
