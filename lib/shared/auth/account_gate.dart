import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_colors.dart';
import '../../core/config/app_text_styles.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/premium_motion.dart';

bool isGuestUser() {
  final auth = Get.find<AuthController>();
  return auth.status.value != AuthStatus.authenticated ||
      auth.session.value == null;
}

Future<bool> requireAccount(
  BuildContext context, {
  required String action,
}) async {
  if (!isGuestUser()) return true;

  await showPremiumBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.person_crop_circle_badge_plus,
                  color: AppColors.primary,
                  size: 27,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Create an account to continue',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You can explore Zoovana freely. To $action, create an account or sign in to your existing account.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    context.push(AppRoutes.register);
                  },
                  icon: const Icon(CupertinoIcons.person_badge_plus),
                  label: const Text('Create account'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    context.push(AppRoutes.login);
                  },
                  child: const Text('I already have an account'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  return false;
}
