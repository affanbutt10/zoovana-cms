import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../domain/entities/product_entity.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/product_status_badge.dart';

/// Displays the full details of a single product.
///
/// Reads the product ID from [Get.arguments] and calls
/// [ProductViewModel.fetchProductById] on init. Shows [AppLoader] while
/// loading and an inline error message on failure.
class ProductDetailScreen extends GetView<ProductViewModel> {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch the product when the view is first built.
    final String? productId = Get.arguments as String?;
    if (productId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only fetch if we don't already have the product loaded.
        if (controller.selectedProduct.value?.id != productId) {
          controller.fetchProductById(productId);
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Product Detail', style: AppTextStyles.titleLarge),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Obx(() {
            final product = controller.selectedProduct.value;
            if (product == null) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(Icons.edit_outlined),
              tooltip: 'Edit product',
              onPressed: () => controller.goToEditForm(product),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.selectedProduct.value == null) {
          return const AppLoader();
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.selectedProduct.value == null) {
          return _ErrorState(message: controller.errorMessage.value);
        }

        final product = controller.selectedProduct.value;
        if (product == null) {
          return const _ErrorState(message: 'Product not found.');
        }

        return _ProductDetailBody(product: product);
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _ProductDetailBody extends StatelessWidget {
  const _ProductDetailBody({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _imagePlaceholder,
                ),
              ),
            )
          else
            _imagePlaceholder,
          const SizedBox(height: 20),

          // Name + status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(product.name, style: AppTextStyles.headlineSmall),
              ),
              const SizedBox(width: 8),
              ProductStatusBadge(status: product.status),
            ],
          ),
          const SizedBox(height: 8),

          // Price
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 16),

          // Description
          _SectionLabel(label: 'Description'),
          const SizedBox(height: 4),
          Text(product.description, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),

          // Metadata
          _SectionLabel(label: 'Details'),
          const SizedBox(height: 8),
          _DetailRow(label: 'Product ID', value: product.id),
          _DetailRow(label: 'Category ID', value: product.categoryId),
          _DetailRow(label: 'Vendor ID', value: product.vendorId),
          if (product.imageUrl != null)
            _DetailRow(label: 'Image URL', value: product.imageUrl!),
        ],
      ),
    );
  }

  Widget get _imagePlaceholder => Container(
    height: 200,
    decoration: BoxDecoration(
      color: AppColors.mistLighter,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Center(
      child: Icon(Icons.image_outlined, color: AppColors.slateLighter, size: 64),
    ),
  );
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
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
