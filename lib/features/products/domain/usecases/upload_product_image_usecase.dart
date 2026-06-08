import '../../../../core/error/result.dart';
import '../repositories/product_repository.dart';

/// Uploads an image for a product.
///
/// Called by [ProductViewModel.uploadImage].
class UploadProductImageUseCase {
  const UploadProductImageUseCase(this._repository);

  final ProductRepository _repository;

  /// Executes the use case.
  ///
  /// [id] is the unique identifier of the product.
  /// [filePath] is the local file system path of the image to upload.
  /// Returns [Result<String>] where the string is the URL of the uploaded image.
  Future<Result<String>> call(String id, String filePath) {
    return _repository.uploadProductImage(id, filePath);
  }
}
