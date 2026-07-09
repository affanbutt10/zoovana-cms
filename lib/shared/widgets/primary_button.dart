import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';
import '../../core/config/app_text_styles.dart';

/// Full-width primary action button.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isLoading && onPressed != null;
    final baseColor = color ?? AppColors.primary;
    final usesDefaultPrimary = color == null;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style:
              ElevatedButton.styleFrom(
                foregroundColor: AppColors.textOnPrimary,
                disabledBackgroundColor: usesDefaultPrimary
                    ? AppColors.primaryDisabled
                    : baseColor.withValues(alpha: 0.5),
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ).copyWith(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return usesDefaultPrimary
                        ? AppColors.primaryDisabled
                        : baseColor.withValues(alpha: 0.5);
                  }
                  if (!usesDefaultPrimary) return baseColor;
                  if (states.contains(WidgetState.pressed)) {
                    return AppColors.primaryPressed;
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return AppColors.primaryHover;
                  }
                  return AppColors.primary;
                }),
              ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.textOnPrimary,
                  ),
                )
              : icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                    Text(label, style: AppTextStyles.button),
                  ],
                )
              : Text(label, style: AppTextStyles.button),
        ),
      ),
    );
  }
}
