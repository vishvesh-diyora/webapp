import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:webapp/core/services/preferences_service.dart';
import 'package:webapp/features/website/data/repositories/local_website_repository.dart';
import 'package:webapp/core/constants/app_constants.dart';
import 'package:webapp/features/cloudflare/data/cloudflare_publish_repository.dart';
import 'package:webapp/features/cloudflare/data/cloudflare_service.dart';
import 'package:webapp/features/cloudflare/presentation/bloc/cloudflare_bloc.dart';
import 'package:webapp/features/dashboard/tabs/home_configurator_tab.dart';
import 'package:webapp/features/website/domain/repositories/website_repository.dart';
import 'package:webapp/features/website/presentation/bloc/my_websites_bloc.dart';
import 'package:webapp/features/website/presentation/screens/my_websites_screen.dart';
import 'package:webapp/features/dashboard/tabs/profile_settings_tab.dart';
import 'package:webapp/features/dashboard/widgets/dashboard_bottom_nav.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  static const _tabCount = 3;
  static const _tabSwitchDuration = Duration(milliseconds: 320);

  int _currentIndex = 0;
  late final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: _tabSwitchDuration,
      curve: Curves.easeOutCubic,
    );
  }

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
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  if (index != _currentIndex) {
                    setState(() => _currentIndex = index);
                  }
                },
                children: const [
                  HomeConfiguratorTab(),
                  MyWebsitesScreen(),
                  ProfileSettingsTab(),
                ],
              ),
            ),
          ),
          bottomNavigationBar: ColoredBox(
            color: Colors.transparent,
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              child: DashboardBottomNav(
                currentIndex: _currentIndex,
                itemCount: _tabCount,
                onSelected: _onTabSelected,
              ),
            ),
          ),
        );
      },
    );
  }
}

class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final repository = LocalWebsiteRepository(PreferencesService.shared);
    final cloudflareService = CloudflareService();
    final publishRepository = CloudflarePublishRepository(
      websiteRepository: repository,
      cloudflareService: cloudflareService,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WebsiteRepository>.value(value: repository),
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
            ),
          ),
        ],
        child: child,
      ),
    );
  }
}
