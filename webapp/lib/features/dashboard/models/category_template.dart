/// Category type identifiers.
abstract final class CategoryType {
  static const int ecommerce = 1;
  static const int portfolio = 2;
  static const int gift = 3;
  static const int custom = 4;
}

/// Content block types (meaning varies by [CategoryTemplate.type]).
abstract final class ContentType {
  static const int banners = 1;
  static const int categories = 2;
  static const int products = 3;
}

/// A single sequenced content block inside a category template.
class CategoryContentBlock {
  const CategoryContentBlock({
    required this.seqId,
    required this.contentType,
  });

  final int seqId;
  final int contentType;

  Map<String, dynamic> toJson() => {
        'seqId': seqId,
        'contentType': contentType,
      };
}

/// Local category template configuration (not persisted).
class CategoryTemplate {
  const CategoryTemplate({
    required this.type,
    required this.templateType,
    required this.name,
    required this.subname,
    required this.description,
    required this.data,
  });

  /// 1 ecom, 2 portfolio, 3 gift, 4 custom
  final int type;

  final int templateType;
  final String name;
  final String subname;
  final String description;
  final List<CategoryContentBlock> data;

  Map<String, dynamic> toJson() => {
        'type': type,
        'templateType': templateType,
        'name': name,
        'subname': subname,
        'description': description,
        'data': data.map((item) => item.toJson()).toList(),
      };

  String toPrettyJson() {
    final buffer = StringBuffer();
    buffer.writeln('{');
    buffer.writeln('  type: $type,');
    buffer.writeln('  templateType: $templateType,');
    buffer.writeln('  name: $name,');
    buffer.writeln('  subname: $subname,');
    buffer.writeln('  description: $description,');
    buffer.writeln('  data: [');
    for (final item in data) {
      buffer.writeln('    {');
      buffer.writeln('      seqId: ${item.seqId},');
      buffer.writeln('      contentType: ${item.contentType},');
      buffer.writeln('    },');
    }
    buffer.writeln('  ]');
    buffer.writeln('}');
    return buffer.toString();
  }
}
