import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_scaffold.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _tabs = [
    HomeScreen(),
    StatsScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_rounded), label: appT(context, 'navHome')),
          NavigationDestination(icon: const Icon(Icons.bar_chart_rounded), label: appT(context, 'navStats')),
          NavigationDestination(icon: const Icon(Icons.favorite_rounded), label: appT(context, 'navFavorites')),
          NavigationDestination(icon: const Icon(Icons.settings_rounded), label: appT(context, 'navSettings')),
        ],
      ),
    );
  }
}
