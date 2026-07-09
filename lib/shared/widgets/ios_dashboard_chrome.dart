import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/config/app_colors.dart';

const Curve iosDashboardCurve = Curves.easeOutCubic;
const Duration iosTapDuration = Duration(milliseconds: 120);
const Duration iosSwitchDuration = Duration(milliseconds: 350);

List<BoxShadow> iosCardShadows([Color? accent]) => [
  BoxShadow(
    color: (accent ?? AppColors.secondary).withValues(alpha: 0.06),
    blurRadius: 24,
    offset: const Offset(0, 12),
    spreadRadius: -12,
  ),
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.045),
    blurRadius: 3,
    offset: const Offset(0, 1),
  ),
];

class IosPressable extends StatefulWidget {
  const IosPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.borderRadius,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final BorderRadius? borderRadius;
  final HitTestBehavior behavior;

  @override
  State<IosPressable> createState() => _IosPressableState();
}

class _IosPressableState extends State<IosPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
      onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
      onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
      onTap: widget.onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              widget.onTap?.call();
            },
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: iosTapDuration,
        curve: iosDashboardCurve,
        child: widget.borderRadius == null
            ? widget.child
            : ClipRRect(
                borderRadius: widget.borderRadius!,
                child: widget.child,
              ),
      ),
    );
  }
}

class IosGlass extends StatelessWidget {
  const IosGlass({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.color,
    this.borderColor,
    this.padding,
    this.blur = 20,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final Color? color;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppColors.surface.withValues(alpha: 0.78),
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.24),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class IosIconButton extends StatelessWidget {
  const IosIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.foregroundColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final button = IosPressable(
      onTap: onTap,
      scale: 0.94,
      borderRadius: BorderRadius.circular(12),
      child: IosGlass(
        blur: 16,
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface.withValues(alpha: 0.70),
        borderColor: AppColors.divider.withValues(alpha: 0.55),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            size: 20,
            color: foregroundColor ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class IosSwitcher extends StatelessWidget {
  const IosSwitcher({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: iosSwitchDuration,
      switchInCurve: iosDashboardCurve,
      switchOutCurve: Curves.easeOutCubic,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.025),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: iosDashboardCurve));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: child,
    );
  }
}

Widget buildFrostedAppBarBackground() {
  return ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.78),
          border: Border(
            bottom: BorderSide(
              color: AppColors.divider.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    ),
  );
}
