/// Represents the status of a product in the marketplace.
enum ProductStatus { active, inactive, draft }

/// Domain entity representing a product in the marketplace.
///
/// This is a pure business object, independent of any API response shape.
/// JSON parsing lives in [ProductModel] (data layer).
class ProductEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final ProductStatus status;
  final String categoryId;
  final String vendorId;
  final String? imageUrl;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.status,
    required this.categoryId,
    required this.vendorId,
    this.imageUrl,
  });

  /// Creates a copy of this entity with the given fields replaced.
  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    ProductStatus? status,
    String? categoryId,
    String? vendorId,
    String? imageUrl,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      vendorId: vendorId ?? this.vendorId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          price == other.price &&
          status == other.status &&
          categoryId == other.categoryId &&
          vendorId == other.vendorId &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      price.hashCode ^
      status.hashCode ^
      categoryId.hashCode ^
      vendorId.hashCode ^
      imageUrl.hashCode;

  @override
  String toString() =>
      'ProductEntity(id: $id, name: $name, price: $price, status: $status)';
}
