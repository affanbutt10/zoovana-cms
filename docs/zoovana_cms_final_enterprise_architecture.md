# Zoovana CMS – Final Enterprise Flutter Architecture Guide

## 1. Purpose

This document defines the final enterprise-level Flutter architecture for the **Zoovana CMS App**.

The goal is to create a scalable, maintainable, testable, and production-ready Flutter project structure using:

- Flutter
- GetX
- Dio
- Repository Pattern
- Service Layer
- Data Source Layer
- Use Case Layer
- Feature-based Modular Architecture
- Typed API Response Handling

This architecture is inspired by practical LayerX/MVVM concepts, Clean Architecture principles, and your current Mystiquehall-style project flow.

---

## 2. Final Recommended Flow

### Enterprise Data Flow

```text
UI / View
   ↓
ViewModel / Controller
   ↓
UseCase
   ↓
Repository
   ↓
Remote / Local DataSource
   ↓
ApiClient / Local Storage
   ↓
Backend API / Cache
```

### Why this flow?

This flow keeps every layer responsible for only one type of work.

- UI shows data only.
- ViewModel manages screen state.
- UseCase handles one business action.
- Repository decides where data comes from.
- DataSource talks to API or local storage.
- ApiClient handles Dio configuration, tokens, and network requests.

---

## 3. Final Folder Structure

```text
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── app_env.dart
│   │   ├── app_assets.dart
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_text_styles.dart
│   │
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── api_endpoints.dart
│   │   ├── api_response.dart
│   │   ├── api_error_handler.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       ├── logging_interceptor.dart
│   │       └── error_interceptor.dart
│   │
│   ├── error/
│   │   ├── exceptions.dart
│   │   ├── failures.dart
│   │   └── result.dart
│   │
│   ├── storage/
│   │   ├── secure_storage_service.dart
│   │   └── local_storage_service.dart
│   │
│   ├── services/
│   │   ├── connectivity_service.dart
│   │   ├── permission_service.dart
│   │   └── notification_service.dart
│   │
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── date_time_utils.dart
│   │   └── app_logger.dart
│   │
│   └── di/
│       └── dependency_injection.dart
│
├── shared/
│   ├── widgets/
│   │   ├── app_button.dart
│   │   ├── app_text_field.dart
│   │   ├── app_loader.dart
│   │   └── app_empty_state.dart
│   │
│   ├── models/
│   │   └── pagination_model.dart
│   │
│   └── extensions/
│       ├── context_extension.dart
│       └── string_extension.dart
│
├── routes/
│   ├── app_routes.dart
│   └── app_pages.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── login_request_model.dart
│   │   │   │   └── login_response_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   │
│   │   └── presentation/
│   │       ├── bindings/
│   │       │   └── auth_binding.dart
│   │       ├── viewmodels/
│   │       │   └── login_viewmodel.dart
│   │       ├── views/
│   │       │   └── login_view.dart
│   │       └── widgets/
│   │           └── login_form.dart
│   │
│   ├── dashboard/
│   ├── vendors/
│   ├── products/
│   ├── orders/
│   ├── categories/
│   ├── clients/
│   ├── quotations/
│   ├── invoices/
│   ├── payments/
│   └── settings/
│
└── l10n/
    ├── app_en.arb
    └── app_ar.arb
```

---

## 4. Layer-by-Layer Explanation

## 4.1 UI / View Layer

### Location

```text
features/feature_name/presentation/views/
```

### Responsibility

The View layer is only responsible for UI rendering.

It should:

- Display widgets.
- Listen to ViewModel state.
- Trigger ViewModel methods on user actions.
- Show loading, empty, success, and error states.

It should not:

- Call APIs directly.
- Parse JSON.
- Store tokens.
- Contain business rules.
- Handle database or cache logic.

### Example

```dart
class ProductListView extends GetView<ProductViewModel> {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const AppLoader();
      }

      if (controller.products.isEmpty) {
        return const AppEmptyState(message: 'No products found');
      }

      return ListView.builder(
        itemCount: controller.products.length,
        itemBuilder: (_, index) {
          final product = controller.products[index];
          return Text(product.name);
        },
      );
    });
  }
}
```

---

## 4.2 ViewModel / Controller Layer

### Location

```text
features/feature_name/presentation/viewmodels/
```

### Responsibility

The ViewModel is the bridge between UI and business logic.

In GetX, this can still extend `GetxController`, but naming it `ViewModel` makes the architecture cleaner.

It should:

- Manage UI state.
- Expose observable variables.
- Call UseCases.
- Handle loading/error/success state.
- Prepare data for UI.

It should not:

- Call Dio directly.
- Access API endpoints directly.
- Parse raw API response.
- Contain heavy business rules.

### Example

```dart
class ProductViewModel extends GetxController {
  final GetProductsUseCase getProductsUseCase;

  ProductViewModel(this.getProductsUseCase);

  final products = <ProductEntity>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await getProductsUseCase();

    result.when(
      success: (data) {
        products.assignAll(data);
      },
      failure: (failure) {
        errorMessage.value = failure.message;
      },
    );

    isLoading.value = false;
  }
}
```

---

## 4.3 UseCase Layer

### Location

```text
features/feature_name/domain/usecases/
```

### Responsibility

A UseCase represents one business action.

Examples:

- Login user
- Fetch products
- Create vendor
- Delete invoice
- Update order status
- Generate quotation invoice

UseCases keep the ViewModel clean and make business logic reusable.

### Example

```dart
class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<Result<List<ProductEntity>>> call({int page = 1}) {
    return repository.getProducts(page: page);
  }
}
```

### Why UseCases are important?

Without UseCases, your controllers become too large.

For example, if the product screen has:

- Fetch products
- Search products
- Filter products
- Create product
- Update product
- Delete product
- Upload product image

Then the controller becomes a God Class.

UseCases prevent that problem.

---

## 4.4 Domain Repository Interface

### Location

```text
features/feature_name/domain/repositories/
```

### Responsibility

The domain repository defines what the feature can do, without caring how it is done.

It is an abstract contract.

### Example

```dart
abstract class ProductRepository {
  Future<Result<List<ProductEntity>>> getProducts({int page});
  Future<Result<ProductEntity>> getProductById(String id);
  Future<Result<ProductEntity>> createProduct(ProductEntity product);
  Future<Result<void>> deleteProduct(String id);
}
```

### Why this exists?

Because your ViewModel and UseCases should not depend on the implementation.

They should depend on abstraction.

This makes testing easier and allows you to replace REST API with Firebase, GraphQL, local DB, or another backend later.

---

## 4.5 Repository Implementation

### Location

```text
features/feature_name/data/repositories/
```

### Responsibility

The repository implementation connects the domain layer with the data layer.

It should:

- Call RemoteDataSource.
- Call LocalDataSource when needed.
- Convert models into entities.
- Return typed results.
- Decide whether data comes from API, cache, or local storage.

### Example

```dart
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<ProductEntity>>> getProducts({int page = 1}) async {
    try {
      final models = await remoteDataSource.getProducts(page: page);
      final entities = models.map((model) => model.toEntity()).toList();
      return Result.success(entities);
    } catch (e) {
      return Result.failure(Failure(message: e.toString()));
    }
  }
}
```

---

## 4.6 DataSource Layer

### Location

```text
features/feature_name/data/datasources/
```

### Responsibility

DataSource is responsible for the real data operation.

RemoteDataSource:

- Calls API.
- Uses ApiClient.
- Sends query parameters.
- Sends request body.
- Receives response.

LocalDataSource:

- Reads/writes cache.
- Reads/writes local DB.
- Reads/writes shared preferences or secure storage.

### Example

```dart
class ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSource(this.apiClient);

  Future<List<ProductModel>> getProducts({int page = 1}) async {
    final response = await apiClient.get(
      ApiEndpoints.products,
      queryParameters: {'page': page},
    );

    final List data = response.data['data'] ?? [];
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }
}
```

---

## 4.7 ApiClient Layer

### Location

```text
core/network/api_client.dart
```

### Responsibility

ApiClient is the central place for all Dio network configuration.

It should handle:

- Base URL
- Headers
- Timeout
- Auth token interceptor
- Error interceptor
- Logging interceptor
- GET / POST / PUT / PATCH / DELETE methods

### Example

```dart
class ApiClient extends GetxService {
  late final Dio dio;

  Future<ApiClient> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(ErrorInterceptor());
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    return this;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.post(path, data: data, queryParameters: queryParameters);
  }
}
```

---

## 4.8 ApiEndpoints

### Location

```text
core/network/api_endpoints.dart
```

### Responsibility

All API URLs should be centralized here.

Do not hardcode API paths inside screens, controllers, repositories, or services.

### Example

```dart
class ApiEndpoints {
  static const String baseUrl = 'https://api.zoovana.com/api/v1';

  static const String login = '/auth/login';
  static const String logout = '/auth/logout';

  static const String vendors = '/vendors';
  static const String products = '/products';
  static const String orders = '/orders';
  static const String invoices = '/invoices';
}
```

---

## 4.9 Models and Entities

### Model

Models belong to the data layer.

Location:

```text
features/feature_name/data/models/
```

Models are used for API JSON parsing.

```dart
class ProductModel {
  final String id;
  final String name;

  ProductModel({
    required this.id,
    required this.name,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
    );
  }
}
```

### Entity

Entities belong to the domain layer.

Location:

```text
features/feature_name/domain/entities/
```

Entities represent business objects.

```dart
class ProductEntity {
  final String id;
  final String name;

  ProductEntity({
    required this.id,
    required this.name,
  });
}
```

### Why separate Model and Entity?

Because API response can change, but your business object should stay stable.

Example:

API may return:

```json
{
  "product_name": "Chair"
}
```

But your app should use:

```dart
product.name
```

The model handles API mapping, and entity keeps the app clean.

---

## 4.10 Result, Failure, and Exception Handling

### Location

```text
core/error/
```

### Responsibility

Do not return raw `Map<String, dynamic>` everywhere.

Use typed result objects.

### Result

```dart
class Result<T> {
  final T? data;
  final Failure? failure;

  const Result._({this.data, this.failure});

  factory Result.success(T data) => Result._(data: data);

  factory Result.failure(Failure failure) => Result._(failure: failure);

  bool get isSuccess => data != null;
}
```

### Failure

```dart
class Failure {
  final String message;
  final int? statusCode;

  Failure({
    required this.message,
    this.statusCode,
  });
}
```

### Why this is better?

Instead of passing loose maps everywhere, every layer knows exactly what type of data it receives.

This reduces runtime crashes and improves code quality.

---

## 4.11 Dependency Injection

### Location

```text
core/di/dependency_injection.dart
```

### Responsibility

Dependency Injection registers all services, repositories, usecases, and ViewModels.

### Global dependencies

```dart
class DependencyInjection {
  static Future<void> init() async {
    await Get.putAsync<ApiClient>(() => ApiClient().init());

    Get.put<SecureStorageService>(SecureStorageService());
    Get.put<ConnectivityService>(ConnectivityService());
  }
}
```

### Feature binding example

```dart
class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRemoteDataSource>(
      () => ProductRemoteDataSource(Get.find<ApiClient>()),
    );

    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(Get.find<ProductRemoteDataSource>()),
    );

    Get.lazyPut<GetProductsUseCase>(
      () => GetProductsUseCase(Get.find<ProductRepository>()),
    );

    Get.lazyPut<ProductViewModel>(
      () => ProductViewModel(Get.find<GetProductsUseCase>()),
    );
  }
}
```

### Why use feature bindings?

Because each feature loads only the dependencies it needs.

This improves startup time and keeps the project organized.

---

## 4.12 Routes

### Location

```text
routes/
```

### app_routes.dart

```dart
class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const products = '/products';
  static const vendors = '/vendors';
}
```

### app_pages.dart

```dart
class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.products,
      page: () => const ProductListView(),
      binding: ProductBinding(),
    ),
  ];
}
```

---

## 4.13 Shared Widgets

### Location

```text
shared/widgets/
```

### Responsibility

Shared widgets are reusable UI components used across multiple features.

Examples:

- AppButton
- AppTextField
- AppLoader
- AppEmptyState
- AppDataTable
- AppSearchField
- AppDropdown
- AppPaginationFooter

### Rule

If a widget is used only inside one feature, keep it inside that feature.

If a widget is used in many features, move it to `shared/widgets`.

---

## 4.14 Core Services

### Location

```text
core/services/
```

### Responsibility

Core services are app-wide helpers.

Examples:

- ConnectivityService
- NotificationService
- PermissionService
- FilePickerService
- ImageUploadService

These are not feature-specific.

---

## 5. Zoovana CMS Suggested Feature Modules

For Zoovana CMS, use the following modules:

```text
features/
├── auth/
├── dashboard/
├── vendors/
├── vendor_sites/
├── products/
├── categories/
├── orders/
├── clients/
├── quotations/
├── invoices/
├── payments/
├── notifications/
├── reports/
├── settings/
└── users_roles_permissions/
```

### Module responsibilities

## Auth

Handles:

- Login
- Logout
- Token storage
- Profile loading
- Session validation

## Dashboard

Handles:

- Analytics cards
- Sales stats
- Vendor stats
- Recent orders
- Revenue overview

## Vendors

Handles:

- Vendor CRUD
- Vendor approval
- Vendor profile
- Vendor status

## Vendor Sites

Handles:

- Sites/branches linked with vendors
- Location details
- Site resources
- Site contact information

## Products

Handles:

- Product CRUD
- Product image upload
- Product category mapping
- Product status

## Categories

Handles:

- Category CRUD
- Parent/child category structure
- Category sorting

## Orders

Handles:

- Order listing
- Order details
- Status updates
- Order tracking

## Clients

Handles:

- Customer/client list
- Client detail
- Client order history

## Quotations

Handles:

- Create quotation
- Update quotation
- Convert quotation to invoice

## Invoices

Handles:

- Invoice generation
- Printable invoice
- PDF invoice
- Payment status

## Payments

Handles:

- Payment confirmations
- Payment history
- Wallet/transactions if needed

## Reports

Handles:

- Revenue reports
- Vendor performance
- Product performance
- Client journey analytics

## Users, Roles, and Permissions

Handles:

- Admin users
- Role management
- Permission control
- CMS access control

---

## 6. Naming Convention

### Files

Use snake_case:

```text
product_view.dart
product_viewmodel.dart
product_repository.dart
product_remote_datasource.dart
get_products_usecase.dart
```

### Classes

Use PascalCase:

```dart
ProductView
ProductViewModel
ProductRepository
ProductRemoteDataSource
GetProductsUseCase
```

### Variables and methods

Use camelCase:

```dart
isLoading
fetchProducts()
createVendor()
```

---

## 7. Recommended Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management, Routing, DI
  get: ^4.7.3

  # HTTP Client
  dio: ^5.4.0

  # Local Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^10.0.0

  # Connectivity
  connectivity_plus: ^6.1.4

  # Utilities
  intl: ^0.20.2
  logger: ^2.0.2

  # Responsive UI
  flutter_screenutil: ^5.9.0

  # UI Enhancements
  google_fonts: ^6.1.0
```

---

## 8. Rules for the Agent

The agent must follow these rules strictly.

### Architecture Rules

1. Do not place API calls inside UI.
2. Do not place API calls inside ViewModel.
3. Do not hardcode endpoints outside `ApiEndpoints`.
4. Do not return raw `Map<String, dynamic>` from repositories.
5. Use typed `Result<T>` and `Failure`.
6. Keep every feature isolated.
7. Register dependencies through bindings or DI.
8. Keep reusable widgets in `shared/widgets`.
9. Keep app-wide services in `core/services`.
10. Keep business objects in `domain/entities`.

### Coding Rules

1. Use null safety properly.
2. Avoid `dynamic` unless unavoidable.
3. Use meaningful class names.
4. Keep files small and focused.
5. Use pagination state for listing screens.
6. Add loading, error, empty, and success UI states.
7. Use `flutter_secure_storage` for auth tokens.
8. Use `shared_preferences` only for non-sensitive preferences.
9. Use Dio interceptors for token injection.
10. Use route bindings for feature dependencies.

---

## 9. Example Full Product Feature Flow

### Step 1: UI calls ViewModel

```dart
controller.fetchProducts();
```

### Step 2: ViewModel calls UseCase

```dart
final result = await getProductsUseCase(page: currentPage.value);
```

### Step 3: UseCase calls Repository

```dart
return repository.getProducts(page: page);
```

### Step 4: Repository calls DataSource

```dart
final models = await remoteDataSource.getProducts(page: page);
```

### Step 5: DataSource calls ApiClient

```dart
final response = await apiClient.get(ApiEndpoints.products);
```

### Step 6: Model converts to Entity

```dart
final entities = models.map((model) => model.toEntity()).toList();
```

### Step 7: ViewModel updates UI state

```dart
products.assignAll(entities);
```

---

## 10. Final Architecture Decision

For Zoovana CMS, use this structure:

```text
Feature-based Clean Architecture + MVVM + GetX + Repository + DataSource + UseCase
```

This is better than the previous simple structure because it supports:

- Larger modules
- Multiple developers
- Testing
- Easier maintenance
- Better API separation
- Future backend changes
- Role-based CMS complexity
- Better long-term scalability

---

## 11. Migration from Old MD to Final Enterprise MD

### Old Flow

```text
UI → Controller → Service → Repository → ApiClient → Backend
```

### New Flow

```text
UI → ViewModel → UseCase → Repository → DataSource → ApiClient → Backend
```

### What changed?

| Old Layer | New Layer | Reason |
|---|---|---|
| Controller | ViewModel | Cleaner MVVM naming |
| Service | UseCase + Core Service | Avoid God Classes |
| Repository direct API call | Repository → DataSource | Better separation |
| Map response | Result<T> / ApiResponse<T> | Type safety |
| Global app/data folders | Feature-based folders | Better scalability |

---

## 12. Final Recommendation

Start with these modules first:

1. Auth
2. Dashboard
3. Vendors
4. Vendor Sites
5. Products
6. Categories
7. Orders
8. Invoices
9. Payments
10. Settings

Do not build all modules at once.

Create one complete module first, for example `products`, then copy the same pattern to other modules.

Recommended first module:

```text
products/
```

Because it includes:

- Listing
- Details
- Create
- Update
- Delete
- Pagination
- Image support
- Status handling

Once Product module is complete, other CMS modules will be easier to create.

---

## 13. Final Deliverable Expected from Agent

The agent should create:

```text
core/
shared/
routes/
features/auth/
features/dashboard/
features/products/
features/vendors/
features/vendor_sites/
```

And inside each feature, follow:

```text
data/
domain/
presentation/
```

The first fully implemented feature should be:

```text
features/products/
```

After that, replicate the same architecture for the remaining CMS modules.
