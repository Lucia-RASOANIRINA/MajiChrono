import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';
import 'app_localizations_mg.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('mg'),
  ];

  /// Nom du produit
  ///
  /// In fr, this message translates to:
  /// **'MajiChrono'**
  String get appName;

  /// No description provided for @commonContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get commonContinue;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get commonConfirm;

  /// No description provided for @commonRetry.
  ///
  /// In fr, this message translates to:
  /// **'Reessayer'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get commonBack;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @commonSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get commonSearch;

  /// No description provided for @commonYes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get commonNo;

  /// No description provided for @commonLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get commonLoading;

  /// No description provided for @langFrench.
  ///
  /// In fr, this message translates to:
  /// **'Francais'**
  String get langFrench;

  /// No description provided for @langMalagasy.
  ///
  /// In fr, this message translates to:
  /// **'Malagasy'**
  String get langMalagasy;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Reglages'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Systeme'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @networkOnline.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get networkOnline;

  /// Bandeau reseau EXI-T06
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne — {count} element(s) en attente'**
  String networkOfflinePending(int count);

  /// No description provided for @networkOfflineNoPending.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get networkOfflineNoPending;

  /// No description provided for @networkSyncing.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation en cours...'**
  String get networkSyncing;

  /// No description provided for @authPhoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre numero'**
  String get authPhoneTitle;

  /// No description provided for @authPhoneSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Nous vous envoyons un code par SMS pour verifier ce numero.'**
  String get authPhoneSubtitle;

  /// No description provided for @authPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Numero de telephone'**
  String get authPhoneLabel;

  /// No description provided for @authPhoneHint.
  ///
  /// In fr, this message translates to:
  /// **'034 12 345 67'**
  String get authPhoneHint;

  /// No description provided for @authPhoneInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Numero malgache invalide'**
  String get authPhoneInvalid;

  /// No description provided for @authPhoneOperator.
  ///
  /// In fr, this message translates to:
  /// **'Operateur reconnu : {operator}'**
  String authPhoneOperator(String operator);

  /// No description provided for @authOtpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Code de verification'**
  String get authOtpTitle;

  /// No description provided for @authOtpSentTo.
  ///
  /// In fr, this message translates to:
  /// **'Code envoye au {phone}'**
  String authOtpSentTo(String phone);

  /// No description provided for @authOtpExpiresIn.
  ///
  /// In fr, this message translates to:
  /// **'Expire dans {time}'**
  String authOtpExpiresIn(String time);

  /// No description provided for @authOtpExpired.
  ///
  /// In fr, this message translates to:
  /// **'Code expire. Demandez-en un nouveau.'**
  String get authOtpExpired;

  /// No description provided for @authOtpResend.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get authOtpResend;

  /// No description provided for @authOtpInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect. Il reste {count} tentative(s).'**
  String authOtpInvalid(int count);

  /// No description provided for @authOtpLocked.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Demandez un nouveau code.'**
  String get authOtpLocked;

  /// No description provided for @authOtpSimulated.
  ///
  /// In fr, this message translates to:
  /// **'Code simule : {code}'**
  String authOtpSimulated(String code);

  /// No description provided for @authProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre profil'**
  String get authProfileTitle;

  /// No description provided for @authProfileSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce choix est definitif : il determine l\'application que vous utilisez.'**
  String get authProfileSubtitle;

  /// No description provided for @authProfileName.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom'**
  String get authProfileName;

  /// No description provided for @authProfileNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom vu par les autres'**
  String get authProfileNameHint;

  /// No description provided for @authProfileNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez votre nom'**
  String get authProfileNameRequired;

  /// No description provided for @authProfileAdminNote.
  ///
  /// In fr, this message translates to:
  /// **'Le profil exploitation est attribue par MajiChrono, il ne se choisit pas ici.'**
  String get authProfileAdminNote;

  /// No description provided for @authPinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Creez un code a 4 chiffres'**
  String get authPinTitle;

  /// No description provided for @authPinSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Il protege votre compte a la reouverture de l\'application.'**
  String get authPinSubtitle;

  /// No description provided for @authPinConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez votre code'**
  String get authPinConfirmTitle;

  /// No description provided for @authPinMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les deux codes ne correspondent pas'**
  String get authPinMismatch;

  /// No description provided for @authPinLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get authPinLater;

  /// No description provided for @authPinSaved.
  ///
  /// In fr, this message translates to:
  /// **'Code enregistre'**
  String get authPinSaved;

  /// No description provided for @authLockTitle.
  ///
  /// In fr, this message translates to:
  /// **'Application verrouillee'**
  String get authLockTitle;

  /// No description provided for @authLockSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre code pour continuer'**
  String get authLockSubtitle;

  /// No description provided for @authLockBiometrics.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser la biometrie'**
  String get authLockBiometrics;

  /// No description provided for @authBiometricsReason.
  ///
  /// In fr, this message translates to:
  /// **'Deverrouiller MajiChrono'**
  String get authBiometricsReason;

  /// No description provided for @authLockWrongPin.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect'**
  String get authLockWrongPin;

  /// No description provided for @authSignOut.
  ///
  /// In fr, this message translates to:
  /// **'Se deconnecter'**
  String get authSignOut;

  /// No description provided for @authSignOutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Se deconnecter effacera les donnees de cet appareil. Continuer ?'**
  String get authSignOutConfirm;

  /// No description provided for @authWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {name}'**
  String authWelcome(String name);

  /// No description provided for @roleChooseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Je suis'**
  String get roleChooseTitle;

  /// No description provided for @roleClient.
  ///
  /// In fr, this message translates to:
  /// **'Expediteur'**
  String get roleClient;

  /// No description provided for @roleClientDesc.
  ///
  /// In fr, this message translates to:
  /// **'J\'envoie un colis ou je commande une course'**
  String get roleClientDesc;

  /// No description provided for @roleDriver.
  ///
  /// In fr, this message translates to:
  /// **'Livreur'**
  String get roleDriver;

  /// No description provided for @roleDriverDesc.
  ///
  /// In fr, this message translates to:
  /// **'Je realise des courses'**
  String get roleDriverDesc;

  /// No description provided for @roleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Exploitation'**
  String get roleAdmin;

  /// No description provided for @roleAdminDesc.
  ///
  /// In fr, this message translates to:
  /// **'Je supervise la flotte et les litiges'**
  String get roleAdminDesc;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navDeliveries.
  ///
  /// In fr, this message translates to:
  /// **'Courses'**
  String get navDeliveries;

  /// No description provided for @navTracking.
  ///
  /// In fr, this message translates to:
  /// **'Suivi'**
  String get navTracking;

  /// No description provided for @navEarnings.
  ///
  /// In fr, this message translates to:
  /// **'Gains'**
  String get navEarnings;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @navFleet.
  ///
  /// In fr, this message translates to:
  /// **'Flotte'**
  String get navFleet;

  /// No description provided for @navDisputes.
  ///
  /// In fr, this message translates to:
  /// **'Litiges'**
  String get navDisputes;

  /// No description provided for @navKyc.
  ///
  /// In fr, this message translates to:
  /// **'KYC'**
  String get navKyc;

  /// Libelle de barre de navigation : doit tenir sur une ligne a 320 dp de large avec 4 destinations (EXI-P09). Le titre complet reste dans la barre de titre.
  ///
  /// In fr, this message translates to:
  /// **'Tableau'**
  String get navDashboard;

  /// No description provided for @clientHomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accueil expediteur'**
  String get clientHomeTitle;

  /// No description provided for @clientNewDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle course'**
  String get clientNewDelivery;

  /// No description provided for @driverHomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accueil livreur'**
  String get driverHomeTitle;

  /// No description provided for @adminHomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supervision'**
  String get adminHomeTitle;

  /// No description provided for @newDeliveryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle course'**
  String get newDeliveryTitle;

  /// No description provided for @stepAddresses.
  ///
  /// In fr, this message translates to:
  /// **'Adresses'**
  String get stepAddresses;

  /// No description provided for @stepPackage.
  ///
  /// In fr, this message translates to:
  /// **'Colis'**
  String get stepPackage;

  /// No description provided for @stepReview.
  ///
  /// In fr, this message translates to:
  /// **'Recapitulatif'**
  String get stepReview;

  /// No description provided for @addrPickupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de depart'**
  String get addrPickupTitle;

  /// No description provided for @addrDropoffTitle.
  ///
  /// In fr, this message translates to:
  /// **'Adresse d\'arrivee'**
  String get addrDropoffTitle;

  /// No description provided for @addrDistrict.
  ///
  /// In fr, this message translates to:
  /// **'Quartier'**
  String get addrDistrict;

  /// No description provided for @addrDistrictHint.
  ///
  /// In fr, this message translates to:
  /// **'Ambohipo'**
  String get addrDistrictHint;

  /// No description provided for @addrLandmark.
  ///
  /// In fr, this message translates to:
  /// **'Point de repere'**
  String get addrLandmark;

  /// No description provided for @addrLandmarkHint.
  ///
  /// In fr, this message translates to:
  /// **'Apres l\'epicerie Tsiky, portail vert'**
  String get addrLandmarkHint;

  /// No description provided for @addrLandmarkHelp.
  ///
  /// In fr, this message translates to:
  /// **'C\'est ce qui permet au livreur de vous trouver.'**
  String get addrLandmarkHelp;

  /// No description provided for @addrContactPhone.
  ///
  /// In fr, this message translates to:
  /// **'Telephone sur place'**
  String get addrContactPhone;

  /// No description provided for @addrContactName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du contact'**
  String get addrContactName;

  /// No description provided for @addrStreet.
  ///
  /// In fr, this message translates to:
  /// **'Rue et numero'**
  String get addrStreet;

  /// No description provided for @addrOptional.
  ///
  /// In fr, this message translates to:
  /// **'facultatif'**
  String get addrOptional;

  /// No description provided for @addrRequired.
  ///
  /// In fr, this message translates to:
  /// **'Champ obligatoire'**
  String get addrRequired;

  /// No description provided for @addrSaveToBook.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer dans mes adresses'**
  String get addrSaveToBook;

  /// No description provided for @addrLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'adresse'**
  String get addrLabel;

  /// No description provided for @addrLabelHint.
  ///
  /// In fr, this message translates to:
  /// **'Maison, Boutique'**
  String get addrLabelHint;

  /// No description provided for @addrBookTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes adresses'**
  String get addrBookTitle;

  /// No description provided for @addrBookEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune adresse enregistree'**
  String get addrBookEmpty;

  /// No description provided for @addrBookEmptyHelp.
  ///
  /// In fr, this message translates to:
  /// **'Les adresses enregistrees ici se reutilisent en un geste.'**
  String get addrBookEmptyHelp;

  /// No description provided for @addrPickFromBook.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans mes adresses'**
  String get addrPickFromBook;

  /// No description provided for @addrNew.
  ///
  /// In fr, this message translates to:
  /// **'Saisir une nouvelle adresse'**
  String get addrNew;

  /// No description provided for @addrDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get addrDelete;

  /// No description provided for @pkgTitle.
  ///
  /// In fr, this message translates to:
  /// **'Le colis'**
  String get pkgTitle;

  /// No description provided for @pkgWeight.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get pkgWeight;

  /// No description provided for @pkgWeightLt2.
  ///
  /// In fr, this message translates to:
  /// **'Moins de 2 kg'**
  String get pkgWeightLt2;

  /// No description provided for @pkgWeight2to5.
  ///
  /// In fr, this message translates to:
  /// **'2 a 5 kg'**
  String get pkgWeight2to5;

  /// No description provided for @pkgWeight5to15.
  ///
  /// In fr, this message translates to:
  /// **'5 a 15 kg'**
  String get pkgWeight5to15;

  /// No description provided for @pkgWeightGt15.
  ///
  /// In fr, this message translates to:
  /// **'Plus de 15 kg'**
  String get pkgWeightGt15;

  /// No description provided for @pkgValue.
  ///
  /// In fr, this message translates to:
  /// **'Valeur declaree'**
  String get pkgValue;

  /// No description provided for @pkgDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get pkgDescription;

  /// No description provided for @pkgPhotoLater.
  ///
  /// In fr, this message translates to:
  /// **'La photo du colis sera demandee au module 5, avec la chaine photo.'**
  String get pkgPhotoLater;

  /// No description provided for @kindTitle.
  ///
  /// In fr, this message translates to:
  /// **'Type de course'**
  String get kindTitle;

  /// No description provided for @kindStandard.
  ///
  /// In fr, this message translates to:
  /// **'Colis standard'**
  String get kindStandard;

  /// No description provided for @kindDocument.
  ///
  /// In fr, this message translates to:
  /// **'Document'**
  String get kindDocument;

  /// No description provided for @kindFragile.
  ///
  /// In fr, this message translates to:
  /// **'Fragile'**
  String get kindFragile;

  /// No description provided for @kindFood.
  ///
  /// In fr, this message translates to:
  /// **'Alimentaire'**
  String get kindFood;

  /// No description provided for @kindShopping.
  ///
  /// In fr, this message translates to:
  /// **'Achat pour compte'**
  String get kindShopping;

  /// No description provided for @kindShoppingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Disponible au module 9'**
  String get kindShoppingSoon;

  /// No description provided for @slotTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quand ?'**
  String get slotTitle;

  /// No description provided for @slotImmediate.
  ///
  /// In fr, this message translates to:
  /// **'Immediat'**
  String get slotImmediate;

  /// No description provided for @slotScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Programme'**
  String get slotScheduled;

  /// No description provided for @slotPickDate.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la date'**
  String get slotPickDate;

  /// No description provided for @slotRange.
  ///
  /// In fr, this message translates to:
  /// **'{start}h - {end}h'**
  String slotRange(int start, int end);

  /// No description provided for @paymentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get paymentTitle;

  /// No description provided for @paymentCash.
  ///
  /// In fr, this message translates to:
  /// **'Especes a la livraison'**
  String get paymentCash;

  /// No description provided for @paymentMajipay.
  ///
  /// In fr, this message translates to:
  /// **'MajiPay'**
  String get paymentMajipay;

  /// No description provided for @paymentMajipaySoon.
  ///
  /// In fr, this message translates to:
  /// **'Disponible au module 7'**
  String get paymentMajipaySoon;

  /// No description provided for @estimateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Estimation du prix'**
  String get estimateTitle;

  /// No description provided for @estimateTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get estimateTotal;

  /// No description provided for @estimateProvisional.
  ///
  /// In fr, this message translates to:
  /// **'Tarif provisoire : la grille definitive n\'est pas encore arretee.'**
  String get estimateProvisional;

  /// No description provided for @priceBase.
  ///
  /// In fr, this message translates to:
  /// **'Prise en charge'**
  String get priceBase;

  /// No description provided for @priceDistance.
  ///
  /// In fr, this message translates to:
  /// **'Distance'**
  String get priceDistance;

  /// No description provided for @priceWeight.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get priceWeight;

  /// No description provided for @priceKind.
  ///
  /// In fr, this message translates to:
  /// **'Majoration type de course'**
  String get priceKind;

  /// No description provided for @priceSchedule.
  ///
  /// In fr, this message translates to:
  /// **'Creneau programme'**
  String get priceSchedule;

  /// No description provided for @priceInsurance.
  ///
  /// In fr, this message translates to:
  /// **'Assurance'**
  String get priceInsurance;

  /// No description provided for @confirmDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la course'**
  String get confirmDelivery;

  /// No description provided for @deliveryCreated.
  ///
  /// In fr, this message translates to:
  /// **'Course creee'**
  String get deliveryCreated;

  /// No description provided for @deliveryQueued.
  ///
  /// In fr, this message translates to:
  /// **'Course enregistree. Elle partira des le retour du reseau.'**
  String get deliveryQueued;

  /// No description provided for @deliveriesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes courses'**
  String get deliveriesTitle;

  /// No description provided for @deliveryPendingSync.
  ///
  /// In fr, this message translates to:
  /// **'En attente d\'envoi'**
  String get deliveryPendingSync;

  /// No description provided for @deliveryCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la course'**
  String get deliveryCancel;

  /// No description provided for @deliveryCancelConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Annuler cette course ? Des frais peuvent s\'appliquer.'**
  String get deliveryCancelConfirm;

  /// No description provided for @deliveryDistance.
  ///
  /// In fr, this message translates to:
  /// **'{km} km'**
  String deliveryDistance(String km);

  /// No description provided for @custodyPickupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Constat de prise en charge'**
  String get custodyPickupTitle;

  /// No description provided for @custodyHandoverTitle.
  ///
  /// In fr, this message translates to:
  /// **'Constat de remise'**
  String get custodyHandoverTitle;

  /// No description provided for @custodyStepPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Photos'**
  String get custodyStepPhotos;

  /// No description provided for @custodyStepCondition.
  ///
  /// In fr, this message translates to:
  /// **'Etat'**
  String get custodyStepCondition;

  /// No description provided for @custodyStepSeal.
  ///
  /// In fr, this message translates to:
  /// **'Scelle'**
  String get custodyStepSeal;

  /// No description provided for @custodyStepSignatures.
  ///
  /// In fr, this message translates to:
  /// **'Signatures'**
  String get custodyStepSignatures;

  /// No description provided for @custodyEngagement.
  ///
  /// In fr, this message translates to:
  /// **'Je certifie remettre ou prendre en charge ce colis dans l\'etat constate ci-dessus.'**
  String get custodyEngagement;

  /// No description provided for @custodySignHere.
  ///
  /// In fr, this message translates to:
  /// **'Signez ici'**
  String get custodySignHere;

  /// No description provided for @custodyClearSignature.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get custodyClearSignature;

  /// No description provided for @custodySignerSender.
  ///
  /// In fr, this message translates to:
  /// **'Expediteur'**
  String get custodySignerSender;

  /// No description provided for @custodySignerDriver.
  ///
  /// In fr, this message translates to:
  /// **'Livreur'**
  String get custodySignerDriver;

  /// No description provided for @custodySignerRecipient.
  ///
  /// In fr, this message translates to:
  /// **'Destinataire'**
  String get custodySignerRecipient;

  /// No description provided for @custodyPhotoTop.
  ///
  /// In fr, this message translates to:
  /// **'Dessus'**
  String get custodyPhotoTop;

  /// No description provided for @custodyPhotoBottom.
  ///
  /// In fr, this message translates to:
  /// **'Dessous'**
  String get custodyPhotoBottom;

  /// No description provided for @custodyPhotoSide1.
  ///
  /// In fr, this message translates to:
  /// **'Cote 1'**
  String get custodyPhotoSide1;

  /// No description provided for @custodyPhotoSide2.
  ///
  /// In fr, this message translates to:
  /// **'Cote 2'**
  String get custodyPhotoSide2;

  /// No description provided for @custodyPhotoGuide.
  ///
  /// In fr, this message translates to:
  /// **'Cadrez le colis dans le gabarit, puis declenchez.'**
  String get custodyPhotoGuide;

  /// No description provided for @custodyPhotoInAppOnly.
  ///
  /// In fr, this message translates to:
  /// **'Photo prise dans l\'application uniquement.'**
  String get custodyPhotoInAppOnly;

  /// No description provided for @custodyPhotoRetake.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get custodyPhotoRetake;

  /// No description provided for @custodyConditionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Etat du colis'**
  String get custodyConditionTitle;

  /// No description provided for @custodyConditionHelp.
  ///
  /// In fr, this message translates to:
  /// **'Cochez ce que vous constatez. Toute anomalie exige une photo et un commentaire.'**
  String get custodyConditionHelp;

  /// No description provided for @conditionPackagingIntact.
  ///
  /// In fr, this message translates to:
  /// **'Emballage intact'**
  String get conditionPackagingIntact;

  /// No description provided for @conditionImpactMark.
  ///
  /// In fr, this message translates to:
  /// **'Trace de choc'**
  String get conditionImpactMark;

  /// No description provided for @conditionMoistureMark.
  ///
  /// In fr, this message translates to:
  /// **'Trace d\'humidite'**
  String get conditionMoistureMark;

  /// No description provided for @conditionAlreadyOpened.
  ///
  /// In fr, this message translates to:
  /// **'Emballage deja ouvert'**
  String get conditionAlreadyOpened;

  /// No description provided for @conditionOriginalTape.
  ///
  /// In fr, this message translates to:
  /// **'Scotch d\'origine present'**
  String get conditionOriginalTape;

  /// No description provided for @conditionCrushedCorners.
  ///
  /// In fr, this message translates to:
  /// **'Angles ecrases'**
  String get conditionCrushedCorners;

  /// No description provided for @custodyAnomalyNote.
  ///
  /// In fr, this message translates to:
  /// **'Precisez l\'anomalie'**
  String get custodyAnomalyNote;

  /// No description provided for @custodySealNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numero de scelle'**
  String get custodySealNumber;

  /// No description provided for @custodySealHint.
  ///
  /// In fr, this message translates to:
  /// **'SC-4821'**
  String get custodySealHint;

  /// No description provided for @custodySealScanLater.
  ///
  /// In fr, this message translates to:
  /// **'Le scan de code arrive au module 10.'**
  String get custodySealScanLater;

  /// No description provided for @custodySealCheck.
  ///
  /// In fr, this message translates to:
  /// **'Etat du scelle'**
  String get custodySealCheck;

  /// No description provided for @sealIntact.
  ///
  /// In fr, this message translates to:
  /// **'Intact'**
  String get sealIntact;

  /// No description provided for @sealBroken.
  ///
  /// In fr, this message translates to:
  /// **'Rompu'**
  String get sealBroken;

  /// No description provided for @sealAbsent.
  ///
  /// In fr, this message translates to:
  /// **'Absent'**
  String get sealAbsent;

  /// No description provided for @custodySealIncident.
  ///
  /// In fr, this message translates to:
  /// **'Un incident sera ouvert automatiquement.'**
  String get custodySealIncident;

  /// No description provided for @custodyWeightConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Poids confirme'**
  String get custodyWeightConfirm;

  /// No description provided for @custodyOtpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Code du destinataire'**
  String get custodyOtpTitle;

  /// No description provided for @custodyOtpHelp.
  ///
  /// In fr, this message translates to:
  /// **'Un code a ete envoye au destinataire par SMS.'**
  String get custodyOtpHelp;

  /// No description provided for @custodyIncomplete.
  ///
  /// In fr, this message translates to:
  /// **'Constat incomplet'**
  String get custodyIncomplete;

  /// No description provided for @custodyValidate.
  ///
  /// In fr, this message translates to:
  /// **'Valider le constat'**
  String get custodyValidate;

  /// No description provided for @custodySealed.
  ///
  /// In fr, this message translates to:
  /// **'Constat scelle'**
  String get custodySealed;

  /// No description provided for @custodySealedHelp.
  ///
  /// In fr, this message translates to:
  /// **'Il ne peut plus etre modifie. Toute precision sera un ajout distinct.'**
  String get custodySealedHelp;

  /// No description provided for @custodyComparatorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comparateur'**
  String get custodyComparatorTitle;

  /// No description provided for @custodyBefore.
  ///
  /// In fr, this message translates to:
  /// **'Prise en charge'**
  String get custodyBefore;

  /// No description provided for @custodyAfter.
  ///
  /// In fr, this message translates to:
  /// **'Remise'**
  String get custodyAfter;

  /// No description provided for @custodyNoDiff.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ecart constate'**
  String get custodyNoDiff;

  /// No description provided for @custodyAppeared.
  ///
  /// In fr, this message translates to:
  /// **'Apparu a la remise'**
  String get custodyAppeared;

  /// No description provided for @custodyDisappeared.
  ///
  /// In fr, this message translates to:
  /// **'Disparu en cours de route'**
  String get custodyDisappeared;

  /// No description provided for @custodyChainIntact.
  ///
  /// In fr, this message translates to:
  /// **'Chaine de preuve intacte'**
  String get custodyChainIntact;

  /// No description provided for @custodyChainBroken.
  ///
  /// In fr, this message translates to:
  /// **'Chaine de preuve rompue'**
  String get custodyChainBroken;

  /// No description provided for @custodyChainHelp.
  ///
  /// In fr, this message translates to:
  /// **'L\'empreinte de la remise integre celle de la prise en charge.'**
  String get custodyChainHelp;

  /// No description provided for @driverOnline.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get driverOnline;

  /// No description provided for @driverOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors service'**
  String get driverOffline;

  /// No description provided for @driverOnlineHelp.
  ///
  /// In fr, this message translates to:
  /// **'Vous recevez des courses tant que vous etes en ligne.'**
  String get driverOnlineHelp;

  /// No description provided for @driverOfflineHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aucune course ne vous sera proposee.'**
  String get driverOfflineHelp;

  /// No description provided for @driverAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Courses disponibles'**
  String get driverAvailable;

  /// No description provided for @driverNoOffers.
  ///
  /// In fr, this message translates to:
  /// **'Aucune course pour l\'instant'**
  String get driverNoOffers;

  /// No description provided for @driverNoOffersHelp.
  ///
  /// In fr, this message translates to:
  /// **'Restez en ligne : les courses arrivent au fil de la journee.'**
  String get driverNoOffersHelp;

  /// No description provided for @driverOfflineEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Passez en ligne pour recevoir des courses'**
  String get driverOfflineEmpty;

  /// No description provided for @driverPickupDistance.
  ///
  /// In fr, this message translates to:
  /// **'{km} km a vide'**
  String driverPickupDistance(String km);

  /// No description provided for @driverEarning.
  ///
  /// In fr, this message translates to:
  /// **'Gain estime'**
  String get driverEarning;

  /// No description provided for @driverAccept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get driverAccept;

  /// No description provided for @driverAcceptIn.
  ///
  /// In fr, this message translates to:
  /// **'Accepter ({seconds} s)'**
  String driverAcceptIn(int seconds);

  /// No description provided for @driverAlreadyTaken.
  ///
  /// In fr, this message translates to:
  /// **'Course deja prise par un autre livreur'**
  String get driverAlreadyTaken;

  /// No description provided for @driverActiveDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Course en cours'**
  String get driverActiveDelivery;

  /// No description provided for @driverNavigate.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir l\'itineraire'**
  String get driverNavigate;

  /// No description provided for @driverCall.
  ///
  /// In fr, this message translates to:
  /// **'Appeler le contact'**
  String get driverCall;

  /// No description provided for @driverStepArrivedPickup.
  ///
  /// In fr, this message translates to:
  /// **'Je suis au depart'**
  String get driverStepArrivedPickup;

  /// No description provided for @driverStepPickedUp.
  ///
  /// In fr, this message translates to:
  /// **'Colis pris en charge'**
  String get driverStepPickedUp;

  /// No description provided for @driverStepArrivedDestination.
  ///
  /// In fr, this message translates to:
  /// **'Je suis a destination'**
  String get driverStepArrivedDestination;

  /// No description provided for @driverStepDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Colis remis'**
  String get driverStepDelivered;

  /// No description provided for @driverCustodyRequired.
  ///
  /// In fr, this message translates to:
  /// **'Un constat sera demande a cette etape (module 5).'**
  String get driverCustodyRequired;

  /// No description provided for @driverIncident.
  ///
  /// In fr, this message translates to:
  /// **'Signaler un incident'**
  String get driverIncident;

  /// No description provided for @incidentRecipientAbsent.
  ///
  /// In fr, this message translates to:
  /// **'Destinataire absent'**
  String get incidentRecipientAbsent;

  /// No description provided for @incidentAddressNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Adresse introuvable'**
  String get incidentAddressNotFound;

  /// No description provided for @incidentRefused.
  ///
  /// In fr, this message translates to:
  /// **'Refus de reception'**
  String get incidentRefused;

  /// No description provided for @incidentBreakdown.
  ///
  /// In fr, this message translates to:
  /// **'Vehicule en panne'**
  String get incidentBreakdown;

  /// No description provided for @outcomeWaitThenReturn.
  ///
  /// In fr, this message translates to:
  /// **'Attendre 10 minutes, puis retour expediteur'**
  String get outcomeWaitThenReturn;

  /// No description provided for @outcomeContactSupport.
  ///
  /// In fr, this message translates to:
  /// **'L\'exploitation vous rappelle'**
  String get outcomeContactSupport;

  /// No description provided for @outcomeReturnToSender.
  ///
  /// In fr, this message translates to:
  /// **'Colis renvoye a l\'expediteur'**
  String get outcomeReturnToSender;

  /// No description provided for @outcomeReassign.
  ///
  /// In fr, this message translates to:
  /// **'La course sera reaffectee'**
  String get outcomeReassign;

  /// No description provided for @earningsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes gains'**
  String get earningsTitle;

  /// No description provided for @earningsToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get earningsToday;

  /// No description provided for @earningsWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get earningsWeek;

  /// No description provided for @earningsMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois-ci'**
  String get earningsMonth;

  /// No description provided for @earningsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} course(s)'**
  String earningsCount(int count);

  /// No description provided for @earningsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun gain enregistre'**
  String get earningsEmpty;

  /// No description provided for @earningsCommission.
  ///
  /// In fr, this message translates to:
  /// **'Montants nets, commission deduite.'**
  String get earningsCommission;

  /// No description provided for @kycTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon dossier'**
  String get kycTitle;

  /// No description provided for @kycStatusDraft.
  ///
  /// In fr, this message translates to:
  /// **'Dossier a completer'**
  String get kycStatusDraft;

  /// No description provided for @kycStatusSubmitted.
  ///
  /// In fr, this message translates to:
  /// **'Dossier transmis'**
  String get kycStatusSubmitted;

  /// No description provided for @kycStatusUnderReview.
  ///
  /// In fr, this message translates to:
  /// **'En cours de verification'**
  String get kycStatusUnderReview;

  /// No description provided for @kycStatusApproved.
  ///
  /// In fr, this message translates to:
  /// **'Dossier valide'**
  String get kycStatusApproved;

  /// No description provided for @kycStatusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Dossier refuse'**
  String get kycStatusRejected;

  /// No description provided for @kycBlocking.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne pouvez pas prendre de course tant que le dossier n\'est pas valide.'**
  String get kycBlocking;

  /// No description provided for @kycDocCinFront.
  ///
  /// In fr, this message translates to:
  /// **'CIN recto'**
  String get kycDocCinFront;

  /// No description provided for @kycDocCinBack.
  ///
  /// In fr, this message translates to:
  /// **'CIN verso'**
  String get kycDocCinBack;

  /// No description provided for @kycDocLicence.
  ///
  /// In fr, this message translates to:
  /// **'Permis de conduire'**
  String get kycDocLicence;

  /// No description provided for @kycDocSelfie.
  ///
  /// In fr, this message translates to:
  /// **'Photo du visage'**
  String get kycDocSelfie;

  /// No description provided for @kycDocRegistration.
  ///
  /// In fr, this message translates to:
  /// **'Carte grise'**
  String get kycDocRegistration;

  /// No description provided for @kycDocVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Photo du vehicule'**
  String get kycDocVehicle;

  /// No description provided for @kycDocPlate.
  ///
  /// In fr, this message translates to:
  /// **'Photo de la plaque'**
  String get kycDocPlate;

  /// No description provided for @kycCaptureLater.
  ///
  /// In fr, this message translates to:
  /// **'La prise de vue des pieces arrive au module 5.'**
  String get kycCaptureLater;

  /// No description provided for @kycSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Transmettre le dossier'**
  String get kycSubmit;

  /// No description provided for @pickLocationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Placer le point'**
  String get pickLocationTitle;

  /// No description provided for @pickLocationAction.
  ///
  /// In fr, this message translates to:
  /// **'Placer sur la carte'**
  String get pickLocationAction;

  /// No description provided for @pickLocationSet.
  ///
  /// In fr, this message translates to:
  /// **'Point place'**
  String get pickLocationSet;

  /// No description provided for @pickLocationHelp.
  ///
  /// In fr, this message translates to:
  /// **'Le point GPS approche le livreur ; le point de repere fait le reste.'**
  String get pickLocationHelp;

  /// No description provided for @trackingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivi de la course'**
  String get trackingTitle;

  /// No description provided for @trackingTimeline.
  ///
  /// In fr, this message translates to:
  /// **'Etapes'**
  String get trackingTimeline;

  /// No description provided for @trackingDriver.
  ///
  /// In fr, this message translates to:
  /// **'Votre livreur'**
  String get trackingDriver;

  /// No description provided for @trackingEta.
  ///
  /// In fr, this message translates to:
  /// **'Arrivee estimee dans {minutes} min'**
  String trackingEta(int minutes);

  /// No description provided for @trackingShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager le suivi'**
  String get trackingShare;

  /// No description provided for @trackingShareMessage.
  ///
  /// In fr, this message translates to:
  /// **'Suivez votre colis MajiChrono : {url}'**
  String trackingShareMessage(String url);

  /// No description provided for @trackingCall.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get trackingCall;

  /// No description provided for @trackingCallMasked.
  ///
  /// In fr, this message translates to:
  /// **'Numero masque des deux cotes'**
  String get trackingCallMasked;

  /// No description provided for @trackingRating.
  ///
  /// In fr, this message translates to:
  /// **'{rating} / 5'**
  String trackingRating(String rating);

  /// No description provided for @trackingPublicTitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivi du colis'**
  String get trackingPublicTitle;

  /// No description provided for @trackingPublicExpired.
  ///
  /// In fr, this message translates to:
  /// **'Ce lien de suivi n\'est plus valable.'**
  String get trackingPublicExpired;

  /// No description provided for @trackingNoDriverYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livreur n\'a encore accepte la course.'**
  String get trackingNoDriverYet;

  /// No description provided for @mapUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Carte indisponible hors ligne. Les points restent affiches.'**
  String get mapUnavailable;

  /// No description provided for @linkCopied.
  ///
  /// In fr, this message translates to:
  /// **'Lien copie'**
  String get linkCopied;

  /// No description provided for @statusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente d\'un livreur'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Livreur en route'**
  String get statusAccepted;

  /// No description provided for @statusAtPickup.
  ///
  /// In fr, this message translates to:
  /// **'Livreur au depart'**
  String get statusAtPickup;

  /// No description provided for @statusPickedUp.
  ///
  /// In fr, this message translates to:
  /// **'Colis pris en charge'**
  String get statusPickedUp;

  /// No description provided for @statusInTransit.
  ///
  /// In fr, this message translates to:
  /// **'En transit'**
  String get statusInTransit;

  /// No description provided for @statusAtDestination.
  ///
  /// In fr, this message translates to:
  /// **'Livreur arrive'**
  String get statusAtDestination;

  /// No description provided for @statusDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Livree'**
  String get statusDelivered;

  /// No description provided for @statusDeliveredWithReserves.
  ///
  /// In fr, this message translates to:
  /// **'Livree avec reserves'**
  String get statusDeliveredWithReserves;

  /// No description provided for @statusRefused.
  ///
  /// In fr, this message translates to:
  /// **'Refusee'**
  String get statusRefused;

  /// No description provided for @statusReturning.
  ///
  /// In fr, this message translates to:
  /// **'Retour expediteur'**
  String get statusReturning;

  /// No description provided for @statusPaid.
  ///
  /// In fr, this message translates to:
  /// **'Payee'**
  String get statusPaid;

  /// No description provided for @statusDisputed.
  ///
  /// In fr, this message translates to:
  /// **'Litige'**
  String get statusDisputed;

  /// No description provided for @statusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulee'**
  String get statusCancelled;

  /// No description provided for @statusClosed.
  ///
  /// In fr, this message translates to:
  /// **'Cloturee'**
  String get statusClosed;

  /// No description provided for @statusDraft.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon'**
  String get statusDraft;

  /// No description provided for @emptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rien a afficher'**
  String get emptyTitle;

  /// No description provided for @emptyDeliveries.
  ///
  /// In fr, this message translates to:
  /// **'Aucune course pour l\'instant'**
  String get emptyDeliveries;

  /// No description provided for @emptyDeliveriesAction.
  ///
  /// In fr, this message translates to:
  /// **'Creer une course'**
  String get emptyDeliveriesAction;

  /// No description provided for @errorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Une action est necessaire'**
  String get errorTitle;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Le reseau est indisponible. L\'action est enregistree et partira des le retour du reseau.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur met trop de temps a repondre.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In fr, this message translates to:
  /// **'Le service est momentanement indisponible.'**
  String get errorServer;

  /// No description provided for @errorUnauthorized.
  ///
  /// In fr, this message translates to:
  /// **'Votre session a expire. Reconnectez-vous.'**
  String get errorUnauthorized;

  /// No description provided for @errorConflict.
  ///
  /// In fr, this message translates to:
  /// **'Cette operation a deja ete traitee.'**
  String get errorConflict;

  /// No description provided for @errorUpdateRequired.
  ///
  /// In fr, this message translates to:
  /// **'Une mise a jour de l\'application est necessaire.'**
  String get errorUpdateRequired;

  /// No description provided for @errorStorage.
  ///
  /// In fr, this message translates to:
  /// **'L\'appareil ne peut pas enregistrer les donnees.'**
  String get errorStorage;

  /// No description provided for @errorUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Reessayez.'**
  String get errorUnknown;

  /// No description provided for @devPanelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Panneau developpeur'**
  String get devPanelTitle;

  /// No description provided for @devNetworkProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil reseau simule'**
  String get devNetworkProfile;

  /// No description provided for @devProfile4g.
  ///
  /// In fr, this message translates to:
  /// **'4G'**
  String get devProfile4g;

  /// No description provided for @devProfile3g.
  ///
  /// In fr, this message translates to:
  /// **'3G'**
  String get devProfile3g;

  /// No description provided for @devProfile2g.
  ///
  /// In fr, this message translates to:
  /// **'2G / EDGE'**
  String get devProfile2g;

  /// No description provided for @devProfileOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne (mode avion)'**
  String get devProfileOffline;

  /// No description provided for @devFailureRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux d\'echec injecte'**
  String get devFailureRate;

  /// No description provided for @devApiMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode API'**
  String get devApiMode;

  /// No description provided for @devDataUsed.
  ///
  /// In fr, this message translates to:
  /// **'Donnees consommees'**
  String get devDataUsed;

  /// No description provided for @devResetMock.
  ///
  /// In fr, this message translates to:
  /// **'Reinitialiser les donnees simulees'**
  String get devResetMock;

  /// No description provided for @socleProbe.
  ///
  /// In fr, this message translates to:
  /// **'Sonde applicative'**
  String get socleProbe;

  /// No description provided for @socleSyncQueue.
  ///
  /// In fr, this message translates to:
  /// **'File de synchronisation'**
  String get socleSyncQueue;

  /// No description provided for @settingsSwitchProfile.
  ///
  /// In fr, this message translates to:
  /// **'Changer de profil'**
  String get settingsSwitchProfile;

  /// No description provided for @dataUsageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ma consommation'**
  String get dataUsageTitle;

  /// No description provided for @dataUsageThisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois-ci'**
  String get dataUsageThisMonth;

  /// No description provided for @dataBudgetReference.
  ///
  /// In fr, this message translates to:
  /// **'Budget mensuel de reference : 25 Mo'**
  String get dataBudgetReference;

  /// No description provided for @dataCatApi.
  ///
  /// In fr, this message translates to:
  /// **'Echanges applicatifs'**
  String get dataCatApi;

  /// No description provided for @dataCatPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Photos et constats'**
  String get dataCatPhotos;

  /// No description provided for @dataCatMaps.
  ///
  /// In fr, this message translates to:
  /// **'Cartes'**
  String get dataCatMaps;

  /// No description provided for @dataCatTracking.
  ///
  /// In fr, this message translates to:
  /// **'Suivi de position'**
  String get dataCatTracking;

  /// No description provided for @dataCatPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get dataCatPayment;

  /// No description provided for @dataCatOther.
  ///
  /// In fr, this message translates to:
  /// **'Autres'**
  String get dataCatOther;

  /// No description provided for @bytesKb.
  ///
  /// In fr, this message translates to:
  /// **'{value} Ko'**
  String bytesKb(String value);

  /// No description provided for @bytesMb.
  ///
  /// In fr, this message translates to:
  /// **'{value} Mo'**
  String bytesMb(String value);

  /// No description provided for @shellModuleWip.
  ///
  /// In fr, this message translates to:
  /// **'Module en cours de construction'**
  String get shellModuleWip;

  /// No description provided for @shellModuleWipDesc.
  ///
  /// In fr, this message translates to:
  /// **'Cet ecran sera livre au module {module}.'**
  String shellModuleWipDesc(String module);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr', 'mg'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
    case 'mg':
      return AppLocalizationsMg();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
