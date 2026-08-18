import 'package:majichrono/features/delivery/domain/entities/delivery.dart';
import 'package:majichrono/features/delivery/domain/value_objects/geo_point.dart';

/// Une course proposee au livreur (EXI-L04).
class AvailableDelivery {
  const AvailableDelivery({
    required this.delivery,
    required this.pickupDistanceKm,
    required this.estimatedEarningAriary,
  });

  final Delivery delivery;

  /// Distance a parcourir **a vide** jusqu'au point de retrait.
  ///
  /// L'exigence EXI-L04 la reclame explicitement, et pour une raison
  /// economique : c'est du carburant que le livreur avance sans etre paye. Une
  /// course bien payee a huit kilometres a vide peut valoir moins qu'une course
  /// modeste au coin de la rue, et lui seul peut en juger.
  final double pickupDistanceKm;

  /// Gain net estime pour le livreur, apres commission.
  final int estimatedEarningAriary;

  double get totalDistanceKm => pickupDistanceKm + delivery.distanceKm;

  /// Rendement en ariary par kilometre reellement parcouru, tout compris.
  double get earningPerKm =>
      totalDistanceKm <= 0 ? 0 : estimatedEarningAriary / totalDistanceKm;

  static AvailableDelivery? fromJson(Map<String, dynamic> json) {
    final delivery = Delivery.fromJson(
      json['delivery'] as Map<String, dynamic>,
    );
    if (delivery == null) return null;
    return AvailableDelivery(
      delivery: delivery,
      pickupDistanceKm: (json['pickupDistanceKm'] as num?)?.toDouble() ?? 0,
      estimatedEarningAriary: (json['estimatedEarning'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Gains du livreur (EXI-L12).
class EarningsSummary {
  const EarningsSummary({
    required this.todayAriary,
    required this.weekAriary,
    required this.monthAriary,
    required this.todayCount,
    required this.entries,
  });

  final int todayAriary;
  final int weekAriary;
  final int monthAriary;
  final int todayCount;

  /// Detail par course : l'exigence demande le detail, pas seulement les
  /// totaux. Un livreur qui conteste un montant doit pouvoir pointer la course.
  final List<EarningEntry> entries;

  static EarningsSummary fromJson(Map<String, dynamic> json) => EarningsSummary(
    todayAriary: (json['today'] as num?)?.toInt() ?? 0,
    weekAriary: (json['week'] as num?)?.toInt() ?? 0,
    monthAriary: (json['month'] as num?)?.toInt() ?? 0,
    todayCount: (json['todayCount'] as num?)?.toInt() ?? 0,
    entries: (json['entries'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(EarningEntry.fromJson)
        .whereType<EarningEntry>()
        .toList(),
  );
}

class EarningEntry {
  const EarningEntry({
    required this.deliveryId,
    required this.amountAriary,
    required this.at,
    required this.label,
  });

  final String deliveryId;
  final int amountAriary;
  final DateTime at;
  final String label;

  static EarningEntry? fromJson(Map<String, dynamic> json) {
    final at = DateTime.tryParse('${json['at']}');
    if (at == null) return null;
    return EarningEntry(
      deliveryId: '${json['deliveryId']}',
      amountAriary: (json['amount'] as num?)?.toInt() ?? 0,
      at: at.toLocal(),
      label: '${json['label'] ?? ''}',
    );
  }
}

/// Nature d'un incident signale par le livreur (EXI-L14).
///
/// Chaque incident porte **sa consequence**, et non seulement son libelle :
/// l'exigence demande que la suite soit definie. Un livreur qui signale une
/// absence doit savoir immediatement ce qui se passe ensuite, sinon il reste
/// planté devant un portail sans instruction.
enum IncidentType {
  recipientAbsent('recipient_absent', IncidentOutcome.waitThenReturn),
  addressNotFound('address_not_found', IncidentOutcome.contactSupport),
  refusedByRecipient('refused', IncidentOutcome.returnToSender),
  vehicleBreakdown('breakdown', IncidentOutcome.reassign);

  const IncidentType(this.wireName, this.outcome);

  final String wireName;
  final IncidentOutcome outcome;
}

enum IncidentOutcome {
  waitThenReturn,
  contactSupport,
  returnToSender,
  reassign,
}

/// Transition de statut demandee par le livreur (EXI-L08).
///
/// La progression suit strictement la machine a etats du §8.3, et le mobile ne
/// fait que **proposer** : le serveur valide. L'enumeration existe pour que
/// l'ecran n'ait qu'un seul bouton a afficher, avec le libelle de l'etape
/// suivante et rien d'autre.
enum DriverAction {
  arrivedAtPickup(DeliveryStatus.accepted, DeliveryStatus.atPickup),
  pickedUp(DeliveryStatus.atPickup, DeliveryStatus.pickedUp),
  arrivedAtDestination(DeliveryStatus.pickedUp, DeliveryStatus.atDestination),
  delivered(DeliveryStatus.atDestination, DeliveryStatus.delivered);

  const DriverAction(this.from, this.to);

  final DeliveryStatus from;
  final DeliveryStatus to;

  /// Action suivante pour un statut donne, ou `null` si rien n'est attendu du
  /// livreur a ce stade.
  static DriverAction? nextFor(DeliveryStatus status) {
    for (final action in DriverAction.values) {
      if (action.from == status) return action;
    }
    return null;
  }

  /// Vrai lorsque l'etape exige un constat contradictoire (§7.3).
  ///
  /// EXI-CC03 : le statut **ne peut pas progresser** tant que le constat n'est
  /// pas complet. Le drapeau est pose des maintenant pour que le module 5
  /// n'ait qu'a intercaler l'ecran de constat, sans toucher a la progression.
  bool get requiresCustodyReport =>
      this == DriverAction.pickedUp || this == DriverAction.delivered;
}

/// Position emise par le livreur (EXI-L09, EXI-L11).
class DriverPing {
  const DriverPing({
    required this.point,
    required this.at,
    this.speedKmh,
    this.accuracyMeters,
  });

  final GeoPoint point;
  final DateTime at;
  final double? speedKmh;
  final double? accuracyMeters;

  Map<String, dynamic> toJson() => {
    'point': point.toJson(),
    'at': at.toUtc().toIso8601String(),
    if (speedKmh != null) 'speedKmh': speedKmh,
    if (accuracyMeters != null) 'accuracy': accuracyMeters,
  };
}

/// Cadence d'emission de position (EXI-L11).
///
/// 15 s en mouvement, 60 s a l'arret, suspendue au-dela de 10 min d'immobilite.
/// Les trois seuils repondent au meme probleme : la batterie et le forfait du
/// livreur (§4.4). Emettre a cadence fixe viderait l'un et l'autre pour
/// retransmettre cinquante fois la meme position d'un scooter a l'arret.
class PingCadence {
  const PingCadence._();

  static const Duration moving = Duration(seconds: 15);
  static const Duration stopped = Duration(seconds: 60);
  static const Duration suspendAfter = Duration(minutes: 10);

  /// Seuil de vitesse au-dela duquel on considere le livreur en mouvement.
  static const double movingSpeedKmh = 3;

  static Duration forSpeed(double? speedKmh) =>
      (speedKmh ?? 0) >= movingSpeedKmh ? moving : stopped;
}
