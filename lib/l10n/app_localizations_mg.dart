// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malagasy (`mg`).
class AppLocalizationsMg extends AppLocalizations {
  AppLocalizationsMg([String locale = 'mg']) : super(locale);

  @override
  String get appName => 'MajiChrono';

  @override
  String get commonContinue => 'Tohizana';

  @override
  String get commonCancel => 'Ajanona';

  @override
  String get commonConfirm => 'Hamafiso';

  @override
  String get commonRetry => 'Andramo indray';

  @override
  String get commonClose => 'Akatona';

  @override
  String get commonBack => 'Miverina';

  @override
  String get commonSave => 'Tehirizo';

  @override
  String get commonSearch => 'Hikaroka';

  @override
  String get commonYes => 'Eny';

  @override
  String get commonNo => 'Tsia';

  @override
  String get commonLoading => 'Miandrasa kely...';

  @override
  String get langFrench => 'Frantsay';

  @override
  String get langMalagasy => 'Malagasy';

  @override
  String get settingsTitle => 'Fandrindrana';

  @override
  String get settingsLanguage => 'Fiteny';

  @override
  String get settingsTheme => 'Endrika';

  @override
  String get themeSystem => 'Rafitra';

  @override
  String get themeLight => 'Mazava';

  @override
  String get themeDark => 'Maizina';

  @override
  String get networkOnline => 'Misy aterineto';

  @override
  String networkOfflinePending(int count) {
    return 'Tsy misy aterineto — $count andrasana';
  }

  @override
  String get networkOfflineNoPending => 'Tsy misy aterineto';

  @override
  String get networkSyncing => 'Manao fampifanarahana...';

  @override
  String get authPhoneTitle => 'Ny laharanao';

  @override
  String get authPhoneSubtitle =>
      'Handefasanay kaody amin\'ny SMS io laharana io mba hamarinana azy.';

  @override
  String get authPhoneLabel => 'Laharana finday';

  @override
  String get authPhoneHint => '034 12 345 67';

  @override
  String get authPhoneInvalid => 'Laharana malagasy tsy mety';

  @override
  String authPhoneOperator(String operator) {
    return 'Mpandraharaha fantatra : $operator';
  }

  @override
  String get authOtpTitle => 'Kaody fanamarinana';

  @override
  String authOtpSentTo(String phone) {
    return 'Kaody nalefa tany amin\'ny $phone';
  }

  @override
  String authOtpExpiresIn(String time) {
    return 'Lany afaka $time';
  }

  @override
  String get authOtpExpired => 'Lany ny kaody. Mangataha vaovao.';

  @override
  String get authOtpResend => 'Alefaso indray ny kaody';

  @override
  String authOtpInvalid(int count) {
    return 'Kaody diso. Mbola misy $count andrana.';
  }

  @override
  String get authOtpLocked => 'Be loatra ny andrana. Mangataha kaody vaovao.';

  @override
  String authOtpSimulated(String code) {
    return 'Kaody an-tsary : $code';
  }

  @override
  String get authProfileTitle => 'Ny andraikitrao';

  @override
  String get authProfileSubtitle =>
      'Tsy azo ovaina intsony ity safidy ity : izy no mamaritra ny fampiharana ampiasainao.';

  @override
  String get authProfileName => 'Ny anaranao';

  @override
  String get authProfileNameHint => 'Anarana hitan\'ny hafa';

  @override
  String get authProfileNameRequired => 'Ampidiro ny anaranao';

  @override
  String get authProfileAdminNote =>
      'Ny andraikitra mpandrindra dia omen\'ny MajiChrono, tsy safidiana eto.';

  @override
  String get authPinTitle => 'Mamorona kaody misy isa efatra';

  @override
  String get authPinSubtitle =>
      'Miaro ny kaontinao rehefa sokafana indray ny fampiharana.';

  @override
  String get authPinConfirmTitle => 'Hamafiso ny kaodinao';

  @override
  String get authPinMismatch => 'Tsy mitovy ny kaody roa';

  @override
  String get authPinLater => 'Aoriana';

  @override
  String get authPinSaved => 'Voatahiry ny kaody';

  @override
  String get authLockTitle => 'Voahidy ny fampiharana';

  @override
  String get authLockSubtitle => 'Ampidiro ny kaodinao hanohizana';

  @override
  String get authLockBiometrics => 'Ampiasao ny biometria';

  @override
  String get authBiometricsReason => 'Sokafy ny MajiChrono';

  @override
  String get authLockWrongPin => 'Kaody diso';

  @override
  String get authSignOut => 'Hivoaka';

  @override
  String get authSignOutConfirm =>
      'Ny fivoahana dia hamafa ny angona ao amin\'ity finday ity. Hanohy ?';

  @override
  String authWelcome(String name) {
    return 'Salama $name';
  }

  @override
  String get roleChooseTitle => 'Izaho dia';

  @override
  String get roleClient => 'Mpandefa';

  @override
  String get roleClientDesc => 'Mandefa entana na mangataka dia aho';

  @override
  String get roleDriver => 'Mpanatitra';

  @override
  String get roleDriverDesc => 'Manatanteraka dia aho';

  @override
  String get roleAdmin => 'Mpandrindra';

  @override
  String get roleAdminDesc => 'Manara-maso ny mpanatitra sy ny fifandirana aho';

  @override
  String get navHome => 'Fandraisana';

  @override
  String get navDeliveries => 'Dia';

  @override
  String get navTracking => 'Fanarahana';

  @override
  String get navEarnings => 'Tombony';

  @override
  String get navProfile => 'Momba';

  @override
  String get navFleet => 'Mpanatitra';

  @override
  String get navDisputes => 'Fifandirana';

  @override
  String get navKyc => 'KYC';

  @override
  String get navDashboard => 'Tabilao';

  @override
  String get clientHomeTitle => 'Fandraisana mpandefa';

  @override
  String get clientNewDelivery => 'Dia vaovao';

  @override
  String get driverHomeTitle => 'Fandraisana mpanatitra';

  @override
  String get adminHomeTitle => 'Fanaraha-maso';

  @override
  String get emptyTitle => 'Tsy misy asehoana';

  @override
  String get emptyDeliveries => 'Tsy misy dia hatreto';

  @override
  String get emptyDeliveriesAction => 'Hamorona dia';

  @override
  String get errorTitle => 'Misy zavatra tokony hatao';

  @override
  String get errorNetwork =>
      'Tsy misy aterineto. Voatahiry ny asa ary halefa rehefa miverina ny aterineto.';

  @override
  String get errorTimeout => 'Ela loatra ny valin\'ny serivisy.';

  @override
  String get errorServer => 'Tsy azo ampiasaina vetivety ny serivisy.';

  @override
  String get errorUnauthorized => 'Lany ny fotoam-pidiranao. Midira indray.';

  @override
  String get errorConflict => 'Efa voakarakara io hetsika io.';

  @override
  String get errorUpdateRequired => 'Ilaina ny fanavaozana ny fampiharana.';

  @override
  String get errorStorage => 'Tsy afaka mitahiry angona ny finday.';

  @override
  String get errorUnknown => 'Nisy olana. Andramo indray.';

  @override
  String get devPanelTitle => 'Efitra mpamorona';

  @override
  String get devNetworkProfile => 'Karazana aterineto';

  @override
  String get devProfile4g => '4G';

  @override
  String get devProfile3g => '3G';

  @override
  String get devProfile2g => '2G / EDGE';

  @override
  String get devProfileOffline => 'Tsy misy aterineto';

  @override
  String get devFailureRate => 'Tahan\'ny tsy fahombiazana';

  @override
  String get devApiMode => 'Fomba API';

  @override
  String get devDataUsed => 'Angona lany';

  @override
  String get devResetMock => 'Averina ny angona an-tsary';

  @override
  String get socleProbe => 'Fitiliana aterineto';

  @override
  String get socleSyncQueue => 'Filaharana fampifanarahana';

  @override
  String get settingsSwitchProfile => 'Manova andraikitra';

  @override
  String get dataUsageTitle => 'Ny lanjan\'angona';

  @override
  String get dataUsageThisMonth => 'Ity volana ity';

  @override
  String get dataBudgetReference => 'Teti-bola isam-bolana : 25 Mo';

  @override
  String get dataCatApi => 'Fifanakalozana';

  @override
  String get dataCatPhotos => 'Sary sy fanamarinana';

  @override
  String get dataCatMaps => 'Sarintany';

  @override
  String get dataCatTracking => 'Fanarahana toerana';

  @override
  String get dataCatPayment => 'Fandoavam-bola';

  @override
  String get dataCatOther => 'Hafa';

  @override
  String bytesKb(String value) {
    return '$value Ko';
  }

  @override
  String bytesMb(String value) {
    return '$value Mo';
  }

  @override
  String get shellModuleWip => 'Mbola amboarina ity modely ity';

  @override
  String shellModuleWipDesc(String module) {
    return 'Halefa amin\'ny modely $module ity efijery ity.';
  }
}
