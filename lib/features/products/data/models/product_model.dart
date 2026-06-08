import '../../domain/entities/product_entity.dart';

/// Data-layer model that parses a product API response.
///
/// Constructed via [ProductModel.fromJson] from the raw API response body.
/// Call [toEntity] to obtain the domain-layer [ProductEntity].
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.status,
    required this.categoryId,
    required this.vendorId,
    this.imageUrl,
  });

  /// Unique identifier for the product.
  final String id;

  /// Display name of the product.
  final String name;

  /// Full description of the product.
  final String description;

  /// Price of the product.
  final double price;

  /// Status string as returned by the API (e.g. 'active', 'inactive', 'draft').
  final String status;

  /// Identifier of the category this product belongs to.
  final String categoryId;

  /// Identifier of the vendor that owns this product.
  final String vendorId;

  /// Optional URL of the product image.
  final String? imageUrl;

  /// Parses a [ProductModel] from the API response JSON map.
  ///
  /// Supports both flat and nested `data` response shapes.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "id": "abc123",
  ///   "name": "Widget Pro",
  ///   "description": "A great widget",
  ///   "price": 29.99,
  ///   "status": "active",
  ///   "category_id": "cat1",
  ///   "vendor_id": "ven1",
  ///   "image_url": "https://example.com/image.png"
  /// }
  /// ```
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Support both flat and nested `data` response shapes.
    final Map<String, dynamic> data =
        (json['data'] as Map<String, dynamic>?) ?? json;

    return ProductModel(
      id: (data['id'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      price: _parseDouble(data['price']),
      status: (data['status'] ?? 'draft').toString(),
      categoryId: (data['category_id'] ?? '').toString(),
      vendorId: (data['vendor_id'] ?? '').toString(),
      imageUrl: data['image_url'] as String?,
    );
  }

  /// Converts this data-layer model to the domain-layer [ProductEntity].
  ///
  /// Maps the status string to the [ProductStatus] enum:
  /// - `'active'`   → [ProductStatus.active]
  /// - `'inactive'` → [ProductStatus.inactive]
  /// - anything else (including `'draft'`) → [ProductStatus.draft]
  ProductEntity toEntity() => ProductEntity(
    id: id,
    name: name,
    description: description,
    price: price,
    status: _parseStatus(status),
    categoryId: categoryId,
    vendorId: vendorId,
    imageUrl: imageUrl,
  );

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Safely parses a numeric value to [double].
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// Maps a status string to the [ProductStatus] enum.
  static ProductStatus _parseStatus(String value) {
    switch (value) {
      case 'active':
        return ProductStatus.active;
      case 'inactive':
        return ProductStatus.inactive;
      default:
        return ProductStatus.draft;
    }
  }
}
