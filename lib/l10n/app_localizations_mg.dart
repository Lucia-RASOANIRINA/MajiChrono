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
  String get stepOptions => 'Safidy';

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
  String get custodyPickupTitle => 'Fanamarinana fandraisana';

  @override
  String get custodyHandoverTitle => 'Fanamarinana fanolorana';

  @override
  String get custodyStepPhotos => 'Sary';

  @override
  String get custodyStepCondition => 'Toetra';

  @override
  String get custodyStepSeal => 'Tombo-kase';

  @override
  String get custodyStepSignatures => 'Sonia';

  @override
  String get custodyEngagement =>
      'Manamarina aho fa manolotra na mandray ity entana ity amin\'ny toetra voamarika etsy ambony.';

  @override
  String get custodySignHere => 'Manaova sonia eto';

  @override
  String get custodyClearSignature => 'Fafao';

  @override
  String get custodySignerSender => 'Mpandefa';

  @override
  String get custodySignerDriver => 'Mpanatitra';

  @override
  String get custodySignerRecipient => 'Mpandray';

  @override
  String get custodyPhotoTop => 'Ambony';

  @override
  String get custodyPhotoBottom => 'Ambany';

  @override
  String get custodyPhotoSide1 => 'Sisiny 1';

  @override
  String get custodyPhotoSide2 => 'Sisiny 2';

  @override
  String get custodyPhotoGuide =>
      'Ampidiro ao anaty tarehimarika ny entana, avy eo alaivo.';

  @override
  String get custodyPhotoInAppOnly =>
      'Sary alaina ao anatin\'ny fampiharana ihany.';

  @override
  String get custodyPhotoRetake => 'Averina alaina';

  @override
  String get custodyConditionTitle => 'Toetran\'ny entana';

  @override
  String get custodyConditionHelp =>
      'Mariho izay hitanao. Ny tsy fahatomombanana rehetra dia mila sary sy fanamarihana.';

  @override
  String get conditionPackagingIntact => 'Fonosana tsy simba';

  @override
  String get conditionImpactMark => 'Misy dian-kadonana';

  @override
  String get conditionMoistureMark => 'Misy dian-drano';

  @override
  String get conditionAlreadyOpened => 'Efa nosokafana ny fonosana';

  @override
  String get conditionOriginalTape => 'Misy ny sokitra tany am-boalohany';

  @override
  String get conditionCrushedCorners => 'Zorony potika';

  @override
  String get custodyAnomalyNote => 'Lazao ny olana';

  @override
  String get custodySealNumber => 'Laharan\'ny tombo-kase';

  @override
  String get custodySealHint => 'SC-4821';

  @override
  String get custodySealScanLater =>
      'Ho avy amin\'ny modely 10 ny fanaraha-maso kaody.';

  @override
  String get custodySealCheck => 'Toetran\'ny tombo-kase';

  @override
  String get sealIntact => 'Tsy simba';

  @override
  String get sealBroken => 'Tapaka';

  @override
  String get sealAbsent => 'Tsy misy';

  @override
  String get custodySealIncident => 'Hisokatra ho azy ny fitarainana.';

  @override
  String get custodyWeightConfirm => 'Lanja voamarina';

  @override
  String get custodyOutcomeTitle => 'Vokatry ny fanolorana';

  @override
  String get custodyOutcomeHelp =>
      'Lazao izay tena nitranga. Manana adidy manokana ny safidy tsirairay.';

  @override
  String get outcomeDelivered => 'Natolotra ny mpandray';

  @override
  String get outcomeWithReserves => 'Natolotra misy fanamarihana';

  @override
  String get outcomeRefused => 'Nolavin\'ny mpandray';

  @override
  String get outcomeThirdParty => 'Natolotra olon-kafa';

  @override
  String get outcomeNoSignature => 'Natolotra tsy nisy sonia';

  @override
  String get custodyOutcomeReason => 'Antony an-tsoratra';

  @override
  String get custodyOutcomeReasonHelp =>
      'Hovakiana araka izao ity antony ity raha misy fifandirana.';

  @override
  String get custodyReservesNotice => 'Hisokatra ho azy ny fitarainana.';

  @override
  String get custodyRefusedNotice =>
      'Miverina any amin\'ny mpandefa ny entana.';

  @override
  String get custodyNoSignatureNotice =>
      'Hampahafantarina ny mpandrindra. Tsy maintsy misy sarin\'ny entana natolotra.';

  @override
  String get custodyThirdPartyName => 'Anaran\'ny olon-kafa';

  @override
  String get custodyThirdPartyRelation => 'Fifandraisana amin\'ny mpandray';

  @override
  String get custodyThirdPartyRelationHint =>
      'Mpiandry trano, mpiara-monina, mpiara-miasa...';

  @override
  String get custodyExtraPhotoSeal => 'Sarin\'ny tombo-kase';

  @override
  String get custodyExtraPhotoId => 'Sarin\'ny kara-panondro';

  @override
  String get custodyExtraPhotoHandover => 'Sarin\'ny entana natolotra';

  @override
  String get custodyExtraPhotoMissing => 'Mila sary fanampiny';

  @override
  String get custodyExportPdf => 'Havoaka PDF';

  @override
  String get custodyExportPdfDone => 'Voavoaka ny fanamarinana';

  @override
  String get custodyExportPdfFailed => 'Tsy vita ny famoahana';

  @override
  String get custodyPdfTitle => 'Fanamarinana ifanatrehana';

  @override
  String get custodyPdfHash => 'Dian-tanana SHA-256';

  @override
  String get custodyPdfPreviousHash => 'Dian-tanana teo aloha';

  @override
  String get custodyPdfSealedAt => 'Voaisy tombo-kase ny';

  @override
  String get custodyPdfServerTime => 'Voaray tao amin\'ny serivera ny';

  @override
  String get custodyPdfPending => 'Tsy mbola nalefa';

  @override
  String get custodyPdfNotice =>
      'Antontan-taratasy noforonin\'i MajiChrono. Manapaka ny dian-tanana ny fanovana rehetra.';

  @override
  String get custodyOtpTitle => 'Kaodin\'ny mpandray';

  @override
  String get custodyOtpHelp =>
      'Nisy kaody nalefa tamin\'ny mpandray tamin\'ny SMS.';

  @override
  String get custodyIncomplete => 'Tsy feno ny fanamarinana';

  @override
  String get custodyValidate => 'Hamafiso ny fanamarinana';

  @override
  String get custodySealed => 'Voaisy tombo-kase ny fanamarinana';

  @override
  String get custodySealedHelp =>
      'Tsy azo ovaina intsony. Ny fanazavana rehetra dia ho fanampiny miavaka.';

  @override
  String get custodyComparatorTitle => 'Mpampitaha';

  @override
  String get custodyBefore => 'Fandraisana';

  @override
  String get custodyAfter => 'Fanolorana';

  @override
  String get custodyNoDiff => 'Tsy misy fiovana hita';

  @override
  String get custodyAppeared => 'Niseho tamin\'ny fanolorana';

  @override
  String get custodyDisappeared => 'Nanjavona teny an-dalana';

  @override
  String get custodyChainIntact => 'Tsy tapaka ny rojo porofo';

  @override
  String get custodyChainBroken => 'Tapaka ny rojo porofo';

  @override
  String get custodyChainHelp =>
      'Ny dian-tanan\'ny fanolorana dia mirakitra izay an\'ny fandraisana.';

  @override
  String get emergencyButton => 'Vonjy maika';

  @override
  String get emergencyTitle => 'Fanairana maika';

  @override
  String get emergencyHelp =>
      'Fantatry ny mpandrindra avy hatrany, miaraka amin\'ny toerana farany fantatra.';

  @override
  String get emergencySend => 'Alefa ny fanairana';

  @override
  String get emergencyKindOptional => 'Fanazavana (tsy voatery)';

  @override
  String get emergencyAccident => 'Loza';

  @override
  String get emergencyAggression => 'Fanafihana';

  @override
  String get emergencyBreakdown => 'Simba ny fiara';

  @override
  String get emergencyMedical => 'Marary';

  @override
  String get emergencyUnspecified => 'Tsy voafaritra';

  @override
  String get emergencySent => 'Voalefa ny fanairana';

  @override
  String get emergencyCallbackSoon =>
      'Hantsoina avy hatrany ianao. Mitadiava toerana azo antoka.';

  @override
  String get emergencyAcknowledgePending =>
      'Nampandrenesina ny mpandrindra. Aza lavitra ny findaina.';

  @override
  String get economyTitle => 'Fomba fitsitsiana';

  @override
  String get economyHelp =>
      'Ahemotra ny sary mandra-pahitana aterineto tsy mandoa, ary tsy misintona sarintany vaovao.';

  @override
  String get economyProofNever =>
      'Mandeha manontolo foana ny fanamarinana, na dia amin\'ny fomba fitsitsiana aza.';

  @override
  String get economyDeferPhotos => 'Hahemotra ny sary tsy an\'ny fanamarinana';

  @override
  String get economyBlockTiles => 'Tsy hisintona sarintany vaovao';

  @override
  String get economyReduceCadence => 'Halavaina ny fandefasana toerana';

  @override
  String get shoppingTitle => 'Fividianana ho an\'ny hafa';

  @override
  String get shoppingHelp =>
      'Ny mpanatitra no mandoa aloha ary manolotra ny tapakila.';

  @override
  String get shoppingAddItem => 'Hanampy entana';

  @override
  String get shoppingItemLabel => 'Entana';

  @override
  String get shoppingItemQuantity => 'Isa';

  @override
  String get shoppingItemPrice => 'Vidiny tombanana';

  @override
  String get shoppingSubstitutable => 'Azo soloina raha tsy misy';

  @override
  String get shoppingStoreHint => 'Fivarotana atolotra (tsy voatery)';

  @override
  String get shoppingCap => 'Fetran\'ny fandaniana';

  @override
  String get shoppingCapHelp =>
      'Tsy mividy mihoatra ny mpanatitra. Izay no arony : ny volany manokana no aloany aloha.';

  @override
  String get shoppingCapTooLow => 'Ambany noho ny tombanao ny fetra';

  @override
  String shoppingCapOutOfRange(String min, String max) {
    return 'Fetra eo anelanelan\'ny $min sy $max';
  }

  @override
  String get shoppingEstimated => 'Tombana ny entana';

  @override
  String get shoppingEmpty => 'Tsy misy entana';

  @override
  String get shoppingActualTotal => 'Vola naloa (tapakila)';

  @override
  String get shoppingReceipt => 'Tapakilan\'ny fivarotana';

  @override
  String get shoppingReceiptMissing => 'Tsy maintsy misy sary hahazoana onitra';

  @override
  String get shoppingReceiptTaken => 'Voasary ny tapakila';

  @override
  String shoppingOverCap(String amount) {
    return 'Mihoatra ny fetra. Onitra : $amount';
  }

  @override
  String get payerTitle => 'Iza no mandoa';

  @override
  String get payerSender => 'Izaho (efa voaloa)';

  @override
  String get payerRecipient => 'Ny mpandray (aloa any)';

  @override
  String get payerRecipientNotice =>
      'Ampandreneso ny mpandray ny vola : raha tsy izany dia handa ny entana izy.';

  @override
  String get relayTitle => 'Toerana fandraisana';

  @override
  String get relayHelp =>
      'Miandry ao am-pivarotana ny entana. Mahasoa raha tsy ao an-trano ny mpandray.';

  @override
  String get relayNone => 'Fanaterana any amin\'ny adiresy';

  @override
  String get relayHours => 'Ora fisokafana';

  @override
  String relayStorage(int days) {
    return 'Tehirizina $days andro';
  }

  @override
  String get relayTooHeavy =>
      'Mavesatra loatra ho an\'ity toerana ity ny entana';

  @override
  String get groupTitle => 'Dia mitambatra';

  @override
  String get groupHelp =>
      'Dia roa ka hatramin\'ny telo amin\'ny lalana iray. Fandraisana aloha, fanolorana avy eo.';

  @override
  String groupSaved(String km) {
    return '$km km voatsitsy';
  }

  @override
  String get groupAdd => 'Hampiaraka amin\'ity';

  @override
  String get groupNotViable => 'Manalavitra loatra ny lalanao ity dia ity';

  @override
  String get groupStopPickup => 'Fandraisana';

  @override
  String get groupStopDropoff => 'Fanolorana';

  @override
  String get adminReasonLabel => 'Antony amin\'ny fanapahan-kevitra';

  @override
  String adminReasonMissing(int count) {
    return 'Mbola $count litera. Ny antony dia hanazavana, fa tsy hamenoana toerana.';
  }

  @override
  String get adminReasonOk =>
      'Hovakiana araka izao ity antony ity raha misy fanoherana.';

  @override
  String get adminReasonRecorded =>
      'Voarakitra miaraka amin\'ny antony sy ny mpanao azy ny fanapahan-kevitra.';

  @override
  String get adminDashboardTitle => 'Tabilaon-tsafidy';

  @override
  String get adminActiveDeliveries => 'Dia an-dalana';

  @override
  String get adminOnlineDrivers => 'Mpanatitra miasa';

  @override
  String get adminOpenIncidents => 'Olana misokatra';

  @override
  String get adminOpenDisputes => 'Fifandirana misokatra';

  @override
  String get adminPendingKyc => 'Antontan-taratasy hamarinina';

  @override
  String get adminRevenueToday => 'Vola voaray androany';

  @override
  String get adminByStatus => 'Fizarazaran\'ny dia';

  @override
  String get adminFleetTitle => 'Ekipa';

  @override
  String get adminFleetAll => 'Rehetra';

  @override
  String get adminFleetAvailable => 'Malalaka';

  @override
  String get adminFleetBusy => 'An-dalana';

  @override
  String get adminFleetOffline => 'Tsy miasa';

  @override
  String get adminFleetSuspended => 'Nampiatoana';

  @override
  String get adminFleetEmpty => 'Tsy misy mpanatitra amin\'ity sivana ity';

  @override
  String get adminFleetStale => 'Toerana efa ela';

  @override
  String get adminFleetMapUnavailable =>
      'Tsy misy sarintany raha tsy misy aterineto';

  @override
  String get adminSuspend => 'Hampiato ny kaonty';

  @override
  String get adminReinstate => 'Hamerina ny kaonty';

  @override
  String get adminSuspendHelp =>
      'Tsy hahazo dia intsony ny mpanatitra mandritra ny fampiatoana.';

  @override
  String get adminReinstateHelp => 'Afaka hiasa indray ny mpanatitra.';

  @override
  String adminSuspendedSince(String reason) {
    return 'Nampiatoana : $reason';
  }

  @override
  String get adminKycTitle => 'Antontan-taratasy hamarinina';

  @override
  String get adminKycEmpty => 'Tsy misy antontan-taratasy miandry';

  @override
  String get adminKycIncomplete => 'Tsy feno ny antontan-taratasy';

  @override
  String get adminKycComplete => 'Feno ny antontan-taratasy';

  @override
  String adminKycMissingDocs(int count) {
    return 'Tsy ampy taratasy $count';
  }

  @override
  String get adminKycApprove => 'Ekena ny antontan-taratasy';

  @override
  String get adminKycReject => 'Lavina ny antontan-taratasy';

  @override
  String get adminKycApproveHelp =>
      'Hiditra ao amin\'ny ekipa ny mpanatitra, tsy miasa mandra-piasany.';

  @override
  String get adminKycRejectHelp =>
      'Halefa amin\'ny mpanatitra ny antony mba hahafahany manitsy.';

  @override
  String adminKycSubmittedAt(String age) {
    return 'Napetraka $age';
  }

  @override
  String get adminDeliveriesTitle => 'Dia';

  @override
  String get adminDeliveriesEmpty => 'Tsy misy dia mifanaraka';

  @override
  String get adminFilterStatus => 'Toetra';

  @override
  String get adminFilterSearch => 'Fokontany, mari-pamantarana, mpanatitra...';

  @override
  String get adminFilterClear => 'Hamafa ny sivana';

  @override
  String get adminReassign => 'Hanova mpanatitra';

  @override
  String get adminReassignTitle => 'Hanova mpanatitra ho an\'ny dia';

  @override
  String get adminReassignHelp =>
      'Ny mpanatitra malalaka ihany no afaka mandray dia.';

  @override
  String get adminReassignPick => 'Misafidy mpanatitra';

  @override
  String get adminReassignNone => 'Tsy misy mpanatitra malalaka';

  @override
  String get adminDisputesTitle => 'Fifandirana';

  @override
  String get adminDisputesEmpty => 'Tsy misy fifandirana misokatra';

  @override
  String get adminDisputeOpen => 'Misokatra';

  @override
  String get adminDisputeInvestigating => 'Fanadihadiana';

  @override
  String get adminDisputeResolved => 'Nekena ho an\'ny mpanjifa';

  @override
  String get adminDisputeRejected => 'Nolavina ny fifandirana';

  @override
  String get adminDisputeReason => 'Antony nanokafana';

  @override
  String get adminDisputeReply => 'Hamaly';

  @override
  String get adminDisputeMessage => 'Ny hafatrao';

  @override
  String get adminDisputeResolve => 'Hanome rariny ny mpanjifa';

  @override
  String get adminDisputeDismiss => 'Hanilika ny fifandirana';

  @override
  String get adminDisputeResolveHelp => 'Ho voavaha ho an\'ny mpanjifa ny dia.';

  @override
  String get adminDisputeDismissHelp =>
      'Hikatona tsy misy tohiny ny fifandirana.';

  @override
  String get adminDisputeClosed =>
      'Mikatona ny fifandirana. Tsy azo valiana intsony.';

  @override
  String adminDisputeDecidedBy(String author) {
    return 'Nofaritan\'i $author';
  }

  @override
  String get adminOpenComparator => 'Hanokatra ny mpampitaha';

  @override
  String get adminActionDone => 'Voarakitra ny fanapahan-kevitra';

  @override
  String get payTitle => 'Fandoavana';

  @override
  String get payBalance => 'Volan\'ny MajiPay';

  @override
  String get payBalanceUnavailable => 'Tsy hita ny vola';

  @override
  String get payAmount => 'Vola aloa';

  @override
  String get payCollect => 'Handray vola';

  @override
  String get payCollectHelp =>
      'Asehoy amin\'ny mpanjifa ity kaody ity. Izy no hanamafy ao amin\'ny findainy.';

  @override
  String get payOffer => 'Handoa';

  @override
  String get payOfferHelp =>
      'Ny mpanatitra no manaraka ity kaody ity. Efa nohamafisinao ny vola.';

  @override
  String get payScan => 'Hanaraka kaody';

  @override
  String get payScanHelp =>
      'Ataovy ao anaty efajoro ny kaody hita amin\'ny findaina hafa.';

  @override
  String get payScanInvalid => 'Tsy kaody fandoavana MajiChrono ity';

  @override
  String get payScanPermission =>
      'Omeo alalana ny fakan-tsary mba hanaraka kaody';

  @override
  String get payShowQr => 'Asehoy ny kaodiko';

  @override
  String payQrExpires(int minutes) {
    return 'Mandaitra $minutes min ny kaody';
  }

  @override
  String get payQrExpired => 'Lany daty ny kaody';

  @override
  String get payQrRenew => 'Hamorona kaody vaovao';

  @override
  String get payWaiting => 'Miandry ny fanarahana...';

  @override
  String get payConfirmTitle => 'Hamafiso ny fandoavana';

  @override
  String get payConfirmTo => 'Mpandray';

  @override
  String get payConfirmPin => 'Ampidiro ny kaodinao hanamafisana';

  @override
  String payConfirmAction(String amount) {
    return 'Hamafiso $amount';
  }

  @override
  String get payConfirmNever =>
      'Tsy ampy ny fanarahana kaody : tsy misy afaka maka vola aminao raha tsy misy ity kaody ity.';

  @override
  String get payWrongPin => 'Diso ny kaody';

  @override
  String get payCaptured => 'Vita ny fandoavana';

  @override
  String get payReceived => 'Voaray ny vola';

  @override
  String get payFailedInsufficient => 'Tsy ampy ny volan\'ny MajiPay';

  @override
  String get payFailedExpired => 'Lany daty ny kaody';

  @override
  String get payFailedDeclined => 'Nolavina ny fandoavana';

  @override
  String get payFailedUnavailable => 'Tsy azo ampiasaina ny MajiPay';

  @override
  String get payCashFallback => 'Handoa vola madinika';

  @override
  String get payCashHelp =>
      'Tsy voasakan\'ny olan\'ny fandoavana mihitsy ny dia.';

  @override
  String get payCashDone => 'Voaloa tamin\'ny vola madinika';

  @override
  String get payReceiptTitle => 'Tapakila';

  @override
  String get payReceiptRef => 'Laharana';

  @override
  String get payReceiptShare => 'Hizara ny tapakila';

  @override
  String get payMethodMajipay => 'MajiPay';

  @override
  String get payMethodCash => 'Vola madinika';

  @override
  String get syncPendingTitle => 'Zavatra miandry';

  @override
  String get syncPendingEmpty => 'Voalefa daholo';

  @override
  String get syncPendingEmptyHelp =>
      'Tsy misy miandry halefa any amin\'ny serivera.';

  @override
  String get syncPendingHelp =>
      'Handeha ireto raha vao miverina ny aterineto. Ny fanamarinana no mialoha.';

  @override
  String get syncRetry => 'Averina andramana';

  @override
  String get syncRetryAll => 'Averina daholo';

  @override
  String get syncItemCustody => 'Fanamarinana';

  @override
  String get syncItemTransition => 'Dia';

  @override
  String get syncItemPosition => 'Toerana';

  @override
  String get syncItemRating => 'Naoty';

  @override
  String get syncCauseNone => 'Miandry aterineto';

  @override
  String get syncCauseNetwork => 'Tsy misy aterineto';

  @override
  String get syncCauseServer => 'Tsy namaly ny serivera';

  @override
  String get syncCauseConflict => 'Hafa ny toetra ao amin\'ny serivera';

  @override
  String get syncCauseRejected => 'Nolavin\'ny serivera';

  @override
  String get syncCauseExhausted => 'Lany ny fanandramana';

  @override
  String get syncNeverAbandon => 'Porofo : tsy afoy mihitsy';

  @override
  String syncAttempts(int count) {
    return 'Fanandramana $count';
  }

  @override
  String get syncAgeNow => 'vao izao';

  @override
  String syncAgeMinutes(int count) {
    return '$count min lasa izay';
  }

  @override
  String syncAgeHours(int count) {
    return '$count ora lasa izay';
  }

  @override
  String syncAgeDays(int count) {
    return '$count andro lasa izay';
  }

  @override
  String get syncConflictNotice =>
      'Ny serivera no manapaka. Nohavaozina ny angonao.';

  @override
  String get syncRetryQueued => 'Nangatahina ny famerenana';

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
