import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webapp/features/cloudflare/data/cloudflare_oauth_service.dart';
import 'package:webapp/features/cloudflare/data/cloudflare_service.dart';
import 'package:webapp/features/cloudflare/domain/entities/cloudflare_tokens.dart';
import 'package:webapp/features/cloudflare/domain/entities/website_deployment_info.dart';
import 'package:webapp/features/generator/static_site_generator.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';
import 'package:webapp/features/website/domain/repositories/website_repository.dart';

class CloudflarePublishResult {
  const CloudflarePublishResult({
    required this.document,
    required this.deployment,
    required this.outputPath,
  });

  final WebsiteDocument document;
  final WebsiteDeploymentInfo deployment;
  final String outputPath;
}

typedef PublishProgressCallback = void Function(String stage, double progress);

/// Generates static files and deploys them to Cloudflare Pages.
class CloudflarePublishRepository {
  CloudflarePublishRepository({
    required WebsiteRepository websiteRepository,
    CloudflareOAuthService? oauthService,
    CloudflareService? cloudflareService,
    StaticSiteGenerator? generator,
  })  : _websiteRepository = websiteRepository,
        _oauthService = oauthService ?? CloudflareOAuthService(),
        _cloudflareService = cloudflareService ?? CloudflareService(),
        _generator = generator ?? const StaticSiteGenerator();

  static const _pendingWebsiteIdKey = 'cf_pending_publish_website_id';

  final WebsiteRepository _websiteRepository;
  final CloudflareOAuthService _oauthService;
  final CloudflareService _cloudflareService;
  final StaticSiteGenerator _generator;

  Future<bool> isCloudflareConnected() => _oauthService.isConnected();

  Future<void> markPendingPublish(String websiteId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingWebsiteIdKey, websiteId);
  }

  Future<String?> takePendingPublishWebsiteId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_pendingWebsiteIdKey);
    if (id != null) {
      await prefs.remove(_pendingWebsiteIdKey);
    }
    return id;
  }

  Future<CloudflarePublishResult> publish({
    required WebsiteDocument document,
    PublishProgressCallback? onProgress,
  }) async {
    onProgress?.call('Saving website', 0.02);
    final saved = await _websiteRepository.saveWebsite(document);

    onProgress?.call('Generating static site', 0.08);
    final root = await getApplicationDocumentsDirectory();
    final projectSeed = saved.deployment?.projectName ?? _defaultProjectName(saved);
    final outputDir = p.join(root.path, 'published_sites', projectSeed);

    final generated = await _generator.generate(
      document: saved,
      outputDirectory: outputDir,
    );

    final tokens = await _oauthService.getValidAccessToken();
    final accountId = await _resolveAccountId(tokens);

    final projectName =
        saved.deployment?.projectName ?? CloudflareService.slugProjectName(projectSeed);

    onProgress?.call('Ensuring Cloudflare Pages project', 0.1);
    await _cloudflareService.ensureProject(
      accountId: accountId,
      projectName: projectName,
      accessToken: tokens.accessToken,
    );

    final deployed = await _cloudflareService.deployDirectory(
      accountId: accountId,
      projectName: projectName,
      siteDirectory: generated.outputPath,
      accessToken: tokens.accessToken,
      onProgress: (stage, progress) {
        onProgress?.call(stage, 0.1 + progress * 0.88);
      },
    );

    final deployment = WebsiteDeploymentInfo(
      publishedUrl: deployed.url,
      projectName: deployed.projectName,
      projectId: deployed.projectId,
      deploymentId: deployed.deploymentId,
      accountId: deployed.accountId,
      updatedAt: DateTime.now(),
    );

    onProgress?.call('Saving deployment info', 0.98);
    final updated = await _websiteRepository.saveWebsite(
      saved.copyWith(deployment: deployment),
    );

    onProgress?.call('Done', 1.0);

    return CloudflarePublishResult(
      document: updated,
      deployment: deployment,
      outputPath: generated.outputPath,
    );
  }

  Future<String> _resolveAccountId(CloudflareTokens tokens) async {
    if (tokens.accountId != null && tokens.accountId!.isNotEmpty) {
      return tokens.accountId!;
    }

    final accounts = await _cloudflareService.listAccounts(tokens.accessToken);
    if (accounts.isEmpty) {
      throw CloudflareApiException('No Cloudflare accounts found for this user.');
    }

    final accountId = accounts.first.id;
    await _oauthService.updateStoredAccountId(accountId);
    return accountId;
  }

  String _defaultProjectName(WebsiteDocument document) {
    if (document.id != null && document.id!.isNotEmpty) {
      final id = document.id!.replaceAll('-', '');
      final short = id.length >= 8 ? id.substring(0, 8) : id;
      return 'wb-$short';
    }
    return CloudflareService.slugProjectName(document.name);
  }
}
