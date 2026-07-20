import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webapp/core/widgets/responsive_center.dart';
import 'package:webapp/features/auth/widgets/email_auth_form.dart';
// TEMPORARY: Google & Apple hidden.
// import 'package:webapp/features/auth/widgets/social_auth_buttons.dart';

/// Primary authentication entry point with email/password and social sign-in.
class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key, this.modal = false});

  /// When `true`, opened from Profile — shows a back button and pops on sign-in.
  final bool modal;

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.modal) {
      _authSubscription =
          Supabase.instance.client.auth.onAuthStateChange.listen((authState) {
        if (authState.session != null && mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: widget.modal
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              _buildHeader(context),
              const SizedBox(height: 24),
              const Expanded(
                child: SingleChildScrollView(
                  child: EmailAuthForm(),
                ),
              ),
              // TEMPORARY: Google & Apple sign-in hidden.
              // const SocialAuthButtons(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.web_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sign in to continue building your web experience',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF64748B),
              ),
        ),
      ],
    );
  }
}
