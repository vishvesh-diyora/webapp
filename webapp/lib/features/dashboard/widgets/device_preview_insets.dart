import 'package:flutter/material.dart';

/// Content insets for device preview frames — keep in sync with chrome overlays
/// in [IPhonePreviewFrame] (_DynamicIsland, _HomeIndicator).
abstract final class DevicePreviewInsets {
  /// Dynamic Island: top 10 + height 34 + 12px breathing room.
  static const double iphoneTop = 56;

  /// Home indicator: bottom 8 + height 5 + 7px breathing room.
  static const double iphoneBottom = 20;

  static EdgeInsets get iphoneContent => const EdgeInsets.only(
        top: iphoneTop,
        bottom: iphoneBottom,
      );
}
