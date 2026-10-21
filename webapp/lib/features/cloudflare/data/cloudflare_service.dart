import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:webapp/core/config/cloudflare_config.dart';
import 'package:webapp/features/cloudflare/data/pages_asset_hasher.dart';

class CloudflareAccount {
  const CloudflareAccount({required this.id, required this.name});

  final String id;
  final String name;
}

class CloudflarePagesProject {
  const CloudflarePagesProject({
    required this.id,
    required this.name,
    required this.subdomain,
  });

  final String id;
  final String name;
  final String subdomain;
}

class CloudflareDeploymentResult {
  const CloudflareDeploymentResult({
    required this.deploymentId,
    required this.projectId,
    required this.projectName,
    required this.url,
    required this.accountId,
  });

  final String deploymentId;
  final String projectId;
  final String projectName;
  final String url;
  final String accountId;
}

class CloudflareApiException implements Exception {
  CloudflareApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

typedef CloudflareDeployProgress = void Function(String stage, double progress);

/// Cloudflare Pages Direct Upload API (official, no GitHub).
class CloudflareService {
  CloudflareService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<CloudflareAccount>> listAccounts(String accessToken) async {
    final data = await _apiGet('/accounts', accessToken);
    final results = (data['result'] as List?) ?? const [];
    return results
        .whereType<Map>()
        .map((row) => CloudflareAccount(
              id: row['id'] as String,
              name: row['name'] as String? ?? row['id'] as String,
            ))
        .toList();
  }

  Future<CloudflarePagesProject> ensureProject({
    required String accountId,
    required String projectName,
    required String accessToken,
  }) async {
    try {
      return await getProject(
        accountId: accountId,
        projectName: projectName,
        accessToken: accessToken,
      );
    } on CloudflareApiException catch (error) {
      if (error.statusCode != 404) rethrow;
    }

    final data = await _apiPost(
      '/accounts/$accountId/pages/projects',
      accessToken,
      body: {
        'name': projectName,
        'production_branch': 'main',
      },
    );
    final result = Map<String, dynamic>.from(data['result'] as Map);
    return _projectFromJson(result);
  }

  Future<CloudflarePagesProject> getProject({
    required String accountId,
    required String projectName,
    required String accessToken,
  }) async {
    final data = await _apiGet(
      '/accounts/$accountId/pages/projects/$projectName',
      accessToken,
    );
    return _projectFromJson(Map<String, dynamic>.from(data['result'] as Map));
  }

  /// Returns true when a Pages project (subdomain) already exists on Cloudflare.
  Future<bool> projectExists({
    required String accountId,
    required String projectName,
    required String accessToken,
  }) async {
    try {
      await getProject(
        accountId: accountId,
        projectName: projectName,
        accessToken: accessToken,
      );
      return true;
    } on CloudflareApiException catch (error) {
      if (error.statusCode == 404) return false;
      rethrow;
    }
  }

  Future<CloudflareDeploymentResult> deployDirectory({
    required String accountId,
    required String projectName,
    required String siteDirectory,
    required String accessToken,
    CloudflareDeployProgress? onProgress,
  }) async {
    onProgress?.call('Preparing files', 0.05);
    final files = await _collectSiteFiles(siteDirectory);
    return deployFiles(
      accountId: accountId,
      projectName: projectName,
      files: files,
      accessToken: accessToken,
      onProgress: onProgress,
    );
  }

  Future<CloudflareDeploymentResult> deployFiles({
    required String accountId,
    required String projectName,
    required Map<String, List<int>> files,
    required String accessToken,
    CloudflareDeployProgress? onProgress,
  }) async {
    if (files.isEmpty) {
      throw CloudflareApiException('No files found in generated website.');
    }

    final manifest = <String, String>{};
    final hashToPath = <String, String>{};
    final hashToBytes = <String, List<int>>{};

    for (final entry in files.entries) {
      final hash = PagesAssetHasher.hash(entry.value, entry.key);
      final webPath = '/${entry.key.replaceAll('\\', '/')}';
      manifest[webPath] = hash;
      hashToPath[hash] = entry.key;
      hashToBytes[hash] = entry.value;
    }

    onProgress?.call('Requesting upload token', 0.12);
    final uploadJwt = await _fetchUploadJwt(
      accountId: accountId,
      projectName: projectName,
      accessToken: accessToken,
    );

    onProgress?.call('Checking assets', 0.2);
    final missing = await _checkMissingHashes(uploadJwt, manifest.values.toSet());

    if (missing.isNotEmpty) {
      onProgress?.call('Uploading ${missing.length} file(s)', 0.35);
      await _uploadAssets(
        uploadJwt: uploadJwt,
        missingHashes: missing,
        hashToBytes: hashToBytes,
        hashToPath: hashToPath,
        onProgress: (uploaded, total) {
          final fraction = 0.35 + (uploaded / total) * 0.45;
          onProgress?.call('Uploading files ($uploaded/$total)', fraction);
        },
      );
      await _upsertHashes(uploadJwt, missing);
    }

    onProgress?.call('Creating deployment', 0.85);
    final deployment = await _createDeployment(
      accountId: accountId,
      projectName: projectName,
      accessToken: accessToken,
      manifest: manifest,
    );

    final project = await getProject(
      accountId: accountId,
      projectName: projectName,
      accessToken: accessToken,
    );

    onProgress?.call('Live', 1.0);

    return CloudflareDeploymentResult(
      deploymentId: deployment['id'] as String,
      projectId: project.id,
      projectName: project.name,
      url: _productionUrl(project),
      accountId: accountId,
    );
  }

  Future<Map<String, List<int>>> _collectSiteFiles(String siteDirectory) async {
    final root = Directory(siteDirectory);
    if (!root.existsSync()) {
      throw CloudflareApiException('Generated site directory not found.');
    }

    final files = <String, List<int>>{};
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final relative = p.relative(entity.path, from: siteDirectory);
      if (relative.startsWith('.') || p.basename(relative).startsWith('.')) {
        continue;
      }
      files[relative] = await entity.readAsBytes();
    }
    return files;
  }

  Future<String> _fetchUploadJwt({
    required String accountId,
    required String projectName,
    required String accessToken,
  }) async {
    final data = await _apiPost(
      '/accounts/$accountId/pages/projects/$projectName/deployments/upload-token',
      accessToken,
      body: const {},
    );
    final result = data['result'] as Map?;
    final token = result?['jwt'] as String? ?? result?['token'] as String?;
    if (token == null || token.isEmpty) {
      throw CloudflareApiException('Cloudflare did not return an upload token.');
    }
    return token;
  }

  Future<Set<String>> _checkMissingHashes(String uploadJwt, Set<String> hashes) async {
    final response = await _client.post(
      Uri.parse('${CloudflareConfig.apiBase}/pages/assets/check-missing'),
      headers: {
        'Authorization': 'Bearer $uploadJwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'hashes': hashes.toList()}),
    );

    final data = _decodeResponse(response);
    final missing = (data['result'] as List?) ?? const [];
    return missing.map((h) => h.toString()).toSet();
  }

  Future<void> _uploadAssets({
    required String uploadJwt,
    required Set<String> missingHashes,
    required Map<String, List<int>> hashToBytes,
    required Map<String, String> hashToPath,
    void Function(int uploaded, int total)? onProgress,
  }) async {
    const batchSize = 40;
    final list = missingHashes.toList();
    var uploaded = 0;

    for (var i = 0; i < list.length; i += batchSize) {
      final batch = list.sublist(i, i + batchSize > list.length ? list.length : i + batchSize);
      final payload = batch.map((hash) {
        final bytes = hashToBytes[hash]!;
        final path = hashToPath[hash]!;
        return {
          'key': hash,
          'value': base64Encode(bytes),
          'metadata': {'contentType': lookupMimeType(path) ?? 'application/octet-stream'},
          'base64': true,
        };
      }).toList();

      final response = await _client.post(
        Uri.parse('${CloudflareConfig.apiBase}/pages/assets/upload'),
        headers: {
          'Authorization': 'Bearer $uploadJwt',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      _decodeResponse(response);

      uploaded += batch.length;
      onProgress?.call(uploaded, list.length);
    }
  }

  Future<void> _upsertHashes(String uploadJwt, Iterable<String> hashes) async {
    final response = await _client.post(
      Uri.parse('${CloudflareConfig.apiBase}/pages/assets/upsert-hashes'),
      headers: {
        'Authorization': 'Bearer $uploadJwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'hashes': hashes.toList()}),
    );
    _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _createDeployment({
    required String accountId,
    required String projectName,
    required String accessToken,
    required Map<String, String> manifest,
  }) async {
    final uri = Uri.parse(
      '${CloudflareConfig.apiBase}/accounts/$accountId/pages/projects/$projectName/deployments',
    );
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..fields['branch'] = 'main'
      ..files.add(
        http.MultipartFile.fromString(
          'manifest',
          jsonEncode(manifest),
          filename: 'manifest.json',
          contentType: http.MediaType('application', 'json'),
        ),
      );

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    final data = _decodeResponse(response);
    return Map<String, dynamic>.from(data['result'] as Map);
  }

  CloudflarePagesProject _projectFromJson(Map<String, dynamic> json) {
    final subdomain = json['subdomain'] as String? ?? json['name'] as String;
    return CloudflarePagesProject(
      id: json['id'] as String,
      name: json['name'] as String,
      subdomain: subdomain,
    );
  }

  String _productionUrl(CloudflarePagesProject project) {
    return 'https://${project.subdomain}.pages.dev';
  }

  Future<Map<String, dynamic>> _apiGet(String path, String accessToken) async {
    final response = await _client.get(
      Uri.parse('${CloudflareConfig.apiBase}$path'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _apiPost(
    String path,
    String accessToken, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _client.post(
      Uri.parse('${CloudflareConfig.apiBase}$path'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    Map<String, dynamic> data;
    try {
      data = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      throw CloudflareApiException(
        'Unexpected Cloudflare response (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    final success = data['success'] as bool? ?? false;
    if (!success || response.statusCode >= 400) {
      final errors = (data['errors'] as List?) ?? const [];
      final message = errors.isNotEmpty
          ? (errors.first as Map)['message'] as String? ?? 'Cloudflare API error'
          : 'Cloudflare API error (${response.statusCode})';
      throw CloudflareApiException(message, statusCode: response.statusCode);
    }

    return data;
  }

  static String slugProjectName(String seed) {
    var slug = seed.toLowerCase().replaceAll(RegExp(r'[^a-z0-9-]+'), '-');
    slug = slug.replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    if (slug.isEmpty) slug = 'website';
    if (slug.length > 58) slug = slug.substring(0, 58).replaceAll(RegExp(r'-+$'), '');
    return slug;
  }
}
