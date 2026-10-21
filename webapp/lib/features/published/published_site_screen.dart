import 'package:flutter/material.dart';
import 'package:webapp/core/utils/publish_subdomain.dart';
import 'package:webapp/features/templates/preview/website_preview_renderer.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';
import 'package:webapp/features/website/domain/repositories/website_repository.dart';

/// Loads a published website saved on this device for the `{username}.pages.dev` host.
class PublishedSiteScreen extends StatefulWidget {
  const PublishedSiteScreen({
    super.key,
    required this.websiteRepository,
    this.username,
  });

  final WebsiteRepository websiteRepository;
  final String? username;

  @override
  State<PublishedSiteScreen> createState() => _PublishedSiteScreenState();
}

class _PublishedSiteScreenState extends State<PublishedSiteScreen> {
  late Future<WebsiteDocument?> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = widget.websiteRepository.fetchPublishedByUsername(
      widget.username ?? publishUsernameFromHost() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<WebsiteDocument?>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final document = snapshot.data;
          if (document == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Website not found',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No published site exists for this address yet.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          return WebsitePreviewRenderer(document: document);
        },
      ),
    );
  }
}
