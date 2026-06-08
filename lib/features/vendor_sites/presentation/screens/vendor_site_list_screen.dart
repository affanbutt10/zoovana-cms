import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/config/app_colors.dart';
import '../../../../../core/config/app_text_styles.dart';
import '../../../../../shared/widgets/app_empty_state.dart';
import '../viewmodels/vendor_site_viewmodel.dart';

/// Placeholder list view for the Vendor Sites feature.
///
/// Extends [GetView<VendorSiteViewModel>] to access the ViewModel via [controller].
/// Displays a basic scaffold with an [AppEmptyState] placeholder until the
/// full vendor site listing is implemented in a future task.
class VendorSiteListScreen extends GetView<VendorSiteViewModel> {
  const VendorSiteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Vendor Sites',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        elevation: 0,
      ),
      body: const SafeArea(
        child: AppEmptyState(
          message:
              'No vendor sites yet.\nVendor site management will be available soon.',
          icon: Icons.location_on_outlined,
        ),
      ),
    );
  }
}
