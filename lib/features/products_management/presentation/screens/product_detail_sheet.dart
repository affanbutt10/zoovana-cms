import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_variant_entity.dart';

class ProductDetailSheet extends StatefulWidget {
  final ProductEntity product;
  const ProductDetailSheet({super.key, required this.product});

  static void show(BuildContext context, ProductEntity product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDetailSheet(product: product),
    );
  }

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  int _imageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final hasImages = product.imageUrls.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: hasImages ? 0.92 : 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 40,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              _DragHandle(),

              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: EdgeInsets.zero,
                  children: [
                    // ── Image carousel ─────────────────────
                    if (hasImages)
                      _ImageCarousel(
                        imageUrls: product.imageUrls,
                        selectedIndex: _imageIndex,
                        onSelect: (i) => setState(() => _imageIndex = i),
                      ),

                    // ── Header ─────────────────────────────
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          20, hasImages ? 20 : 4, 20, 0),
                      child: _ProductHeader(product: product),
                    ),

                    const SizedBox(height: 20),

                    // ── Cards ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Pricing card
                          _DetailCard(
                            icon: Icons.payments_rounded,
                            iconColor: AppColors.success,
                            title: 'Pricing',
                            children: [
                              _DetailRow(
                                icon: Icons.sell_rounded,
                                label: 'Selling Price',
                                value: product.price > 0
                                    ? 'SAR ${product.price.toStringAsFixed(2)}'
                                    : 'Not set',
                                highlight: product.price > 0,
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Description card
                          if (product.description != null &&
                              product.description!.isNotEmpty) ...[
                            _DetailCard(
                              icon: Icons.description_rounded,
                              iconColor: AppColors.primary,
                              title: 'Description',
                              children: [
                                _NoteRow(text: product.description!),
                              ],
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Variants card
                          if (product.variants.isNotEmpty) ...[
                            _DetailCard(
                              icon: Icons.layers_rounded,
                              iconColor: AppColors.accent,
                              title:
                                  'Variants  ·  ${product.variants.length}',
                              children: product.variants
                                  .map((v) => _VariantRow(variant: v))
                                  .toList(),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Record info card
                          _DetailCard(
                            icon: Icons.info_outline_rounded,
                            iconColor: AppColors.primary,
                            title: 'Record Information',
                            children: [
                              _DetailRow(
                                icon: Icons.calendar_today_rounded,
                                label: 'Created',
                                value: DateFormat('dd MMM yyyy · HH:mm')
                                    .format(product.createdAt.toLocal()),
                              ),
                              _DetailRow(
                                icon: Icons.update_rounded,
                                label: 'Last Updated',
                                value: DateFormat('dd MMM yyyy · HH:mm')
                                    .format(product.updatedAt.toLocal()),
                              ),
                              _DetailRow(
                                icon: Icons.fingerprint_rounded,
                                label: 'Product ID',
                                value: product.id,
                                mono: true,
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Image carousel
// ─────────────────────────────────────────────────────────────

class _ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _ImageCarousel({
    required this.imageUrls,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main image
        Stack(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              child: Image.network(
                imageUrls[selectedIndex],
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 240,
                  color: AppColors.primary.withValues(alpha: 0.06),
                  child: Center(
                    child: Icon(Icons.inventory_2_rounded,
                        color: AppColors.primary, size: 56),
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.background.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
            ),
            // Image counter badge
            if (imageUrls.length > 1)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${selectedIndex + 1} / ${imageUrls.length}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Thumbnail strip
        if (imageUrls.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final selected = i == selectedIndex;
                  return GestureDetector(
                    onTap: () => onSelect(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.divider,
                          width: selected ? 2.5 : 1,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrls[i],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                              Icons.image_outlined,
                              color: AppColors.textTertiary,
                              size: 20),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Product header
// ─────────────────────────────────────────────────────────────

class _ProductHeader extends StatelessWidget {
  final ProductEntity product;
  const _ProductHeader({required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _StatusBadge(status: product.status),
                  if (product.categoryName != null)
                    _MiniChip(
                      label: product.categoryName!,
                      color: AppColors.highlight,
                      icon: Icons.category_rounded,
                    ),
                  if (product.variants.isNotEmpty)
                    _MiniChip(
                      label: '${product.variants.length} variants',
                      color: AppColors.accent,
                      icon: Icons.layers_rounded,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.close_rounded,
                color: AppColors.textSecondary, size: 18),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Variant row
// ─────────────────────────────────────────────────────────────

class _VariantRow extends StatelessWidget {
  final ProductVariantEntity variant;
  const _VariantRow({required this.variant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(Icons.layers_outlined,
                color: AppColors.accent, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variant.name,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (variant.price > 0)
                  Text(
                    'SAR ${variant.price.toStringAsFixed(2)}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Status badge
// ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status.toLowerCase()) {
      'active' || 'published' => (
          'Active',
          AppColors.success,
          Icons.check_circle_rounded
        ),
      'draft' => ('Draft', AppColors.warning, Icons.edit_rounded),
      'inactive' || 'archived' => (
          'Inactive',
          AppColors.textTertiary,
          Icons.archive_rounded
        ),
      _ => (status, AppColors.textTertiary, Icons.circle_outlined),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Shared widgets
// ─────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.dividerStrong,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _DetailCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 15),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),
          ...children.asMap().entries.map((e) => Column(
                children: [
                  e.value,
                  if (e.key < children.length - 1)
                    Divider(
                        height: 1,
                        indent: 52,
                        endIndent: 16,
                        color: AppColors.divider),
                ],
              )),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool mono;
  final bool highlight;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.mono = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: AppColors.textTertiary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: mono
                      ? AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontFamily: 'monospace',
                          fontSize: 11,
                        )
                      : highlight
                          ? AppTextStyles.titleMedium.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            )
                          : AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  final String text;
  const _NoteRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          height: 1.6,
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _MiniChip(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
