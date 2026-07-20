import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webapp/core/services/password_reset_service.dart';
import 'package:webapp/core/utils/auth_error_messages.dart';
import 'package:webapp/core/utils/email_validator.dart';
import 'package:webapp/core/utils/snackbar_utils.dart';
import 'package:webapp/core/widgets/loading_button.dart';

/// Forgot-password: verify email exists, then send a free reset link.
class ForgotPasswordOverlay extends StatefulWidget {
  const ForgotPasswordOverlay({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<ForgotPasswordOverlay> createState() => _ForgotPasswordOverlayState();
}

class _ForgotPasswordOverlayState extends State<ForgotPasswordOverlay> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordResetService = PasswordResetService();

  bool _isLoading = false;
  bool _emailSent = false;
  bool _lookupWasUnavailable = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final lookup = await _passwordResetService.lookupEmail(email);

      if (lookup == EmailLookupResult.notFound) {
        if (!mounted) return;
        SnackbarUtils.showError(
          context,
          'No account found with this email address.',
        );
        return;
      }

      await _passwordResetService.sendResetLink(email);
      if (!mounted) return;

      setState(() {
        _emailSent = true;
        _lookupWasUnavailable = lookup == EmailLookupResult.lookupUnavailable;
      });
      SnackbarUtils.showSuccess(
        context,
        lookup == EmailLookupResult.lookupUnavailable
            ? 'If an account exists, a reset link was sent to your inbox.'
            : 'Reset link sent. Check your inbox.',
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      SnackbarUtils.showError(
        context,
        AuthErrorMessages.fromAuthException(error),
      );
    } on PostgrestException {
      if (!mounted) return;
      SnackbarUtils.showError(
        context,
        'We couldn\'t verify that email right now. Please try again.',
      );
    } catch (_) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: _emailSent ? _buildSuccessView() : _buildEmailForm(),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          const Text(
            'Enter your email. If an account exists, we\'ll send a link to reset your password.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: EmailValidator.validate,
          ),
          const SizedBox(height: 24),
          LoadingButton(
            label: 'Send Reset Link',
            isLoading: _isLoading,
            onPressed: _sendResetLink,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        Icon(
          Icons.mark_email_read_outlined,
          size: 56,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        const Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _emailSent && _lookupWasUnavailable
              ? 'If an account exists for ${_emailController.text.trim()}, '
                  'we sent a password reset link. Open the link to set a new password.'
              : 'We sent a password reset link to ${_emailController.text.trim()}. '
                  'Open the link to set a new password.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 24),
        LoadingButton(
          label: 'Done',
          onPressed: widget.onClose,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Reset Password',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: widget.onClose,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}
