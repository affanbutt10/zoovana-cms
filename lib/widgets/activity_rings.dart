import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import '../models/dashboard_models.dart';

/// Apple-Watch-style concentric activity rings that animate their fill
/// in on first build and whenever [rings] changes (e.g. role switch).
class ActivityRings extends StatefulWidget {
  final List<RingData> rings;
  final double size;
  const ActivityRings({super.key, required this.rings, this.size = 96});

  @override
  State<ActivityRings> createState() => _ActivityRingsState();
}

class _ActivityRingsState extends State<ActivityRings>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant ActivityRings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rings != widget.rings) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _RingsPainter(
            rings: widget.rings,
            progress: Curves.easeOutCubic.transform(_controller.value),
          ),
        );
      },
    );
  }
}

class _RingsPainter extends CustomPainter {
  final List<RingData> rings;
  final double progress; // 0-1, staggered per ring inside paint()

  _RingsPainter({required this.rings, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 8.0;
    final radii = [
      size.width / 2 - strokeWidth / 2,
      size.width / 2 - strokeWidth * 2.2,
      size.width / 2 - strokeWidth * 3.6,
    ];

    for (var i = 0; i < rings.length && i < radii.length; i++) {
      final ring = rings[i];
      final radius = radii[i];
      // stagger: ring i starts slightly after ring i-1
      final delay = i * 0.12;
      final local = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
      final sweep = 2 * math.pi * (ring.pct / 100) * local;

      final trackPaint = Paint()
        ..color = const Color(0x26FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, trackPaint);

      final fillPaint = Paint()
        ..color = ring.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweep,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.rings != rings;
}

/// Legend rows shown next to the rings (dot + "78% Wellness score").
class RingsLegend extends StatelessWidget {
  final List<RingData> rings;
  const RingsLegend({super.key, required this.rings});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: rings
          .map(
            (r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.5),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: r.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xD9FFFFFF),
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: '${r.pct.toInt()}% ',
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(text: r.label),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
