import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'package:webapp/features/templates/preview/shared/catalog_product_utils.dart';

/// Reel playback on Flutter web.
///
/// Google Drive MP4 URLs cannot be used as a plain `<video src>` in Chrome
/// (MEDIA_ERR_SRC_NOT_SUPPORTED). The official embed preview iframe works and
/// is configured for muted autoplay where the browser allows it.
class CatalogReelVideoPlayer extends StatefulWidget {
  const CatalogReelVideoPlayer({
    super.key,
    required this.url,
    required this.placeholder,
    required this.error,
  });

  final String url;
  final Widget placeholder;
  final Widget error;

  @override
  State<CatalogReelVideoPlayer> createState() => _CatalogReelVideoPlayerState();
}

class _CatalogReelVideoPlayerState extends State<CatalogReelVideoPlayer> {
  late final String _viewType;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final fileId = catalogDriveFileIdFromUrl(widget.url);
    final embedUrl = fileId != null
        ? catalogDrivePreviewEmbedUrl(fileId)
        : widget.url;

    _viewType =
        'catalog-reel-${embedUrl.hashCode}-${identityHashCode(this)}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      if (fileId != null) {
        return _buildDriveIframe(embedUrl);
      }
      return _buildDirectVideo(embedUrl);
    });
  }

  web.HTMLIFrameElement _buildDriveIframe(String embedUrl) {
    final iframe = web.HTMLIFrameElement();
    iframe.src = embedUrl;
    iframe.style.border = 'none';
    iframe.style.width = '100%';
    iframe.style.height = '100%';
    iframe.style.pointerEvents = 'none';
    iframe.style.transform = 'scale(1.55)';
    iframe.style.transformOrigin = 'center center';
    iframe.allow = 'autoplay; fullscreen; encrypted-media';
    iframe.setAttribute('allowfullscreen', '');

    iframe.onLoad.listen((_) {
      if (mounted) setState(() => _ready = true);
    });
    iframe.onError.listen((_) {
      if (mounted) setState(() => _failed = true);
    });

    return iframe;
  }

  web.HTMLVideoElement _buildDirectVideo(String src) {
    final video = web.HTMLVideoElement();
    video.style.width = '100%';
    video.style.height = '100%';
    video.style.objectFit = 'cover';
    video.autoplay = true;
    video.muted = true;
    video.loop = true;
    video.playsInline = true;
    video.setAttribute('playsinline', '');
    video.preload = 'auto';
    video.crossOrigin = 'anonymous';
    video.src = src;

    video.onLoadedData.listen((_) {
      if (mounted) setState(() => _ready = true);
    });
    video.onError.listen((_) {
      if (mounted) setState(() => _failed = true);
    });
    video.play();

    return video;
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return widget.error;
    return Stack(
      fit: StackFit.expand,
      children: [
        HtmlElementView(viewType: _viewType),
        if (!_ready) widget.placeholder,
      ],
    );
  }
}
