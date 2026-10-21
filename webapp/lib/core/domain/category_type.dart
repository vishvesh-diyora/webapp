/// Website category identifiers — fixed across app, editor, preview, and generator.
abstract final class CategoryType {
  static const int ecommerce = 1;
  static const int restaurantMenu = 2;
  static const int businessProfile = 3;
  static const int portfolio = 4;
  static const int giftReveal = 5;

  /// Home screen and picker order.
  static const List<int> all = [
    ecommerce,
    restaurantMenu,
    businessProfile,
    portfolio,
    giftReveal,
  ];

  static String label(int type) => switch (type) {
        portfolio => 'Portfolio',
        businessProfile => 'Business Profile',
        giftReveal => 'Gift Reveal',
        restaurantMenu => 'Restaurant Menu',
        ecommerce => 'Ecommerce Product Catalogue',
        _ => 'Website',
      };

  static String description(int type) => switch (type) {
        portfolio =>
          'Showcase projects, experience, skills, and testimonials.',
        businessProfile =>
          'Professional business site with services, gallery, and branches.',
        giftReveal =>
          'Animated gift reveal with countdown, music, and messages.',
        restaurantMenu =>
          'Menu, categories, offers, and WhatsApp ordering.',
        ecommerce =>
          'Product catalogue with local cart and WhatsApp checkout.',
        _ => '',
      };
}

/// Content block types — meaning varies by [CategoryType].
abstract final class ContentType {
  static const int primary = 1;
  static const int secondary = 2;
  static const int tertiary = 3;

  /// Legacy aliases used by portfolio design widgets.
  static const int banners = primary;
  static const int categories = secondary;
  static const int products = tertiary;
}
