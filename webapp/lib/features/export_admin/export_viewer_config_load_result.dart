import 'package:webapp/features/export_admin/export_remote_config_keys.dart';
import 'package:webapp/features/export_admin/export_runtime_config.dart';

/// Result of loading config for the downloaded / hosted website viewer.
class ExportViewerConfigLoadResult {
  const ExportViewerConfigLoadResult({
    required this.config,
    this.missingRemoteConfigKeys = const [],
    this.missingGithubKeys = const [],
    this.remoteConfigError,
    this.firebaseWebConfigMissing = true,
    this.usedFirebaseRemoteConfig = false,
  });

  final ExportRuntimeConfig config;
  final List<String> missingRemoteConfigKeys;
  final List<String> missingGithubKeys;
  final String? remoteConfigError;
  final bool firebaseWebConfigMissing;
  final bool usedFirebaseRemoteConfig;

  bool get canValidateLogin =>
      config.adminUsername.isNotEmpty && config.adminPassword.isNotEmpty;

  List<String> get loginBlockers {
    final lines = <String>[];
    if (remoteConfigError != null) {
      lines.add(remoteConfigError!);
    }
    if (firebaseWebConfigMissing) {
      lines.add('firebase-config.json is missing or still has YOUR_* placeholders.');
    }
    if (missingRemoteConfigKeys.isNotEmpty) {
      lines.add(
        'Remote Config missing (Firebase Console → Publish): '
        '${missingRemoteConfigKeys.join(', ')}',
      );
    }
    if (!canValidateLogin && missingRemoteConfigKeys.isEmpty && !firebaseWebConfigMissing) {
      lines.add(
        'Admin login is not configured. Set ${ExportRemoteConfigKeys.loginKeys.join(' and ')} '
        'in Remote Config, or adminUsername / adminPassword in runtime-config.json for local testing.',
      );
    }
    return lines;
  }
}
