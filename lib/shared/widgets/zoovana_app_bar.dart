import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';
import '../../core/config/app_text_styles.dart';
import 'app_logo.dart';

/// Custom AppBar used across all main screens.
class ZoovanaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ZoovanaAppBar({
    super.key,
    this.title,
    this.showLogo = false,
    this.showBack = false,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String? title;
  final bool showLogo;
  final bool showBack;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.divider,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: foregroundColor ?? AppColors.textPrimary,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: showLogo
          ? Row(
              children: [
                const AppLogoTile(size: 32, radius: 8, showShadow: false),
                const SizedBox(width: 8),
                Text(
                  'Zoovana',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            )
          : title != null
          ? Text(
              title!,
              style: AppTextStyles.titleMedium.copyWith(
                color: foregroundColor ?? AppColors.textPrimary,
              ),
            )
          : null,
      actions: actions,
    );
  }
}
