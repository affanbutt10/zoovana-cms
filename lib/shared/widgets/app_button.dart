import 'package:flutter/material.dart';

import '../../core/config/app_colors.dart';
import '../../core/config/app_text_styles.dart';

/// A primary action button with an optional loading state.
///
/// When [isLoading] is `true` the label is replaced by a small
/// [CircularProgressIndicator] and the button is disabled.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  /// Text displayed on the button.
  final String label;

  /// Callback invoked when the button is tapped.
  /// Set to `null` to disable the button.
  final VoidCallback? onPressed;

  /// When `true`, shows a loading indicator and disables the button.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isLoading && onPressed != null;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
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
                disabledBackgroundColor: AppColors.primaryDisabled,
                foregroundColor: AppColors.textOnPrimary,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ).copyWith(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return AppColors.primaryDisabled;
                  }
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
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textOnPrimary,
                    ),
                  ),
                )
              : Text(label, style: AppTextStyles.button),
        ),
      ),
    );
  }
}
