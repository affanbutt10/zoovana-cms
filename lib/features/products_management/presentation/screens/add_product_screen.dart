import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../../../shop/presentation/controllers/shop_init_controller.dart';
import '../../data/models/product_model.dart';
import '../controllers/product_management_controller.dart';

class AddProductScreen extends StatefulWidget {
  final String branchId;
  const AddProductScreen({super.key, required this.branchId});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();

  final _picker = ImagePicker();
  final List<File> _images = [];

  // Variants
  final List<_VariantRow> _variants = [];

  // Selected category
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    for (final v in _variants) {
      v.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductManagementController>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.6,
        maxChildSize: 0.97,
        expand: false,
        builder: (context, scrollCtrl) {
          return Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2)),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: AppColors.primaryGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_box_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('Add New Product',
                        style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800)),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: AppColors.divider),

              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(24),
                    children: [
                      // ── Images ──────────────────────────────
                      _buildSectionTitle('Product Images'),
                      const SizedBox(height: 10),
                      _buildImagePicker(),
                      const SizedBox(height: 20),

                      // ── Basic info ───────────────────────────
                      _buildSectionTitle('Basic Information'),
                      const SizedBox(height: 10),
                      _buildField(
                        ctrl: _nameCtrl,
                        label: 'Product Name',
                        hint: 'e.g. Premium Dog Food 5kg',
                        icon: Icons.inventory_2_outlined,
                        required: true,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Product name is required'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _buildField(
                        ctrl: _descCtrl,
                        label: 'Description',
                        hint: 'Describe the product…',
                        icon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 14),

                      // ── Category ─────────────────────────────
                      _buildSectionTitle('Category'),
                      const SizedBox(height: 10),
                      _buildCategoryPicker(),
                      const SizedBox(height: 20),

                      // ── Pricing & Stock ──────────────────────
                      _buildSectionTitle('Pricing & Stock'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              ctrl: _priceCtrl,
                              label: 'Price (SAR)',
                              hint: '0.00',
                              icon: Icons.payments_outlined,
                              required: true,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'))
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(v) == null) {
                                  return 'Invalid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildField(
                              ctrl: _stockCtrl,
                              label: 'Stock',
                              hint: '0',
                              icon: Icons.warehouse_outlined,
                              required: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (int.tryParse(v) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Variants ─────────────────────────────
                      _buildSectionTitle('Variants (optional)'),
                      const SizedBox(height: 4),
                      Text(
                        'Add size, colour, or other options',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.textTertiary),
                      ),
                      const SizedBox(height: 10),
                      _buildVariantSection(),
                      const SizedBox(height: 24),

                      // ── Submit ───────────────────────────────
                      Obx(() {
                        final creating = controller.createStatus.value ==
                            ProductCreateStatus.creating;
                        return ElevatedButton(
                          onPressed: creating ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: creating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text('Add Product',
                                  style: AppTextStyles.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                        );
                      }),

                      // Error
                      Obx(() {
                        final msg =
                            controller.createErrorMessage.value;
                        if (msg.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color:
                                      AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: AppColors.error, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(msg,
                                      style: AppTextStyles.bodySmall
                                          .copyWith(color: AppColors.error)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary, fontWeight: FontWeight.w700));
  }

  Widget _buildField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label,
              style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          if (required) ...[
            const SizedBox(width: 4),
            Text('*', style: TextStyle(color: AppColors.error, fontSize: 16)),
          ],
        ]),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textTertiary),
            prefixIcon:
                Icon(icon, color: AppColors.textSecondary, size: 20),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.divider)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: AppColors.primary, width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.error)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: AppColors.error, width: 2)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        // Existing images
        if (_images.isNotEmpty)
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                if (i == _images.length) {
                  return _addImageTile();
                }
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_images[i],
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _images.removeAt(i)),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        else
          _addImageTile(fullWidth: true),
      ],
    );
  }

  Widget _addImageTile({bool fullWidth = false}) {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: fullWidth ? double.infinity : 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColors.divider, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: AppColors.textTertiary, size: 28),
            if (fullWidth) ...[
              const SizedBox(height: 6),
              Text('Add images',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPicker() {
    final catCtrl = Get.find<CategoryController>();
    final branchId =
        Get.find<ShopInitController>().activeBranchId.value;

    // Trigger load if not yet loaded
    if (catCtrl.status.value == CategoryStatus.idle) {
      catCtrl.loadCategories(branchId: branchId);
    }

    return Obx(() {
      if (catCtrl.status.value == CategoryStatus.loading) {
        return Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2),
            ),
          ),
        );
      }

      final categories = catCtrl.categories;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedCategoryId == null
                ? AppColors.divider
                : AppColors.primary,
            width: _selectedCategoryId == null ? 1 : 1.5,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedCategoryId,
            isExpanded: true,
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.category_outlined,
                      color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Text('Select category',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            borderRadius: BorderRadius.circular(12),
            dropdownColor: AppColors.surface,
            items: categories
                .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(c.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary)),
                      ),
                    ))
                .toList(),
            onChanged: (id) {
              setState(() {
                _selectedCategoryId = id;
                _selectedCategoryName = categories
                    .firstWhereOrNull((c) => c.id == id)
                    ?.name;
              });
            },
          ),
        ),
      );
    });
  }

  Widget _buildVariantSection() {
    return Column(
      children: [
        ..._variants.asMap().entries.map((e) {
          final i = e.key;
          final v = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Variant ${i + 1}',
                        style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _variants.removeAt(i)),
                      child: Icon(Icons.delete_outline_rounded,
                          color: AppColors.error, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: v.nameCtrl,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textPrimary),
                  decoration: _inputDeco('Name (e.g. Large)',
                      Icons.label_outline),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: v.priceCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'))
                        ],
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textPrimary),
                        decoration:
                            _inputDeco('Price', Icons.payments_outlined),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: v.stockCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textPrimary),
                        decoration:
                            _inputDeco('Stock', Icons.warehouse_outlined),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () =>
              setState(() => _variants.add(_VariantRow())),
          icon: Icon(Icons.add_circle_outline_rounded,
              color: AppColors.primary, size: 18),
          label: Text('Add Variant',
              style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
      filled: true,
      fillColor: AppColors.background,
      isDense: true,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.divider)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.divider)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked.isNotEmpty) {
        setState(() {
          _images.addAll(picked.map((x) => File(x.path)));
        });
      }
    } catch (e) {
      debugPrint('[ADD_PRODUCT] Image pick error: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please select a category'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final controller = Get.find<ProductManagementController>();

    final variants = _variants
        .where((v) => v.nameCtrl.text.trim().isNotEmpty)
        .map((v) => CreateVariantRequest(
              name: v.nameCtrl.text.trim(),
              price: double.tryParse(v.priceCtrl.text) ?? 0,
              stock: int.tryParse(v.stockCtrl.text) ?? 0,
            ))
        .toList();

    final request = CreateProductRequest(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty
          ? null
          : _descCtrl.text.trim(),
      categoryId: _selectedCategoryId!,
      price: double.parse(_priceCtrl.text),
      stock: int.parse(_stockCtrl.text),
      images: _images,
      variants: variants,
    );

    final success = await controller.createNewProduct(
      branchId: widget.branchId,
      request: request,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('"${request.name}" added successfully'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
      controller.resetCreateStatus();
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  Variant row helper
// ─────────────────────────────────────────────────────────────

class _VariantRow {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final stockCtrl = TextEditingController();

  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
  }
}
