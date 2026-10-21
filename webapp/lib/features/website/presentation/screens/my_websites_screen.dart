import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webapp/core/domain/category_type.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';
import 'package:webapp/features/website/domain/repositories/website_repository.dart';
import 'package:webapp/features/website/presentation/bloc/my_websites_bloc.dart';
import 'package:webapp/features/website/presentation/bloc/website_editor_bloc.dart';
import 'package:webapp/features/website/presentation/screens/website_editor_screen.dart';

class MyWebsitesScreen extends StatelessWidget {
  const MyWebsitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyWebsitesBloc, MyWebsitesState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            context.read<MyWebsitesBloc>().add(const MyWebsitesRequested());
          },
          child: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(MyWebsitesState state) {
    if (state is MyWebsitesLoading) {
      return ListView(
        children: const [
          SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
        ],
      );
    }
    if (state is MyWebsitesFailure) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(state.message, textAlign: TextAlign.center),
          ),
        ],
      );
    }
    if (state is MyWebsitesReady) {
      if (state.websites.isEmpty) {
        return const _EmptyWebsitesPlaceholder();
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.websites.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _WebsiteTile(site: state.websites[index]),
      );
    }
    return const SizedBox.shrink();
  }
}

class _EmptyWebsitesPlaceholder extends StatelessWidget {
  const _EmptyWebsitesPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.maxWidth,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 168,
                      height: 168,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFFA855F7),
                            Color(0xFF0EA5E9),
                          ],
                          stops: [0.0, 0.45, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                          BoxShadow(
                            color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            right: 18,
                            top: 22,
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: 28,
                              color: Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                          Icon(
                            Icons.language_rounded,
                            size: 80,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'No websites yet',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Text(
                        'Create your first site from the Create tab, then it will show up here.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF64748B),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WebsiteTile extends StatelessWidget {
  const _WebsiteTile({required this.site});

  final WebsiteDocument site;

  @override
  Widget build(BuildContext context) {
    final publishedUrl = site.deployment?.publishedUrl;
    final hasLiveUrl = publishedUrl != null && publishedUrl.isNotEmpty;

    return Card(
      child: ListTile(
        title: Text(site.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${CategoryType.label(site.type)} · Template ${site.templateType}'),
            if (hasLiveUrl) ...[
              const SizedBox(height: 4),
              Text(
                publishedUrl,
                style: const TextStyle(color: Color(0xFF2563EB), fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasLiveUrl)
              IconButton(
                icon: const Icon(Icons.open_in_new_rounded, color: Color(0xFF2563EB)),
                tooltip: 'Open live site',
                onPressed: () async {
                  final uri = Uri.parse(publishedUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: site.id == null
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete website?'),
                          content: Text('Remove "${site.name}" permanently?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        context.read<MyWebsitesBloc>().add(MyWebsitesDeleted(site.id!));
                      }
                    },
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider(
                create: (_) => WebsiteEditorBloc(
                  repository: context.read<WebsiteRepository>(),
                )..add(WebsiteEditorStarted(site)),
                child: const WebsiteEditorScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}
