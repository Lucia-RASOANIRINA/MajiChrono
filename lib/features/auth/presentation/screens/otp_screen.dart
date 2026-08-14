import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/core/error/failure.dart';
import 'package:majichrono/core/providers/core_providers.dart';
import 'package:majichrono/features/auth/domain/entities/auth_entities.dart';
import 'package:majichrono/features/auth/presentation/providers/auth_providers.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/l10n/failure_messages.dart';
import 'package:majichrono/shared/widgets/mc_primary_action.dart';

/// Saisie du code OTP (EXI-T01) : 6 chiffres, 5 minutes, 3 tentatives.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({required this.challenge, super.key});

  final OtpChallenge challenge;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController _controller = TextEditingController();
  late OtpChallenge _challenge = widget.challenge;
  Timer? _ticker;
  Duration _remaining = Duration.zero;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  void _startTicker() {
    _remaining = _challenge.remaining;
    _ticker?.cancel();
    // Une seconde suffit : le compte a rebours est une information de confort,
    // pas une horloge de securite — c'est le serveur qui tranche l'expiration.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = _challenge.remaining);
      if (_remaining == Duration.zero) _ticker?.cancel();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_busy || _controller.text.length != 6) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    final l10n = AppLocalizations.of(context);
    try {
      final verification = await ref.read(authRepositoryProvider).verifyOtp(
            challengeId: _challenge.challengeId,
            code: _controller.text,
          );
      await ref.read(authControllerProvider.notifier).onOtpVerified(verification);
      // La redirection est faite par le routeur, qui observe l'etat de session :
      // aucun `pop` ni `go` ici, sans quoi deux sources decideraient de la
      // navigation et finiraient par se contredire.
    } on ValidationFailure catch (failure) {
      if (!mounted) return;
      final left = failure.details?['attemptsLeft'] as int?;
      setState(() {
        _controller.clear();
        _error = left != null && left > 0
            ? l10n.authOtpInvalid(left)
            : l10n.authOtpLocked;
      });
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _error = failure.localizedMessage(l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final fresh =
          await ref.read(authRepositoryProvider).requestOtp(_challenge.phone);
      if (!mounted) return;
      setState(() {
        _challenge = fresh;
        _controller.clear();
      });
      _startTicker();
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() =>
          _error = failure.localizedMessage(AppLocalizations.of(context)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String get _formattedRemaining {
    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final expired = _remaining == Duration.zero;
    final showDebugCode = ref.watch(appConfigProvider).enableDevPanel &&
        _challenge.debugCode != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authOtpTitle)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                Text(
                  // Le numero est reaffiche en entier : l'utilisateur doit
                  // pouvoir verifier qu'il n'a pas fait de faute de frappe avant
                  // d'attendre un SMS qui n'arrivera jamais.
                  l10n.authOtpSentTo(_challenge.phone.displayNational),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  expired
                      ? l10n.authOtpExpired
                      : l10n.authOtpExpiresIn(_formattedRemaining),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: expired
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (showDebugCode) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Card(
                    color: theme.colorScheme.secondaryContainer,
                    child: Padding(
                      padding: AppSpacing.card,
                      child: Row(
                        children: [
                          const Icon(Icons.bug_report_outlined),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              l10n.authOtpSimulated(_challenge.debugCode!),
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  enabled: !expired,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: theme.textTheme.displaySmall?.copyWith(letterSpacing: 12),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(counterText: ''),
                  onChanged: (value) {
                    setState(() => _error = null);
                    // Validation automatique au sixieme chiffre : un geste de
                    // moins sur un parcours qui en compte deja assez (§4.5).
                    if (value.length == 6) _verify();
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: TextButton.icon(
                    onPressed: _busy ? null : _resend,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.authOtpResend),
                  ),
                ),
              ],
            ),
          ),
          McPrimaryAction(
            label: l10n.commonContinue,
            busy: _busy,
            onPressed: expired ? null : _verify,
          ),
        ],
      ),
    );
  }
}
