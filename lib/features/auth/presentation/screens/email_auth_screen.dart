import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/core/error/failure.dart';
import 'package:majichrono/features/auth/domain/entities/google_entities.dart';
import 'package:majichrono/features/auth/presentation/providers/auth_providers.dart';
import 'package:majichrono/features/auth/presentation/widgets/auth_branding.dart';
import 'package:majichrono/features/auth/presentation/widgets/google_account_sheet.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/l10n/failure_messages.dart';
import 'package:majichrono/shared/widgets/mc_loader.dart';

/// Connexion et inscription par adresse e-mail.
///
/// Un seul ecran pour les deux : la maquette montre deux pages qui ne different
/// que par un champ et trois libelles. En faire deux fichiers garantirait qu'un
/// jour l'un recoive une correction que l'autre n'aura pas — c'est arrive assez
/// souvent pour qu'on l'evite ici.
enum EmailAuthMode { signIn, signUp }

class EmailAuthScreen extends ConsumerStatefulWidget {
  const EmailAuthScreen({required this.mode, super.key});

  final EmailAuthMode mode;

  @override
  ConsumerState<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends ConsumerState<EmailAuthScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _busy = false;
  bool _obscure = true;
  String? _error;

  /// Meme regle que le serveur, pour ne pas payer un aller-retour sur 2G a
  /// cause d'une faute de frappe evidente.
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s.]+\.[^@\s]+$');
  static const int minPasswordLength = 8;

  bool get _isSignUp => widget.mode == EmailAuthMode.signUp;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (!_emailPattern.hasMatch(_email.text.trim())) return false;
    if (_password.text.length < minPasswordLength) return false;
    if (_isSignUp && _confirm.text != _password.text) return false;
    return true;
  }

  Future<void> _submit() async {
    if (_busy || !_canSubmit) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    final l10n = AppLocalizations.of(context);
    final repository = ref.read(authRepositoryProvider);

    try {
      final result = _isSignUp
          ? await repository.signUpWithPassword(
              email: _email.text.trim(),
              password: _password.text,
            )
          : await repository.signInWithPassword(
              email: _email.text.trim(),
              password: _password.text,
            );
      if (!mounted) return;
      await _handle(result);
    } on UnauthorizedFailure {
      if (!mounted) return;
      setState(() => _error = l10n.authBadCredentials);
    } on ConflictFailure {
      if (!mounted) return;
      setState(() => _error = l10n.authEmailTaken);
    } on ValidationFailure catch (failure) {
      if (!mounted) return;
      setState(
        () => _error = failure.details?['minLength'] != null
            ? l10n.authPasswordTooShort
            : failure.localizedMessage(l10n),
      );
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _error = failure.localizedMessage(l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Issue commune au mot de passe et aux entrees sociales.
  Future<void> _handle(EmailVerification result) async {
    switch (result) {
      case EmailLinked(:final verification):
        await ref
            .read(authControllerProvider.notifier)
            .onOtpVerified(verification);
      // Aucune navigation : le routeur observe l'etat de session.
      case EmailUnlinked(:final email):
        // L'adresse est prouvee mais aucun numero ne s'y rattache. Le compte
        // n'existe pas tant que le numero n'est pas confirme.
        ref.read(pendingEmailLinkProvider.notifier).state = email;
        if (mounted) unawaited(context.push(AppRoutes.authPhone));
    }
  }

  /// Entree sociale : le fournisseur ne fait que designer une adresse, le code
  /// recu dans la boite mail fait le reste.
  Future<void> _social(SocialProvider provider) async {
    final email = await showGoogleAccountSheet(context, provider: provider);
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (!_isSignUp) const AuthBanner(),
            if (_isSignUp)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                children: [
                  Text(
                    l10n.appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    _isSignUp ? l10n.authSignUpTitle : l10n.authSignInTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _Field(
                    controller: _email,
                    hint: l10n.authFieldEmail,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    error:
                        _email.text.isNotEmpty &&
                            !_emailPattern.hasMatch(_email.text.trim())
                        ? l10n.authGoogleEmailInvalid
                        : null,
                    onChanged: () => setState(() => _error = null),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _Field(
                    controller: _password,
                    hint: l10n.authFieldPassword,
                    obscure: _obscure,
                    // Le mot de passe se relit : sur un clavier virtuel, la
                    // frappe a l'aveugle est la premiere cause d'echec de
                    // connexion.
                    trailing: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                    error:
                        _password.text.isNotEmpty &&
                            _password.text.length < minPasswordLength
                        ? l10n.authPasswordTooShort
                        : null,
                    onChanged: () => setState(() => _error = null),
                  ),
                  if (_isSignUp) ...[
                    const SizedBox(height: AppSpacing.md),
                    _Field(
                      controller: _confirm,
                      hint: l10n.authFieldPasswordConfirm,
                      obscure: _obscure,
                      error:
                          _confirm.text.isNotEmpty &&
                              _confirm.text != _password.text
                          ? l10n.authPasswordMismatch
                          : null,
                      onChanged: () => setState(() => _error = null),
                    ),
                  ],

                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    height: AppSizes.driverActionHeight,
                    child: FilledButton(
                      onPressed: _canSubmit && !_busy ? _submit : null,
                      child: _busy
                          ? const McLoader.small()
                          : Text(_isSignUp ? l10n.authSignUp : l10n.authSignIn),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    _isSignUp ? l10n.authOrSignUpWith : l10n.authOrSignInWith,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SocialRow(busy: _busy, onPick: _social),

                  const SizedBox(height: AppSpacing.xxl),
                  AuthFooterBadge(
                    icon: _isSignUp ? Icons.two_wheeler : Icons.handshake,
                    title: _isSignUp
                        ? l10n.authFooterSpeedTitle
                        : l10n.authFooterTrustTitle,
                    note: _isSignUp
                        ? l10n.authFooterSpeedNote
                        : l10n.authFooterTrustNote,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignUp ? l10n.authHaveAccount : l10n.authNoAccount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _isSignUp
                            ? context.pop()
                            : context.push(AppRoutes.authSignUp),
                        child: Text(
                          _isSignUp ? l10n.authSignIn : l10n.authSignUp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Champ de la maquette : fond clair, contour discret, pas d'etiquette flottante.
class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
    this.obscure = false,
    this.autofocus = false,
    this.trailing,
    this.error,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool autofocus;
  final Widget? trailing;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      autofocus: autofocus,
      keyboardType: keyboardType,
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        hintText: hint,
        errorText: error,
        suffixIcon: trailing,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
      ),
    );
  }
}
