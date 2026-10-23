import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webapp/export_site_data.dart';
import 'package:webapp/features/dashboard/widgets/category_template_preview_content.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_screen_background.dart';
import 'package:webapp/features/templates/preview/template_preview_image_resolver.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

/// Hosted static site entry — same widgets as in-app template preview.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _ExportViewerBootstrap());
}

class _ExportViewerBootstrap extends StatefulWidget {
  const _ExportViewerBootstrap();

  @override
  State<_ExportViewerBootstrap> createState() => _ExportViewerBootstrapState();
}

class _ExportViewerBootstrapState extends State<_ExportViewerBootstrap> {
  WebsiteDocument? _document;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      Map<String, dynamic>? json = readInlineExportSiteData();
      if (json == null) {
        final uri = Uri.base.resolve('site.json');
        final response = await http.get(uri);
        if (response.statusCode != 200) {
          throw StateError('HTTP ${response.statusCode}');
        }
        json = jsonDecode(response.body) as Map<String, dynamic>;
      }
      final doc = WebsiteDocument.fromJson(json);
      setState(() {
        _document = TemplatePreviewImageResolver.documentWithPreviewImages(doc);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load site.json.\n$_error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }
    if (_document == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return _ExportViewerApp(document: _document!);
  }
}

class _ExportViewerApp extends StatelessWidget {
  const _ExportViewerApp({required this.document});

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
