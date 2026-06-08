import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/product_entity.dart';
import '../models/product_model.dart';

/// Abstract contract for the product remote data source.
///
/// Throws typed exceptions ([NetworkException] / [ServerException]) on
/// failure — the repository layer catches these and wraps them in [Result].
abstract class ProductRemoteDataSource {
  /// Returns a paginated list of products for the given [page].
  Future<List<ProductModel>> getProducts({int page = 1});

  /// Returns the product with the given [id].
  Future<ProductModel> getProductById(String id);

  /// Creates a new product from [product] and returns the persisted model.
  Future<ProductModel> createProduct(ProductEntity product);

  /// Updates an existing product with the data in [product] and returns
  /// the updated model.
  Future<ProductModel> updateProduct(ProductEntity product);

  /// Deletes the product with the given [id].
  Future<void> deleteProduct(String id);

  /// Uploads an image file at [filePath] for the product with [id] using
  /// multipart form-data.
  ///
  /// Returns the URL of the uploaded image on success.
  Future<String> uploadProductImage(String id, String filePath);

  /// Updates the [status] of the product with [id] and returns the
  /// updated model.
  Future<ProductModel> updateProductStatus(String id, ProductStatus status);
}

/// Concrete implementation that communicates with the Zoovana backend.
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  const ProductRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ProductModel>> getProducts({int page = 1}) async {
    final response = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: {'page': page},
    );

    final List<dynamic> items = _extractList(response.data);
    return items
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.productById(id));
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProductModel> createProduct(ProductEntity product) async {
    final response = await _apiClient.post(
      ApiEndpoints.products,
      data: _entityToJson(product),
    );
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProductModel> updateProduct(ProductEntity product) async {
    final response = await _apiClient.put(
      ApiEndpoints.productById(product.id),
      data: _entityToJson(product),
    );
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _apiClient.delete(ApiEndpoints.productById(id));
  }

  @override
  Future<String> uploadProductImage(String id, String filePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
    });

    final response = await _apiClient.post(
      ApiEndpoints.productImage(id),
      data: formData,
    );

    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    // Support both flat and nested `data` response shapes.
    final Map<String, dynamic> data =
        (body['data'] as Map<String, dynamic>?) ?? body;
    return (data['image_url'] ?? data['url'] ?? '').toString();
  }

  @override
  Future<ProductModel> updateProductStatus(
    String id,
    ProductStatus status,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.productStatus(id),
      data: {'status': _statusToString(status)},
    );
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Extracts the list of items from the API response, supporting both a
  /// flat list and a nested `data` wrapper.
  List<dynamic> _extractList(dynamic responseData) {
    if (responseData is List) return responseData;
    if (responseData is Map<String, dynamic>) {
      final nested = responseData['data'];
      if (nested is List) return nested;
    }
    return [];
  }

  /// Converts a [ProductEntity] to a JSON map for create/update requests.
  Map<String, dynamic> _entityToJson(ProductEntity product) => {
    'name': product.name,
    'description': product.description,
    'price': product.price,
    'status': _statusToString(product.status),
    'category_id': product.categoryId,
    'vendor_id': product.vendorId,
    if (product.imageUrl != null) 'image_url': product.imageUrl,
  };

  /// Converts a [ProductStatus] enum value to its API string representation.
  String _statusToString(ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
        return 'active';
      case ProductStatus.inactive:
        return 'inactive';
      case ProductStatus.draft:
        return 'draft';
    }
  }
}
