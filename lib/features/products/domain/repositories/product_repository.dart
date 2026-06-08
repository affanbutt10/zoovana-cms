import '../../../../core/error/result.dart';
import '../entities/product_entity.dart';

/// Abstract contract for product data operations.
///
/// The domain layer depends only on this interface. The concrete
/// implementation ([ProductRepositoryImpl]) lives in the data layer and
/// is injected at runtime via [ProductBinding].
abstract class ProductRepository {
  /// Returns a paginated list of products for the given [page].
  Future<Result<List<ProductEntity>>> getProducts({int page = 1});

  /// Returns the product with the given [id].
  Future<Result<ProductEntity>> getProductById(String id);

  /// Creates a new product from [product] and returns the persisted entity.
  Future<Result<ProductEntity>> createProduct(ProductEntity product);

  /// Updates an existing product with the data in [product] and returns
  /// the updated entity.
  Future<Result<ProductEntity>> updateProduct(ProductEntity product);

  /// Deletes the product with the given [id].
  Future<Result<void>> deleteProduct(String id);

  /// Uploads an image file at [filePath] for the product with [id].
  ///
  /// Returns the URL of the uploaded image on success.
  Future<Result<String>> uploadProductImage(String id, String filePath);

  /// Updates the [status] of the product with [id] and returns the
  /// updated entity.
  Future<Result<ProductEntity>> updateProductStatus(
    String id,
    ProductStatus status,
  );
}
