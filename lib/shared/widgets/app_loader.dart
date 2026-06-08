import 'package:flutter/material.dart';

import '../../core/config/app_colors.dart';

/// A centered loading indicator.
///
/// Displays a [CircularProgressIndicator] in the center of its available space.
/// Suitable for full-screen loading states or inline loading placeholders.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.color});

  /// Color of the progress indicator. Defaults to [AppColors.primary].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
      ),
    );
  }
}
