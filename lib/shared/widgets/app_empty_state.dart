import 'package:flutter/material.dart';

import '../../core/config/app_colors.dart';
import '../../core/config/app_text_styles.dart';

/// An empty-state placeholder widget.
///
/// Shown when a list or data set has no items to display.
/// Accepts a required [message] and an optional [icon].
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.message,
    this.icon,
    this.iconSize = 64,
    this.iconColor,
  });

  /// Descriptive message explaining the empty state.
  final String message;

  /// Optional icon displayed above the message.
  /// Defaults to [Icons.inbox_outlined] when not provided.
  final IconData? icon;

  /// Size of the icon. Defaults to 64.
  final double iconSize;

  /// Color of the icon. Defaults to [AppColors.slateLighter].
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: iconSize,
              color: iconColor ?? AppColors.slateLighter,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
