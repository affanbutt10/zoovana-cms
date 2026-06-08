import '../../../../core/error/app_error.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

/// Concrete implementation of [ProductRepository].
///
/// Wraps every data-source call in a try/catch and converts typed exceptions
/// into [Failure] objects, keeping exception handling out of the
/// domain and presentation layers.
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._remoteDataSource);

  final ProductRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<ProductEntity>>> getProducts({int page = 1}) async {
    try {
      final models = await _remoteDataSource.getProducts(page: page);
      return Success(models.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return Failure(AppError.network(e.message));
    } on ServerException catch (e) {
      return Failure(AppError.serverError(e.message));
    } catch (e) {
      return Failure(AppError.serverError(e.toString()));
    }
  }

  @override
  Future<Result<ProductEntity>> getProductById(String id) async {
    try {
      final model = await _remoteDataSource.getProductById(id);
      return Success(model.toEntity());
    } on NetworkException catch (e) {
      return Failure(AppError.network(e.message));
    } on ServerException catch (e) {
      return Failure(AppError.serverError(e.message));
    } catch (e) {
      return Failure(AppError.serverError(e.toString()));
    }
  }

  @override
  Future<Result<ProductEntity>> createProduct(ProductEntity product) async {
    try {
      final model = await _remoteDataSource.createProduct(product);
      return Success(model.toEntity());
    } on NetworkException catch (e) {
      return Failure(AppError.network(e.message));
    } on ServerException catch (e) {
      return Failure(AppError.serverError(e.message));
    } catch (e) {
      return Failure(AppError.serverError(e.toString()));
    }
  }

  @override
  Future<Result<ProductEntity>> updateProduct(ProductEntity product) async {
    try {
      final model = await _remoteDataSource.updateProduct(product);
      return Success(model.toEntity());
    } on NetworkException catch (e) {
      return Failure(AppError.network(e.message));
    } on ServerException catch (e) {
      return Failure(AppError.serverError(e.message));
    } catch (e) {
      return Failure(AppError.serverError(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteProduct(String id) async {
    try {
      await _remoteDataSource.deleteProduct(id);
      return const Success(null);
    } on NetworkException catch (e) {
      return Failure(AppError.network(e.message));
    } on ServerException catch (e) {
      return Failure(AppError.serverError(e.message));
    } catch (e) {
      return Failure(AppError.serverError(e.toString()));
    }
  }

  @override
  Future<Result<String>> uploadProductImage(String id, String filePath) async {
    try {
      final imageUrl = await _remoteDataSource.uploadProductImage(id, filePath);
      return Success(imageUrl);
    } on NetworkException catch (e) {
      return Failure(AppError.network(e.message));
    } on ServerException catch (e) {
      return Failure(AppError.serverError(e.message));
    } catch (e) {
      return Failure(AppError.serverError(e.toString()));
    }
  }

  @override
  Future<Result<ProductEntity>> updateProductStatus(
    String id,
    ProductStatus status,
  ) async {
    try {
      final model = await _remoteDataSource.updateProductStatus(id, status);
      return Success(model.toEntity());
    } on NetworkException catch (e) {
      return Failure(AppError.network(e.message));
    } on ServerException catch (e) {
      return Failure(AppError.serverError(e.message));
    } catch (e) {
      return Failure(AppError.serverError(e.toString()));
    }
  }
}
