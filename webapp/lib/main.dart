import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webapp/app.dart';
import 'package:webapp/core/config/app_config.dart';
import 'package:webapp/core/services/auth_callback_handler.dart';
import 'package:webapp/core/services/preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PreferencesService.init();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Web: parse #access_token / ?code from reset-password & OAuth redirects.
  await AuthCallbackHandler.handleInitialCallback();

  runApp(const WebApp());
}
