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
  String get authPhoneTitle => 'Votre numero';

  @override
  String get authPhoneSubtitle =>
      'Nous vous envoyons un code par SMS pour verifier ce numero.';

  @override
  String get authPhoneLabel => 'Numero de telephone';

  @override
  String get authPhoneHint => '034 12 345 67';

  @override
  String get authPhoneInvalid => 'Numero malgache invalide';

  @override
  String authPhoneOperator(String operator) {
    return 'Operateur reconnu : $operator';
  }

  @override
  String get authOtpTitle => 'Code de verification';

  @override
  String authOtpSentTo(String phone) {
    return 'Code envoye au $phone';
  }

  @override
  String authOtpExpiresIn(String time) {
    return 'Expire dans $time';
  }

  @override
  String get authOtpExpired => 'Code expire. Demandez-en un nouveau.';

  @override
  String get authOtpResend => 'Renvoyer le code';

  @override
  String authOtpInvalid(int count) {
    return 'Code incorrect. Il reste $count tentative(s).';
  }

  @override
  String get authOtpLocked => 'Trop de tentatives. Demandez un nouveau code.';

  @override
  String authOtpSimulated(String code) {
    return 'Code simule : $code';
  }

  @override
  String get authProfileTitle => 'Votre profil';

  @override
  String get authProfileSubtitle =>
      'Ce choix est definitif : il determine l\'application que vous utilisez.';

  @override
  String get authProfileName => 'Votre nom';

  @override
  String get authProfileNameHint => 'Nom vu par les autres';

  @override
  String get authProfileNameRequired => 'Indiquez votre nom';

  @override
  String get authProfileAdminNote =>
      'Le profil exploitation est attribue par MajiChrono, il ne se choisit pas ici.';

  @override
  String get authPinTitle => 'Creez un code a 4 chiffres';

  @override
  String get authPinSubtitle =>
      'Il protege votre compte a la reouverture de l\'application.';

  @override
  String get authPinConfirmTitle => 'Confirmez votre code';

  @override
  String get authPinMismatch => 'Les deux codes ne correspondent pas';

  @override
  String get authPinLater => 'Plus tard';

  @override
  String get authPinSaved => 'Code enregistre';

  @override
  String get authLockTitle => 'Application verrouillee';

  @override
  String get authLockSubtitle => 'Saisissez votre code pour continuer';

  @override
  String get authLockBiometrics => 'Utiliser la biometrie';

  @override
  String get authBiometricsReason => 'Deverrouiller MajiChrono';

  @override
  String get authLockWrongPin => 'Code incorrect';

  @override
  String get authSignOut => 'Se deconnecter';

  @override
  String get authSignOutConfirm =>
      'Se deconnecter effacera les donnees de cet appareil. Continuer ?';

  @override
  String authWelcome(String name) {
    return 'Bonjour $name';
  }

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
  String get newDeliveryTitle => 'Nouvelle course';

  @override
  String get stepAddresses => 'Adresses';

  @override
  String get stepPackage => 'Colis';

  @override
  String get stepReview => 'Recapitulatif';

  @override
  String get addrPickupTitle => 'Adresse de depart';

  @override
  String get addrDropoffTitle => 'Adresse d\'arrivee';

  @override
  String get addrDistrict => 'Quartier';

  @override
  String get addrDistrictHint => 'Ambohipo';

  @override
  String get addrLandmark => 'Point de repere';

  @override
  String get addrLandmarkHint => 'Apres l\'epicerie Tsiky, portail vert';

  @override
  String get addrLandmarkHelp =>
      'C\'est ce qui permet au livreur de vous trouver.';

  @override
  String get addrContactPhone => 'Telephone sur place';

  @override
  String get addrContactName => 'Nom du contact';

  @override
  String get addrStreet => 'Rue et numero';

  @override
  String get addrOptional => 'facultatif';

  @override
  String get addrRequired => 'Champ obligatoire';

  @override
  String get addrSaveToBook => 'Enregistrer dans mes adresses';

  @override
  String get addrLabel => 'Nom de l\'adresse';

  @override
  String get addrLabelHint => 'Maison, Boutique';

  @override
  String get addrBookTitle => 'Mes adresses';

  @override
  String get addrBookEmpty => 'Aucune adresse enregistree';

  @override
  String get addrBookEmptyHelp =>
      'Les adresses enregistrees ici se reutilisent en un geste.';

  @override
  String get addrPickFromBook => 'Choisir dans mes adresses';

  @override
  String get addrNew => 'Saisir une nouvelle adresse';

  @override
  String get addrDelete => 'Supprimer';

  @override
  String get pkgTitle => 'Le colis';

  @override
  String get pkgWeight => 'Poids';

  @override
  String get pkgWeightLt2 => 'Moins de 2 kg';

  @override
  String get pkgWeight2to5 => '2 a 5 kg';

  @override
  String get pkgWeight5to15 => '5 a 15 kg';

  @override
  String get pkgWeightGt15 => 'Plus de 15 kg';

  @override
  String get pkgValue => 'Valeur declaree';

  @override
  String get pkgDescription => 'Description';

  @override
  String get pkgPhotoLater =>
      'La photo du colis sera demandee au module 5, avec la chaine photo.';

  @override
  String get kindTitle => 'Type de course';

  @override
  String get kindStandard => 'Colis standard';

  @override
  String get kindDocument => 'Document';

  @override
  String get kindFragile => 'Fragile';

  @override
  String get kindFood => 'Alimentaire';

  @override
  String get kindShopping => 'Achat pour compte';

  @override
  String get kindShoppingSoon => 'Disponible au module 9';

  @override
  String get slotTitle => 'Quand ?';

  @override
  String get slotImmediate => 'Immediat';

  @override
  String get slotScheduled => 'Programme';

  @override
  String get slotPickDate => 'Choisir la date';

  @override
  String slotRange(int start, int end) {
    return '${start}h - ${end}h';
  }

  @override
  String get paymentTitle => 'Paiement';

  @override
  String get paymentCash => 'Especes a la livraison';

  @override
  String get paymentMajipay => 'MajiPay';

  @override
  String get paymentMajipaySoon => 'Disponible au module 7';

  @override
  String get estimateTitle => 'Estimation du prix';

  @override
  String get estimateTotal => 'Total';

  @override
  String get estimateProvisional =>
      'Tarif provisoire : la grille definitive n\'est pas encore arretee.';

  @override
  String get priceBase => 'Prise en charge';

  @override
  String get priceDistance => 'Distance';

  @override
  String get priceWeight => 'Poids';

  @override
  String get priceKind => 'Majoration type de course';

  @override
  String get priceSchedule => 'Creneau programme';

  @override
  String get priceInsurance => 'Assurance';

  @override
  String get confirmDelivery => 'Confirmer la course';

  @override
  String get deliveryCreated => 'Course creee';

  @override
  String get deliveryQueued =>
      'Course enregistree. Elle partira des le retour du reseau.';

  @override
  String get deliveriesTitle => 'Mes courses';

  @override
  String get deliveryPendingSync => 'En attente d\'envoi';

  @override
  String get deliveryCancel => 'Annuler la course';

  @override
  String get deliveryCancelConfirm =>
      'Annuler cette course ? Des frais peuvent s\'appliquer.';

  @override
  String deliveryDistance(String km) {
    return '$km km';
  }

  @override
  String get statusPending => 'En attente d\'un livreur';

  @override
  String get statusAccepted => 'Livreur en route';

  @override
  String get statusAtPickup => 'Livreur au depart';

  @override
  String get statusPickedUp => 'Colis pris en charge';

  @override
  String get statusInTransit => 'En transit';

  @override
  String get statusAtDestination => 'Livreur arrive';

  @override
  String get statusDelivered => 'Livree';

  @override
  String get statusDeliveredWithReserves => 'Livree avec reserves';

  @override
  String get statusRefused => 'Refusee';

  @override
  String get statusReturning => 'Retour expediteur';

  @override
  String get statusPaid => 'Payee';

  @override
  String get statusDisputed => 'Litige';

  @override
  String get statusCancelled => 'Annulee';

  @override
  String get statusClosed => 'Cloturee';

  @override
  String get statusDraft => 'Brouillon';

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
