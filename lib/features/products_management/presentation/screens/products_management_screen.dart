import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/premium_motion.dart';
import '../../../shop/presentation/controllers/shop_init_controller.dart';
import '../controllers/product_management_controller.dart';
import 'add_product_screen.dart';
import 'product_detail_sheet.dart';

class ProductsManagementScreen extends GetView<ProductManagementController> {
  const ProductsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final branchId = Get.find<ShopInitController>().activeBranchId.value;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.status.value == ProductMgmtStatus.idle) {
        controller.loadProducts(branchId: branchId);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            shadowColor: AppColors.divider,
            elevation: 0,
            scrolledUnderElevation: 1,
            toolbarHeight: 60,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: AppColors.primary,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Products',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () => _showAddProduct(context, branchId),
                ),
              ),
            ],
          ),

          // ── Content ──────────────────────────────────────
          Obx(() {
            if (controller.status.value == ProductMgmtStatus.loading &&
                controller.products.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ),
              );
            }

            if (controller.status.value == ProductMgmtStatus.error &&
                controller.products.isEmpty) {
              return SliverFillRemaining(
                child: _ErrorState(
                  message: controller.errorMessage.value,
                  onRetry: () => controller.loadProducts(branchId: branchId),
                ),
              );
            }

            if (controller.products.isEmpty) {
              return SliverFillRemaining(
                child: _EmptyState(
                  onAdd: () => _showAddProduct(context, branchId),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == controller.products.length) {
                      if (controller.hasMore.value) {
                        controller.loadMore(branchId);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    final product = controller.products[index];
                    return _ProductCard(
                      name: product.name,
                      categoryName: product.categoryName,
                      price: product.price,
                      stock: product.stock,
                      imageUrl: product.imageUrls.isNotEmpty
                          ? product.imageUrls.first
                          : null,
                      variantCount: product.variants.length,
                      onTap: () => ProductDetailSheet.show(context, product),
                    );
                  },
                  childCount:
                      controller.products.length +
                      (controller.hasMore.value ? 1 : 0),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showAddProduct(BuildContext context, String branchId) {
    showPremiumBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddProductScreen(branchId: branchId),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Product card
// ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final String name;
  final String? categoryName;
  final double price;
  final int stock;
  final String? imageUrl;
  final int variantCount;
  final VoidCallback onTap;

  const _ProductCard({
    required this.name,
    this.categoryName,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.variantCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = stock > 0 && stock <= 5;
    final isOutOfStock = stock == 0;
    final stockColor = isOutOfStock
        ? AppColors.error
        : isLowStock
        ? AppColors.warning
        : AppColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAtElevation(1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Thumbnail
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.inventory_2_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.inventory_2_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (categoryName != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          categoryName!,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'SAR ${price.toStringAsFixed(2)}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: stockColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: stockColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              isOutOfStock ? 'Out of stock' : '$stock in stock',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: stockColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          if (variantCount > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$variantCount variants',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Error / Empty states
// ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: AppColors.textTertiary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No products yet',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first product to get started',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
