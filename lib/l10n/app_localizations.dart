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
