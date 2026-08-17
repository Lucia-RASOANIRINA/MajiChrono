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
  String get custodyPickupTitle => 'Constat de prise en charge';

  @override
  String get custodyHandoverTitle => 'Constat de remise';

  @override
  String get custodyStepPhotos => 'Photos';

  @override
  String get custodyStepCondition => 'Etat';

  @override
  String get custodyStepSeal => 'Scelle';

  @override
  String get custodyStepSignatures => 'Signatures';

  @override
  String get custodyEngagement =>
      'Je certifie remettre ou prendre en charge ce colis dans l\'etat constate ci-dessus.';

  @override
  String get custodySignHere => 'Signez ici';

  @override
  String get custodyClearSignature => 'Effacer';

  @override
  String get custodySignerSender => 'Expediteur';

  @override
  String get custodySignerDriver => 'Livreur';

  @override
  String get custodySignerRecipient => 'Destinataire';

  @override
  String get custodyPhotoTop => 'Dessus';

  @override
  String get custodyPhotoBottom => 'Dessous';

  @override
  String get custodyPhotoSide1 => 'Cote 1';

  @override
  String get custodyPhotoSide2 => 'Cote 2';

  @override
  String get custodyPhotoGuide =>
      'Cadrez le colis dans le gabarit, puis declenchez.';

  @override
  String get custodyPhotoInAppOnly =>
      'Photo prise dans l\'application uniquement.';

  @override
  String get custodyPhotoRetake => 'Reprendre';

  @override
  String get custodyConditionTitle => 'Etat du colis';

  @override
  String get custodyConditionHelp =>
      'Cochez ce que vous constatez. Toute anomalie exige une photo et un commentaire.';

  @override
  String get conditionPackagingIntact => 'Emballage intact';

  @override
  String get conditionImpactMark => 'Trace de choc';

  @override
  String get conditionMoistureMark => 'Trace d\'humidite';

  @override
  String get conditionAlreadyOpened => 'Emballage deja ouvert';

  @override
  String get conditionOriginalTape => 'Scotch d\'origine present';

  @override
  String get conditionCrushedCorners => 'Angles ecrases';

  @override
  String get custodyAnomalyNote => 'Precisez l\'anomalie';

  @override
  String get custodySealNumber => 'Numero de scelle';

  @override
  String get custodySealHint => 'SC-4821';

  @override
  String get custodySealScanLater => 'Le scan de code arrive au module 10.';

  @override
  String get custodySealCheck => 'Etat du scelle';

  @override
  String get sealIntact => 'Intact';

  @override
  String get sealBroken => 'Rompu';

  @override
  String get sealAbsent => 'Absent';

  @override
  String get custodySealIncident => 'Un incident sera ouvert automatiquement.';

  @override
  String get custodyWeightConfirm => 'Poids confirme';

  @override
  String get custodyOutcomeTitle => 'Issue de la remise';

  @override
  String get custodyOutcomeHelp =>
      'Dites ce qui s\'est reellement passe. Chaque issue a ses obligations.';

  @override
  String get outcomeDelivered => 'Remis au destinataire';

  @override
  String get outcomeWithReserves => 'Remis sous reserves';

  @override
  String get outcomeRefused => 'Refuse par le destinataire';

  @override
  String get outcomeThirdParty => 'Remis a un tiers';

  @override
  String get outcomeNoSignature => 'Remis sans signature';

  @override
  String get custodyOutcomeReason => 'Motif ecrit';

  @override
  String get custodyOutcomeReasonHelp =>
      'Ce motif sera lu tel quel en cas de litige.';

  @override
  String get custodyReservesNotice => 'Un litige sera ouvert automatiquement.';

  @override
  String get custodyRefusedNotice => 'Le colis repart en retour expediteur.';

  @override
  String get custodyNoSignatureNotice =>
      'L\'exploitation sera alertee. La photo du colis remis est obligatoire.';

  @override
  String get custodyThirdPartyName => 'Nom du tiers';

  @override
  String get custodyThirdPartyRelation => 'Lien avec le destinataire';

  @override
  String get custodyThirdPartyRelationHint => 'Gardien, voisin, collegue...';

  @override
  String get custodyExtraPhotoSeal => 'Photo du scelle';

  @override
  String get custodyExtraPhotoId => 'Photo de la piece d\'identite';

  @override
  String get custodyExtraPhotoHandover => 'Photo du colis remis';

  @override
  String get custodyExtraPhotoMissing => 'Photo supplementaire requise';

  @override
  String get custodyExportPdf => 'Exporter en PDF';

  @override
  String get custodyExportPdfDone => 'Constat exporte';

  @override
  String get custodyExportPdfFailed => 'Export impossible';

  @override
  String get custodyPdfTitle => 'Constat contradictoire';

  @override
  String get custodyPdfHash => 'Empreinte SHA-256';

  @override
  String get custodyPdfPreviousHash => 'Empreinte precedente';

  @override
  String get custodyPdfSealedAt => 'Scelle le';

  @override
  String get custodyPdfServerTime => 'Recu par le serveur le';

  @override
  String get custodyPdfPending => 'Non transmis';

  @override
  String get custodyPdfNotice =>
      'Document genere par MajiChrono. Toute alteration rompt l\'empreinte.';

  @override
  String get custodyOtpTitle => 'Code du destinataire';

  @override
  String get custodyOtpHelp => 'Un code a ete envoye au destinataire par SMS.';

  @override
  String get custodyIncomplete => 'Constat incomplet';

  @override
  String get custodyValidate => 'Valider le constat';

  @override
  String get custodySealed => 'Constat scelle';

  @override
  String get custodySealedHelp =>
      'Il ne peut plus etre modifie. Toute precision sera un ajout distinct.';

  @override
  String get custodyComparatorTitle => 'Comparateur';

  @override
  String get custodyBefore => 'Prise en charge';

  @override
  String get custodyAfter => 'Remise';

  @override
  String get custodyNoDiff => 'Aucun ecart constate';

  @override
  String get custodyAppeared => 'Apparu a la remise';

  @override
  String get custodyDisappeared => 'Disparu en cours de route';

  @override
  String get custodyChainIntact => 'Chaine de preuve intacte';

  @override
  String get custodyChainBroken => 'Chaine de preuve rompue';

  @override
  String get custodyChainHelp =>
      'L\'empreinte de la remise integre celle de la prise en charge.';

  @override
  String get payTitle => 'Paiement';

  @override
  String get payBalance => 'Solde MajiPay';

  @override
  String get payBalanceUnavailable => 'Solde indisponible';

  @override
  String get payAmount => 'Montant a regler';

  @override
  String get payCollect => 'Encaisser';

  @override
  String get payCollectHelp =>
      'Presentez ce code au client. Il confirmera sur son telephone.';

  @override
  String get payOffer => 'Payer';

  @override
  String get payOfferHelp =>
      'Le livreur scanne ce code. Vous avez deja confirme le montant.';

  @override
  String get payScan => 'Scanner un code';

  @override
  String get payScanHelp => 'Cadrez le code affiche sur l\'autre telephone.';

  @override
  String get payScanInvalid =>
      'Ce code n\'est pas un code de paiement MajiChrono';

  @override
  String get payScanPermission => 'Autorisez l\'appareil photo pour scanner';

  @override
  String get payShowQr => 'Afficher mon code';

  @override
  String payQrExpires(int minutes) {
    return 'Code valable $minutes min';
  }

  @override
  String get payQrExpired => 'Code expire';

  @override
  String get payQrRenew => 'Generer un nouveau code';

  @override
  String get payWaiting => 'En attente du scan...';

  @override
  String get payConfirmTitle => 'Confirmer le paiement';

  @override
  String get payConfirmTo => 'Beneficiaire';

  @override
  String get payConfirmPin => 'Saisissez votre code pour confirmer';

  @override
  String payConfirmAction(String amount) {
    return 'Confirmer $amount';
  }

  @override
  String get payConfirmNever =>
      'Scanner ne suffit pas : personne ne peut debiter votre compte sans ce code.';

  @override
  String get payWrongPin => 'Code incorrect';

  @override
  String get payCaptured => 'Paiement effectue';

  @override
  String get payReceived => 'Paiement recu';

  @override
  String get payFailedInsufficient => 'Solde MajiPay insuffisant';

  @override
  String get payFailedExpired => 'Le code a expire';

  @override
  String get payFailedDeclined => 'Paiement refuse';

  @override
  String get payFailedUnavailable => 'MajiPay est indisponible';

  @override
  String get payCashFallback => 'Regler en especes';

  @override
  String get payCashHelp =>
      'La course n\'est jamais bloquee par un probleme de paiement.';

  @override
  String get payCashDone => 'Regle en especes';

  @override
  String get payReceiptTitle => 'Recu';

  @override
  String get payReceiptRef => 'Reference';

  @override
  String get payReceiptShare => 'Partager le recu';

  @override
  String get payMethodMajipay => 'MajiPay';

  @override
  String get payMethodCash => 'Especes';

  @override
  String get syncPendingTitle => 'Elements en attente';

  @override
  String get syncPendingEmpty => 'Tout est transmis';

  @override
  String get syncPendingEmptyHelp =>
      'Rien n\'attend d\'etre envoye au serveur.';

  @override
  String get syncPendingHelp =>
      'Ces elements partiront des le retour du reseau. Les constats passent en premier.';

  @override
  String get syncRetry => 'Relancer';

  @override
  String get syncRetryAll => 'Tout relancer';

  @override
  String get syncItemCustody => 'Constat';

  @override
  String get syncItemTransition => 'Course';

  @override
  String get syncItemPosition => 'Positions';

  @override
  String get syncItemRating => 'Notation';

  @override
  String get syncCauseNone => 'En attente d\'une fenetre reseau';

  @override
  String get syncCauseNetwork => 'Reseau indisponible';

  @override
  String get syncCauseServer => 'Le serveur n\'a pas repondu';

  @override
  String get syncCauseConflict => 'Le serveur a un autre etat';

  @override
  String get syncCauseRejected => 'Refuse par le serveur';

  @override
  String get syncCauseExhausted => 'Tentatives epuisees';

  @override
  String get syncNeverAbandon => 'Preuve : jamais abandonnee';

  @override
  String syncAttempts(int count) {
    return '$count tentatives';
  }

  @override
  String get syncAgeNow => 'a l\'instant';

  @override
  String syncAgeMinutes(int count) {
    return 'il y a $count min';
  }

  @override
  String syncAgeHours(int count) {
    return 'il y a $count h';
  }

  @override
  String syncAgeDays(int count) {
    return 'il y a $count j';
  }

  @override
  String get syncConflictNotice =>
      'Le serveur a impose son etat. Vos donnees ont ete mises a jour.';

  @override
  String get syncRetryQueued => 'Relance demandee';

  @override
  String get driverOnline => 'En ligne';

  @override
  String get driverOffline => 'Hors service';

  @override
  String get driverOnlineHelp =>
      'Vous recevez des courses tant que vous etes en ligne.';

  @override
  String get driverOfflineHelp => 'Aucune course ne vous sera proposee.';

  @override
  String get driverAvailable => 'Courses disponibles';

  @override
  String get driverNoOffers => 'Aucune course pour l\'instant';

  @override
  String get driverNoOffersHelp =>
      'Restez en ligne : les courses arrivent au fil de la journee.';

  @override
  String get driverOfflineEmpty => 'Passez en ligne pour recevoir des courses';

  @override
  String driverPickupDistance(String km) {
    return '$km km a vide';
  }

  @override
  String get driverEarning => 'Gain estime';

  @override
  String get driverAccept => 'Accepter';

  @override
  String driverAcceptIn(int seconds) {
    return 'Accepter ($seconds s)';
  }

  @override
  String get driverAlreadyTaken => 'Course deja prise par un autre livreur';

  @override
  String get driverActiveDelivery => 'Course en cours';

  @override
  String get driverNavigate => 'Ouvrir l\'itineraire';

  @override
  String get driverCall => 'Appeler le contact';

  @override
  String get driverStepArrivedPickup => 'Je suis au depart';

  @override
  String get driverStepPickedUp => 'Colis pris en charge';

  @override
  String get driverStepArrivedDestination => 'Je suis a destination';

  @override
  String get driverStepDelivered => 'Colis remis';

  @override
  String get driverCustodyRequired =>
      'Un constat sera demande a cette etape (module 5).';

  @override
  String get driverIncident => 'Signaler un incident';

  @override
  String get incidentRecipientAbsent => 'Destinataire absent';

  @override
  String get incidentAddressNotFound => 'Adresse introuvable';

  @override
  String get incidentRefused => 'Refus de reception';

  @override
  String get incidentBreakdown => 'Vehicule en panne';

  @override
  String get outcomeWaitThenReturn =>
      'Attendre 10 minutes, puis retour expediteur';

  @override
  String get outcomeContactSupport => 'L\'exploitation vous rappelle';

  @override
  String get outcomeReturnToSender => 'Colis renvoye a l\'expediteur';

  @override
  String get outcomeReassign => 'La course sera reaffectee';

  @override
  String get earningsTitle => 'Mes gains';

  @override
  String get earningsToday => 'Aujourd\'hui';

  @override
  String get earningsWeek => 'Cette semaine';

  @override
  String get earningsMonth => 'Ce mois-ci';

  @override
  String earningsCount(int count) {
    return '$count course(s)';
  }

  @override
  String get earningsEmpty => 'Aucun gain enregistre';

  @override
  String get earningsCommission => 'Montants nets, commission deduite.';

  @override
  String get kycTitle => 'Mon dossier';

  @override
  String get kycStatusDraft => 'Dossier a completer';

  @override
  String get kycStatusSubmitted => 'Dossier transmis';

  @override
  String get kycStatusUnderReview => 'En cours de verification';

  @override
  String get kycStatusApproved => 'Dossier valide';

  @override
  String get kycStatusRejected => 'Dossier refuse';

  @override
  String get kycBlocking =>
      'Vous ne pouvez pas prendre de course tant que le dossier n\'est pas valide.';

  @override
  String get kycDocCinFront => 'CIN recto';

  @override
  String get kycDocCinBack => 'CIN verso';

  @override
  String get kycDocLicence => 'Permis de conduire';

  @override
  String get kycDocSelfie => 'Photo du visage';

  @override
  String get kycDocRegistration => 'Carte grise';

  @override
  String get kycDocVehicle => 'Photo du vehicule';

  @override
  String get kycDocPlate => 'Photo de la plaque';

  @override
  String get kycCaptureLater =>
      'La prise de vue des pieces arrive au module 5.';

  @override
  String get kycSubmit => 'Transmettre le dossier';

  @override
  String get pickLocationTitle => 'Placer le point';

  @override
  String get pickLocationAction => 'Placer sur la carte';

  @override
  String get pickLocationSet => 'Point place';

  @override
  String get pickLocationHelp =>
      'Le point GPS approche le livreur ; le point de repere fait le reste.';

  @override
  String get trackingTitle => 'Suivi de la course';

  @override
  String get trackingTimeline => 'Etapes';

  @override
  String get trackingDriver => 'Votre livreur';

  @override
  String trackingEta(int minutes) {
    return 'Arrivee estimee dans $minutes min';
  }

  @override
  String get trackingShare => 'Partager le suivi';

  @override
  String trackingShareMessage(String url) {
    return 'Suivez votre colis MajiChrono : $url';
  }

  @override
  String get trackingCall => 'Appeler';

  @override
  String get trackingCallMasked => 'Numero masque des deux cotes';

  @override
  String trackingRating(String rating) {
    return '$rating / 5';
  }

  @override
  String get trackingPublicTitle => 'Suivi du colis';

  @override
  String get trackingPublicExpired => 'Ce lien de suivi n\'est plus valable.';

  @override
  String get trackingNoDriverYet =>
      'Aucun livreur n\'a encore accepte la course.';

  @override
  String get mapUnavailable =>
      'Carte indisponible hors ligne. Les points restent affiches.';

  @override
  String get linkCopied => 'Lien copie';

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
