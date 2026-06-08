# Tasks

## Task List

- [x] 1. Update pubspec.yaml with all required dependencies
  - [x] 1.1 Add `get: ^4.7.3` to dependencies
  - [x] 1.2 Add `dio: ^5.4.0` to dependencies
  - [x] 1.3 Add `shared_preferences: ^2.2.2` to dependencies
  - [x] 1.4 Add `flutter_secure_storage: ^10.0.0` to dependencies
  - [x] 1.5 Add `connectivity_plus: ^6.1.4` to dependencies
  - [x] 1.6 Add `intl: ^0.20.2` to dependencies
  - [x] 1.7 Add `logger: ^2.0.2` to dependencies
  - [x] 1.8 Add `flutter_screenutil: ^5.9.0` to dependencies
  - [x] 1.9 Add `google_fonts: ^6.1.0` to dependencies

- [x] 2. Create core error types
  - [x] 2.1 Create `lib/core/error/exceptions.dart` with `NetworkException`, `ServerException`, `CacheException`
  - [x] 2.2 Create `lib/core/error/failures.dart` with `Failure` class (message, optional statusCode)
  - [x] 2.3 Create `lib/core/error/result.dart` with `Result<T>` generic class (success/failure factories, `when` method)

- [x] 3. Create core configuration files
  - [x] 3.1 Create `lib/core/config/app_colors.dart` with color constants
  - [x] 3.2 Create `lib/core/config/app_strings.dart` with string constants
  - [x] 3.3 Create `lib/core/config/app_text_styles.dart` with TextStyle constants
  - [x] 3.4 Create `lib/core/config/app_assets.dart` with asset path constants
  - [x] 3.5 Create `lib/core/config/app_config.dart` with environment configuration (baseUrl, env name)
  - [x] 3.6 Create `lib/core/config/app_env.dart` with environment enum (dev, staging, prod)

- [x] 4. Create core utilities
  - [x] 4.1 Create `lib/core/utils/validators.dart` with `Validators` class (email, phone, required)
  - [x] 4.2 Create `lib/core/utils/date_time_utils.dart` with `DateTimeUtils` formatting helpers
  - [x] 4.3 Create `lib/core/utils/app_logger.dart` wrapping the `logger` package

- [x] 5. Create core storage services
  - [x] 5.1 Create `lib/core/storage/secure_storage_service.dart` with `writeToken`, `readToken`, `deleteToken`
  - [x] 5.2 Create `lib/core/storage/local_storage_service.dart` with typed get/set/remove/clear methods

- [x] 6. Create core network layer
  - [x] 6.1 Create `lib/core/network/api_endpoints.dart` with all API path constants as `static const String`
  - [x] 6.2 Create `lib/core/network/interceptors/auth_interceptor.dart` (injects Bearer token; redirects on 401)
  - [x] 6.3 Create `lib/core/network/interceptors/error_interceptor.dart` (converts DioException to typed Failure)
  - [x] 6.4 Create `lib/core/network/interceptors/logging_interceptor.dart` (logs requests/responses in debug mode)
  - [x] 6.5 Create `lib/core/network/api_client.dart` extending `GetxService` with Dio configuration and HTTP methods

- [x] 7. Create core services
  - [x] 7.1 Create `lib/core/services/connectivity_service.dart` extending `GetxService` with reactive `isConnected`
  - [x] 7.2 Create `lib/core/services/permission_service.dart` with request/check permission methods
  - [x] 7.3 Create `lib/core/services/notification_service.dart` with local notification display methods

- [x] 8. Create global dependency injection
  - [x] 8.1 Create `lib/core/di/dependency_injection.dart` registering `ApiClient` (putAsync), `SecureStorageService`, `LocalStorageService`, `ConnectivityService`

- [x] 9. Create shared widgets and utilities
  - [x] 9.1 Create `lib/shared/widgets/app_button.dart` (label, onPressed, isLoading)
  - [x] 9.2 Create `lib/shared/widgets/app_text_field.dart` (label, hint, controller, validator, obscureText)
  - [x] 9.3 Create `lib/shared/widgets/app_loader.dart` (centered CircularProgressIndicator)
  - [x] 9.4 Create `lib/shared/widgets/app_empty_state.dart` (message, optional icon)
  - [x] 9.5 Create `lib/shared/models/pagination_model.dart` parsing currentPage, lastPage, total, perPage
  - [x] 9.6 Create `lib/shared/extensions/context_extension.dart` with screen size and theme helpers
  - [x] 9.7 Create `lib/shared/extensions/string_extension.dart` with `capitalize` and `isNullOrEmpty`

- [x] 10. Create routing
  - [x] 10.1 Create `lib/routes/app_routes.dart` with all route name constants (splash, login, dashboard, products, productDetail, productForm, vendors, vendorSites, settings)
  - [x] 10.2 Create `lib/routes/app_pages.dart` mapping each route to its View and Binding using `GetPage`

- [x] 11. Create app entry point and root widget
  - [x] 11.1 Create `lib/app.dart` with `GetMaterialApp` configured with `initialRoute`, `getPages`, and `defaultTransition`; initialize `ScreenUtil`
  - [x] 11.2 Rewrite `lib/main.dart` to call `DependencyInjection.init()` then `runApp(const App())`

- [x] 12. Create auth feature
  - [x] 12.1 Create `lib/features/auth/domain/entities/user_entity.dart` with id, name, email, token fields
  - [x] 12.2 Create `lib/features/auth/domain/repositories/auth_repository.dart` abstract interface
  - [x] 12.3 Create `lib/features/auth/domain/usecases/login_usecase.dart`
  - [x] 12.4 Create `lib/features/auth/domain/usecases/logout_usecase.dart`
  - [x] 12.5 Create `lib/features/auth/data/models/login_request_model.dart`
  - [x] 12.6 Create `lib/features/auth/data/models/login_response_model.dart` with `fromJson` and `toEntity()`
  - [x] 12.7 Create `lib/features/auth/data/datasources/auth_remote_datasource.dart`
  - [x] 12.8 Create `lib/features/auth/data/repositories/auth_repository_impl.dart`
  - [x] 12.9 Create `lib/features/auth/presentation/viewmodels/login_viewmodel.dart` with isLoading, errorMessage observables; stores token on success; navigates to dashboard
  - [x] 12.10 Create `lib/features/auth/presentation/views/login_view.dart` with email/password form, submit button, error display
  - [x] 12.11 Create `lib/features/auth/presentation/widgets/login_form.dart`
  - [x] 12.12 Create `lib/features/auth/presentation/bindings/auth_binding.dart` registering all auth dependencies via lazyPut

- [x] 13. Create products feature — domain layer
  - [x] 13.1 Create `lib/features/products/domain/entities/product_entity.dart` with id, name, description, price, status (ProductStatus enum), categoryId, vendorId, imageUrl
  - [x] 13.2 Create `lib/features/products/domain/repositories/product_repository.dart` abstract interface with getProducts, getProductById, createProduct, updateProduct, deleteProduct, uploadProductImage, updateProductStatus
  - [x] 13.3 Create `lib/features/products/domain/usecases/get_products_usecase.dart`
  - [x] 13.4 Create `lib/features/products/domain/usecases/get_product_by_id_usecase.dart`
  - [x] 13.5 Create `lib/features/products/domain/usecases/create_product_usecase.dart`
  - [x] 13.6 Create `lib/features/products/domain/usecases/update_product_usecase.dart`
  - [x] 13.7 Create `lib/features/products/domain/usecases/delete_product_usecase.dart`
  - [x] 13.8 Create `lib/features/products/domain/usecases/upload_product_image_usecase.dart`
  - [x] 13.9 Create `lib/features/products/domain/usecases/update_product_status_usecase.dart`

- [x] 14. Create products feature — data layer
  - [x] 14.1 Create `lib/features/products/data/models/product_model.dart` with `fromJson` and `toEntity()`
  - [x] 14.2 Create `lib/features/products/data/datasources/product_remote_datasource.dart` with getProducts (page param), getProductById, createProduct, updateProduct, deleteProduct, uploadProductImage (multipart), updateProductStatus
  - [x] 14.3 Create `lib/features/products/data/repositories/product_repository_impl.dart` implementing all repository methods with try/catch → Result wrapping

- [x] 15. Create products feature — presentation layer
  - [x] 15.1 Create `lib/features/products/presentation/viewmodels/product_viewmodel.dart` with products, isLoading, errorMessage, currentPage, lastPage observables; all CRUD methods; pagination (fetchNextPage only when currentPage < lastPage)
  - [x] 15.2 Create `lib/features/products/presentation/views/product_list_view.dart` showing AppLoader while loading, AppEmptyState when empty, scrollable list with pagination trigger on scroll end
  - [x] 15.3 Create `lib/features/products/presentation/views/product_detail_view.dart` displaying all product fields; shows error message on failure
  - [x] 15.4 Create `lib/features/products/presentation/views/product_form_view.dart` reused for create and update; pre-populates fields for update; validates required fields before calling UseCase
  - [x] 15.5 Create `lib/features/products/presentation/widgets/product_list_item.dart`
  - [x] 15.6 Create `lib/features/products/presentation/widgets/product_status_badge.dart` displaying visual status indicator
  - [x] 15.7 Create `lib/features/products/presentation/bindings/product_binding.dart` registering ProductRemoteDataSource, ProductRepositoryImpl, all UseCases, and ProductViewModel via lazyPut

- [x] 16. Create dashboard feature scaffold
  - [x] 16.1 Create `lib/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart` (placeholder)
  - [x] 16.2 Create `lib/features/dashboard/presentation/views/dashboard_view.dart` (placeholder — initial screen after login)
  - [x] 16.3 Create `lib/features/dashboard/presentation/bindings/dashboard_binding.dart`

- [x] 17. Create vendors feature scaffold
  - [x] 17.1 Create `lib/features/vendors/domain/entities/vendor_entity.dart` with id, name, email, status, createdAt
  - [x] 17.2 Create `lib/features/vendors/presentation/viewmodels/vendor_viewmodel.dart` (placeholder)
  - [x] 17.3 Create `lib/features/vendors/presentation/views/vendor_list_view.dart` (placeholder)
  - [x] 17.4 Create `lib/features/vendors/presentation/bindings/vendor_binding.dart`

- [x] 18. Create vendor sites feature scaffold
  - [x] 18.1 Create `lib/features/vendor_sites/domain/entities/vendor_site_entity.dart` with id, vendorId, name, address, status
  - [x] 18.2 Create `lib/features/vendor_sites/presentation/viewmodels/vendor_site_viewmodel.dart` (placeholder)
  - [x] 18.3 Create `lib/features/vendor_sites/presentation/views/vendor_site_list_view.dart` (placeholder)
  - [x] 18.4 Create `lib/features/vendor_sites/presentation/bindings/vendor_site_binding.dart`

- [x] 19. Write unit and property-based tests
  - [x] 19.1 Write unit tests for `Result<T>`: success factory, failure factory, `when` dispatch, `isSuccess`
  - [x] 19.2 Write property-based test for Result exhaustiveness (Property 1): for any Result, `when` calls exactly one callback
  - [x] 19.3 Write property-based test for ProductModel round trip (Property 2): random JSON → fromJson → toEntity → field equality
  - [x] 19.4 Write property-based test for LoginResponseModel round trip (Property 3): random JSON → fromJson → toEntity → field equality
  - [x] 19.5 Write property-based test for PaginationModel round trip (Property 4): random pagination JSON → fromJson → field equality
  - [x] 19.6 Write property-based test for Validator rejects blank (Property 5): whitespace-only strings → required returns non-null
  - [x] 19.7 Write property-based test for Validator email (Property 6): valid emails → null; invalid emails → non-null
  - [x] 19.8 Write property-based test for repository success wraps entity (Property 7): mocked data source returns models → Result.success with correct length
  - [x] 19.9 Write property-based test for repository failure wraps failure (Property 8): mocked data source throws → Result.failure with non-empty message
  - [x] 19.10 Write unit tests for `Validators` class with specific examples (empty string, null, valid/invalid email, valid/invalid phone)
  - [x] 19.11 Write unit tests for `ProductRepositoryImpl` success and failure paths with mocked data source
  - [x] 19.12 Write unit tests for `ProductViewModel` state management (isLoading, products list, errorMessage, pagination guard)
