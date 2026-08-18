import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/core/error/failure.dart';
import 'package:majichrono/core/providers/core_providers.dart';
import 'package:majichrono/features/auth/domain/entities/google_entities.dart';
import 'package:majichrono/features/auth/presentation/providers/auth_providers.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/l10n/failure_messages.dart';
import 'package:majichrono/shared/widgets/mc_primary_action.dart';

/// Saisie du code recu par e-mail, apres « Continuer avec Google ».
///
/// Memes regles que l'OTP telephonique — six chiffres, cinq minutes, trois
/// tentatives — mais une issue de plus : l'adresse peut etre prouvee sans
/// qu'aucun compte n'y soit rattache. Ce cas n'est pas une erreur, c'est le
/// parcours normal d'un nouvel utilisateur, et l'ecran le traite comme tel.
class EmailCodeScreen extends ConsumerStatefulWidget {
  const EmailCodeScreen({required this.challenge, super.key});

  final EmailChallenge challenge;

  @override
  ConsumerState<EmailCodeScreen> createState() => _EmailCodeScreenState();
}

class _EmailCodeScreenState extends ConsumerState<EmailCodeScreen> {
  final TextEditingController _controller = TextEditingController();
  late EmailChallenge _challenge = widget.challenge;
  Timer? _ticker;
  Duration _remaining = Duration.zero;
  bool _busy = false;
  String? _error;

  /// Renseigne quand l'adresse est prouvee mais inconnue : l'ecran bascule alors
  /// sur l'explication et le renvoi vers le numero.
  String? _unlinked;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  void _startTicker() {
    _remaining = _challenge.remaining;
    _ticker?.cancel();
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
      final result = await ref
          .read(authRepositoryProvider)
          .verifyEmailCode(
            challengeId: _challenge.challengeId,
            code: _controller.text,
          );

      switch (result) {
        case EmailLinked(:final verification):
          await ref
              .read(authControllerProvider.notifier)
              .onOtpVerified(verification);
        // Aucune navigation ici : le routeur observe l'etat de session.
        case EmailUnlinked(:final email):
          // L'adresse est retenue pour etre rattachee des que le numero sera
          // confirme. Elle ne survit pas au processus (§ pendingEmailLink).
          ref.read(pendingEmailLinkProvider.notifier).state = email;
          _ticker?.cancel();
          if (mounted) setState(() => _unlinked = email);
      }
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
      final fresh = await ref
          .read(authRepositoryProvider)
          .requestEmailCode(_challenge.email);
      if (!mounted) return;
      setState(() {
        _challenge = fresh;
        _controller.clear();
      });
      _startTicker();
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(
        () => _error = failure.localizedMessage(AppLocalizations.of(context)),
      );
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

    if (_unlinked != null) {
      return _UnlinkedPanel(email: _unlinked!);
    }

    final expired = _remaining == Duration.zero;
    final showDebugCode =
        ref.watch(appConfigProvider).enableDevPanel &&
        _challenge.debugCode != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authEmailCodeTitle)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                Text(
                  l10n.authEmailCodeSentTo(_challenge.email),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.authEmailCodeHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
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
                  style: theme.textTheme.displaySmall?.copyWith(
                    letterSpacing: 12,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(counterText: ''),
                  onChanged: (value) {
                    setState(() => _error = null);
                    if (value.length == 6) _verify();
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
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

/// Adresse prouvee, compte inconnu.
///
/// L'ecran explique **pourquoi** on redemande un numero, au lieu de renvoyer
/// sans un mot sur la saisie du telephone : sans explication, l'utilisateur
/// croit que sa connexion Google a echoue et recommence en boucle.
class _UnlinkedPanel extends StatelessWidget {
  const _UnlinkedPanel({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authEmailCodeTitle)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                Icon(
                  Icons.mark_email_read_outlined,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.authEmailUnlinkedTitle,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.authEmailUnlinkedBody(email),
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          McPrimaryAction(
            label: l10n.authEmailUnlinkedAction,
            // `go` et non `pop` : la pile contient l'ecran du code, dont
            // le defi est brule. Y revenir par le bouton retour du systeme
            // n'aurait plus aucun sens.
            onPressed: () => context.go(AppRoutes.authPhone),
          ),
        ],
      ),
    );
  }
}
