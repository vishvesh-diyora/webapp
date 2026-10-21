import 'package:webapp/features/website/domain/entities/website_document.dart';

abstract class WebsiteRepository {
  Future<List<WebsiteDocument>> fetchWebsites();
  Future<WebsiteDocument> saveWebsite(WebsiteDocument document);
  Future<void> deleteWebsite(String id);
  Future<bool> isPublishUsernameAvailable(String username, {String? excludeWebsiteId});
  Future<WebsiteDocument?> fetchPublishedByUsername(String username);
}
