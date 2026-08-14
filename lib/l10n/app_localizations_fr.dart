// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'MajiChrono';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonRetry => 'Reessayer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonSearch => 'Rechercher';

  @override
  String get commonYes => 'Oui';

  @override
  String get commonNo => 'Non';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String get langFrench => 'Francais';

  @override
  String get langMalagasy => 'Malagasy';

  @override
  String get settingsTitle => 'Reglages';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsTheme => 'Apparence';

  @override
  String get themeSystem => 'Systeme';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get networkOnline => 'En ligne';

  @override
  String networkOfflinePending(int count) {
    return 'Hors ligne — $count element(s) en attente';
  }

  @override
  String get networkOfflineNoPending => 'Hors ligne';

  @override
  String get networkSyncing => 'Synchronisation en cours...';

  @override
  String get roleChooseTitle => 'Je suis';

  @override
  String get roleClient => 'Expediteur';

  @override
  String get roleClientDesc => 'J\'envoie un colis ou je commande une course';

  @override
  String get roleDriver => 'Livreur';

  @override
  String get roleDriverDesc => 'Je realise des courses';

  @override
  String get roleAdmin => 'Exploitation';

  @override
  String get roleAdminDesc => 'Je supervise la flotte et les litiges';

  @override
  String get navHome => 'Accueil';

  @override
  String get navDeliveries => 'Courses';

  @override
  String get navTracking => 'Suivi';

  @override
  String get navEarnings => 'Gains';

  @override
  String get navProfile => 'Profil';

  @override
  String get navFleet => 'Flotte';

  @override
  String get navDisputes => 'Litiges';

  @override
  String get navKyc => 'KYC';

  @override
  String get navDashboard => 'Tableau';

  @override
  String get clientHomeTitle => 'Accueil expediteur';

  @override
  String get clientNewDelivery => 'Nouvelle course';

  @override
  String get driverHomeTitle => 'Accueil livreur';

  @override
  String get adminHomeTitle => 'Supervision';

  @override
  String get emptyTitle => 'Rien a afficher';

  @override
  String get emptyDeliveries => 'Aucune course pour l\'instant';

  @override
  String get emptyDeliveriesAction => 'Creer une course';

  @override
  String get errorTitle => 'Une action est necessaire';

  @override
  String get errorNetwork =>
      'Le reseau est indisponible. L\'action est enregistree et partira des le retour du reseau.';

  @override
  String get errorTimeout => 'Le serveur met trop de temps a repondre.';

  @override
  String get errorServer => 'Le service est momentanement indisponible.';

  @override
  String get errorUnauthorized => 'Votre session a expire. Reconnectez-vous.';

  @override
  String get errorConflict => 'Cette operation a deja ete traitee.';

  @override
  String get errorUpdateRequired =>
      'Une mise a jour de l\'application est necessaire.';

  @override
  String get errorStorage => 'L\'appareil ne peut pas enregistrer les donnees.';

  @override
  String get errorUnknown => 'Une erreur est survenue. Reessayez.';

  @override
  String get devPanelTitle => 'Panneau developpeur';

  @override
  String get devNetworkProfile => 'Profil reseau simule';

  @override
  String get devProfile4g => '4G';

  @override
  String get devProfile3g => '3G';

  @override
  String get devProfile2g => '2G / EDGE';

  @override
  String get devProfileOffline => 'Hors ligne (mode avion)';

  @override
  String get devFailureRate => 'Taux d\'echec injecte';

  @override
  String get devApiMode => 'Mode API';

  @override
  String get devDataUsed => 'Donnees consommees';

  @override
  String get devResetMock => 'Reinitialiser les donnees simulees';

  @override
  String get socleProbe => 'Sonde applicative';

  @override
  String get socleSyncQueue => 'File de synchronisation';

  @override
  String get settingsSwitchProfile => 'Changer de profil';

  @override
  String get dataUsageTitle => 'Ma consommation';

  @override
  String get dataUsageThisMonth => 'Ce mois-ci';

  @override
  String get dataBudgetReference => 'Budget mensuel de reference : 25 Mo';

  @override
  String get dataCatApi => 'Echanges applicatifs';

  @override
  String get dataCatPhotos => 'Photos et constats';

  @override
  String get dataCatMaps => 'Cartes';

  @override
  String get dataCatTracking => 'Suivi de position';

  @override
  String get dataCatPayment => 'Paiement';

  @override
  String get dataCatOther => 'Autres';

  @override
  String bytesKb(String value) {
    return '$value Ko';
  }

  @override
  String bytesMb(String value) {
    return '$value Mo';
  }

  @override
  String get shellModuleWip => 'Module en cours de construction';

  @override
  String shellModuleWipDesc(String module) {
    return 'Cet ecran sera livre au module $module.';
  }
}
