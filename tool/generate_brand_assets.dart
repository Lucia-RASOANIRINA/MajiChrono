import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart';

/// Generation des visuels de marque.
///
/// Les icones sont **dessinees par programme** plutot que deposees en binaire :
/// un PNG dans un depot est un fichier que personne ne sait plus reproduire six
/// mois plus tard, et dont on ne peut ni corriger une teinte ni changer une
/// proportion sans rouvrir un editeur.
///
/// Ici, la charte est du code : les couleurs viennent des memes valeurs que le
/// theme, et regenerer se fait par `dart run tool/generate_brand_assets.dart`.
///
/// Le motif est volontairement geometrique — un colis et son sillage de
/// vitesse. Il reste lisible a 48 px dans une liste d'applications, ce qu'un
/// dessin detaille ne fait pas.
void main() {
  Directory('assets/icon').createSync(recursive: true);

  _write('assets/icon/app_icon.png', _icon(1024, withBackground: true));
  // Icone adaptative Android : le premier plan est recadre par le lanceur, donc
  // le motif tient dans les 66 % centraux.
  _write('assets/icon/app_icon_foreground.png', _icon(1024, safeArea: true));
  _write('assets/icon/app_icon_monochrome.png', _icon(1024, monochrome: true));

  stdout.writeln('Icones generees dans assets/icon/');
}

/// Bleu profond de la marque, identique a `AppColors.primary`.
const int _brand = 0xFF1E2A78;
const int _accent = 0xFF2F6BE4;

void _write(String path, Image image) =>
    File(path).writeAsBytesSync(encodePng(image));

Image _icon(
  int size, {
  bool withBackground = false,
  bool safeArea = false,
  bool monochrome = false,
}) {
  final image = Image(width: size, height: size, numChannels: 4);
  fill(image, color: ColorRgba8(0, 0, 0, 0));

  if (withBackground) {
    fillCircle(
      image,
      x: size ~/ 2,
      y: size ~/ 2,
      radius: size ~/ 2,
      color: _rgb(_brand),
    );
  }

  // Le motif occupe 62 % de la toile quand il doit survivre au recadrage du
  // lanceur adaptatif, 78 % sinon.
  final scale = safeArea ? 0.62 : 0.78;
  final unit = size * scale;
  final left = (size - unit) / 2;
  final top = (size - unit) / 2;

  final mark = monochrome ? _rgb(0xFFFFFFFF) : _rgb(0xFFFFFFFF);
  final trail = monochrome ? _rgb(0xFFFFFFFF) : _rgb(_accent);

  // --- Le colis ---------------------------------------------------------
  final boxWidth = unit * 0.52;
  final boxHeight = unit * 0.46;
  final boxLeft = left + unit * 0.36;
  final boxTop = top + unit * 0.29;
  final stroke = math.max(2, unit * 0.055).round();

  _roundedBox(
    image,
    x: boxLeft.round(),
    y: boxTop.round(),
    w: boxWidth.round(),
    h: boxHeight.round(),
    thickness: stroke,
    color: mark,
  );

  // La bande de scellement : c'est elle qui fait lire « colis » et non
  // « rectangle ».
  fillRect(
    image,
    x1: (boxLeft + boxWidth * 0.42).round(),
    y1: boxTop.round(),
    x2: (boxLeft + boxWidth * 0.58).round(),
    y2: (boxTop + boxHeight).round(),
    color: mark,
  );

  // --- Le sillage de vitesse -------------------------------------------
  // Trois traits decroissants a gauche du colis : le mouvement, sans dessiner
  // de vehicule qui deviendrait illisible en petit.
  for (var i = 0; i < 3; i++) {
    final lineY = boxTop + boxHeight * (0.22 + i * 0.28);
    final lineLength = unit * (0.30 - i * 0.07);
    final lineLeft = boxLeft - unit * 0.06 - lineLength;

    _roundedBar(
      image,
      x: lineLeft.round(),
      y: (lineY - stroke / 2).round(),
      w: lineLength.round(),
      h: stroke,
      color: trail,
    );
  }

  return image;
}

ColorRgba8 _rgb(int argb) => ColorRgba8(
  (argb >> 16) & 0xFF,
  (argb >> 8) & 0xFF,
  argb & 0xFF,
  (argb >> 24) & 0xFF,
);

/// Contour de rectangle d'epaisseur donnee.
void _roundedBox(
  Image image, {
  required int x,
  required int y,
  required int w,
  required int h,
  required int thickness,
  required Color color,
}) {
  fillRect(image, x1: x, y1: y, x2: x + w, y2: y + thickness, color: color);
  fillRect(
    image,
    x1: x,
    y1: y + h - thickness,
    x2: x + w,
    y2: y + h,
    color: color,
  );
  fillRect(image, x1: x, y1: y, x2: x + thickness, y2: y + h, color: color);
  fillRect(
    image,
    x1: x + w - thickness,
    y1: y,
    x2: x + w,
    y2: y + h,
    color: color,
  );
}

void _roundedBar(
  Image image, {
  required int x,
  required int y,
  required int w,
  required int h,
  required Color color,
}) {
  if (w <= 0 || h <= 0) return;
  fillRect(image, x1: x, y1: y, x2: x + w, y2: y + h, color: color);
  fillCircle(image, x: x, y: y + h ~/ 2, radius: h ~/ 2, color: color);
  fillCircle(image, x: x + w, y: y + h ~/ 2, radius: h ~/ 2, color: color);
}
