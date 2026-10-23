import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:webapp/features/export_admin/export_runtime_config.dart';

/// Publishes [site.json] and media files to GitHub (used by /admin Save).
class ExportGithubService {
  ExportGithubService(this.config);

  final ExportGithubConfig config;

  Uri _api(String path) => Uri.parse(
        'https://api.github.com/repos/${config.owner}/${config.repo}/contents/$path',
      );

  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${config.token}',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      };

  Future<String> uploadBytes({
    required List<int> bytes,
    required String fileName,
    String? commitMessage,
  }) async {
    final path = '${config.mediaFolder}/$fileName';
    final body = {
      'message': commitMessage ?? 'Upload $fileName',
      'content': base64Encode(bytes),
      'branch': config.branch,
    };
    final existingSha = await _shaForPath(path);
    if (existingSha != null) body['sha'] = existingSha;

    final response = await http.put(
      _api(path),
      headers: _headers,
      body: jsonEncode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw StateError('GitHub upload failed (${response.statusCode}): ${response.body}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content = decoded['content'] as Map<String, dynamic>?;
    final download = content?['download_url'] as String?;
    if (download != null && download.isNotEmpty) return download;
    return 'https://raw.githubusercontent.com/${config.owner}/${config.repo}/${config.branch}/$path';
  }

  Future<void> publishSiteJson(Map<String, dynamic> siteJson) async {
    final path = config.siteJsonPath;
    final encoded = utf8.encode(const JsonEncoder.withIndent('  ').convert(siteJson));
    final body = {
      'message': 'Update site content',
      'content': base64Encode(encoded),
      'branch': config.branch,
    };
    final existingSha = await _shaForPath(path);
    if (existingSha != null) body['sha'] = existingSha;

    final response = await http.put(
      _api(path),
      headers: _headers,
      body: jsonEncode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw StateError('GitHub site.json update failed (${response.statusCode}): ${response.body}');
    }
  }

  Future<String?> _shaForPath(String path) async {
    final response = await http.get(_api(path), headers: _headers);
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) return null;
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['sha'] as String?;
  }
}
