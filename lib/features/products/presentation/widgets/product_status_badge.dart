import 'package:flutter/material.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../domain/entities/product_entity.dart';

/// A compact badge that displays a product's status with a color-coded
/// background.
///
/// Maps [ProductStatus] values to distinct colors defined in [AppColors]:
/// - [ProductStatus.active]   → green ([AppColors.statusActive])
/// - [ProductStatus.inactive] → red ([AppColors.statusInactive])
/// - [ProductStatus.draft]    → amber ([AppColors.statusDraft])
class ProductStatusBadge extends StatelessWidget {
  const ProductStatusBadge({super.key, required this.status});

  /// The product status to display.
  final ProductStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _backgroundColor, width: 1),
      ),
      child: Text(
        _label,
        style: AppTextStyles.labelSmall.copyWith(
          color: _backgroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Returns the display label for the status.
  String get _label {
    switch (status) {
      case ProductStatus.active:
        return 'Active';
      case ProductStatus.inactive:
        return 'Inactive';
      case ProductStatus.draft:
        return 'Draft';
    }
  }

  /// Returns the color associated with the status.
  Color get _backgroundColor {
    switch (status) {
      case ProductStatus.active:
        return AppColors.statusActive;
      case ProductStatus.inactive:
        return AppColors.statusInactive;
      case ProductStatus.draft:
        return AppColors.statusDraft;
    }
  }
}
