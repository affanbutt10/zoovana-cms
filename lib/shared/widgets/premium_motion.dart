import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/config/app_colors.dart';

class PremiumMotion {
  const PremiumMotion._();

  static const Curve curve = Curves.easeOutCubic;
  static const Duration routeDuration = Duration(milliseconds: 420);
  static const Duration routeReverseDuration = Duration(milliseconds: 320);
  static const Duration sheetDuration = Duration(milliseconds: 360);
  static const Duration sheetReverseDuration = Duration(milliseconds: 260);
  static const Duration pressDuration = Duration(milliseconds: 120);
}

Future<T?> showPremiumBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useRootNavigator = false,
  bool useSafeArea = true,
  bool isScrollControlled = true,
  bool? showDragHandle,
  Color? backgroundColor,
  ShapeBorder? shape,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    useSafeArea: useSafeArea,
    isScrollControlled: isScrollControlled,
    showDragHandle: showDragHandle ?? true,
    backgroundColor: backgroundColor ?? AppColors.surface,
    barrierColor: AppColors.overlay.withValues(alpha: 0.38),
    shape:
        shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
    sheetAnimationStyle: const AnimationStyle(
      duration: PremiumMotion.sheetDuration,
      reverseDuration: PremiumMotion.sheetReverseDuration,
    ),
    builder: builder,
  );
}

Future<T?> showPremiumDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: CupertinoLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.overlay.withValues(alpha: 0.34),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: PremiumMotion.curve,
        reverseCurve: PremiumMotion.curve,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}
