import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import 'calendar_screen.dart';
import 'documents_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    CalendarScreen(),
    DocumentsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      // Rounded top corners so the bar reads as one of the cozy cards.
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          // Outlined-only icons: the tangerine pill already marks selection,
          // so no filled swap — stays smooth and airy in both modes.
          NavigationDestination(
            icon: const Icon(AppIcons.home),
            selectedIcon: const Icon(AppIcons.home),
            label: 'nav_home'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.calendar),
            selectedIcon: const Icon(AppIcons.calendar),
            label: 'nav_care'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.folder),
            selectedIcon: const Icon(AppIcons.folder),
            label: 'nav_files'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.settings),
            selectedIcon: const Icon(AppIcons.settings),
            label: 'nav_more'.tr(),
          ),
        ],
        ),
      ),
    );
  }
}
