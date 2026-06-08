import 'package:flutter/material.dart';

import '../../core/config/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppLogoTile
//
// Renders the real logo.png inside an optionally rounded, shadowed container.
// Drop-in replacement for the old gradient-tile — same constructor API.
// ─────────────────────────────────────────────────────────────────────────────

class AppLogoTile extends StatelessWidget {
  const AppLogoTile({
    super.key,
    this.size = 44,
    this.radius,
    this.showShadow = true,
    this.backgroundColor,
    this.padding,
  });

  final double size;
  final double? radius;
  final bool showShadow;

  /// Background behind the logo. Defaults to [AppColors.surface].
  final Color? backgroundColor;

  /// Inner padding around the image. Defaults to 18 % of [size].
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? size * 0.28;
    final bg = backgroundColor ?? AppColors.surface;
    final pad = padding ?? EdgeInsets.all(size * 0.18);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: size * 0.30,
                  offset: Offset(0, size * 0.08),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Padding(
          padding: pad,
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppLogoImage
//
// Bare logo image with no container — useful when you just need the PNG
// at a specific size without any background or border.
// ─────────────────────────────────────────────────────────────────────────────

class AppLogoImage extends StatelessWidget {
  const AppLogoImage({
    super.key,
    this.size = 44,
    this.fit = BoxFit.contain,
  });

  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: size,
      height: size,
      fit: fit,
      filterQuality: FilterQuality.high,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppLogoMark  (canvas fallback — kept for backward compatibility)
// ─────────────────────────────────────────────────────────────────────────────

class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 28, this.color, this.accentColor});

  final double size;
  final Color? color;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: AppLogoPainter(
        color: color ?? AppColors.white,
        accentColor: accentColor ?? AppColors.accent,
      ),
    );
  }
}

class AppLogoPainter extends CustomPainter {
  const AppLogoPainter({required this.color, required this.accentColor});

  final Color color;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 56;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(center.dx - 14 * scale, center.dy - 10 * scale)
      ..lineTo(center.dx + 8 * scale, center.dy - 10 * scale)
      ..lineTo(center.dx - 10 * scale, center.dy + 10 * scale)
      ..lineTo(center.dx + 14 * scale, center.dy + 10 * scale);

    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx + 14 * scale, center.dy - 10 * scale),
      3.5 * scale,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant AppLogoPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.accentColor != accentColor;
  }
}
