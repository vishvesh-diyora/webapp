import 'package:webapp/core/domain/category_type.dart';
import 'package:webapp/features/templates/catalog/template_catalog.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

export 'package:webapp/features/templates/catalog/template_catalog.dart'
    show TemplateCatalog, TemplateDefinition, TemplateStyle;

typedef PortfolioTemplateStyle = TemplateStyle;

/// Backward-compatible accessors for template metadata and documents.
abstract final class CategoryTemplatesData {
  static List<WebsiteDocument> get portfolioTemplates =>
      TemplateCatalog.forCategory(CategoryType.portfolio).map((t) => t.toDocument()).toList();

  static List<TemplateDefinition> templatesForCategory(int type) =>
      TemplateCatalog.forCategory(type);

  static WebsiteDocument defaultForCategory(int type) =>
      TemplateCatalog.defaultForCategory(type).toDocument();

  static WebsiteDocument? byTypeAndTemplateType(int type, int templateType) =>
      TemplateCatalog.byTypeAndTemplate(type, templateType)?.toDocument();

  static TemplateStyle styleFor(WebsiteDocument document) =>
      TemplateCatalog.styleFor(document);

  static WebsiteDocument? byType(int type) {
    if (!CategoryType.all.contains(type)) return null;
    return defaultForCategory(type);
  }

  static List<WebsiteDocument> byCategoryType(int type) =>
      templatesForCategory(type).map((t) => t.toDocument()).toList();
}
