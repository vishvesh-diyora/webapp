/// Central application configuration.
///
/// Update [supabaseUrl] and [supabaseAnonKey] with your Supabase project
/// credentials, then run the app with a plain `flutter run` command.
class AppConfig {
  AppConfig._();

  // ── Supabase ──────────────────────────────────────────────────────────────
  // Dashboard → Project Settings → API
  //
  // Auth providers (all free tier):
  //   • Email / Password  — turn OFF "Confirm email" in Auth → Providers → Email
  //   • Google OAuth
  //   • Apple OAuth
  //
  // Instant signup (no verify-email step):
  //   1. Supabase → Auth → Providers → Email → disable "Confirm email"
  //   2. Run SQL: supabase/migrations/002_auto_confirm_email.sql
  //
  // Forgot password uses resetPasswordForEmail (free).
  // Run SQL migration: supabase/migrations/001_check_email_exists.sql
  //
  // Supabase Dashboard → Auth → URL Configuration → Redirect URLs:
  //   Web (dev):  http://localhost:<port>   (auto-detected at runtime)
  //   Web (prod): set [webRedirectUrl] below, e.g. https://yourdomain.com
  //   Mobile:     io.supabase.webapp://login-callback
  //
  // Site URL (Auth → URL Configuration): set to your production web URL.

  static const String supabaseUrl = 'https://lxkqtjgpblqqydgkqjmj.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4a3F0amdwYmxxcXlkZ2txam1qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQyMTE3NjAsImV4cCI6MjA5OTc4Nzc2MH0.IoZ6dKbnc2Rkonyb_2Q4zRfwKleT3SU8aXbD2c5sJng';

  /// Production web callback URL. Leave empty to auto-detect from the browser.
  /// Example: 'https://yourdomain.com'
  static const String webRedirectUrl = '';

  /// Deep link for mobile password-reset and OAuth callbacks.
  static const String mobileRedirectUrl = 'io.supabase.webapp://login-callback';

  // ── App ───────────────────────────────────────────────────────────────────

  static const String appName = 'WebApp Configurator';

  /// When `true`, users must sign in before using the app.
  /// When `false`, the app opens directly and login is available from Profile.
  static const bool isLoginSignupMandatory = false;
}
