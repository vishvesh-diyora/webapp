import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:webapp/features/templates/preview/shared/catalog_product_utils.dart';

/// Network reel playback via [video_player] (mobile, desktop).
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
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant CatalogReelVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _disposeController();
      _failed = false;
      _init();
    }
  }

  Future<void> _init() async {
    final playUrl = catalogNormalizeReelVideoUrl(widget.url);
    final controller = VideoPlayerController.networkUrl(Uri.parse(playUrl));
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      if (!mounted) return;
      setState(() => _ready = true);
      await controller.play();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
      _disposeController();
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
    _ready = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return widget.error;
    if (!_ready || _controller == null) return widget.placeholder;
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _controller!.value.size.width,
        height: _controller!.value.size.height,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}
