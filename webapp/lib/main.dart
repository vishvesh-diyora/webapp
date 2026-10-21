import 'package:flutter/material.dart';
import 'package:webapp/app.dart';
import 'package:webapp/core/config/env_config.dart';
import 'package:webapp/core/services/preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.load();
  await PreferencesService.init();

  runApp(const WebApp());
}
