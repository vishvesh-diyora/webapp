import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webapp/core/utils/auth_redirect_urls.dart';

enum EmailLookupResult { exists, notFound, lookupUnavailable }

/// Handles forgot-password via Supabase's free reset-link email flow.
class PasswordResetService {
  PasswordResetService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Checks whether [email] is registered.
  ///
  /// Returns [EmailLookupResult.lookupUnavailable] when the Supabase SQL
  /// function has not been deployed yet — reset can still proceed.
  Future<EmailLookupResult> lookupEmail(String email) async {
    try {
      final result = await _client.rpc(
        'check_email_exists',
        params: {'user_email': email.trim()},
      );
      return result == true
          ? EmailLookupResult.exists
          : EmailLookupResult.notFound;
    } on PostgrestException catch (error) {
      if (_isLookupUnavailable(error)) {
        return EmailLookupResult.lookupUnavailable;
      }
      rethrow;
    }
  }

  bool _isLookupUnavailable(PostgrestException error) {
    final message = error.message.toLowerCase();
    return error.code == 'PGRST202' ||
        message.contains('check_email_exists') ||
        message.contains('could not find the function');
  }

  /// Sends a password reset link to [email] (free on Supabase).
  Future<void> sendResetLink(String email) async {
    await _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: AuthRedirectUrls.callback(),
    );
  }

  /// Sets a new password after the user opens the reset link from their email.
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
    await _client.auth.signOut();
  }
}
