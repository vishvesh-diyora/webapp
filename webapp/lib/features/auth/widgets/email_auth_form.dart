import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webapp/core/utils/auth_error_messages.dart';
import 'package:webapp/core/utils/email_validator.dart';
import 'package:webapp/core/utils/snackbar_utils.dart';
import 'package:webapp/core/widgets/loading_button.dart';
import 'package:webapp/features/auth/widgets/forgot_password_overlay.dart';
import 'package:webapp/features/auth/widgets/terms_acceptance_row.dart';

enum EmailAuthMode { login, signup }

/// Email/password login, signup, and forgot-password flows.
class EmailAuthForm extends StatefulWidget {
  const EmailAuthForm({super.key});

  @override
  State<EmailAuthForm> createState() => _EmailAuthFormState();
}

class _EmailAuthFormState extends State<EmailAuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  EmailAuthMode _mode = EmailAuthMode.login;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _showForgotPassword = false;
  bool _acceptedTerms = false;

  SupabaseClient get _supabase => Supabase.instance.client;

  bool get _isSignup => _mode == EmailAuthMode.signup;

  bool get _canSubmit {
    if (_isLoading || !_acceptedTerms) return false;

    final emailValid = EmailValidator.validate(_emailController.text) == null;
    final password = _passwordController.text;
    if (!emailValid || password.length < 6) return false;

    if (_isSignup) {
      return _confirmPasswordController.text == password;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
    _confirmPasswordController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFormChanged);
    _passwordController.removeListener(_onFormChanged);
    _confirmPasswordController.removeListener(_onFormChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    if (!_acceptedTerms) {
      SnackbarUtils.showError(
        context,
        'Please accept the Terms & Conditions and Privacy Policy to continue.',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_mode == EmailAuthMode.login) {
        await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (!mounted) return;
        SnackbarUtils.showSuccess(context, 'Welcome back!');
      } else {
        await _signUpAndEnter(email, password);
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      SnackbarUtils.showError(
        context,
        AuthErrorMessages.fromAuthException(error),
      );
    } catch (error) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpAndEnter(String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.session != null) {
      if (!mounted) return;
      SnackbarUtils.showSuccess(context, 'Welcome! Your account is ready.');
      return;
    }

    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (!mounted) return;
    SnackbarUtils.showSuccess(context, 'Welcome! Your account is ready.');
  }

  void _toggleMode() {
    setState(() {
      _mode = _isSignup ? EmailAuthMode.login : EmailAuthMode.signup;
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: EmailValidator.validate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                autofillHints: _isSignup
                    ? const [AutofillHints.newPassword]
                    : const [AutofillHints.password],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              if (_isSignup) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  autofillHints: const [AutofillHints.newPassword],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
              if (!_isSignup) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => setState(() => _showForgotPassword = true),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ] else
                const SizedBox(height: 4),
              const SizedBox(height: 8),
              TermsAcceptanceRow(
                value: _acceptedTerms,
                onChanged: (accepted) =>
                    setState(() => _acceptedTerms = accepted),
              ),
              const SizedBox(height: 12),
              LoadingButton(
                label: _isSignup ? 'Create Account' : 'Sign In',
                isLoading: _isLoading,
                onPressed: (_canSubmit && !_isLoading) ? _submit : null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isSignup
                        ? 'Already have an account?'
                        : "Don't have an account?",
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _toggleMode,
                    child: Text(
                      _isSignup ? 'Sign In' : 'Sign Up',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_showForgotPassword)
          ForgotPasswordOverlay(
            onClose: () => setState(() => _showForgotPassword = false),
          ),
      ],
    );
  }
}
