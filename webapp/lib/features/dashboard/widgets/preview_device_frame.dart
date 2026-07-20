import 'package:flutter/material.dart';

const _frameShadow = [
  BoxShadow(
    color: Color(0x40000000),
    blurRadius: 28,
    offset: Offset(0, 14),
  ),
];

const _titaniumFrame = Color(0xFF3D3D40);
const _titaniumEdge = Color(0xFF565658);
const _monitorFrame = Color(0xFF1E293B);
const _monitorEdge = Color(0xFF334155);

Matrix4 _devicePerspective({
  double rotateX = -0.1,
  double rotateY = 0.16,
}) {
  return Matrix4.identity()
    ..setEntry(3, 2, 0.0012)
    ..rotateX(rotateX)
    ..rotateY(rotateY);
}

class _Device3DWrapper extends StatelessWidget {
  const _Device3DWrapper({
    required this.child,
    this.rotateX = -0.1,
    this.rotateY = 0.16,
  });

  final Widget child;
  final double rotateX;
  final double rotateY;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: _devicePerspective(rotateX: rotateX, rotateY: rotateY),
      child: child,
    );
  }
}

/// Centers a device inside a larger canvas so 3D transforms and shadows fit.
class _DeviceFitCanvas extends StatelessWidget {
  const _DeviceFitCanvas({
    required this.fitWidth,
    required this.fitHeight,
    required this.designWidth,
    required this.designHeight,
    required this.rotateX,
    required this.rotateY,
    required this.device,
    this.deviceAlignment = Alignment.center,
  });

  final double fitWidth;
  final double fitHeight;
  final double designWidth;
  final double designHeight;
  final double rotateX;
  final double rotateY;
  final Widget device;
  final Alignment deviceAlignment;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fitWidth,
      height: fitHeight,
      child: _Device3DWrapper(
        rotateX: rotateX,
        rotateY: rotateY,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: deviceAlignment,
          children: [
            SizedBox(
              width: designWidth,
              height: designHeight,
              child: device,
            ),
          ],
        ),
      ),
    );
  }
}

/// Latest iPhone-style frame (Dynamic Island, thin bezels, home indicator).
class IPhonePreviewFrame extends StatelessWidget {
  const IPhonePreviewFrame({super.key, required this.child});

  static const double designWidth = 330;
  static const double designHeight = 720;
  static const double fitWidth = 364;
  static const double fitHeight = 752;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _DeviceFitCanvas(
      fitWidth: fitWidth,
      fitHeight: fitHeight,
      designWidth: designWidth,
      designHeight: designHeight,
      rotateX: -0.08,
      rotateY: 0.14,
      device: Stack(
        clipBehavior: Clip.none,
        children: [
            Positioned(
              left: 2,
              top: 88,
              child: _SideButton(height: 52),
            ),
            Positioned(
              right: 2,
              top: 120,
              child: _SideButton(height: 72),
            ),
            Positioned(
              right: 2,
              top: 210,
              child: _SideButton(height: 72),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(52),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_titaniumEdge, _titaniumFrame, Color(0xFF2A2A2C)],
                ),
                boxShadow: _frameShadow,
                border: Border.all(color: const Color(0xFF636366), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(47),
                  child: ColoredBox(
                    color: Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(44),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(
                              color: const Color(0xFFF8FAFC),
                              child: Column(
                                children: [
                                  const SizedBox(height: 14),
                                  Expanded(child: ClipRect(child: child)),
                                  const SizedBox(height: 10),
                                  const _HomeIndicator(),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                            const Positioned(
                              top: 10,
                              left: 0,
                              right: 0,
                              child: _DynamicIsland(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              left: designWidth * 0.2,
              right: designWidth * 0.2,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}

/// iPad Pro-style frame (portrait, thin bezels).
class TabletPreviewFrame extends StatelessWidget {
  const TabletPreviewFrame({super.key, required this.child});

  static const double designWidth = 500;
  static const double designHeight = 680;
  static const double fitWidth = 536;
  static const double fitHeight = 712;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _DeviceFitCanvas(
      fitWidth: fitWidth,
      fitHeight: fitHeight,
      designWidth: designWidth,
      designHeight: designHeight,
      rotateX: -0.08,
      rotateY: 0.14,
      device: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3A3A3C),
                  Color(0xFF1C1C1E),
                  Color(0xFF141416),
                ],
              ),
              boxShadow: _frameShadow,
              border: Border.all(color: const Color(0xFF48484A), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColoredBox(
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ColoredBox(
                        color: const Color(0xFFF8FAFC),
                        child: Column(
                          children: [
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B0B0C),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF2C2C2E),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(child: ClipRect(child: child)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: designHeight * 0.22,
            right: 0,
            child: Container(
              width: 2,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF48484A),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: designWidth * 0.18,
            right: designWidth * 0.18,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// PC monitor frame with thin bezels and stand for web preview.
class DesktopPreviewFrame extends StatelessWidget {
  const DesktopPreviewFrame({super.key, required this.child});

  static const double designWidth = 600;
  static const double designHeight = 420;
  static const double fitWidth = 660;
  static const double fitHeight = 520;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _DeviceFitCanvas(
      fitWidth: fitWidth,
      fitHeight: fitHeight,
      designWidth: designWidth,
      designHeight: designHeight,
      rotateX: -0.1,
      rotateY: 0.16,
      deviceAlignment: const Alignment(0, -0.12),
      device: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: designWidth,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _monitorFrame,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _monitorEdge, width: 1),
                    boxShadow: _frameShadow,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 320,
                      child: ColoredBox(
                        color: const Color(0xFFF8FAFC),
                        child: ClipRect(child: child),
                      ),
                    ),
                  ),
                ),
                Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.identity()..rotateX(0.32),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 32,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF475569), Color(0xFF334155)],
                          ),
                        ),
                      ),
                      Container(
                        width: 150,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 4,
              left: designWidth * 0.18,
              right: designWidth * 0.18,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}

class _DynamicIsland extends StatelessWidget {
  const _DynamicIsland();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 118,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 11,
              height: 11,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1A2E),
                border: Border.all(color: const Color(0xFF2D2D44)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF555557),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
