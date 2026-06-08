import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/config/app_colors.dart';
import '../../../../../core/config/app_text_styles.dart';
import '../../../../../shared/widgets/app_empty_state.dart';
import '../viewmodels/vendor_viewmodel.dart';

/// Placeholder list view for the Vendors feature.
///
/// Extends [GetView<VendorViewModel>] to access the ViewModel via [controller].
/// Displays a basic scaffold with an [AppEmptyState] placeholder until the
/// full vendor listing is implemented in a future task.
class VendorListScreen extends GetView<VendorViewModel> {
  const VendorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Vendors',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        elevation: 0,
      ),
      body: const SafeArea(
        child: AppEmptyState(
          message: 'No vendors yet.\nVendor management will be available soon.',
          icon: Icons.store_outlined,
        ),
      ),
    );
  }
}
