import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Destination de la barre de navigation d'un profil.
class ShellDestination {
  const ShellDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;

  /// Toujours renseigne : l'iconographie est systematiquement doublee d'un
  /// libelle (§15.1), y compris pour les utilisateurs peu a l'aise avec le
  /// numerique (§4.5).
  final String label;
}

/// Coquille commune aux trois profils.
///
/// Elle porte le bandeau reseau permanent (EXI-T06) au-dessus du contenu :
/// place ici plutot que dans chaque ecran, il ne peut pas etre oublie.
class RoleShell extends StatelessWidget {
  const RoleShell({
    required this.navigationShell,
    required this.destinations,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<ShellDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Le bandeau reseau (EXI-T06) n'est pas ici mais au-dessus du Navigator,
      // dans `MajiChronoApp.builder` : porte par la coquille, il disparaitrait
      // au premier ecran empile.
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Un second appui sur l'onglet actif revient a sa racine.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
              tooltip: destination.label,
            ),
        ],
      ),
    );
  }
}
