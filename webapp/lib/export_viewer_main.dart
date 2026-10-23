import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:webapp/features/export_admin/export_admin_editor_screen.dart';
import 'package:webapp/features/export_admin/export_admin_login_screen.dart';
import 'package:webapp/features/export_admin/export_admin_session.dart';
import 'package:webapp/features/export_admin/export_runtime_config.dart';
import 'package:webapp/features/export_admin/export_site_loader.dart';
import 'package:webapp/features/dashboard/widgets/category_template_preview_content.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_screen_background.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(const ExportHostedApp());
}

class ExportHostedApp extends StatefulWidget {
  const ExportHostedApp();

  @override
  State<ExportHostedApp> createState() => _ExportHostedAppState();
}

class _ExportHostedAppState extends State<ExportHostedApp> {
  ExportRuntimeConfig? _config;
  WebsiteDocument? _document;
  String? _error;
  bool _adminMode = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final config = await loadRuntimeConfig();
      final doc = await loadSiteDocument(config);
      final path = Uri.base.path;
      final admin = path.contains('/admin');
      if (!mounted) return;
      setState(() {
        _config = config;
        _document = doc;
        _adminMode = admin;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _reloadSite() async {
    final config = _config ?? ExportRuntimeConfig.deployDefaults;
    final doc = await loadSiteDocument(config);
    if (mounted) setState(() => _document = doc);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Failed to load site.\n$_error')),
        ),
      );
    }
    if (_config == null || _document == null) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    if (_adminMode) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: exportAdminIsLoggedIn()
            ? ExportAdminEditorScreen(
                config: _config!,
                initialDocument: _document!,
                onSaved: (doc) {
                  setState(() => _document = doc);
                  _reloadSite();
                },
              )
            : ExportAdminLoginScreen(
                config: _config!,
                onLoggedIn: () => setState(() {}),
              ),
      );
    }

    return _PublicSiteApp(document: _document!);
  }
}

class _PublicSiteApp extends StatelessWidget {
  const _PublicSiteApp({required this.document});

  final WebsiteDocument document;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: document.name,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
      ),
      home: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final compact = width < 600;
          final mobileProfileLayout = width < 900;
          final screenBg = PreviewScreenBackground.forTemplate(
            document,
            mobileProfileLayout: mobileProfileLayout,
          );

          return Scaffold(
            backgroundColor: screenBg.color ?? const Color(0xFFF8FAFC),
            body: DecoratedBox(
              decoration: screenBg.decoration ?? BoxDecoration(color: screenBg.color),
              child: CategoryTemplatePreviewContent(
                document: document,
                compact: compact,
                mobileProfileLayout: mobileProfileLayout,
              ),
            ),
          );
        },
      ),
    );
  }
}
