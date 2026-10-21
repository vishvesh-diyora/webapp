import 'package:flutter/material.dart';
import 'package:webapp/core/services/preferences_service.dart';
import 'package:webapp/features/dashboard/dashboard_shell.dart';
import 'package:webapp/features/onboarding/onboarding_screen.dart';

/// Resolves the initial route from persisted onboarding flag.
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  bool _showOnboarding = PreferencesService.isFirstInstall;

  void _onOnboardingComplete() {
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _showOnboarding
          ? OnboardingScreen(
              key: const ValueKey('onboarding'),
              onComplete: _onOnboardingComplete,
            )
          : const DashboardShell(
              key: ValueKey('dashboard'),
            ),
    );
  }
}
