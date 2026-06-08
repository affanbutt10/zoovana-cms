import 'dart:io';

import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_variant_entity.dart';

/// Variant model.
/// API fields: id, sku, selling_price, is_active, created_at, updated_at
class ProductVariantModel {
  final String id;
  final String sku;
  final double sellingPrice;
  final double costPrice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductVariantModel({
    required this.id,
    required this.sku,
    required this.sellingPrice,
    required this.costPrice,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (json['cost_price'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'sku': sku,
        'selling_price': sellingPrice,
        'cost_price': costPrice,
      };

  ProductVariantEntity toEntity() {
    return ProductVariantEntity(
      id: id,
      name: sku,
      price: sellingPrice,
      stock: 0, // stock not returned per-variant in list endpoint
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Product model.
/// API fields: id, name_en, name_ar, description_en, category_id,
///   category.name_en, images[].file_url, variants[].selling_price,
///   status, created_at, updated_at
class ProductModel {
  final String id;
  final String name;        // name_en
  final String? nameAr;     // name_ar
  final String? description; // description_en
  final String categoryId;
  final String? categoryName; // category.name_en
  final String status;
  final List<String> imageUrls; // images[].file_url
  final List<ProductVariantModel> variants;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    required this.categoryId,
    this.categoryName,
    required this.status,
    required this.imageUrls,
    required this.variants,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // images is a list of objects: [{ file_url: "...", is_primary: true }, ...]
    final imagesJson = json['images'] as List<dynamic>? ?? [];
    final imageUrls = imagesJson
        .map((img) {
          if (img is Map<String, dynamic>) {
            return img['file_url']?.toString() ?? '';
          }
          return img.toString();
        })
        .where((url) => url.isNotEmpty)
        .toList();

    final variantsJson = json['variants'] as List<dynamic>? ?? [];

    // category can be nested object or flat id
    final categoryObj = json['category'];
    final categoryId = json['category_id']?.toString() ??
        (categoryObj is Map ? categoryObj['id']?.toString() : null) ??
        '';
    final categoryName = categoryObj is Map
        ? (categoryObj['name_en']?.toString() ??
            categoryObj['name']?.toString())
        : null;

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name_en']?.toString() ?? json['name']?.toString() ?? '',
      nameAr: json['name_ar']?.toString(),
      description: json['description_en']?.toString() ??
          json['description']?.toString(),
      categoryId: categoryId,
      categoryName: categoryName,
      status: json['status']?.toString() ?? 'draft',
      imageUrls: imageUrls,
      variants: variantsJson
          .map((v) =>
              ProductVariantModel.fromJson(v as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  /// Price shown in the UI — first variant's selling_price, or 0.
  double get displayPrice =>
      variants.isNotEmpty ? variants.first.sellingPrice : 0.0;

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      description: description,
      categoryId: categoryId,
      categoryName: categoryName,
      price: displayPrice,
      stock: 0,
      status: status,
      imageUrls: imageUrls,
      variants: variants.map((v) => v.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Request model for creating a product variant.
class CreateVariantRequest {
  final String name;
  final double price;
  final int stock;

  const CreateVariantRequest({
    required this.name,
    required this.price,
    required this.stock,
  });

  Map<String, dynamic> toJson() => {
        'sku': name,
        'selling_price': price,
        'cost_price': price,
      };
}

/// Request model for creating a new product.
class CreateProductRequest {
  final String name;
  final String? description;
  final String categoryId;
  final double price;
  final int stock;
  final List<File> images;
  final List<CreateVariantRequest> variants;

  const CreateProductRequest({
    required this.name,
    this.description,
    required this.categoryId,
    required this.price,
    required this.stock,
    required this.images,
    required this.variants,
  });

  Map<String, dynamic> toJson() => {
        'name_en': name,
        if (description != null && description!.isNotEmpty)
          'description_en': description,
        'category_id': categoryId,
        if (variants.isNotEmpty)
          'variants': variants.map((v) => v.toJson()).toList(),
      };
}

/// Response model for paginated product list.
/// API shape: { success, message, data: [...], meta: { total, page, page_size } }
class ProductListResponse {
  final List<ProductModel> products;
  final int total;
  final int page;
  final int pageSize;

  const ProductListResponse({
    required this.products,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return ProductListResponse(
      products: data
          .map((item) =>
              ProductModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: meta['total'] as int? ?? data.length,
      page: meta['page'] as int? ?? 1,
      pageSize: meta['page_size'] as int? ?? 10,
    );
  }
}
