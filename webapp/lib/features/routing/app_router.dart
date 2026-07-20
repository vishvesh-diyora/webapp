import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webapp/core/config/app_config.dart';
import 'package:webapp/core/services/auth_callback_handler.dart';
import 'package:webapp/core/services/preferences_service.dart';
import 'package:webapp/core/utils/auth_redirect_urls.dart';
import 'package:webapp/features/auth/auth_gate_screen.dart';
import 'package:webapp/features/auth/update_password_screen.dart';
import 'package:webapp/features/dashboard/dashboard_shell.dart';
import 'package:webapp/features/onboarding/onboarding_screen.dart';

/// Application route states driven by auth session and onboarding flag.
enum AppRoute { loading, onboarding, authGate, updatePassword, dashboard }

/// Resolves the initial route from persisted onboarding state.
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  late final Stream<AuthState> _authStream;
  StreamSubscription<AuthState>? _authSubscription;

  bool _showOnboarding = PreferencesService.isFirstInstall;
  bool _passwordRecovery = AuthRedirectUrls.isPasswordRecoveryUrl();
  bool _authReady = false;

  @override
  void initState() {
    super.initState();
    _authStream = Supabase.instance.client.auth.onAuthStateChange;
    _authSubscription = _authStream.listen(_onAuthStateChange);
    _bootstrapAuth();
  }

  Future<void> _bootstrapAuth() async {
    // Web callback may have already been parsed in main(); sync recovery state.
    if (AuthRedirectUrls.isPasswordRecoveryUrl()) {
      _passwordRecovery = true;
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && _passwordRecovery) {
      AuthCallbackHandler.markPasswordRecovery();
    }

    if (mounted) {
      setState(() => _authReady = true);
    }
  }

  void _onAuthStateChange(AuthState authState) {
    if (!mounted) return;

    switch (authState.event) {
      case AuthChangeEvent.passwordRecovery:
        AuthCallbackHandler.markPasswordRecovery();
        setState(() => _passwordRecovery = true);
      case AuthChangeEvent.signedOut:
        AuthCallbackHandler.clearPasswordRecovery();
        setState(() => _passwordRecovery = false);
      case AuthChangeEvent.signedIn:
        if (_passwordRecovery) {
          setState(() {});
        }
      default:
        if (authState.session == null && authState.event != AuthChangeEvent.initialSession) {
          AuthCallbackHandler.clearPasswordRecovery();
          setState(() => _passwordRecovery = false);
        }
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _onOnboardingComplete() {
    setState(() => _showOnboarding = false);
  }

  AppRoute _resolveRoute(Session? session) {
    if (session != null && _passwordRecovery) {
      return AppRoute.updatePassword;
    }
    if (session != null) return AppRoute.dashboard;
    if (_showOnboarding) return AppRoute.onboarding;
    if (AppConfig.isLoginSignupMandatory) return AppRoute.authGate;
    return AppRoute.dashboard;
  }

  @override
  Widget build(BuildContext context) {
    if (!_authReady) {
      return const _SplashView();
    }

    return StreamBuilder<AuthState>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _SplashView();
        }

        final route = _resolveRoute(snapshot.data!.session);

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: switch (route) {
            AppRoute.onboarding => OnboardingScreen(
                key: const ValueKey('onboarding'),
                onComplete: _onOnboardingComplete,
              ),
            AppRoute.authGate => const AuthGateScreen(
                key: ValueKey('auth_gate'),
              ),
            AppRoute.updatePassword => const UpdatePasswordScreen(
                key: ValueKey('update_password'),
              ),
            AppRoute.dashboard => const DashboardShell(
                key: ValueKey('dashboard'),
              ),
            AppRoute.loading => const _SplashView(),
          },
        );
      },
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
