/// Chemins de navigation.
///
/// Ils sont declares en constantes parce qu'ils servent aussi de cibles aux
/// liens profonds des notifications (EXI-N04) et au lien de suivi public
/// partage par SMS (EXI-C24) : une chaine litterale dispersee dans le code
/// deviendrait vite un lien mort.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';

  // --- Authentification (module 1) --------------------------------------
  static const String authPhone = '/auth/phone';
  static const String authOtp = '/auth/otp';
  static const String authProfile = '/auth/profile';
  static const String authPin = '/auth/pin';
  static const String authLock = '/auth/lock';

  /// Vrai pour toute route du parcours d'authentification.
  static bool isAuthRoute(String location) => location.startsWith('/auth');

  static const String settings = '/settings';
  static const String dataUsage = '/settings/data';

  /// Elements en attente de synchronisation (EXI-S06).
  static const String pendingSync = '/settings/sync';
  static const String devPanel = '/dev';

  // --- Client ----------------------------------------------------------
  static const String clientHome = '/client';
  static const String clientDeliveries = '/client/deliveries';
  static const String clientProfile = '/client/profile';
  static const String clientNewDelivery = '/client/new';
  static String clientTracking(String id) => '/client/track/$id';

  // --- Livreur ---------------------------------------------------------
  static const String driverHome = '/driver';
  static const String driverDeliveries = '/driver/deliveries';
  static const String driverEarnings = '/driver/earnings';
  static const String driverProfile = '/driver/profile';
  static String driverActive(String id) => '/driver/active/$id';

  // --- Administration --------------------------------------------------
  static const String adminHome = '/admin';
  static const String adminFleet = '/admin/fleet';
  static const String adminDisputes = '/admin/disputes';
  static const String adminProfile = '/admin/profile';

  /// Ecrans atteints depuis le tableau de bord plutot que par un onglet : la
  /// barre inferieure en compte deja quatre, et au-dela les libelles ne tiennent
  /// plus sur un ecran de 320 dp (§15.1).
  static const String adminKyc = '/admin/kyc';
  static const String adminDeliveries = '/admin/deliveries';
  static String adminDispute(String id) => '/admin/disputes/$id';

  // --- Liens profonds --------------------------------------------------
  static const String publicTrack = '/track/:token';
  static String publicTrackFor(String token) => '/track/$token';
}
