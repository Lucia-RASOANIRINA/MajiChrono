import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/core/error/failure.dart';
import 'package:majichrono/core/i18n/locale_controller.dart';
import 'package:majichrono/features/auth/domain/value_objects/malagasy_phone.dart';
import 'package:majichrono/features/auth/presentation/providers/auth_providers.dart';
import 'package:majichrono/features/auth/presentation/widgets/google_account_sheet.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/l10n/failure_messages.dart';
import 'package:majichrono/shared/widgets/mc_primary_action.dart';

/// Saisie du numero de telephone (EXI-T01).
class PhoneInputScreen extends ConsumerStatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  ConsumerState<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends ConsumerState<PhoneInputScreen> {
  final TextEditingController _controller = TextEditingController();
  MalagasyPhone? _phone;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      _phone = MalagasyPhone.tryParse(value);
      _error = null;
    });
  }

  Future<void> _submit() async {
    final phone = _phone;
    if (phone == null || _busy) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final challenge = await ref
          .read(authRepositoryProvider)
          .requestOtp(phone);
      if (!mounted) return;
      // `unawaited` : le futur de `push` ne se complete qu'au retour de l'ecran
      // OTP. L'attendre bloquerait ce bloc `try` jusque-la, et le `finally`
      // remettrait `_busy` a faux beaucoup trop tard.
      unawaited(context.push(AppRoutes.authOtp, extra: challenge));
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(
        () => _error = failure.localizedMessage(AppLocalizations.of(context)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Entree par Google : choix du compte, puis code dans la boite mail.
  ///
  /// Le numero reste la cle du compte. Ce chemin ne le remplace pas, il evite
  /// seulement d'attendre un SMS quand on est sur Wi-Fi — situation ordinaire a
  /// Antananarivo, ou la couverture GSM d'un appartement peut etre pire que
  /// celle de sa box.
  Future<void> _continueWithGoogle() async {
    final email = await showGoogleAccountSheet(context);
    if (email == null || !mounted) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final challenge = await ref
          .read(authRepositoryProvider)
          .requestEmailCode(email);
      if (!mounted) return;
      unawaited(context.push(AppRoutes.authEmailCode, extra: challenge));
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(
        () => _error = failure.localizedMessage(AppLocalizations.of(context)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final operator = _phone?.operator;

    // Le bouton n'apparait que si l'appareil porte vraiment des comptes Google.
    // Sur un telephone sans services Google — courant sur le parc vise — il
    // n'aurait rien a proposer, et un bouton qui echoue au premier appui coute
    // plus de confiance qu'il n'en fait gagner.
    final googleAccounts =
        ref.watch(googleAccountHintsProvider).valueOrNull ?? const [];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: AppSpacing.lg,
                top: AppSpacing.sm,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'fr', label: Text(l10n.langFrench)),
                    ButtonSegment(value: 'mg', label: Text(l10n.langMalagasy)),
                  ],
                  selected: {locale.languageCode},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) => ref
                      .read(localeProvider.notifier)
                      .set(AppLocales.fromCode(selection.first)),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  Text(l10n.appName, style: theme.textTheme.displaySmall),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(l10n.authPhoneTitle, style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.authPhoneSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    // Le clavier telephonique laisse passer des caracteres de
                    // mise en forme : on les accepte a la saisie et on normalise
                    // au moment de valider, plutot que de bloquer la frappe.
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d +().-]')),
                      LengthLimitingTextInputFormatter(20),
                    ],
                    style: theme.textTheme.titleLarge,
                    decoration: InputDecoration(
                      labelText: l10n.authPhoneLabel,
                      hintText: l10n.authPhoneHint,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      // Trois messages distincts, parce que trois causes
                      // distinctes : saisie incomplete, prefixe qu'aucun
                      // operateur n'exploite, et ligne fixe qui ne recevra
                      // jamais le SMS. « Numero invalide » pour les trois
                      // laisserait l'utilisateur corriger au hasard.
                      errorText: _controller.text.isNotEmpty && _phone == null
                          ? (MalagasyPhone.isUnknownOperator(_controller.text)
                                ? l10n.authPhoneUnknownOperator
                                : l10n.authPhoneInvalid)
                          : null,
                      helperText: switch (operator) {
                        null => null,
                        MobileOperator.unknown => null,
                        MobileOperator.telmaFixe => l10n.authPhoneNoSms,
                        final known => l10n.authPhoneOperator(known.label),
                      },
                      helperMaxLines: 2,
                      errorMaxLines: 3,
                    ),
                    onChanged: _onChanged,
                    onSubmitted: (_) => _submit(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  if (googleAccounts.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: Text(
                            l10n.authOrSeparator,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: AppSizes.minTouchTarget,
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : _continueWithGoogle,
                        icon: const _GoogleMark(),
                        label: Text(l10n.authGoogleContinue),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            McPrimaryAction(
              label: l10n.commonContinue,
              busy: _busy,
              onPressed: _phone == null ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/// Marque du bouton Google.
///
/// Un cercle a quatre secteurs, et non le « G » officiel : le logo de Google est
/// une marque deposee dont l'usage est encadre par ses regles de marque, qui
/// imposent l'asset fourni par Google — jamais un dessin approchant. L'asset
/// officiel sera pose ici en meme temps que l'identifiant client OAuth, dans le
/// meme lot. D'ici la, une marque neutre annonce l'origine du bouton sans
/// pretendre etre celle de Google.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) =>
      const SizedBox.square(dimension: 20, child: CustomPaint(painter: _GoogleMarkPainter()));
}

class _GoogleMarkPainter extends CustomPainter {
  const _GoogleMarkPainter();

  /// Les quatre couleurs de la marque, dans leur ordre habituel.
  static const List<Color> _sectors = [
    Color(0xFF4285F4),
    Color(0xFFEA4335),
    Color(0xFFFBBC05),
    Color(0xFF34A853),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.18;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Un quart de tour par secteur, avec un leger espace : sans lui, les arcs se
    // touchent et le cercle se lit comme un anneau bicolore a petite taille.
    const sweep = 1.4;
    for (var i = 0; i < _sectors.length; i++) {
      paint.color = _sectors[i];
      canvas.drawArc(rect, -1.4 + i * 1.5708, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_GoogleMarkPainter oldDelegate) => false;
}
