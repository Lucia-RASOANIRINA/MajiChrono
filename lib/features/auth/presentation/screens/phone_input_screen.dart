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
      final challenge =
          await ref.read(authRepositoryProvider).requestOtp(phone);
      if (!mounted) return;
      // `unawaited` : le futur de `push` ne se complete qu'au retour de l'ecran
      // OTP. L'attendre bloquerait ce bloc `try` jusque-la, et le `finally`
      // remettrait `_busy` a faux beaucoup trop tard.
      unawaited(context.push(AppRoutes.authOtp, extra: challenge));
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _error = failure.localizedMessage(AppLocalizations.of(context)));
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg, top: AppSpacing.sm),
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
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
                      errorText: _controller.text.isNotEmpty && _phone == null
                          ? l10n.authPhoneInvalid
                          : null,
                      helperText: operator != null &&
                              operator != MobileOperator.unknown
                          ? l10n.authPhoneOperator(operator.label)
                          : null,
                    ),
                    onChanged: _onChanged,
                    onSubmitted: (_) => _submit(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _error!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.error),
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
