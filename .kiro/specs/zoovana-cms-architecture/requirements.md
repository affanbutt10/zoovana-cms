# Requirements Document

## Introduction

The Zoovana CMS App is an enterprise-grade Flutter content management system for managing a marketplace's vendors, products, orders, invoices, payments, and related operations. The app is built on a feature-based Clean Architecture using Flutter, GetX, and Dio. This document defines the requirements for scaffolding the full enterprise architecture and implementing the first set of feature modules: core infrastructure, shared components, routing, authentication, products (fully implemented), dashboard, vendors, and vendor sites.

---

## Glossary

- **App**: The Zoovana CMS Flutter application.
- **ApiClient**: The central Dio-based HTTP client responsible for all network communication.
- **ApiEndpoints**: The single source of truth for all API URL paths.
- **Result**: A typed wrapper `Result<T>` that holds either a success value or a `Failure`.
- **Failure**: A typed error object containing a message and optional HTTP status code.
- **Entity**: A domain-layer business object that is independent of API structure.
- **Model**: A data-layer object responsible for JSON parsing and conversion to an Entity.
- **Repository**: An abstract contract (domain) and its implementation (data) that mediates between UseCases and DataSources.
- **DataSource**: A class responsible for direct API calls (RemoteDataSource) or local storage access (LocalDataSource).
- **UseCase**: A class encapsulating a single business action, called by the ViewModel.
- **ViewModel**: A `GetxController` subclass that manages UI state and delegates business logic to UseCases.
- **View**: A `GetView` widget responsible solely for rendering UI based on ViewModel state.
- **Binding**: A GetX `Bindings` class that registers feature-specific dependencies via lazy injection.
- **DependencyInjection**: The global DI initializer that registers app-wide services at startup.
- **SecureStorageService**: A service wrapping `flutter_secure_storage` for storing sensitive data such as auth tokens.
- **LocalStorageService**: A service wrapping `shared_preferences` for storing non-sensitive preferences.
- **ConnectivityService**: A GetX service that monitors network connectivity state.
- **AppRoutes**: A class of named route string constants.
- **AppPages**: A class mapping named routes to Views and Bindings.
- **PaginationModel**: A shared model representing paginated API list responses.

---

## Requirements

### Requirement 1: Project Dependencies

**User Story:** As a developer, I want all required packages declared in `pubspec.yaml`, so that the project compiles with the correct dependency versions from the start.

#### Acceptance Criteria

1. THE App SHALL declare `get: ^4.7.3` as a dependency in `pubspec.yaml`.
2. THE App SHALL declare `dio: ^5.4.0` as a dependency in `pubspec.yaml`.
3. THE App SHALL declare `shared_preferences: ^2.2.2` as a dependency in `pubspec.yaml`.
4. THE App SHALL declare `flutter_secure_storage: ^10.0.0` as a dependency in `pubspec.yaml`.
5. THE App SHALL declare `connectivity_plus: ^6.1.4` as a dependency in `pubspec.yaml`.
6. THE App SHALL declare `intl: ^0.20.2` as a dependency in `pubspec.yaml`.
7. THE App SHALL declare `logger: ^2.0.2` as a dependency in `pubspec.yaml`.
8. THE App SHALL declare `flutter_screenutil: ^5.9.0` as a dependency in `pubspec.yaml`.
9. THE App SHALL declare `google_fonts: ^6.1.0` as a dependency in `pubspec.yaml`.

---

### Requirement 2: Application Entry Point and Root Widget

**User Story:** As a developer, I want a clean `main.dart` and `app.dart`, so that the app initializes all global dependencies before launching and uses GetX for routing.

#### Acceptance Criteria

1. THE App SHALL initialize `DependencyInjection` before calling `runApp` in `main.dart`.
2. THE App SHALL use `GetMaterialApp` as the root widget in `app.dart`.
3. THE App SHALL configure `GetMaterialApp` with `initialRoute`, `getPages`, and a `defaultTransition`.
4. WHEN the app starts, THE App SHALL initialize `ScreenUtil` for responsive layout support.

---

### Requirement 3: Core Network Layer

**User Story:** As a developer, I want a centralized `ApiClient` with Dio, so that all HTTP communication is handled consistently with proper headers, timeouts, and interceptors.

#### Acceptance Criteria

1. THE ApiClient SHALL extend `GetxService` and be initialized asynchronously via `Get.putAsync`.
2. THE ApiClient SHALL configure Dio with a `baseUrl` sourced from `ApiEndpoints.baseUrl`.
3. THE ApiClient SHALL set a `connectTimeout` and `receiveTimeout` of 30 seconds.
4. THE ApiClient SHALL set default headers `Content-Type: application/json` and `Accept: application/json`.
5. THE ApiClient SHALL attach an `AuthInterceptor` that injects the Bearer token from `SecureStorageService` into every request.
6. THE ApiClient SHALL attach an `ErrorInterceptor` that converts Dio errors into typed `Failure` objects.
7. THE ApiClient SHALL attach a `LoggingInterceptor` that logs request and response details in debug mode.
8. THE ApiClient SHALL expose `get`, `post`, `put`, `patch`, and `delete` methods that delegate to the underlying Dio instance.
9. THE ApiEndpoints SHALL declare all API path constants as `static const String` fields.
10. IF a network request fails due to a connection timeout, THEN THE ApiClient SHALL throw a typed `NetworkException`.
11. IF a network request returns an HTTP 401 status, THEN THE AuthInterceptor SHALL clear stored tokens and redirect to the login route.

---

### Requirement 4: Core Error Handling

**User Story:** As a developer, I want typed error and result types, so that every layer of the architecture communicates outcomes without using raw maps or untyped exceptions.

#### Acceptance Criteria

1. THE Result SHALL be a generic class `Result<T>` with a `success` factory and a `failure` factory.
2. THE Result SHALL expose a `when` method accepting `success` and `failure` callbacks for exhaustive handling.
3. THE Failure SHALL be a class with a required `message` field and an optional `statusCode` field.
4. THE App SHALL define a `NetworkException`, `ServerException`, and `CacheException` in `core/error/exceptions.dart`.
5. IF a repository operation succeeds, THEN THE Repository SHALL return `Result.success(entity)`.
6. IF a repository operation fails, THEN THE Repository SHALL return `Result.failure(Failure(message: ..., statusCode: ...))`.

---

### Requirement 5: Core Storage Services

**User Story:** As a developer, I want dedicated storage services, so that sensitive data and preferences are stored using the appropriate mechanism.

#### Acceptance Criteria

1. THE SecureStorageService SHALL use `flutter_secure_storage` to read and write auth tokens.
2. THE SecureStorageService SHALL expose `writeToken`, `readToken`, and `deleteToken` methods.
3. THE LocalStorageService SHALL use `shared_preferences` to read and write non-sensitive user preferences.
4. THE LocalStorageService SHALL expose typed `getString`, `setString`, `getBool`, `setBool`, `remove`, and `clear` methods.
5. THE App SHALL NOT store auth tokens using `shared_preferences`.

---

### Requirement 6: Core Services

**User Story:** As a developer, I want app-wide services for connectivity, permissions, and notifications, so that these cross-cutting concerns are handled in one place.

#### Acceptance Criteria

1. THE ConnectivityService SHALL extend `GetxService` and expose an observable `isConnected` boolean.
2. WHEN network connectivity changes, THE ConnectivityService SHALL update `isConnected` reactively.
3. THE PermissionService SHALL expose methods to request and check device permissions.
4. THE NotificationService SHALL expose methods to display local notifications.

---

### Requirement 7: Core Utilities and Configuration

**User Story:** As a developer, I want centralized configuration, utilities, and constants, so that values like colors, strings, and text styles are never hardcoded in feature code.

#### Acceptance Criteria

1. THE App SHALL define all color constants in `core/config/app_colors.dart`.
2. THE App SHALL define all string constants in `core/config/app_strings.dart`.
3. THE App SHALL define all text style constants in `core/config/app_text_styles.dart`.
4. THE App SHALL define asset path constants in `core/config/app_assets.dart`.
5. THE App SHALL define environment configuration (base URL, environment name) in `core/config/app_config.dart` and `core/config/app_env.dart`.
6. THE App SHALL provide a `Validators` class in `core/utils/validators.dart` with methods for email, phone, and required-field validation.
7. THE App SHALL provide a `DateTimeUtils` class in `core/utils/date_time_utils.dart` with formatting helpers.
8. THE App SHALL provide an `AppLogger` class in `core/utils/app_logger.dart` that wraps the `logger` package.

---

### Requirement 8: Global Dependency Injection

**User Story:** As a developer, I want a single DI initializer, so that all app-wide services are registered before the first screen renders.

#### Acceptance Criteria

1. THE DependencyInjection SHALL register `ApiClient` using `Get.putAsync` so it is available before any feature loads.
2. THE DependencyInjection SHALL register `SecureStorageService` using `Get.put`.
3. THE DependencyInjection SHALL register `LocalStorageService` using `Get.put`.
4. THE DependencyInjection SHALL register `ConnectivityService` using `Get.put`.
5. THE App SHALL call `DependencyInjection.init()` in `main.dart` before `runApp`.

---

### Requirement 9: Shared Widgets

**User Story:** As a developer, I want a library of reusable UI components, so that consistent styling is applied across all features without duplicating widget code.

#### Acceptance Criteria

1. THE App SHALL provide an `AppButton` widget in `shared/widgets/` that accepts a label, callback, and optional loading state.
2. THE App SHALL provide an `AppTextField` widget in `shared/widgets/` that accepts a label, hint, controller, validator, and optional obscure-text flag.
3. THE App SHALL provide an `AppLoader` widget in `shared/widgets/` that displays a centered loading indicator.
4. THE App SHALL provide an `AppEmptyState` widget in `shared/widgets/` that accepts a message and optional icon.
5. THE PaginationModel SHALL be a shared model in `shared/models/` that parses `currentPage`, `lastPage`, `total`, and `perPage` from API responses.
6. THE App SHALL provide a `ContextExtension` in `shared/extensions/` exposing screen size and theme helpers on `BuildContext`.
7. THE App SHALL provide a `StringExtension` in `shared/extensions/` with helpers such as `capitalize` and `isNullOrEmpty`.

---

### Requirement 10: Routing

**User Story:** As a developer, I want named routes managed in one place, so that navigation is consistent and bindings are automatically applied when a route is pushed.

#### Acceptance Criteria

1. THE AppRoutes SHALL declare all route name constants as `static const String` fields.
2. THE AppPages SHALL map each route name to its corresponding View and Binding using `GetPage`.
3. WHEN a route is navigated to, THE App SHALL automatically invoke the corresponding Binding to register feature dependencies.
4. THE AppRoutes SHALL include routes for: splash, login, dashboard, products, vendors, vendor sites, and settings.

---

### Requirement 11: Authentication Feature

**User Story:** As a CMS operator, I want to log in with my credentials, so that I can access the CMS securely and my session is maintained across app restarts.

#### Acceptance Criteria

1. WHEN a user submits valid credentials, THE AuthRemoteDataSource SHALL call the login API endpoint and return a `LoginResponseModel`.
2. THE LoginResponseModel SHALL parse the API response and expose a `toEntity()` method returning a `UserEntity`.
3. THE UserEntity SHALL contain at minimum: `id`, `name`, `email`, and `token` fields.
4. THE LoginUseCase SHALL call `AuthRepository.login` and return `Result<UserEntity>`.
5. WHEN login succeeds, THE LoginViewModel SHALL store the auth token via `SecureStorageService` and navigate to the dashboard route.
6. WHEN login fails, THE LoginViewModel SHALL expose a non-empty `errorMessage` observable.
7. WHILE a login request is in progress, THE LoginViewModel SHALL set `isLoading` to `true`.
8. THE LogoutUseCase SHALL call `AuthRepository.logout`, clear the stored token, and navigate to the login route.
9. THE AuthBinding SHALL register `AuthRemoteDataSource`, `AuthRepository`, `LoginUseCase`, `LogoutUseCase`, and `LoginViewModel` via lazy injection.
10. THE LoginView SHALL display a form with email and password fields, a submit button, and an error message area.
11. IF the login form is submitted with an empty email or password, THEN THE LoginView SHALL display inline validation errors without making an API call.

---

### Requirement 12: Products Feature — Listing

**User Story:** As a CMS operator, I want to view a paginated list of products, so that I can browse and manage all products in the system.

#### Acceptance Criteria

1. THE GetProductsUseCase SHALL call `ProductRepository.getProducts` with a `page` parameter and return `Result<List<ProductEntity>>`.
2. THE ProductRemoteDataSource SHALL call `ApiEndpoints.products` with a `page` query parameter and return `List<ProductModel>`.
3. THE ProductModel SHALL parse all product fields from JSON and expose a `toEntity()` method.
4. THE ProductEntity SHALL contain at minimum: `id`, `name`, `description`, `price`, `status`, `categoryId`, `vendorId`, and `imageUrl` fields.
5. WHEN `fetchProducts` is called, THE ProductViewModel SHALL set `isLoading` to `true`, call the UseCase, and update the `products` observable list.
6. WHEN the product list loads successfully, THE ProductListView SHALL render a scrollable list of product items.
7. WHEN the product list is empty, THE ProductListView SHALL display an `AppEmptyState` widget.
8. WHILE products are loading, THE ProductListView SHALL display an `AppLoader` widget.
9. THE ProductViewModel SHALL support pagination by tracking `currentPage` and `lastPage` observables.
10. WHEN the user scrolls to the end of the list, THE ProductViewModel SHALL fetch the next page if `currentPage < lastPage`.

---

### Requirement 13: Products Feature — Detail

**User Story:** As a CMS operator, I want to view the full details of a product, so that I can review all its attributes before making changes.

#### Acceptance Criteria

1. THE GetProductByIdUseCase SHALL call `ProductRepository.getProductById(id)` and return `Result<ProductEntity>`.
2. WHEN a product detail screen is opened, THE ProductViewModel SHALL call `fetchProductById` with the product ID.
3. WHEN the product detail loads successfully, THE ProductDetailView SHALL display all product fields.
4. IF the product detail request fails, THEN THE ProductDetailView SHALL display the error message from the ViewModel.

---

### Requirement 14: Products Feature — Create and Update

**User Story:** As a CMS operator, I want to create and update products, so that the product catalog stays accurate and up to date.

#### Acceptance Criteria

1. THE CreateProductUseCase SHALL call `ProductRepository.createProduct(entity)` and return `Result<ProductEntity>`.
2. THE UpdateProductUseCase SHALL call `ProductRepository.updateProduct(entity)` and return `Result<ProductEntity>`.
3. WHEN a product is created successfully, THE ProductViewModel SHALL add the new entity to the `products` list and navigate back.
4. WHEN a product is updated successfully, THE ProductViewModel SHALL replace the updated entity in the `products` list and navigate back.
5. THE ProductFormView SHALL be reused for both create and update operations, pre-populating fields when an existing entity is provided.
6. IF a required product field is empty on form submission, THEN THE ProductFormView SHALL display a validation error without calling the UseCase.

---

### Requirement 15: Products Feature — Delete

**User Story:** As a CMS operator, I want to delete a product, so that discontinued or incorrect products are removed from the catalog.

#### Acceptance Criteria

1. THE DeleteProductUseCase SHALL call `ProductRepository.deleteProduct(id)` and return `Result<void>`.
2. WHEN a product is deleted successfully, THE ProductViewModel SHALL remove the entity from the `products` list.
3. IF the delete request fails, THEN THE ProductViewModel SHALL expose the error message and leave the `products` list unchanged.

---

### Requirement 16: Products Feature — Image Upload

**User Story:** As a CMS operator, I want to upload a product image, so that each product has a visual representation in the catalog.

#### Acceptance Criteria

1. THE ProductRemoteDataSource SHALL support a `uploadProductImage(id, filePath)` method that sends a multipart form-data request.
2. THE UploadProductImageUseCase SHALL call `ProductRepository.uploadProductImage` and return `Result<String>` where the string is the returned image URL.
3. WHEN an image is uploaded successfully, THE ProductViewModel SHALL update the `imageUrl` field of the corresponding product entity.
4. IF the image upload fails, THEN THE ProductViewModel SHALL expose the error message without modifying the product entity.

---

### Requirement 17: Products Feature — Status Handling

**User Story:** As a CMS operator, I want to change a product's status (e.g., active, inactive, draft), so that I can control product visibility in the marketplace.

#### Acceptance Criteria

1. THE ProductEntity SHALL include a `status` field typed as a `ProductStatus` enum with values `active`, `inactive`, and `draft`.
2. THE UpdateProductStatusUseCase SHALL call `ProductRepository.updateProductStatus(id, status)` and return `Result<ProductEntity>`.
3. WHEN a status update succeeds, THE ProductViewModel SHALL update the status of the corresponding entity in the `products` list.
4. THE ProductListView SHALL display a visual indicator of each product's status.

---

### Requirement 18: Products Feature — Dependency Injection

**User Story:** As a developer, I want all product feature dependencies registered through a binding, so that they are lazily loaded only when the products route is accessed.

#### Acceptance Criteria

1. THE ProductBinding SHALL register `ProductRemoteDataSource` via `Get.lazyPut`.
2. THE ProductBinding SHALL register `ProductRepository` (as `ProductRepositoryImpl`) via `Get.lazyPut`.
3. THE ProductBinding SHALL register all product UseCases via `Get.lazyPut`.
4. THE ProductBinding SHALL register `ProductViewModel` via `Get.lazyPut`.
5. THE AppPages SHALL associate the products route with `ProductBinding`.

---

### Requirement 19: Dashboard Feature Structure

**User Story:** As a developer, I want the dashboard feature scaffolded with the correct layer structure, so that analytics and summary data can be implemented following the same architecture pattern.

#### Acceptance Criteria

1. THE App SHALL create the `features/dashboard/` directory with `data/`, `domain/`, and `presentation/` subdirectories.
2. THE App SHALL create a `DashboardBinding`, `DashboardViewModel`, and `DashboardView` as placeholder implementations.
3. THE DashboardView SHALL be the initial screen after successful login.

---

### Requirement 20: Vendors Feature Structure

**User Story:** As a developer, I want the vendors feature scaffolded with the correct layer structure, so that vendor management can be implemented following the same architecture pattern.

#### Acceptance Criteria

1. THE App SHALL create the `features/vendors/` directory with `data/`, `domain/`, and `presentation/` subdirectories.
2. THE App SHALL create a `VendorEntity` with at minimum: `id`, `name`, `email`, `status`, and `createdAt` fields.
3. THE App SHALL create a `VendorBinding`, `VendorViewModel`, and `VendorListView` as placeholder implementations.

---

### Requirement 21: Vendor Sites Feature Structure

**User Story:** As a developer, I want the vendor sites feature scaffolded with the correct layer structure, so that site/branch management can be implemented following the same architecture pattern.

#### Acceptance Criteria

1. THE App SHALL create the `features/vendor_sites/` directory with `data/`, `domain/`, and `presentation/` subdirectories.
2. THE App SHALL create a `VendorSiteEntity` with at minimum: `id`, `vendorId`, `name`, `address`, and `status` fields.
3. THE App SHALL create a `VendorSiteBinding`, `VendorSiteViewModel`, and `VendorSiteListView` as placeholder implementations.

---

### Requirement 22: Architecture Enforcement Rules

**User Story:** As a developer, I want the architecture rules enforced by convention throughout the codebase, so that the project remains maintainable as it scales.

#### Acceptance Criteria

1. THE App SHALL NOT contain any direct Dio calls inside View or ViewModel classes.
2. THE App SHALL NOT contain any hardcoded URL strings outside of `ApiEndpoints`.
3. THE App SHALL NOT return `Map<String, dynamic>` from any Repository method — all repository methods SHALL return `Result<T>`.
4. THE App SHALL NOT use `dynamic` types except where unavoidable in JSON parsing within Model classes.
5. THE App SHALL register all feature-level dependencies through feature Bindings, not in `DependencyInjection.init()`.
6. THE App SHALL keep widgets used by only one feature inside that feature's `presentation/widgets/` directory.
7. THE App SHALL keep widgets used by more than one feature inside `shared/widgets/`.
