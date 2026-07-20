import 'package:flutter/material.dart';
import 'package:webapp/core/config/app_config.dart';
import 'package:webapp/core/theme/app_theme.dart';
import 'package:webapp/features/routing/app_router.dart';

/// Root MaterialApp widget.
class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppRouter(),
    );
  }
}
