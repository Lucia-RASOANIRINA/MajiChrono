import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:majichrono/features/delivery/domain/entities/delivery.dart';
import 'package:majichrono/features/delivery/domain/value_objects/geo_point.dart';

/// Moment du transfert de responsabilite (EXI-CC01).
enum CustodyStage {
  pickup('pickup'),
  handover('handover');

  const CustodyStage(this.wireName);

  final String wireName;

  static CustodyStage fromWire(String? value) =>
      value == 'handover' ? CustodyStage.handover : CustodyStage.pickup;
}

/// Angle de prise de vue impose par le gabarit (EXI-CC10).
///
/// Quatre angles au minimum, **les memes a la prise en charge et a la remise**
/// (EXI-CC20), sans quoi la comparaison du §7.3.4 n'aurait aucun sens : deux
/// photos prises sous des angles differents ne se comparent pas, elles se
/// discutent.
enum PhotoAngle {
  top('top'),
  bottom('bottom'),
  side1('side1'),
  side2('side2');

  const PhotoAngle(this.wireName);

  final String wireName;

  static PhotoAngle? fromWire(String? value) {
    for (final angle in PhotoAngle.values) {
      if (angle.wireName == value) return angle;
    }
    return null;
  }
}

/// Photo de constat, horodatee et geolocalisee (EXI-CC41).
class CustodyPhoto {
  const CustodyPhoto({
    required this.angle,
    required this.localPath,
    required this.takenAt,
    required this.sizeBytes,
    required this.sha256,
    this.point,
    this.anomalyNote,
  });

  final PhotoAngle angle;

  /// Chemin local. La photo n'est **jamais** ecrite dans la galerie publique
  /// (EXI-SEC12) : elle vit dans le stockage prive de l'application, chiffre
  /// tant qu'elle n'est pas accusee par le serveur (EXI-CC46).
  final String localPath;

  final DateTime takenAt;
  final int sizeBytes;

  /// Empreinte de l'image seule, qui entre dans l'empreinte du constat.
  final String sha256;

  final GeoPoint? point;

  /// Renseigne lorsque la photo documente une anomalie cochee (EXI-CC13).
  final String? anomalyNote;

  Map<String, dynamic> toJson() => {
    'angle': angle.wireName,
    'takenAt': takenAt.toUtc().toIso8601String(),
    'sizeBytes': sizeBytes,
    'sha256': sha256,
    if (point != null) 'point': point!.toJson(),
    if (anomalyNote != null) 'anomalyNote': anomalyNote,
  };
}

/// Critere de la grille d'etat (EXI-CC12).
///
/// La grille est **fermee** : six criteres, les memes des deux cotes. Une
/// saisie libre serait ininstruisible — deux descriptions en prose ne se
/// comparent pas, alors que deux grilles cochees se soustraient.
enum ConditionCriterion {
  packagingIntact('packaging_intact', positive: true),
  impactMark('impact_mark'),
  moistureMark('moisture_mark'),
  alreadyOpened('already_opened'),
  originalTapePresent('original_tape', positive: true),
  crushedCorners('crushed_corners');

  const ConditionCriterion(this.wireName, {this.positive = false});

  final String wireName;

  /// Vrai lorsque cocher le critere est **rassurant** (emballage intact) plutot
  /// qu'inquietant. La distinction pilote la couleur et, surtout, la regle
  /// EXI-CC13 : seule une anomalie exige photo et commentaire.
  final bool positive;

  static ConditionCriterion? fromWire(String? value) {
    for (final c in ConditionCriterion.values) {
      if (c.wireName == value) return c;
    }
    return null;
  }
}

/// Grille d'etat du colis.
class ConditionGrid {
  const ConditionGrid(this.checked);

  /// Criteres coches.
  final Set<ConditionCriterion> checked;

  /// Anomalies cochees, c'est-a-dire les criteres inquietants.
  Set<ConditionCriterion> get anomalies =>
      checked.where((c) => !c.positive).toSet();

  bool get hasAnomaly => anomalies.isNotEmpty;

  /// Ecarts entre deux grilles, dans l'ordre chronologique.
  ///
  /// C'est l'operation qui tranche un litige en dix secondes (§3.3) : ce qui
  /// est apparu entre le depart et l'arrivee, et ce qui a disparu.
  ConditionDiff diff(ConditionGrid later) => ConditionDiff(
    appeared: later.checked.difference(checked),
    disappeared: checked.difference(later.checked),
  );

  List<String> toJson() => checked.map((c) => c.wireName).toList()..sort();

  static ConditionGrid fromJson(List<dynamic>? json) => ConditionGrid(
    (json ?? [])
        .map((v) => ConditionCriterion.fromWire('$v'))
        .whereType<ConditionCriterion>()
        .toSet(),
  );
}

class ConditionDiff {
  const ConditionDiff({required this.appeared, required this.disappeared});

  final Set<ConditionCriterion> appeared;
  final Set<ConditionCriterion> disappeared;

  bool get isEmpty => appeared.isEmpty && disappeared.isEmpty;

  /// Vrai des qu'une anomalie est apparue en cours de transport : c'est le cas
  /// qui engage la responsabilite du livreur.
  bool get hasNewAnomaly => appeared.any((c) => !c.positive);
}

/// Etat du scelle a la remise (EXI-CC22).
enum SealCheck {
  intact('intact'),
  broken('broken'),
  absent('absent');

  const SealCheck(this.wireName);

  final String wireName;

  /// « Rompu » ou « absent » declenche une photo obligatoire et l'ouverture
  /// automatique d'un incident.
  bool get requiresIncident => this != SealCheck.intact;

  static SealCheck? fromWire(String? value) {
    for (final s in SealCheck.values) {
      if (s.wireName == value) return s;
    }
    return null;
  }
}

/// Signature manuscrite capturee en vectoriel (EXI-CC40).
///
/// Le vecteur est conserve, le rendu PNG en est derive. La difference compte :
/// une image de signature se copie-colle, une suite de points portant pression
/// et horodatage relatif se rejoue et s'expertise. C'est ce qui distingue une
/// signature d'un dessin.
class VectorSignature {
  const VectorSignature({
    required this.strokes,
    required this.signedAt,
    required this.signerLabel,
  });

  /// Traits : chaque point porte x, y, pression et temps relatif en millisecondes.
  final List<List<SignaturePoint>> strokes;

  final DateTime signedAt;

  /// Qui signe : expediteur, livreur, destinataire, tiers.
  final String signerLabel;

  int get pointCount => strokes.fold(0, (sum, s) => sum + s.length);

  /// Duree du trace. Une signature apposee en quelques millisecondes est
  /// suspecte : c'est un indice utile a l'instruction d'un litige.
  Duration get duration {
    if (strokes.isEmpty) return Duration.zero;
    final points = strokes.expand((s) => s).toList();
    if (points.length < 2) return Duration.zero;
    return Duration(milliseconds: points.last.tMs - points.first.tMs);
  }

  Map<String, dynamic> toJson() => {
    'signerLabel': signerLabel,
    'signedAt': signedAt.toUtc().toIso8601String(),
    'strokes': strokes
        .map((s) => s.map((p) => p.toJson()).toList())
        .toList(),
  };
}

class SignaturePoint {
  const SignaturePoint(this.x, this.y, this.pressure, this.tMs);

  final double x;
  final double y;
  final double pressure;

  /// Millisecondes depuis le debut du trace.
  final int tMs;

  Map<String, dynamic> toJson() => {
    'x': double.parse(x.toStringAsFixed(2)),
    'y': double.parse(y.toStringAsFixed(2)),
    'p': double.parse(pressure.toStringAsFixed(3)),
    't': tMs,
  };
}

/// Constat contradictoire (§7.3).
///
/// Un document horodate, geolocalise, photographie et signe par les deux
/// parties, qui etablit l'etat du colis au moment precis ou il change de mains.
/// Deux constats encadrent la course ; leur comparaison tranche tout litige sur
/// un dommage.
class CustodyReport {
  const CustodyReport({
    required this.id,
    required this.deliveryId,
    required this.stage,
    required this.photos,
    required this.grid,
    required this.sealNumber,
    required this.weight,
    required this.signatures,
    required this.capturedAt,
    required this.point,
    this.sealCheck,
    this.reserveReason,
    this.otpVerified = false,
    this.previousHash,
    this.hash,
    this.serverTimestamp,
    this.sealedAt,
  });

  final String id;
  final String deliveryId;
  final CustodyStage stage;
  final List<CustodyPhoto> photos;
  final ConditionGrid grid;

  /// Numero du scelle appose physiquement sur le colis (EXI-CC14).
  final String sealNumber;

  /// Categorie de poids confirmee ou corrigee par le livreur (EXI-CC15).
  final WeightCategory weight;

  /// Les deux signatures : celle de la partie et la contre-signature du livreur
  /// (EXI-CC16, EXI-CC17, EXI-CC24, EXI-CC25).
  final List<VectorSignature> signatures;

  /// Horodatage local, conserve a titre indicatif (EXI-CC45).
  final DateTime capturedAt;

  final GeoPoint point;

  /// Verification du scelle, remise uniquement (EXI-CC22).
  final SealCheck? sealCheck;

  /// Motif de reserve, si le destinataire accepte avec reserves (EXI-CC26).
  final String? reserveReason;

  /// Code OTP du destinataire verifie (EXI-CC24).
  final bool otpVerified;

  /// Empreinte du constat precedent, qui realise le chainage (EXI-CC44).
  final String? previousHash;

  /// Empreinte SHA-256 de l'ensemble du constat (EXI-CC43).
  final String? hash;

  /// Horodatage serveur, **qui fait foi** (EXI-CC45).
  final DateTime? serverTimestamp;

  /// Instant de scellement. Une fois pose, le constat est immuable (EXI-CC04).
  final DateTime? sealedAt;

  bool get isSealed => sealedAt != null;

  /// Un constat est complet lorsque toutes ses pieces sont la (EXI-CC02).
  ///
  /// C'est cette propriete, et elle seule, qui autorise la progression du
  /// statut (EXI-CC03). La regle vit dans le domaine, pas dans un ecran : un
  /// ecran qui oublierait de la verifier ne pourrait pas contourner le
  /// repository.
  bool get isComplete {
    final anglesCovered = photos.map((p) => p.angle).toSet();
    if (anglesCovered.length < PhotoAngle.values.length) return false;
    if (sealNumber.trim().isEmpty) return false;
    if (signatures.length < 2) return false;

    // EXI-CC13 : toute anomalie cochee exige une photo dediee et un commentaire.
    if (grid.hasAnomaly &&
        !photos.any((p) => (p.anomalyNote ?? '').trim().isNotEmpty)) {
      return false;
    }

    // EXI-CC22 : un scelle rompu ou absent exige une photo supplementaire.
    if (stage == CustodyStage.handover) {
      if (sealCheck == null) return false;
      if (sealCheck!.requiresIncident && photos.length <= PhotoAngle.values.length) {
        return false;
      }
      // EXI-CC24 : signature du destinataire **et** code OTP, double preuve.
      if (!otpVerified) return false;
    }

    return true;
  }

  /// Poids total du constat, plafonne a 1,2 Mo (EXI-CC42).
  int get totalBytes => photos.fold(0, (sum, p) => sum + p.sizeBytes);

  static const int maxBytes = 1200 * 1024;

  bool get fitsBudget => totalBytes <= maxBytes;

  /// Corps canonique servant au calcul de l'empreinte.
  ///
  /// L'ordre est **deterministe** — photos triees par angle, grille triee,
  /// signatures dans l'ordre d'apposition — sans quoi deux serialisations du
  /// meme constat donneraient deux empreintes differentes et le serveur
  /// rejetterait un constat pourtant intact (EXI-B05).
  Map<String, dynamic> canonicalBody() {
    final sortedPhotos = [...photos]
      ..sort((a, b) => a.angle.index.compareTo(b.angle.index));

    return {
      'deliveryId': deliveryId,
      'stage': stage.wireName,
      'capturedAt': capturedAt.toUtc().toIso8601String(),
      'point': point.toJson(),
      'sealNumber': sealNumber,
      'weight': weight.wireName,
      'grid': grid.toJson(),
      'photos': sortedPhotos.map((p) => p.toJson()).toList(),
      'signatures': signatures.map((s) => s.toJson()).toList(),
      if (sealCheck != null) 'sealCheck': sealCheck!.wireName,
      if (reserveReason != null) 'reserveReason': reserveReason,
      'otpVerified': otpVerified,
      if (previousHash != null) 'previousHash': previousHash,
    };
  }

  /// Calcule l'empreinte SHA-256 du constat (EXI-CC43).
  ///
  /// Le chainage passe par `previousHash`, deja inclus dans le corps canonique :
  /// l'empreinte du constat de remise integre celle de la prise en charge, si
  /// bien que toute alteration de l'un rompt la chaine et devient detectable
  /// (EXI-CC44).
  String computeHash() {
    final canonical = jsonEncode(canonicalBody());
    return sha256.convert(utf8.encode(canonical)).toString();
  }

  /// Verifie l'integrite : l'empreinte enregistree correspond-elle au contenu ?
  bool verifyIntegrity() => hash != null && hash == computeHash();

  /// Scelle le constat (EXI-CC04).
  ///
  /// Apres cet appel, plus aucune modification n'est possible : toute precision
  /// ulterieure est un ajout horodate distinct, jamais une reecriture.
  CustodyReport seal({String? previousHash}) {
    final sealedReport = CustodyReport(
      id: id,
      deliveryId: deliveryId,
      stage: stage,
      photos: photos,
      grid: grid,
      sealNumber: sealNumber,
      weight: weight,
      signatures: signatures,
      capturedAt: capturedAt,
      point: point,
      sealCheck: sealCheck,
      reserveReason: reserveReason,
      otpVerified: otpVerified,
      previousHash: previousHash ?? this.previousHash,
      sealedAt: DateTime.now(),
    );

    return sealedReport.copyWithHash(sealedReport.computeHash());
  }

  CustodyReport copyWithHash(String value) => CustodyReport(
    id: id,
    deliveryId: deliveryId,
    stage: stage,
    photos: photos,
    grid: grid,
    sealNumber: sealNumber,
    weight: weight,
    signatures: signatures,
    capturedAt: capturedAt,
    point: point,
    sealCheck: sealCheck,
    reserveReason: reserveReason,
    otpVerified: otpVerified,
    previousHash: previousHash,
    hash: value,
    serverTimestamp: serverTimestamp,
    sealedAt: sealedAt,
  );

  Map<String, dynamic> toJson() => {
    ...canonicalBody(),
    'id': id,
    if (hash != null) 'hash': hash,
    if (sealedAt != null) 'sealedAt': sealedAt!.toUtc().toIso8601String(),
    if (serverTimestamp != null)
      'serverTimestamp': serverTimestamp!.toUtc().toIso8601String(),
  };
}

/// Verification de la chaine entre les deux constats d'une course (EXI-CC44).
class CustodyChain {
  const CustodyChain({required this.pickup, required this.handover});

  final CustodyReport? pickup;
  final CustodyReport? handover;

  /// La chaine est intacte lorsque chaque constat verifie sa propre empreinte
  /// et que la remise reference bien celle de la prise en charge.
  bool get isIntact {
    final p = pickup;
    final h = handover;
    if (p == null) return false;
    if (!p.verifyIntegrity()) return false;
    if (h == null) return true;
    return h.verifyIntegrity() && h.previousHash == p.hash;
  }

  /// Ecarts d'etat entre le depart et l'arrivee (EXI-CC30).
  ConditionDiff? get diff {
    final p = pickup;
    final h = handover;
    if (p == null || h == null) return null;
    return p.grid.diff(h.grid);
  }
}
