import 'package:flutter/material.dart';
import 'package:webapp/core/constants/app_constants.dart';
import 'package:webapp/features/dashboard/tabs/configurator_canvas_tab.dart';
import 'package:webapp/features/dashboard/tabs/home_configurator_tab.dart';
import 'package:webapp/features/dashboard/tabs/profile_settings_tab.dart';

/// Authenticated shell with persistent bottom navigation.
class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _currentIndex = 0;

  static const _tabs = [
    HomeConfiguratorTab(),
    ConfiguratorCanvasTab(),
    ProfileSettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > AppConstants.maxDashboardWidth
            ? AppConstants.maxDashboardWidth
            : constraints.maxWidth;

        return Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: maxWidth,
              child: IndexedStack(
                index: _currentIndex,
                children: _tabs,
              ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Canvas',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
