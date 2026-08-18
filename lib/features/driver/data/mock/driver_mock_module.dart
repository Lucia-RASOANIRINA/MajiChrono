import 'dart:math';

import 'package:majichrono/core/network/api_endpoints.dart';
import 'package:majichrono/core/network/mock/mock_backend.dart';
import 'package:majichrono/features/delivery/domain/entities/delivery.dart';
import 'package:majichrono/features/delivery/domain/entities/price_estimate.dart';
import 'package:majichrono/features/delivery/domain/value_objects/geo_point.dart';

/// Routes simulees du parcours livreur (§12.2).
///
/// Le simulateur fabrique des courses disponibles autour d'Antananarivo, gere
/// l'acceptation et valide les transitions de statut **cote serveur**, comme le
/// fait le vrai backend (EXI-B02). C'est important : si le simulateur acceptait
/// toutes les transitions, l'application donnerait l'illusion de fonctionner et
/// le defaut n'apparaitrait qu'au branchement du vrai serveur.
class DriverMockModule extends MockModule {
  DriverMockModule({required this.deliveries, Random? random})
    : _random = random ?? Random();

  final Map<String, Map<String, dynamic>> Function() deliveries;
  final Random _random;

  /// Courses proposees, generees une fois puis stables tant qu'elles ne sont
  /// pas acceptees — une file qui change a chaque rafraichissement serait
  /// impossible a recetter.
  final Map<String, Map<String, dynamic>> _offers = {};

  /// Commission de la plateforme. Provisoire : la decision DO-3 du §19.2 n'est
  /// pas arbitree, et elle determine ce que le livreur voit comme gain.
  static const double platformCommission = 0.20;

  /// Quartiers d'Antananarivo utilises pour fabriquer des courses credibles.
  static const List<(String, String, double, double)> _places = [
    ('Ambohipo', 'Apres l epicerie Tsiky, portail vert', -18.9010, 47.5490),
    ('Analakely', 'Face a l escalier, boutique bleue', -18.9100, 47.5250),
    ('Ivandry', 'Derriere la station, mur blanc', -18.8680, 47.5320),
    ('Ankorondrano', 'A cote du grand magasin', -18.8790, 47.5230),
    ('Andraharo', 'Immeuble jaune, 2e portail', -18.8850, 47.5140),
    ('Ambohimanarina', 'Apres le marche, ruelle a droite', -18.8600, 47.4980),
  ];

  @override
  void register(MockBackend backend) {
    backend.get(ApiEndpoints.deliveriesAvailable, _available);
    backend.post('/deliveries/{id}/accept', _accept);
    backend.post('/deliveries/{id}/status', _status);
    backend.post(ApiEndpoints.trackingBatch, _trackingBatch);
    backend.get('/drivers/earnings', _earnings);
    backend.get(ApiEndpoints.kycStatus, _kycStatus);
    backend.post(ApiEndpoints.kycSubmit, _kycSubmit);
  }

  @override
  Future<void> reset() async {
    _offers.clear();
    _kyc = 'draft';
    _completed.clear();
  }

  String _kyc = 'draft';
  final List<Map<String, dynamic>> _completed = [];

  // --- File des courses disponibles (EXI-L04) ---------------------------

  Future<MockResponse> _available(
    MockRequest req,
    Map<String, String> _,
  ) async {
    if (_offers.isEmpty) _seedOffers();

    // Position du livreur, transmise par le client pour trier par distance a vide.
    final lat = double.tryParse(req.query['lat'] ?? '');
    final lng = double.tryParse(req.query['lng'] ?? '');
    final driver = lat != null && lng != null
        ? GeoPoint(lat, lng)
        : GeoPoint.antananarivo;

    final items =
        _offers.values.map((delivery) {
          final pickup = GeoPoint.fromJson(
            (delivery['pickup'] as Map<String, dynamic>)['point']
                as Map<String, dynamic>?,
          )!;
          final price = (delivery['price'] as num?)?.toInt() ?? 0;
          return {
            'delivery': delivery,
            'pickupDistanceKm': driver.distanceKmTo(pickup),
            'estimatedEarning': (price * (1 - platformCommission)).round(),
          };
        }).toList()..sort(
          (a, b) => (a['pickupDistanceKm']! as double).compareTo(
            b['pickupDistanceKm']! as double,
          ),
        );

    return MockResponse.ok({'items': items});
  }

  void _seedOffers() {
    for (var i = 0; i < 4; i++) {
      final from = _places[_random.nextInt(_places.length)];
      var to = _places[_random.nextInt(_places.length)];
      while (to == from) {
        to = _places[_random.nextInt(_places.length)];
      }

      final id = 'dlv_offer_${_random.nextInt(1 << 32)}';
      final weight =
          WeightCategory.values[_random.nextInt(WeightCategory.values.length)];
      final kind =
          DeliveryKind.values[_random.nextInt(DeliveryKind.values.length - 1)];

      final estimate = TariffGrid.provisional.estimate(
        straightLineKm: GeoPoint(
          from.$3,
          from.$4,
        ).distanceKmTo(GeoPoint(to.$3, to.$4)),
        kind: kind,
        weight: weight,
        slot: const PickupSlot.immediate(),
      );

      _offers[id] = {
        'id': id,
        'status': DeliveryStatus.pending.wireName,
        'kind': kind.wireName,
        'pickup': _address(from),
        'dropoff': _address(to),
        'package': {'weight': weight.wireName},
        'slot': {'immediate': true},
        'paymentMethod': PaymentMethod.cash.wireName,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'price': estimate.totalAriary,
        'trackingToken': 'trk_${_random.nextInt(1 << 32)}',
      };
    }
  }

  Map<String, dynamic> _address((String, String, double, double) place) => {
    'point': GeoPoint(place.$3, place.$4).toJson(),
    'district': place.$1,
    'landmark': place.$2,
    'contactPhone': '+261341234567',
  };

  // --- Acceptation (EXI-L05) --------------------------------------------

  Future<MockResponse> _accept(
    MockRequest req,
    Map<String, String> params,
  ) async {
    final id = params['id']!;
    final offer = _offers[id];
    if (offer == null) {
      // Course deja prise par un autre livreur : c'est un cas normal, pas une
      // erreur technique. L'interface doit le dire et retirer la ligne.
      return MockResponse.error(409, 'already_taken', 'Course deja acceptee');
    }

    offer['status'] = DeliveryStatus.accepted.wireName;
    offer['driverId'] = 'drv_001';
    offer['driverName'] = 'Naina Andria';

    _offers.remove(id);
    deliveries()[id] = offer;

    return MockResponse.ok(offer);
  }

  // --- Progression (EXI-L08, EXI-B02) -----------------------------------

  Future<MockResponse> _status(
    MockRequest req,
    Map<String, String> params,
  ) async {
    final delivery = deliveries()[params['id']];
    if (delivery == null) {
      return MockResponse.error(404, 'not_found', 'Course inconnue');
    }

    final current = DeliveryStatus.fromWire(delivery['status'] as String?);
    final target = DeliveryStatus.fromWire(req.json['status'] as String?);

    // Le serveur valide la transition (EXI-B02). Une transition illegale
    // retourne 409 avec l'etat courant, que le client affichera.
    final allowed = DriverAllowed.transition(current, target);
    if (!allowed) {
      return MockResponse.error(
        409,
        'illegal_transition',
        'Transition refusee',
        details: {'currentState': current.wireName},
      );
    }

    delivery['status'] = target.wireName;

    if (target == DeliveryStatus.delivered) {
      final price = (delivery['price'] as num?)?.toInt() ?? 0;
      _completed.add({
        'deliveryId': delivery['id'],
        'amount': (price * (1 - platformCommission)).round(),
        'at': DateTime.now().toUtc().toIso8601String(),
        'label': (delivery['dropoff'] as Map<String, dynamic>)['district'],
      });
    }

    return MockResponse.ok(delivery);
  }

  // --- Positions (EXI-L10) -----------------------------------------------

  Future<MockResponse> _trackingBatch(
    MockRequest req,
    Map<String, String> _,
  ) async {
    final points = (req.json['points'] as List<dynamic>? ?? []).length;
    // EXI-B06 : le lot accepte jusqu'a 50 points en une requete compressee.
    if (points > 50) {
      return MockResponse.error(
        422,
        'batch_too_large',
        'Lot de plus de 50 points',
      );
    }
    return MockResponse.ok({'accepted': points});
  }

  // --- Gains (EXI-L12) ----------------------------------------------------

  Future<MockResponse> _earnings(MockRequest req, Map<String, String> _) async {
    final total = _completed.fold<int>(
      0,
      (sum, e) => sum + (e['amount']! as int),
    );
    return MockResponse.ok({
      'today': total,
      'week': total,
      'month': total,
      'todayCount': _completed.length,
      'entries': _completed.reversed.toList(),
    });
  }

  // --- KYC (EXI-L01, EXI-L02) --------------------------------------------

  Future<MockResponse> _kycStatus(
    MockRequest req,
    Map<String, String> _,
  ) async => MockResponse.ok({
    'status': _kyc,
    'documents': const [
      'cin_front',
      'cin_back',
      'licence',
      'selfie',
      'registration',
      'vehicle',
      'plate',
    ],
    'rejectionReason': null,
  });

  Future<MockResponse> _kycSubmit(
    MockRequest req,
    Map<String, String> _,
  ) async {
    _kyc = 'submitted';
    return MockResponse.ok({'status': _kyc});
  }
}

/// Transitions autorisees du parcours livreur (§8.3).
class DriverAllowed {
  const DriverAllowed._();

  static const Map<DeliveryStatus, Set<DeliveryStatus>> _graph = {
    DeliveryStatus.accepted: {
      DeliveryStatus.atPickup,
      DeliveryStatus.cancelled,
    },
    DeliveryStatus.atPickup: {
      DeliveryStatus.pickedUp,
      DeliveryStatus.cancelled,
    },
    DeliveryStatus.pickedUp: {
      DeliveryStatus.inTransit,
      DeliveryStatus.atDestination,
    },
    DeliveryStatus.inTransit: {DeliveryStatus.atDestination},
    DeliveryStatus.atDestination: {
      DeliveryStatus.delivered,
      DeliveryStatus.deliveredWithReserves,
      DeliveryStatus.refused,
    },
  };

  static bool transition(DeliveryStatus from, DeliveryStatus to) =>
      _graph[from]?.contains(to) ?? false;
}
