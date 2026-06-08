/// Entity representing a product variant.
///
/// Variants allow a single product to have multiple options (e.g., sizes, colors)
/// with different prices and stock levels.
class ProductVariantEntity {
  final String id;
  final String name;
  final double price;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductVariantEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariantEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          price == other.price &&
          stock == other.stock &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      price.hashCode ^
      stock.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'ProductVariantEntity(id: $id, name: $name, price: $price, '
        'stock: $stock, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
