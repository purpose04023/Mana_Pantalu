import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mana_pantalu/app/theme.dart';
import 'package:mana_pantalu/l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/diagnose')) return 1;
    if (location.startsWith('/my-crops')) return 2;
    if (location.startsWith('/tips')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/diagnose');
        break;
      case 2:
        context.go('/my-crops');
        break;
      case 3:
        context.go('/tips');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final int selectedIndex = _calculateSelectedIndex(context);

    // Hide bottom nav on scanning & result screens for focused UX
    final String location = GoRouterState.of(context).uri.toString();
    final bool hideNav = location.contains('/diagnose/scan') || location.contains('/diagnose/result');

    return Scaffold(
      body: child,
      bottomNavigationBar: hideNav
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.primary.withAlpha(50),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home, color: AppColors.primary),
                  label: l10n.home,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.camera_alt_outlined),
                  selectedIcon: const Icon(Icons.camera_alt, color: AppColors.primary),
                  label: l10n.diagnose,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.agriculture_outlined),
                  selectedIcon: const Icon(Icons.agriculture, color: AppColors.primary),
                  label: l10n.myCrops,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.lightbulb_outline),
                  selectedIcon: const Icon(Icons.lightbulb, color: AppColors.primary),
                  label: l10n.tips,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person, color: AppColors.primary),
                  label: l10n.profile,
                ),
              ],
            ),
    );
  }
}
