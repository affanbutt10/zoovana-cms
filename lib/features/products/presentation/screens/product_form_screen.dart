import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/product_entity.dart';
import '../viewmodels/product_viewmodel.dart';

/// A form view reused for both creating and updating a product.
///
/// When [Get.arguments] contains a [ProductEntity], the form is in edit mode
/// and all fields are pre-populated. When arguments are null, the form is in
/// create mode.
///
/// Required fields (name, description, price, categoryId, vendorId) are
/// validated before the UseCase is called. If validation fails, inline errors
/// are shown and no network request is made.
class ProductFormScreen extends GetView<ProductViewModel> {
  const ProductFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductEntity? existing = Get.arguments as ProductEntity?;
    final bool isEditing = existing != null;

    return _ProductFormContent(
      existing: existing,
      isEditing: isEditing,
      controller: controller,
    );
  }
}

// ---------------------------------------------------------------------------
// Stateful form content
// ---------------------------------------------------------------------------

class _ProductFormContent extends StatefulWidget {
  const _ProductFormContent({
    required this.existing,
    required this.isEditing,
    required this.controller,
  });

  final ProductEntity? existing;
  final bool isEditing;
  final ProductViewModel controller;

  @override
  State<_ProductFormContent> createState() => _ProductFormContentState();
}

class _ProductFormContentState extends State<_ProductFormContent> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryIdController;
  late final TextEditingController _vendorIdController;
  late final TextEditingController _imageUrlController;

  late ProductStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p != null ? p.price.toStringAsFixed(2) : '',
    );
    _categoryIdController = TextEditingController(text: p?.categoryId ?? '');
    _vendorIdController = TextEditingController(text: p?.vendorId ?? '');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _selectedStatus = p?.status ?? ProductStatus.draft;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryIdController.dispose();
    _vendorIdController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    final entity = ProductEntity(
      id: widget.existing?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      status: _selectedStatus,
      categoryId: _categoryIdController.text.trim(),
      vendorId: _vendorIdController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
    );

    if (widget.isEditing) {
      await widget.controller.updateProduct(entity);
    } else {
      await widget.controller.createProduct(entity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Product' : 'New Product',
          style: AppTextStyles.titleLarge,
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error banner
              Obx(() {
                final error = widget.controller.errorMessage.value;
                if (error.isEmpty) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    error,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                );
              }),

              // Name
              AppTextField(
                label: 'Name *',
                hint: 'Enter product name',
                controller: _nameController,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              AppTextField(
                label: 'Description *',
                hint: 'Enter product description',
                controller: _descriptionController,
                maxLines: 4,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price
              AppTextField(
                label: 'Price *',
                hint: '0.00',
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category ID
              AppTextField(
                label: 'Category ID *',
                hint: 'Enter category ID',
                controller: _categoryIdController,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Category ID is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Vendor ID
              AppTextField(
                label: 'Vendor ID *',
                hint: 'Enter vendor ID',
                controller: _vendorIdController,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vendor ID is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image URL (optional)
              AppTextField(
                label: 'Image URL',
                hint: 'https://example.com/image.png',
                controller: _imageUrlController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Status dropdown
              _StatusDropdown(
                value: _selectedStatus,
                onChanged: (status) {
                  if (status != null) {
                    setState(() => _selectedStatus = status);
                  }
                },
              ),
              const SizedBox(height: 32),

              // Submit button
              Obx(
                () => AppButton(
                  label: widget.isEditing ? 'Update Product' : 'Create Product',
                  isLoading: widget.controller.isLoading.value,
                  onPressed: _submit,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status dropdown
// ---------------------------------------------------------------------------

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});

  final ProductStatus value;
  final ValueChanged<ProductStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Status', style: AppTextStyles.labelLarge),
        const SizedBox(height: 6),
        DropdownButtonFormField<ProductStatus>(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.mist),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.mist),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          items: ProductStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(
                _statusLabel(status),
                style: AppTextStyles.bodyMedium,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _statusLabel(ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
        return 'Active';
      case ProductStatus.inactive:
        return 'Inactive';
      case ProductStatus.draft:
        return 'Draft';
    }
  }
}
