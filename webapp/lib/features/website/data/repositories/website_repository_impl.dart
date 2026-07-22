import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webapp/features/cloudflare/domain/entities/website_deployment_info.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';
import 'package:webapp/features/website/domain/repositories/website_repository.dart';

class WebsiteRepositoryImpl implements WebsiteRepository {
  WebsiteRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _table = 'websites';

  @override
  Future<List<WebsiteDocument>> fetchWebsites() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];

    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return (response as List)
        .map((row) => _fromRow(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  @override
  Future<WebsiteDocument> saveWebsite(WebsiteDocument document) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Sign in to save websites.');
    }

    final payload = {
      'user_id': userId,
      'content': document.toPublishedJson(),
      'updated_at': DateTime.now().toIso8601String(),
      if (document.deployment != null) 'deployment': document.deployment!.toJson(),
    };

    if (document.id == null) {
      final inserted = await _client.from(_table).insert(payload).select().single();
      return _fromRow(Map<String, dynamic>.from(inserted));
    }

    final updated = await _client
        .from(_table)
        .update(payload)
        .eq('id', document.id!)
        .select()
        .single();
    return _fromRow(Map<String, dynamic>.from(updated));
  }

  @override
  Future<void> deleteWebsite(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  WebsiteDocument _fromRow(Map<String, dynamic> row) {
    final content = Map<String, dynamic>.from(row['content'] as Map);
    WebsiteDeploymentInfo? deployment;
    if (row['deployment'] != null) {
      deployment = WebsiteDeploymentInfo.fromJson(
        Map<String, dynamic>.from(row['deployment'] as Map),
      );
    }
    final document = WebsiteDocument.fromJson(content).copyWith(
      id: row['id'] as String?,
      userId: row['user_id'] as String?,
      updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? ''),
      deployment: deployment,
    );
    return document;
  }
}
