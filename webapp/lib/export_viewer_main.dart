import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:webapp/features/export_admin/export_admin_editor_screen.dart';
import 'package:webapp/features/export_admin/export_admin_login_screen.dart';
import 'package:webapp/features/export_admin/export_admin_session.dart';
import 'package:webapp/features/export_admin/export_runtime_config.dart';
import 'package:webapp/features/export_admin/export_site_loader.dart';
import 'package:webapp/features/export_admin/export_viewer_browser_path.dart';
import 'package:webapp/features/export_admin/export_viewer_config_load_result.dart';
import 'package:webapp/features/dashboard/widgets/category_template_preview_content.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_screen_background.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final startOnAdmin = exportViewerIsAdminPath();
  exportViewerPinAdminPathIfNeeded(startOnAdmin);
  runApp(ExportHostedApp(startOnAdmin: startOnAdmin));
}

/// Downloaded / hosted website only (not the Flutter builder app).
class ExportHostedApp extends StatefulWidget {
  const ExportHostedApp({super.key, required this.startOnAdmin});

  final bool startOnAdmin;

  @override
  State<ExportHostedApp> createState() => _ExportHostedAppState();
}

class _ExportHostedAppState extends State<ExportHostedApp> {
  ExportViewerConfigLoadResult? _configLoad;
  WebsiteDocument? _document;
  String? _siteLoadError;

  bool get _onAdminRoute => widget.startOnAdmin || exportViewerIsAdminPath();

  @override
  void initState() {
    super.initState();
    exportViewerPinAdminPathIfNeeded(widget.startOnAdmin);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final configLoad = await loadExportViewerConfig();
    if (!mounted) return;
    setState(() => _configLoad = configLoad);

    try {
      final doc = await loadSiteDocument(configLoad.config);
      if (!mounted) return;
      setState(() {
        _document = doc;
        _siteLoadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _siteLoadError = e.toString());
    }

    exportViewerPinAdminPathIfNeeded(_onAdminRoute);
  }

  Future<void> _reloadSite() async {
    final config = _configLoad?.config ?? ExportRuntimeConfig.deployDefaults;
    try {
      final doc = await loadSiteDocument(config);
      if (mounted) {
        setState(() {
          _document = doc;
          _siteLoadError = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _siteLoadError = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    exportViewerPinAdminPathIfNeeded(_onAdminRoute);

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
    );

    if (_onAdminRoute) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: _buildAdminShell(),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      title: _document?.name ?? 'Website',
      home: _buildPublicBody(),
    );
  }

  Widget _buildAdminShell() {
    if (_configLoad == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (exportAdminIsLoggedIn()) {
      if (_document == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Admin')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _siteLoadError != null
                    ? 'Could not load site data for editing:\n$_siteLoadError'
                    : 'Loading site data…',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }
      return ExportAdminEditorScreen(
        config: _configLoad!.config,
        initialDocument: _document!,
        onSaved: (doc) {
          setState(() => _document = doc);
          _reloadSite();
        },
      );
    }

    return ExportAdminLoginScreen(
      loadResult: _configLoad!,
      onLoggedIn: () => setState(() {}),
    );
  }

  Widget _buildPublicBody() {
    if (_document == null) {
      if (_siteLoadError != null) {
        return Scaffold(
          body: Center(child: Text('Failed to load site.\n$_siteLoadError')),
        );
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _PublicSiteShell(document: _document!);
  }
}

class _PublicSiteShell extends StatelessWidget {
  const _PublicSiteShell({required this.document});

  final WebsiteDocument document;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
    );
  }
}
