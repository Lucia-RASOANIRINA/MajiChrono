import 'package:majichrono/features/delivery/domain/entities/delivery_options.dart';
import 'package:majichrono/features/delivery/domain/entities/shopping_order.dart';
import 'package:majichrono/features/delivery/domain/entities/address.dart';
import 'package:majichrono/features/delivery/domain/entities/delivery.dart';

/// Brouillon de course, tel que le construit l'assistant de creation.
class DeliveryDraft {
  const DeliveryDraft({
    required this.pickup,
    required this.dropoff,
    required this.kind,
    required this.package,
    required this.slot,
    required this.paymentMethod,
    this.insuredValueAriary,
    this.payer = Payer.sender,
    this.shopping,
    this.relayPointId,
  });

  final Address pickup;
  final Address dropoff;
  final DeliveryKind kind;
  final PackageDeclaration package;
  final PickupSlot slot;
  final PaymentMethod paymentMethod;
  final int? insuredValueAriary;

  /// Qui paie (EXI-C42), liste de courses (EXI-C07), relais de remise (D6).
  final Payer payer;
  final ShoppingOrder? shopping;
  final String? relayPointId;
}

abstract interface class DeliveryRepository {
  // --- Carnet d'adresses (EXI-C05) -------------------------------------

  /// Flux du carnet, servi par la base locale : il reste disponible hors ligne.
  Stream<List<SavedAddress>> watchAddressBook();

  Future<SavedAddress> saveAddress({
    required String label,
    required Address address,
  });

  Future<void> deleteAddress(String id);

  /// Enregistre l'usage d'une adresse, pour faire remonter les plus frequentes.
  Future<void> touchAddress(String id);

  // --- Courses ----------------------------------------------------------

  /// Cree une course.
  ///
  /// Ecriture locale d'abord, puis mise en file (EXI-C13) : la course existe
  /// pour l'utilisateur des la confirmation, meme sans reseau.
  Future<Delivery> createDelivery(DeliveryDraft draft);

  /// Flux des courses de l'utilisateur, servi par la base locale (EXI-C33).
  Stream<List<Delivery>> watchDeliveries();

  /// Rafraichit depuis le serveur et met a jour le cache local.
  Future<void> refreshDeliveries();

  Future<Delivery?> deliveryById(String id);

  /// Annulation avant prise en charge (EXI-C26).
  Future<void> cancelDelivery(String id);
}
