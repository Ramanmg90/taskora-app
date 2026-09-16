import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// پس‌زمینه‌ی زنده‌ی «شفق نئون» + نویز شبکه‌ای ظریف.
/// یک‌بار در ریشه‌ی اپ قرار می‌گیرد و همه‌ی صفحه‌ها روی آن شناورند.
class NeonBackground extends StatefulWidget {
  final Widget child;
  const NeonBackground({super.key, required this.child});

  @override
  State<NeonBackground> createState() => _NeonBackgroundState();
}

class _NeonBackgroundState extends State<NeonBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? const [NeonPalette.abyss, NeonPalette.deep, Color(0xFF070815)]
              : const [NeonPalette.mist, Color(0xFFF7F4FF), NeonPalette.cloud],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, __) => CustomPaint(
                  painter: _AuroraPainter(_c.value, isDark),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _GridPainter(isDark)),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double t;
  final bool isDark;
  _AuroraPainter(this.t, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final blobs = <_Blob>[
      _Blob(NeonPalette.teal, 0.22, 0.18, 0.55, 0.0),
      _Blob(NeonPalette.cyan, 0.82, 0.30, 0.45, 0.35),
      _Blob(NeonPalette.orange, 0.70, 0.82, 0.42, 0.62),
      _Blob(NeonPalette.violet, 0.18, 0.72, 0.38, 0.85),
    ];

    for (final b in blobs) {
      final phase = (t + b.phase) * 2 * math.pi;
      final dx = math.cos(phase) * size.width * 0.10;
      final dy = math.sin(phase * 0.8) * size.height * 0.07;
      final radius = size.width * b.scale * (0.86 + 0.14 * math.sin(phase));

      final paint = Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90)
        ..shader = RadialGradient(
          colors: [
            b.color.withOpacity(isDark ? 0.22 : 0.30),
            b.color.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * b.x + dx, size.height * b.y + dy),
            radius: radius,
          ),
        );

      canvas.drawCircle(
        Offset(size.width * b.x + dx, size.height * b.y + dy),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.t != t || old.isDark != isDark;
}

class _Blob {
  final Color color;
  final double x, y, scale, phase;
  _Blob(this.color, this.x, this.y, this.scale, this.phase);
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter(this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : NeonPalette.teal)
          .withOpacity(isDark ? 0.022 : 0.030)
      ..strokeWidth = 1;

    const step = 34.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.isDark != isDark;
}

/// یک هاله‌ی نئونی ملایم که پشت هر ویجتی می‌نشیند.
class NeonHalo extends StatelessWidget {
  final Widget child;
  final Color color;
  final double blur;
  final double opacity;

  const NeonHalo({
    super.key,
    required this.child,
    this.color = NeonPalette.teal,
    this.blur = 40,
    this.opacity = 0.35,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.7,
                  heightFactor: 0.7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(opacity),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
