/// Points d'entree du backend, tels qu'imposes par le §12.2 du cahier des charges.
///
/// Cette classe est l'unique source de verite des chemins. Le transport simule
/// (`MockHttpAdapter`) et le transport reel consomment strictement les memes
/// constantes : passer de `mock` a `live` ne change aucune URL.
class ApiEndpoints {
  const ApiEndpoints._();

  // --- Socle -----------------------------------------------------------
  static const String health = '/health';

  // --- Authentification ------------------------------------------------
  static const String otpRequest = '/auth/otp/request';
  static const String otpVerify = '/auth/otp/verify';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // --- Profil ----------------------------------------------------------
  static const String me = '/me';
  static const String meAvatar = '/me/avatar';

  // --- Courses ---------------------------------------------------------
  static const String deliveries = '/deliveries';
  static String delivery(String id) => '/deliveries/$id';
  static String deliveryCancel(String id) => '/deliveries/$id/cancel';

  // --- Livreur ---------------------------------------------------------
  static const String deliveriesAvailable = '/deliveries/available';
  static String deliveryAccept(String id) => '/deliveries/$id/accept';
  static String deliveryStatus(String id) => '/deliveries/$id/status';

  // --- Constats (§7.3) -------------------------------------------------
  static String custodyPickup(String id) => '/deliveries/$id/custody/pickup';
  static String custodyHandover(String id) => '/deliveries/$id/custody/handover';
  static String custody(String id) => '/deliveries/$id/custody';

  // --- Pieces jointes --------------------------------------------------
  static const String uploads = '/uploads';

  // --- Suivi -----------------------------------------------------------
  static const String trackingPing = '/tracking/ping';
  static const String trackingBatch = '/tracking/batch';
  static String deliveryTrace(String id) => '/deliveries/$id/trace';

  // --- KYC -------------------------------------------------------------
  static const String kycSubmit = '/drivers/kyc';
  static const String kycStatus = '/drivers/kyc/status';

  // --- Paiement (§11.2) ------------------------------------------------
  static const String paymentBalance = '/payments/balance';
  static const String paymentIntent = '/payments/intent';
  static String payment(String id) => '/payments/$id';

  /// Appariement des deux appareils par code QR. N'autorise aucun debit a lui
  /// seul : le payeur confirme toujours sur son propre appareil.
  static String paymentClaim(String id) => '/payments/$id/claim';
  static String paymentConfirm(String id) => '/payments/$id/confirm';
  static String paymentCash(String id) => '/payments/$id/cash';

  // --- Notations -------------------------------------------------------
  static const String reviews = '/reviews';

  // --- Litiges ---------------------------------------------------------
  static const String disputes = '/disputes';
  static String dispute(String id) => '/disputes/$id';
  static String disputeMessages(String id) => '/disputes/$id/messages';

  /// Decision finale sur un litige (EXI-A05). Distincte des messages : clore un
  /// litige n'est pas y repondre.
  static String disputeDecision(String id) => '/disputes/$id/decision';

  // --- Suivi public (EXI-C24) ------------------------------------------
  static String publicTrack(String token) => '/public/track/$token';

  // --- Administration --------------------------------------------------
  static const String adminDashboard = '/admin/dashboard';
  static const String adminFleet = '/admin/fleet';
  static const String adminKyc = '/admin/kyc';
  static String adminKycReview(String id) => '/admin/kyc/$id/review';

  /// Suspension et reintegration d'un compte (EXI-A06).
  static String adminDriverSuspension(String id) =>
      '/admin/drivers/$id/suspension';

  /// Reaffectation manuelle d'une course (EXI-A07).
  ///
  /// Route distincte de `/deliveries/{id}/status` a dessein : le graphe de
  /// transitions du livreur ne prevoit pas ce mouvement, et le faire passer par
  /// la meme porte reviendrait a donner au mobile un pouvoir qu'il ne doit pas
  /// avoir.
  static String adminDeliveryReassign(String id) =>
      '/admin/deliveries/$id/reassign';
}
