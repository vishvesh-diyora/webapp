import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webapp/core/constants/app_constants.dart';
import 'package:webapp/features/cloudflare/data/cloudflare_oauth_service.dart';
import 'package:webapp/features/cloudflare/data/cloudflare_publish_repository.dart';
import 'package:webapp/features/cloudflare/data/cloudflare_service.dart';
import 'package:webapp/features/cloudflare/presentation/bloc/cloudflare_bloc.dart';
import 'package:webapp/features/dashboard/tabs/home_configurator_tab.dart';
import 'package:webapp/features/website/data/repositories/website_repository_impl.dart';
import 'package:webapp/features/website/domain/repositories/website_repository.dart';
import 'package:webapp/features/website/presentation/bloc/my_websites_bloc.dart';
import 'package:webapp/features/website/presentation/screens/my_websites_screen.dart';
import 'package:webapp/features/dashboard/tabs/profile_settings_tab.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > AppConstants.maxDashboardWidth
            ? AppConstants.maxDashboardWidth
            : constraints.maxWidth;

        return Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: maxWidth,
              child: IndexedStack(
                index: _currentIndex,
                children: const [
                  HomeConfiguratorTab(),
                  MyWebsitesScreen(),
                ],
              ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline),
                selectedIcon: Icon(Icons.add_circle),
                label: 'Create Website',
              ),
              NavigationDestination(
                icon: Icon(Icons.web_asset_outlined),
                selectedIcon: Icon(Icons.web_asset),
                label: 'My Websites',
              ),
            ],
          ),
          floatingActionButton: _currentIndex == 0
              ? null
              : FloatingActionButton.small(
                  onPressed: () => _openProfile(context),
                  child: const Icon(Icons.person_outline),
                ),
        );
      },
    );
  }

  void _openProfile(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SizedBox(
        height: 420,
        child: ProfileSettingsTab(),
      ),
    );
  }
}

class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final repository = WebsiteRepositoryImpl(client);
    final oauthService = CloudflareOAuthService();
    final cloudflareService = CloudflareService();
    final publishRepository = CloudflarePublishRepository(
      websiteRepository: repository,
      oauthService: oauthService,
      cloudflareService: cloudflareService,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WebsiteRepository>.value(value: repository),
        RepositoryProvider<CloudflareOAuthService>.value(value: oauthService),
        RepositoryProvider<CloudflareService>.value(value: cloudflareService),
        RepositoryProvider<CloudflarePublishRepository>.value(value: publishRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => MyWebsitesBloc(repository: repository),
          ),
          BlocProvider(
            create: (context) => CloudflareBloc(
              publishRepository: publishRepository,
              oauthService: oauthService,
              websiteRepository: repository,
            )..add(const CloudflareStarted()),
          ),
        ],
        child: child,
      ),
    );
  }
}
