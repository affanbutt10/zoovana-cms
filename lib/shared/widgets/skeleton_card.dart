import 'package:flutter/material.dart';

import '../../core/config/app_colors.dart';

/// An animated shimmer placeholder card that pulses between two grey shades.
///
/// Uses [AnimationController] + [ColorTween] — no external packages required.
class SkeletonCard extends StatefulWidget {
  const SkeletonCard({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: AppColors.surfaceVariant,
      end: AppColors.surfaceElevated,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// A thin skeleton placeholder for text lines.
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({super.key, required this.width, this.height = 12.0});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(width: width, height: height, borderRadius: 4.0);
  }
}
