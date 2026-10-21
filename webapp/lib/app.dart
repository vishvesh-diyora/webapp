import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webapp/core/config/app_config.dart';
import 'package:webapp/core/theme/app_theme.dart';
import 'package:webapp/core/utils/publish_subdomain.dart';
import 'package:webapp/features/dashboard/dashboard_shell.dart';
import 'package:webapp/features/published/published_site_screen.dart';
import 'package:webapp/features/routing/app_router.dart';
import 'package:webapp/features/website/domain/repositories/website_repository.dart';

class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          TextScaler scaler;
          try {
            scaler = mediaQuery.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.35,
            );
          } catch (_) {
            scaler = TextScaler.noScaling;
          }
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: scaler),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const _AppEntry(),
      ),
    );
  }
}

class _AppEntry extends StatelessWidget {
  const _AppEntry();

  @override
  Widget build(BuildContext context) {
    if (isPublishedSubdomainHost) {
      return PublishedSiteScreen(
        websiteRepository: context.read<WebsiteRepository>(),
      );
    }
    return const AppRouter();
  }
}
