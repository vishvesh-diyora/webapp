num? catalogParseAmount(dynamic value) {
  if (value is num) return value;
  if (value is String && value.isNotEmpty) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    return num.tryParse(cleaned);
  }
  return null;
}

double catalogDiscountPercent(Map<String, dynamic> item) {
  return catalogParseAmount(item['discount'])?.toDouble() ?? 0;
}

double catalogListedPrice(Map<String, dynamic> item) {
  return catalogParseAmount(item['price'])?.toDouble() ?? 0;
}

double? catalogExplicitCompareAt(Map<String, dynamic> item) {
  final raw = item['originalPrice'] ?? item['compareAtPrice'] ?? item['mrp'];
  final parsed = catalogParseAmount(raw);
  if (parsed == null || parsed <= 0) return null;
  return parsed.toDouble();
}

/// Price charged at checkout (after discount when applicable).
double catalogSalePrice(Map<String, dynamic> item) {
  final listed = catalogListedPrice(item);
  final discount = catalogDiscountPercent(item);
  final explicit = catalogExplicitCompareAt(item);

  if (discount > 0 && listed > 0) {
    return listed * (1 - discount / 100);
  }
  if (explicit != null && explicit > listed && listed > 0) {
    return listed;
  }
  return listed;
}

/// Strikethrough / MRP when it differs from the sale price.
double? catalogCompareAtPrice(Map<String, dynamic> item) {
  final sale = catalogSalePrice(item);
  final discount = catalogDiscountPercent(item);
  final listed = catalogListedPrice(item);
  final explicit = catalogExplicitCompareAt(item);

  if (discount > 0 && listed > sale + 0.009) {
    return listed;
  }
  if (explicit != null && explicit > sale + 0.009) {
    return explicit;
  }
  return null;
}

String catalogFormatMoney(num value) {
  final rounded = value.toDouble();
  if ((rounded - rounded.roundToDouble()).abs() < 0.01) {
    return '\$${rounded.round()}';
  }
  return '\$${rounded.toStringAsFixed(2)}';
}
