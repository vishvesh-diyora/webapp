import 'package:flutter/material.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

class CartScope extends InheritedWidget {
  const CartScope({super.key, required this.addToCart, required super.child});

  final void Function(String name, num price) addToCart;

  static CartScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CartScope>();

  @override
  bool updateShouldNotify(CartScope oldWidget) => false;
}

/// In-app cart bar for restaurant and ecommerce previews (mirrors published JS cart).
class CartPreviewShell extends StatefulWidget {
  const CartPreviewShell({
    super.key,
    required this.document,
    required this.compact,
    required this.whatsappField,
    required this.child,
  });

  final WebsiteDocument document;
  final bool compact;
  final String whatsappField;
  final Widget child;

  @override
  State<CartPreviewShell> createState() => _CartPreviewShellState();
}

class _CartPreviewShellState extends State<CartPreviewShell> {
  final Map<String, _CartLine> _cart = {};

  void _addItem(String name, num price) {
    setState(() {
      final line = _cart[name];
      if (line == null) {
        _cart[name] = _CartLine(name: name, price: price, qty: 1);
      } else {
        _cart[name] = line.copyWith(qty: line.qty + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.document.blockByContentType(1)?.contentData ?? {};
    final whatsapp = primary[widget.whatsappField] as String? ?? primary['phone'] as String? ?? '';
    final total = _cart.values.fold<double>(0, (sum, line) => sum + line.price * line.qty);
    final count = _cart.values.fold<int>(0, (sum, line) => sum + line.qty);

    return CartScope(
      addToCart: _addItem,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: widget.compact ? 52 : 56),
            child: widget.child,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              elevation: 8,
              color: const Color(0xFF111827),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.compact ? 12 : 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        count == 0 ? 'Cart empty' : '$count item(s) · \$${total.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.white, fontSize: widget.compact ? 12 : 14),
                      ),
                    ),
                    if (whatsapp.isNotEmpty && count > 0)
                      FilledButton(
                        onPressed: () {},
                        child: Text('WhatsApp', style: TextStyle(fontSize: widget.compact ? 12 : 14)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLine {
  const _CartLine({required this.name, required this.price, required this.qty});
  final String name;
  final num price;
  final int qty;

  _CartLine copyWith({int? qty}) => _CartLine(name: name, price: price, qty: qty ?? this.qty);
}
