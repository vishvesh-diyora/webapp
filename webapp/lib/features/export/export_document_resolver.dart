import 'package:webapp/core/domain/category_type.dart';
import 'package:webapp/features/templates/catalog/template_catalog.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

/// Ensures export/preview JSON includes full template blocks (products, categories, …).
abstract final class ExportDocumentResolver {
  static WebsiteDocument ensureFullContent(WebsiteDocument document) {
    if (_hasRenderableContent(document)) return document;

    final template = TemplateCatalog.byTypeAndTemplate(
      document.type,
      document.templateType,
    );
    if (template == null) return document;

    final defaults = template.toDocument();
    return defaults.copyWith(
      id: document.id,
      name: document.name.isNotEmpty ? document.name : defaults.name,
      subname: document.subname.isNotEmpty ? document.subname : defaults.subname,
      description:
          document.description.isNotEmpty ? document.description : defaults.description,
      logo: document.logo.isNotEmpty ? document.logo : defaults.logo,
      updatedAt: document.updatedAt,
    );
  }

  static bool _hasRenderableContent(WebsiteDocument document) {
    switch (document.type) {
      case CategoryType.ecommerce:
      case CategoryType.restaurantMenu:
        final tertiary = document.blockByContentType(ContentType.tertiary)?.contentData;
        final catalogItems = document.type == CategoryType.ecommerce
            ? (tertiary == null ? null : tertiary['products'])
            : (tertiary == null ? null : tertiary['menuItems']);
        return catalogItems is List && catalogItems.isNotEmpty;
      case CategoryType.portfolio:
        final tertiary = document.blockByContentType(ContentType.tertiary)?.contentData;
        final projects = tertiary?['projects'];
        return projects is List && projects.isNotEmpty;
      case CategoryType.businessProfile:
        final secondary = document.blockByContentType(ContentType.secondary)?.contentData;
        final services = secondary?['services'];
        return services is List && services.isNotEmpty;
      case CategoryType.giftReveal:
        final primary = document.blockByContentType(ContentType.primary)?.contentData;
        return primary != null && primary.isNotEmpty;
      default:
        return document.data.isNotEmpty;
    }
  }
}
