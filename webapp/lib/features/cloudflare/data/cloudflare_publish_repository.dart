import 'package:flutter/foundation.dart';
import 'package:webapp/core/config/cloudflare_config.dart';
import 'package:webapp/features/cloudflare/data/cloudflare_service.dart';
import 'package:webapp/features/cloudflare/domain/entities/website_deployment_info.dart';
import 'package:webapp/features/cloudflare/domain/publish_username_check_result.dart';
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

/// Saves website JSON locally and deploys a static site to Cloudflare Pages.
class CloudflarePublishRepository {
  CloudflarePublishRepository({
    required WebsiteRepository websiteRepository,
    CloudflareService? cloudflareService,
    StaticSiteGenerator? generator,
  })  : _websiteRepository = websiteRepository,
        _cloudflareService = cloudflareService ?? CloudflareService(),
        _generator = generator ?? const StaticSiteGenerator();

  final WebsiteRepository _websiteRepository;
  final CloudflareService _cloudflareService;
  final StaticSiteGenerator _generator;

  Future<PublishUsernameCheckResult> checkUsernameAvailability({
    required String username,
    String? excludeWebsiteId,
    String? ownedProjectName,
  }) async {
    try {
      final projectName = normalizeUsername(username);
      final validationError = PublishUsername.validate(projectName);
      if (validationError != null) {
        return PublishUsernameCheckResult(
          isAvailable: false,
          message: validationError,
        );
      }

      if (ownedProjectName != null &&
          normalizeUsername(ownedProjectName) == projectName) {
        return const PublishUsernameCheckResult(isAvailable: true);
      }

      if (!CloudflareConfig.isConfigured) {
        return const PublishUsernameCheckResult(
          isAvailable: false,
          message:
              'Cloudflare is not configured. Add CLOUDFLARE_ACCOUNT_ID and '
              'CLOUDFLARE_API_TOKEN to your .env file.',
        );
      }

      if (!kIsWeb) {
        final cloudflareCheck = await _checkCloudflareUsername(projectName);
        if (cloudflareCheck != null) {
          return cloudflareCheck;
        }
      }

      final reservedInApp = await _websiteRepository.isPublishUsernameAvailable(
        projectName,
        excludeWebsiteId: excludeWebsiteId,
      );
      if (!reservedInApp) {
        return PublishUsernameCheckResult(
          isAvailable: false,
          message:
              '${CloudflareConfig.pagesUrlForUsername(projectName)} is already taken. Choose another username.',
        );
      }

      return const PublishUsernameCheckResult(isAvailable: true);
    } on StateError catch (error) {
      return PublishUsernameCheckResult(
        isAvailable: false,
        message: error.message,
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('checkUsernameAvailability failed: $error');
      }
      return PublishUsernameCheckResult(
        isAvailable: false,
        message: 'Could not verify username. Try again.',
      );
    }
  }

  Future<PublishUsernameCheckResult?> _checkCloudflareUsername(
    String projectName,
  ) async {
    try {
      final takenOnCloudflare = await _cloudflareService.projectExists(
        accountId: CloudflareConfig.accountId,
        projectName: projectName,
        accessToken: CloudflareConfig.apiToken,
      );
      if (takenOnCloudflare) {
        return PublishUsernameCheckResult(
          isAvailable: false,
          message:
              '${CloudflareConfig.pagesUrlForUsername(projectName)} is already taken on Cloudflare. Choose another username.',
        );
      }
      return null;
    } on CloudflareApiException catch (error) {
      return PublishUsernameCheckResult(
        isAvailable: false,
        message: error.message,
      );
    }
  }

  Future<CloudflarePublishResult> publish({
    required WebsiteDocument document,
    required String username,
    PublishProgressCallback? onProgress,
  }) async {
    CloudflareConfig.assertConfigured();

    final projectName = normalizeUsername(username);
    final availability = await checkUsernameAvailability(
      username: projectName,
      excludeWebsiteId: document.id,
      ownedProjectName: document.deployment?.projectName,
    );
    if (!availability.isAvailable) {
      throw CloudflareApiException(
        availability.message ?? 'That username is not available.',
      );
    }

    onProgress?.call('Saving website', 0.02);
    final saved = await _websiteRepository.saveWebsite(document);

    final isRepublish =
        saved.deployment?.projectName == projectName && saved.deployment != null;

    final deployment = WebsiteDeploymentInfo(
      publishedUrl: CloudflareConfig.pagesUrlForUsername(projectName),
      projectName: projectName,
      projectId: saved.deployment?.projectId ?? '',
      deploymentId: saved.deployment?.deploymentId ?? '',
      accountId: CloudflareConfig.accountId,
      updatedAt: DateTime.now(),
    );

    if (isRepublish) {
      onProgress?.call('Updating live site', 0.5);
      final updated = await _websiteRepository.saveWebsite(
        saved.copyWith(deployment: deployment),
      );
      onProgress?.call('Done', 1.0);
      return CloudflarePublishResult(
        document: updated,
        deployment: deployment,
        outputPath: projectName,
      );
    }

    onProgress?.call('Generating static site', 0.08);
    final bundle = await _generator.buildSiteFiles(saved);

    onProgress?.call('Deploying to Cloudflare', 0.12);
    WebsiteDeploymentInfo finalDeployment;
    try {
      await _cloudflareService.ensureProject(
        accountId: CloudflareConfig.accountId,
        projectName: projectName,
        accessToken: CloudflareConfig.apiToken,
      );

      final deployed = await _cloudflareService.deployFiles(
        accountId: CloudflareConfig.accountId,
        projectName: projectName,
        files: bundle.files,
        accessToken: CloudflareConfig.apiToken,
        onProgress: (stage, progress) {
          onProgress?.call(stage, 0.12 + progress * 0.84);
        },
      );

      finalDeployment = deployment.copyWith(
        projectId: deployed.projectId,
        deploymentId: deployed.deploymentId,
      );
    } catch (error) {
      if (kIsWeb) {
        throw CloudflareApiException(
          'Website JSON was saved, but Cloudflare deploy from the browser is blocked. '
          'Run the app on desktop once to finish first publish: flutter run -d macos',
        );
      }
      rethrow;
    }

    onProgress?.call('Saving deployment info', 0.98);
    final updated = await _websiteRepository.saveWebsite(
      saved.copyWith(deployment: finalDeployment),
    );

    onProgress?.call('Done', 1.0);

    return CloudflarePublishResult(
      document: updated,
      deployment: finalDeployment,
      outputPath: projectName,
    );
  }
}
