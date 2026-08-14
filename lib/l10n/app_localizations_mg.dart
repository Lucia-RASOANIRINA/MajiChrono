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
  String get newDeliveryTitle => 'Dia vaovao';

  @override
  String get stepAddresses => 'Adiresy';

  @override
  String get stepPackage => 'Entana';

  @override
  String get stepReview => 'Famintinana';

  @override
  String get addrPickupTitle => 'Adiresy fiaingana';

  @override
  String get addrDropoffTitle => 'Adiresy hidirana';

  @override
  String get addrDistrict => 'Fokontany';

  @override
  String get addrDistrictHint => 'Ambohipo';

  @override
  String get addrLandmark => 'Famantarana';

  @override
  String get addrLandmarkHint =>
      'Aorian\'ny episerian\'i Tsiky, vavahady maitso';

  @override
  String get addrLandmarkHelp => 'Io no ahafahan\'ny mpanatitra mahita anao.';

  @override
  String get addrContactPhone => 'Laharana eo an-toerana';

  @override
  String get addrContactName => 'Anaran\'ny olona';

  @override
  String get addrStreet => 'Lalana sy laharana';

  @override
  String get addrOptional => 'tsy voatery';

  @override
  String get addrRequired => 'Tsy maintsy fenoina';

  @override
  String get addrSaveToBook => 'Tehirizo ao amin\'ny adiresiko';

  @override
  String get addrLabel => 'Anaran\'ny adiresy';

  @override
  String get addrLabelHint => 'Trano, Fivarotana';

  @override
  String get addrBookTitle => 'Ny adiresiko';

  @override
  String get addrBookEmpty => 'Tsy misy adiresy voatahiry';

  @override
  String get addrBookEmptyHelp =>
      'Ny adiresy voatahiry eto dia azo averina ampiasaina avy hatrany.';

  @override
  String get addrPickFromBook => 'Misafidiana amin\'ny adiresiko';

  @override
  String get addrNew => 'Hanoratra adiresy vaovao';

  @override
  String get addrDelete => 'Fafao';

  @override
  String get pkgTitle => 'Ny entana';

  @override
  String get pkgWeight => 'Lanja';

  @override
  String get pkgWeightLt2 => 'Latsaky ny 2 kg';

  @override
  String get pkgWeight2to5 => '2 ka hatramin\'ny 5 kg';

  @override
  String get pkgWeight5to15 => '5 ka hatramin\'ny 15 kg';

  @override
  String get pkgWeightGt15 => 'Mihoatra ny 15 kg';

  @override
  String get pkgValue => 'Sanda ambara';

  @override
  String get pkgDescription => 'Famaritana';

  @override
  String get pkgPhotoLater =>
      'Hangatahina amin\'ny modely 5 ny sarin\'ny entana.';

  @override
  String get kindTitle => 'Karazan-dia';

  @override
  String get kindStandard => 'Entana tsotra';

  @override
  String get kindDocument => 'Taratasy';

  @override
  String get kindFragile => 'Mora vaky';

  @override
  String get kindFood => 'Sakafo';

  @override
  String get kindShopping => 'Fividianana solon-tena';

  @override
  String get kindShoppingSoon => 'Ho avy amin\'ny modely 9';

  @override
  String get slotTitle => 'Rahoviana ?';

  @override
  String get slotImmediate => 'Avy hatrany';

  @override
  String get slotScheduled => 'Voalahatra';

  @override
  String get slotPickDate => 'Safidio ny daty';

  @override
  String slotRange(int start, int end) {
    return '${start}o - ${end}o';
  }

  @override
  String get paymentTitle => 'Fandoavam-bola';

  @override
  String get paymentCash => 'Vola madio rehefa tonga';

  @override
  String get paymentMajipay => 'MajiPay';

  @override
  String get paymentMajipaySoon => 'Ho avy amin\'ny modely 7';

  @override
  String get estimateTitle => 'Tombana vidiny';

  @override
  String get estimateTotal => 'Totaliny';

  @override
  String get estimateProvisional =>
      'Vidiny vonjimaika : mbola tsy raikitra ny tabilaon-tarifa.';

  @override
  String get priceBase => 'Fandraisana';

  @override
  String get priceDistance => 'Halavirana';

  @override
  String get priceWeight => 'Lanja';

  @override
  String get priceKind => 'Fampiakarana karazan-dia';

  @override
  String get priceSchedule => 'Fotoana voalahatra';

  @override
  String get priceInsurance => 'Fiantohana';

  @override
  String get confirmDelivery => 'Hamafiso ny dia';

  @override
  String get deliveryCreated => 'Voaforona ny dia';

  @override
  String get deliveryQueued =>
      'Voatahiry ny dia. Halefa rehefa miverina ny aterineto.';

  @override
  String get deliveriesTitle => 'Ny diako';

  @override
  String get deliveryPendingSync => 'Miandry halefa';

  @override
  String get deliveryCancel => 'Foanana ny dia';

  @override
  String get deliveryCancelConfirm => 'Foanana ity dia ity ? Mety hisy sarany.';

  @override
  String deliveryDistance(String km) {
    return '$km km';
  }

  @override
  String get driverOnline => 'Miasa';

  @override
  String get driverOffline => 'Tsy miasa';

  @override
  String get driverOnlineHelp => 'Mahazo dia ianao raha mbola miasa.';

  @override
  String get driverOfflineHelp => 'Tsy hisy dia hatolotra anao.';

  @override
  String get driverAvailable => 'Dia misy';

  @override
  String get driverNoOffers => 'Tsy misy dia hatreto';

  @override
  String get driverNoOffersHelp =>
      'Mijanona miasa : misy dia tonga mandritra ny andro.';

  @override
  String get driverOfflineEmpty => 'Miasà mba hahazo dia';

  @override
  String driverPickupDistance(String km) {
    return '$km km foana';
  }

  @override
  String get driverEarning => 'Tombony tombanana';

  @override
  String get driverAccept => 'Ekena';

  @override
  String driverAcceptIn(int seconds) {
    return 'Ekena ($seconds s)';
  }

  @override
  String get driverAlreadyTaken => 'Efa nalain\'ny mpanatitra hafa ilay dia';

  @override
  String get driverActiveDelivery => 'Dia an-dalana';

  @override
  String get driverNavigate => 'Sokafy ny lalana';

  @override
  String get driverCall => 'Antsoy ny olona';

  @override
  String get driverStepArrivedPickup => 'Tonga eo am-piaingana aho';

  @override
  String get driverStepPickedUp => 'Voaray ny entana';

  @override
  String get driverStepArrivedDestination => 'Tonga eo amin\'ny toerana aho';

  @override
  String get driverStepDelivered => 'Voatolotra ny entana';

  @override
  String get driverCustodyRequired =>
      'Hangatahina fanamarinana amin\'ity dingana ity (modely 5).';

  @override
  String get driverIncident => 'Hitatitra olana';

  @override
  String get incidentRecipientAbsent => 'Tsy eo ny mpandray';

  @override
  String get incidentAddressNotFound => 'Tsy hita ny adiresy';

  @override
  String get incidentRefused => 'Nolavina ny fandraisana';

  @override
  String get incidentBreakdown => 'Simba ny fiara';

  @override
  String get outcomeWaitThenReturn =>
      'Miandry 10 minitra, avy eo miverina any amin\'ny mpandefa';

  @override
  String get outcomeContactSupport => 'Hiantso anao ny mpandrindra';

  @override
  String get outcomeReturnToSender => 'Averina any amin\'ny mpandefa ny entana';

  @override
  String get outcomeReassign => 'Homena mpanatitra hafa ny dia';

  @override
  String get earningsTitle => 'Ny tomboko';

  @override
  String get earningsToday => 'Androany';

  @override
  String get earningsWeek => 'Ity herinandro ity';

  @override
  String get earningsMonth => 'Ity volana ity';

  @override
  String earningsCount(int count) {
    return 'dia $count';
  }

  @override
  String get earningsEmpty => 'Tsy misy tombony voarakitra';

  @override
  String get earningsCommission => 'Vola madio, efa nesorina ny sara.';

  @override
  String get kycTitle => 'Ny antontan-taratasiko';

  @override
  String get kycStatusDraft => 'Tokony fenoina ny antontan-taratasy';

  @override
  String get kycStatusSubmitted => 'Nalefa ny antontan-taratasy';

  @override
  String get kycStatusUnderReview => 'Eo am-panamarinana';

  @override
  String get kycStatusApproved => 'Nekena ny antontan-taratasy';

  @override
  String get kycStatusRejected => 'Nolavina ny antontan-taratasy';

  @override
  String get kycBlocking =>
      'Tsy afaka maka dia ianao raha tsy nekena ny antontan-taratasy.';

  @override
  String get kycDocCinFront => 'Kara-panondro ambony';

  @override
  String get kycDocCinBack => 'Kara-panondro ambadika';

  @override
  String get kycDocLicence => 'Fahazoan-dalana mitondra';

  @override
  String get kycDocSelfie => 'Sarin\'ny tarehy';

  @override
  String get kycDocRegistration => 'Karatra volamena';

  @override
  String get kycDocVehicle => 'Sarin\'ny fiara';

  @override
  String get kycDocPlate => 'Sarin\'ny laharana';

  @override
  String get kycCaptureLater => 'Ho avy amin\'ny modely 5 ny fakana sary.';

  @override
  String get kycSubmit => 'Alefaso ny antontan-taratasy';

  @override
  String get pickLocationTitle => 'Apetraho ny teboka';

  @override
  String get pickLocationAction => 'Apetraho eo amin\'ny sarintany';

  @override
  String get pickLocationSet => 'Voapetraka ny teboka';

  @override
  String get pickLocationHelp =>
      'Manakaiky ny mpanatitra ny teboka GPS ; ny famantarana no manatanteraka ny sisa.';

  @override
  String get trackingTitle => 'Fanarahana ny dia';

  @override
  String get trackingTimeline => 'Dingana';

  @override
  String get trackingDriver => 'Ny mpanatitra anao';

  @override
  String trackingEta(int minutes) {
    return 'Tombanana ho tonga afaka $minutes min';
  }

  @override
  String get trackingShare => 'Zaraina ny fanarahana';

  @override
  String trackingShareMessage(String url) {
    return 'Araho ny entanao MajiChrono : $url';
  }

  @override
  String get trackingCall => 'Antsoy';

  @override
  String get trackingCallMasked => 'Miafina ny laharana amin\'ny roa tonta';

  @override
  String trackingRating(String rating) {
    return '$rating / 5';
  }

  @override
  String get trackingPublicTitle => 'Fanarahana ny entana';

  @override
  String get trackingPublicExpired =>
      'Tsy mety intsony ity rohy fanarahana ity.';

  @override
  String get trackingNoDriverYet => 'Mbola tsy nisy mpanatitra nanaiky ny dia.';

  @override
  String get mapUnavailable =>
      'Tsy misy sarintany tsy misy aterineto. Mbola hita ny teboka.';

  @override
  String get linkCopied => 'Voadika ny rohy';

  @override
  String get statusPending => 'Miandry mpanatitra';

  @override
  String get statusAccepted => 'Mpanatitra an-dalana';

  @override
  String get statusAtPickup => 'Mpanatitra tonga teo am-piaingana';

  @override
  String get statusPickedUp => 'Voaray ny entana';

  @override
  String get statusInTransit => 'An-dalana';

  @override
  String get statusAtDestination => 'Tonga ny mpanatitra';

  @override
  String get statusDelivered => 'Voatolotra';

  @override
  String get statusDeliveredWithReserves => 'Voatolotra misy fanamarihana';

  @override
  String get statusRefused => 'Nolavina';

  @override
  String get statusReturning => 'Miverina any amin\'ny mpandefa';

  @override
  String get statusPaid => 'Voaloa';

  @override
  String get statusDisputed => 'Fifandirana';

  @override
  String get statusCancelled => 'Nofoanana';

  @override
  String get statusClosed => 'Vita';

  @override
  String get statusDraft => 'Volavola';

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
