import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webapp/core/utils/auth_redirect_urls.dart';
import 'package:webapp/core/utils/auth_error_messages.dart';
import 'package:webapp/core/utils/snackbar_utils.dart';

/// Google and Apple OAuth sign-in buttons pinned at the bottom.
class SocialAuthButtons extends StatefulWidget {
  const SocialAuthButtons({super.key});

  @override
  State<SocialAuthButtons> createState() => _SocialAuthButtonsState();
}

class _SocialAuthButtonsState extends State<SocialAuthButtons> {
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  Future<void> _signInWithOAuth(OAuthProvider provider) async {
    final isGoogle = provider == OAuthProvider.google;
    setState(() {
      if (isGoogle) {
        _isGoogleLoading = true;
      } else {
        _isAppleLoading = true;
      }
    });

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: AuthRedirectUrls.oauthRedirect(),
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      SnackbarUtils.showError(
        context,
        AuthErrorMessages.fromAuthException(error),
      );
    } catch (_) {
      if (!mounted) return;
      SnackbarUtils.showError(
        context,
        'OAuth sign-in failed. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
          _isAppleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or continue with',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            // TEMPORARY: Google sign-in hidden.
            // Expanded(
            //   child: _SocialButton(
            //     label: 'Google',
            //     icon: Icons.g_mobiledata_rounded,
            //     iconColor: const Color(0xFF4285F4),
            //     isLoading: _isGoogleLoading,
            //     onPressed: _isGoogleLoading || _isAppleLoading
            //         ? null
            //         : () => _signInWithOAuth(OAuthProvider.google),
            //   ),
            // ),
            // const SizedBox(width: 12),
            Expanded(
              child: _SocialButton(
                label: 'Apple',
                icon: Icons.apple,
                iconColor: Colors.black,
                isLoading: _isAppleLoading,
                onPressed: _isGoogleLoading || _isAppleLoading
                    ? null
                    : () => _signInWithOAuth(OAuthProvider.apple),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: iconColor, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
