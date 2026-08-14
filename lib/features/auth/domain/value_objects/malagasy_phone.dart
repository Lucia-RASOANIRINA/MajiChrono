/// Operateur de telephonie mobile malgache, deduit du prefixe du numero.
///
/// L'information sert deux fois : afficher a l'utilisateur qu'on a bien reconnu
/// son operateur — rassurant quand on saisit un numero sur un ecran de 5 pouces —
/// et, plus tard, orienter le paiement vers le bon connecteur MajiPay. Le module
/// M11 du §11.3 designe explicitement cette detection par prefixe comme une
/// brique du routage operateur ; la faire ici evite de la refaire au module 7.
enum MobileOperator {
  orange('Orange', {'32'}),
  airtel('Airtel', {'33'}),
  yas('YAS', {'34', '38'}),
  unknown('', {});

  const MobileOperator(this.label, this.prefixes);

  final String label;

  /// Deux chiffres suivant l'indicatif pays, sans le 0 national.
  final Set<String> prefixes;

  static MobileOperator fromNationalPrefix(String twoDigits) {
    for (final operator in MobileOperator.values) {
      if (operator.prefixes.contains(twoDigits)) return operator;
    }
    return MobileOperator.unknown;
  }
}

/// Numero de telephone mobile malgache (EXI-T01).
///
/// Format canonique retenu : `+261XXXXXXXXX` — indicatif pays suivi de neuf
/// chiffres commencant par 3. C'est cette forme qui circule sur le reseau ; les
/// formes saisies par l'utilisateur (`034 12 345 67`, `+261 34 12 345 67`,
/// `0341234567`) sont toutes normalisees vers elle.
///
/// La validation accepte **tout prefixe `3X`**, comme l'ecrit le cahier des
/// charges, et non la seule liste des operateurs connus : une nouvelle plage
/// attribuee par l'ARTEC ne doit pas empecher un livreur de s'inscrire. La
/// detection d'operateur reste separee, et peut donc repondre « inconnu » sur un
/// numero par ailleurs parfaitement valide.
class MalagasyPhone {
  const MalagasyPhone._(this.e164);

  /// Forme canonique `+261XXXXXXXXX`.
  final String e164;

  static const String countryCode = '261';
  static const int nationalLength = 9;

  /// Analyse une saisie utilisateur. Retourne `null` si le numero est invalide.
  ///
  /// Tolerante a la mise en forme : espaces, points, tirets et parentheses sont
  /// ignores, car un utilisateur recopie son numero comme il l'a note.
  static MalagasyPhone? tryParse(String input) {
    final digits = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.isEmpty) return null;

    var national = digits;

    if (national.startsWith('+$countryCode')) {
      national = national.substring(countryCode.length + 1);
    } else if (national.startsWith('00$countryCode')) {
      national = national.substring(countryCode.length + 2);
    } else if (national.startsWith(countryCode) &&
        national.length == countryCode.length + nationalLength) {
      national = national.substring(countryCode.length);
    } else if (national.startsWith('0')) {
      // Forme nationale : le 0 remplace l'indicatif pays.
      national = national.substring(1);
    }

    if (national.length != nationalLength) return null;
    if (!RegExp(r'^3\d{8}$').hasMatch(national)) return null;

    return MalagasyPhone._('+$countryCode$national');
  }

  static bool isValid(String input) => tryParse(input) != null;

  /// Les neuf chiffres nationaux, sans indicatif ni zero.
  String get national => e164.substring(countryCode.length + 1);

  MobileOperator get operator =>
      MobileOperator.fromNationalPrefix(national.substring(0, 2));

  /// Mise en forme lisible : `034 12 345 67`.
  ///
  /// C'est la forme sous laquelle un Malgache lit et dicte son numero ; afficher
  /// `+261341234567` d'un bloc rend la relecture penible et les erreurs de
  /// saisie invisibles.
  String get displayNational {
    final n = national;
    return '0${n.substring(0, 2)} ${n.substring(2, 4)} '
        '${n.substring(4, 7)} ${n.substring(7)}';
  }

  /// Mise en forme internationale : `+261 34 12 345 67`.
  String get displayInternational {
    final n = national;
    return '+$countryCode ${n.substring(0, 2)} ${n.substring(2, 4)} '
        '${n.substring(4, 7)} ${n.substring(7)}';
  }

  /// Forme masquee, seule autorisee dans un journal ou face a l'autre partie
  /// (EXI-T10, EXI-B07) : `+261 ** ** *** 67`.
  String get masked => '+$countryCode ** ** *** ${national.substring(7)}';

  @override
  String toString() => e164;

  @override
  bool operator ==(Object other) =>
      other is MalagasyPhone && other.e164 == e164;

  @override
  int get hashCode => e164.hashCode;
}
