import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/shop_init_controller.dart';

/// Shop initialization loading screen.
///
/// Calls [ShopInitController.initialize] in [initState] and displays:
/// - A circular progress indicator when [status == ShopInitStatus.loading]
/// - A retry button and error message when [status == ShopInitStatus.error]
/// - A success state when [status == ShopInitStatus.ready]
///
/// Requirements: 14.5, 14.6, 14.7, 20.8
class ShopInitLoadingScreen extends StatefulWidget {
  const ShopInitLoadingScreen({super.key});

  @override
  State<ShopInitLoadingScreen> createState() => _ShopInitLoadingScreenState();
}

class _ShopInitLoadingScreenState extends State<ShopInitLoadingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<ShopInitController>();
      // Reset any stale error state from a previous run (e.g. hot restart)
      // so the loading UI shows immediately instead of the error screen.
      if (controller.status.value == ShopInitStatus.error) {
        controller.reset();
      }
      controller.initialize();
    });
  }

  // ---------------------------------------------------------------------------
  // Error display
  // ---------------------------------------------------------------------------

  String _errorMessage() {
    final error = Get.find<ShopInitController>().error.value;
    if (error == null) return 'An unexpected error occurred.';

    if (error.networkError) {
      return 'Unable to connect to server.\nPlease check your internet connection.';
    }
    if (error.unauthorized) return 'Session expired. Please login again.';
    if (error.forbidden) {
      // Show the actual error message from backend if available,
      // which may contain more context like "Account setup pending"
      return error.message.isNotEmpty
          ? error.message
          : 'You do not have permission to access this account.';
    }
    if (error.notFound) {
      return 'Required setup data not found.\nPlease contact support.';
    }
    if (error.serverError) return 'Server error. Please try again later.';
    // Show the real mapped message (e.g. "Response format mismatch")
    return error.message.isNotEmpty
        ? error.message
        : 'An unexpected error occurred.';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            final controller = Get.find<ShopInitController>();
            final status = controller.status.value;

            // Loading state
            if (status == ShopInitStatus.loading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Setting up your shop...',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please wait while we load your data.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Error state
            if (status == ShopInitStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: 40,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Initialization Failed',
                      style: AppTextStyles.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _errorMessage(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final error = controller.error.value;
                          // If session expired or unauthorized, logout and go to login
                          if (error?.unauthorized == true) {
                            await Get.find<AuthController>().logout();
                            if (context.mounted) {
                              context.go(AppRoutes.login);
                            }
                          } else {
                            // Otherwise, retry initialization
                            controller.initialize();
                          }
                        },
                        icon: Icon(
                          controller.error.value?.unauthorized == true
                              ? Icons.login
                              : Icons.refresh,
                          color: AppColors.white,
                        ),
                        label: Text(
                          controller.error.value?.unauthorized == true
                              ? 'Go to Login'
                              : 'Retry',
                          style: AppTextStyles.button,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Ready state
            if (status == ShopInitStatus.ready) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 44,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ready!',
                      style: AppTextStyles.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your shop is ready. Redirecting...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // Idle state (should not be visible in normal flow)
            return Center(
              child: Text(
                'Waiting to initialize...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
