import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/premium_motion.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/product_list_item.dart';

/// Displays a paginated, scrollable list of products.
///
/// Shows [AppLoader] while the initial load is in progress, [AppEmptyState]
/// when the list is empty, and a [ListView] of [ProductListItem] widgets
/// otherwise. Triggers [ProductViewModel.fetchNextPage] when the user
/// scrolls to the bottom of the list.
class ProductListScreen extends GetView<ProductViewModel> {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Products', style: AppTextStyles.titleLarge),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add product',
            onPressed: controller.goToCreateForm,
          ),
        ],
      ),
      body: Obx(() {
        // Show full-screen loader only on the initial load (empty list).
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const AppLoader();
        }

        if (controller.products.isEmpty) {
          return AppEmptyState(
            message: 'No products found.\nTap + to add one.',
            icon: Icons.inventory_2_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchProducts,
          color: AppColors.primary,
          child: _ProductList(controller: controller),
        );
      }),
    );
  }
}

/// Internal widget that renders the scrollable product list with pagination.
class _ProductList extends StatefulWidget {
  const _ProductList({required this.controller});

  final ProductViewModel controller;

  @override
  State<_ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<_ProductList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      widget.controller.fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final products = widget.controller.products;
      final isLoadingMore =
          widget.controller.isLoading.value && products.isNotEmpty;

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        // +1 for the loading indicator at the bottom when paginating.
        itemCount: products.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == products.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: AppLoader(),
            );
          }

          final product = products[index];
          return ProductListItem(
            product: product,
            onTap: () => widget.controller.goToDetail(product),
            onDelete: () => _confirmDelete(context, product.id),
          );
        },
      );
    });
  }

  Future<void> _confirmDelete(BuildContext context, String productId) async {
    final confirmed = await showPremiumDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product'),
        content: const Text(
          'Are you sure you want to delete this product? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.controller.deleteProduct(productId);
    }
  }
}
