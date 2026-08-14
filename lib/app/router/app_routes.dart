/// Chemins de navigation.
///
/// Ils sont declares en constantes parce qu'ils servent aussi de cibles aux
/// liens profonds des notifications (EXI-N04) et au lien de suivi public
/// partage par SMS (EXI-C24) : une chaine litterale dispersee dans le code
/// deviendrait vite un lien mort.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String roleSelect = '/role';
  static const String settings = '/settings';
  static const String dataUsage = '/settings/data';
  static const String devPanel = '/dev';

  // --- Client ----------------------------------------------------------
  static const String clientHome = '/client';
  static const String clientDeliveries = '/client/deliveries';
  static const String clientProfile = '/client/profile';
  static const String clientNewDelivery = '/client/new';

  // --- Livreur ---------------------------------------------------------
  static const String driverHome = '/driver';
  static const String driverDeliveries = '/driver/deliveries';
  static const String driverEarnings = '/driver/earnings';
  static const String driverProfile = '/driver/profile';

  // --- Administration --------------------------------------------------
  static const String adminHome = '/admin';
  static const String adminFleet = '/admin/fleet';
  static const String adminDisputes = '/admin/disputes';
  static const String adminProfile = '/admin/profile';

  // --- Liens profonds --------------------------------------------------
  static const String publicTrack = '/track/:token';
  static String publicTrackFor(String token) => '/track/$token';
}
