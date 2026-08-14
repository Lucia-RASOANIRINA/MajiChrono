import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/core/providers/core_providers.dart';
import 'package:majichrono/l10n/app_localizations.dart';

/// Bandeau permanent d'etat reseau (EXI-T06).
///
/// Regle d'interaction §15.2.5 : le mode hors ligne est visible en permanence,
/// jamais decouvert au moment d'un echec. Le bandeau n'est donc pas une
/// notification transitoire mais une bande fixe en haut de chaque ecran.
class McNetworkBanner extends ConsumerWidget {
  const McNetworkBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(networkStatusProvider);
    final pending = ref.watch(pendingSyncCountProvider);

    final online = status.valueOrNull?.isOnline ?? false;
    final profile = status.valueOrNull?.profile;
    final pendingCount = pending.valueOrNull ?? 0;

    final String label;
    final Color background;
    final IconData icon;

    if (online) {
      background = AppColors.success;
      icon = Icons.cloud_done_outlined;
      label = profile == null
          ? l10n.networkOnline
          : '${l10n.networkOnline} · ${profile.label}';
    } else {
      background = AppColors.offline;
      icon = Icons.cloud_off_outlined;
      label = pendingCount > 0
          ? l10n.networkOfflinePending(pendingCount)
          : l10n.networkOfflineNoPending;
    }

    // Le fond deborde volontairement sous la barre d'etat : le bandeau occupe
    // la bande systeme au lieu de s'y glisser dessous. L'etat reseau reste ainsi
    // lisible en permanence (§15.2.5) sans voler une ligne au contenu, ce qui
    // compte sur les ecrans de 320 dp du parc d'entree de gamme (§4.4).
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: background,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: AnimatedContainer(
        duration: AppMotion.standard,
        curve: AppMotion.curve,
        color: background,
        width: double.infinity,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: AppSizes.bannerHeight,
            child: Semantics(
              liveRegion: true,
              label: label,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      // Le bandeau vit au-dessus du Navigator, donc hors de
                      // tout Material : sans `decoration: none`, le texte
                      // herite du style de secours de Flutter et s'affiche
                      // souligne en jaune.
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
