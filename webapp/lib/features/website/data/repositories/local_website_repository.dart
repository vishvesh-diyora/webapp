import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:webapp/core/config/cloudflare_config.dart';
import 'package:webapp/features/cloudflare/domain/entities/website_deployment_info.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';
import 'package:webapp/features/website/domain/repositories/website_repository.dart';

/// Persists websites on device (no remote database).
class LocalWebsiteRepository implements WebsiteRepository {
  LocalWebsiteRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _storageKey = 'local_websites_v1';
  final _uuid = const Uuid();

  List<Map<String, dynamic>> _readRows() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  Future<void> _writeRows(List<Map<String, dynamic>> rows) async {
    await _prefs.setString(_storageKey, jsonEncode(rows));
  }

  @override
  Future<List<WebsiteDocument>> fetchWebsites() async {
    final rows = _readRows();
    rows.sort((a, b) {
      final aTime = DateTime.tryParse(a['updated_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = DateTime.tryParse(b['updated_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return rows.map(_fromRow).toList();
  }

  @override
  Future<WebsiteDocument> saveWebsite(WebsiteDocument document) async {
    final rows = _readRows();
    final now = DateTime.now();
    final id = document.id ?? _uuid.v4();
    final row = {
      'id': id,
      'updated_at': now.toIso8601String(),
      'content': document.toPublishedJson(),
      if (document.deployment != null) 'deployment': document.deployment!.toJson(),
    };

    final index = rows.indexWhere((r) => r['id'] == id);
    if (index >= 0) {
      rows[index] = row;
    } else {
      rows.add(row);
    }

    await _writeRows(rows);
    return _fromRow(row);
  }

  @override
  Future<void> deleteWebsite(String id) async {
    final rows = _readRows();
    rows.removeWhere((r) => r['id'] == id);
    await _writeRows(rows);
  }

  @override
  Future<WebsiteDocument?> fetchPublishedByUsername(String username) async {
    final normalized = normalizeUsername(username);
    if (normalized.isEmpty) return null;

    for (final row in _readRows()) {
      final deploymentJson = row['deployment'];
      if (deploymentJson is! Map) continue;
      final deployment = WebsiteDeploymentInfo.fromJson(
        Map<String, dynamic>.from(deploymentJson),
      );
      if (normalizeUsername(deployment.projectName) == normalized) {
        return _fromRow(row);
      }
    }
    return null;
  }

  @override
  Future<bool> isPublishUsernameAvailable(
    String username, {
    String? excludeWebsiteId,
  }) async {
    final normalized = normalizeUsername(username);
    for (final row in _readRows()) {
      if (excludeWebsiteId != null && row['id'] == excludeWebsiteId) {
        continue;
      }
      final deploymentJson = row['deployment'];
      if (deploymentJson is! Map) continue;
      final deployment = WebsiteDeploymentInfo.fromJson(
        Map<String, dynamic>.from(deploymentJson),
      );
      if (normalizeUsername(deployment.projectName) == normalized) {
        return false;
      }
    }
    return true;
  }

  WebsiteDocument _fromRow(Map<String, dynamic> row) {
    final content = Map<String, dynamic>.from(row['content'] as Map);
    WebsiteDeploymentInfo? deployment;
    if (row['deployment'] != null) {
      deployment = WebsiteDeploymentInfo.fromJson(
        Map<String, dynamic>.from(row['deployment'] as Map),
      );
    }
    return WebsiteDocument.fromJson(content).copyWith(
      id: row['id'] as String?,
      updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? ''),
      deployment: deployment,
    );
  }
}
