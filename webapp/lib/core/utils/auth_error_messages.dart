import 'package:supabase_flutter/supabase_flutter.dart';

/// User-friendly messages for Supabase Auth errors.
class AuthErrorMessages {
  AuthErrorMessages._();

  static const String _generic =
      'Something went wrong. Please try again in a moment.';
  static const String _invalidCredentials =
      'The email or password you entered is incorrect. Please check and try again.';
  static const String _networkIssue =
      'We couldn\'t reach the server. Check your connection and try again.';

  static String fromAuthException(AuthException error) {
    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();

    // Match by error code first (most reliable).
    switch (code) {
      case 'invalid_credentials':
      case 'invalid_login_credentials':
        return _invalidCredentials;
      case 'email_not_confirmed':
        return _emailNotConfirmed;
      case 'user_already_registered':
      case 'email_exists':
        return 'An account with this email already exists. Try signing in instead.';
      case 'weak_password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'over_request_rate_limit':
      case 'too_many_requests':
        return _rateLimitMessage(error.message);
      case 'signup_disabled':
        return 'New signups are temporarily unavailable. Please try again later.';
      case 'user_not_found':
        return 'No account found with this email. Check the address or sign up.';
      case 'session_expired':
      case 'refresh_token_not_found':
        return 'Your session has expired. Please sign in again.';
      case 'validation_failed':
        return 'Please check your details and try again.';
    }

    // Match by message text (fallback).
    if (_isRateLimited(message)) {
      return _rateLimitMessage(error.message);
    }

    if (_isInvalidCredentials(message)) {
      return _invalidCredentials;
    }

    if (message.contains('email not confirmed')) {
      return _emailNotConfirmed;
    }

    if (message.contains('user already registered') ||
        message.contains('already been registered') ||
        message.contains('email address is already')) {
      return 'An account with this email already exists. Try signing in instead.';
    }

    if (message.contains('password') && message.contains('weak')) {
      return 'Password is too weak. Use at least 6 characters.';
    }

    if (message.contains('user not found')) {
      return 'No account found with this email. Check the address or sign up.';
    }

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('socket')) {
      return _networkIssue;
    }

    if (message.contains('invalid email') || message.contains('malformed')) {
      return 'Please enter a valid email address.';
    }

    // Never expose raw Supabase/GoTrue messages to users.
    return _generic;
  }

  static const String _emailNotConfirmed =
      'Your email is not verified yet. Check your inbox or contact support.';

  static bool _isInvalidCredentials(String message) {
    return message.contains('invalid login credentials') ||
        message.contains('invalid credentials') ||
        message.contains('invalid login') ||
        message.contains('wrong password') ||
        message.contains('incorrect password') ||
        message.contains('email or password');
  }

  static bool _isRateLimited(String message) {
    return message.contains('security purposes') ||
        message.contains('only request this after') ||
        message.contains('rate limit') ||
        message.contains('too many requests');
  }

  static String _rateLimitMessage(String originalMessage) {
    final seconds = _extractWaitSeconds(originalMessage);
    if (seconds != null) {
      return 'Too many attempts. Please wait $seconds seconds and try again.';
    }
    return 'Too many attempts. Please wait about 60 seconds and try again.';
  }

  static int? _extractWaitSeconds(String message) {
    final match = RegExp(r'after (\d+) seconds?', caseSensitive: false)
        .firstMatch(message);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }
}
