import 'product_variant_entity.dart';

/// Entity representing a product in the system.
///
/// This is a domain-level entity that represents a product with all its
/// properties including images and variants.
class ProductEntity {
  final String id;
  final String name;
  final String? description;
  final String categoryId;
  final String? categoryName;
  final double price;
  final int stock;
  final String status;
  final List<String> imageUrls;
  final List<ProductVariantEntity> variants;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    this.description,
    required this.categoryId,
    this.categoryName,
    required this.price,
    required this.stock,
    this.status = 'draft',
    required this.imageUrls,
    required this.variants,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          categoryId == other.categoryId &&
          categoryName == other.categoryName &&
          price == other.price &&
          stock == other.stock &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      categoryId.hashCode ^
      categoryName.hashCode ^
      price.hashCode ^
      stock.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'ProductEntity(id: $id, name: $name, description: $description, '
        'categoryId: $categoryId, categoryName: $categoryName, price: $price, '
        'stock: $stock, images: ${imageUrls.length}, variants: ${variants.length}, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
