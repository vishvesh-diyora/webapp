import 'package:flutter/foundation.dart';

/// Reads the publish username from a `{username}.pages.dev` host.
String? publishUsernameFromHost() {
  if (!kIsWeb) return null;

  final host = Uri.base.host.toLowerCase();
  if (!host.endsWith('.pages.dev')) return null;

  final labels = host.split('.');
  if (labels.length < 3) return null;

  final username = labels.first;
  if (username.isEmpty || username == 'www') return null;
  return username;
}

/// True when this browser session should render a published site, not the builder.
bool get isPublishedSubdomainHost => publishUsernameFromHost() != null;
