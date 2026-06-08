/// Entity representing a product category in the system.
///
/// This is a domain-level entity that represents a category with all its
/// properties including an optional image. It's immutable and contains only
/// business logic data.
class CategoryEntity {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.productCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          imageUrl == other.imageUrl &&
          productCount == other.productCount &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      imageUrl.hashCode ^
      productCount.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'CategoryEntity(id: $id, name: $name, description: $description, '
        'imageUrl: $imageUrl, productCount: $productCount, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
