import 'package:flutter_test/flutter_test.dart';
import 'package:majichrono/features/auth/domain/value_objects/malagasy_phone.dart';

/// EXI-T01 : inscription par numero malgache `+261 3x xx xxx xx`.
///
/// C'est le premier champ que remplit tout utilisateur de l'application. Un
/// rejet a tort ferme la porte a un livreur ; une acceptation a tort envoie un
/// SMS dans le vide et laisse l'utilisateur attendre un code qui n'arrivera pas.
void main() {
  group('formes acceptees', () {
    const equivalentes = [
      '+261341234567',
      '+261 34 12 345 67',
      '00261341234567',
      '0341234567',
      '034 12 345 67',
      '034-12-345-67',
      '(034) 12 345 67',
      '261341234567',
    ];

    test('toutes les ecritures usuelles donnent le meme numero canonique', () {
      for (final saisie in equivalentes) {
        final phone = MalagasyPhone.tryParse(saisie);
        expect(phone, isNotNull, reason: 'refuse a tort : $saisie');
        expect(phone!.e164, '+261341234567', reason: 'mal normalise : $saisie');
      }
    });
  });

  group('formes refusees', () {
    const invalides = {
      '': 'vide',
      '0341234': 'trop court',
      '03412345678': 'trop long',
      '+261241234567': 'ne commence pas par 3 (fixe)',
      '+33612345678': 'indicatif etranger',
      'abcdefghij': 'non numerique',
      '+2613412345a': 'caractere parasite',
    };

    test('les saisies invalides sont refusees', () {
      invalides.forEach((saisie, motif) {
        expect(
          MalagasyPhone.tryParse(saisie),
          isNull,
          reason: 'accepte a tort ($motif) : "$saisie"',
        );
      });
    });
  });

  group('operateur', () {
    test('les prefixes connus sont reconnus', () {
      expect(MalagasyPhone.tryParse('0321234567')!.operator, MobileOperator.orange);
      expect(MalagasyPhone.tryParse('0331234567')!.operator, MobileOperator.airtel);
      expect(MalagasyPhone.tryParse('0341234567')!.operator, MobileOperator.yas);
      expect(MalagasyPhone.tryParse('0381234567')!.operator, MobileOperator.yas);
    });

    test('un prefixe inconnu reste un numero valide', () {
      // Une plage nouvellement attribuee ne doit pas empecher une inscription :
      // la validation suit le cahier des charges (`3x`), la detection
      // d'operateur est un confort separe.
      final phone = MalagasyPhone.tryParse('0391234567');
      expect(phone, isNotNull);
      expect(phone!.operator, MobileOperator.unknown);
    });
  });

  group('mises en forme', () {
    final phone = MalagasyPhone.tryParse('+261341234567')!;

    test('forme nationale lisible', () {
      expect(phone.displayNational, '034 12 345 67');
    });

    test('forme internationale lisible', () {
      expect(phone.displayInternational, '+261 34 12 345 67');
    });

    test('forme masquee : rien d exploitable ne subsiste', () {
      // EXI-T10 et EXI-B07 : c'est la seule forme admise dans un journal ou
      // face a l'autre partie.
      expect(phone.masked, '+261 ** ** *** 67');
      expect(phone.masked.contains('1234'), isFalse);
    });
  });

  test('l egalite porte sur le numero canonique, pas sur la saisie', () {
    expect(
      MalagasyPhone.tryParse('0341234567'),
      MalagasyPhone.tryParse('+261 34 12 345 67'),
    );
  });
}
