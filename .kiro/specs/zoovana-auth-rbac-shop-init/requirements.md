# Requirements Document

## Introduction

This document specifies the requirements for implementing four tightly coupled Flutter mobile flows in the Zoovana CMS app:

1. **Authentication** — Login, registration, email verification, and password reset using the Auth Service (port 8001), with JWT token storage in `flutter_secure_storage`, proactive + reactive token refresh, and a Dio interceptor chain.
2. **Role-Based Access Control (RBAC)** — Parsing and storing the `roles` array and `is_superuser` flag from the login response, persisting the user's selected role, and enforcing role-based navigation guards.
3. **Tenant & Approval Flow** — Using `default_tenant_id` from the session, detecting pending-approval state, and redirecting to the correct screen.
4. **Shop Owner Initialization** — Post-login data loading for shop owners: fetching business, branches, and dashboard overview from the Shop Service (port 8012), then routing to the shop dashboard.

The implementation uses Dio for HTTP, `flutter_secure_storage` for token storage, `shared_preferences` for non-sensitive session metadata, Riverpod (or BLoC) for state management, GoRouter for navigation, and `get_it` as the service locator.

---

## Glossary

- **Auth_Service**: The backend microservice at `http://161.35.222.194:8001`. Handles authentication, users, roles, permissions, and tenants.
- **Shop_Service**: The backend microservice at `http://161.35.222.194:8012`. Handles businesses, branches, products, categories, and inventory.
- **Access_Token**: A short-lived JWT (default 1800 seconds / 30 minutes) issued by the Auth_Service on login. Sent as a `Bearer` token in the `Authorization` header of every authenticated request.
- **Refresh_Token**: A long-lived token used to obtain a new Access_Token without re-login via `POST /api/v1/auth/refresh`.
- **Auth_Interceptor**: A Dio interceptor that injects the Access_Token into every request and handles 401 responses by refreshing the token and retrying.
- **Error_Interceptor**: A Dio interceptor that normalizes all `DioException` instances into typed `AppError` objects with boolean flags.
- **Locale_Interceptor**: A Dio interceptor that injects the `Accept-Language` header based on the device locale.
- **Logger_Interceptor**: A Dio interceptor that logs request and response details in debug mode.
- **Secure_Storage**: The `flutter_secure_storage` service used to persist `access_token` and `refresh_token`.
- **Local_Storage**: The `shared_preferences` service used to persist non-sensitive session metadata (`user_id`, `full_name`, `email`, `is_superuser`, `default_tenant_id`).
- **Role**: A named set of permissions assigned to a user. Returned as an array of role objects in the login response.
- **Role_Store**: A Riverpod `StateNotifier` (or BLoC) that tracks the user's currently selected role when the user holds multiple roles. Persisted to `shared_preferences`.
- **Tenant**: A top-level organizational unit. Each user belongs to a tenant identified by `default_tenant_id`.
- **Business**: The parent entity of one or more Branches, managed via the Shop_Service.
- **Branch**: A physical or logical sub-unit of a Business. All shop data (products, categories, inventory) is scoped to a Branch.
- **AppError**: A typed error object with boolean flags (`badRequest`, `unauthorized`, `forbidden`, `notFound`, `conflict`, `validationErrors`, `serverError`, `networkError`, `cancelled`) used throughout the app instead of raw HTTP status codes.
- **Auth_State**: The Riverpod/BLoC state object representing the current authentication status: `unauthenticated`, `authenticated`, `pendingApproval`, or `loading`.
- **Shop_Init_State**: The Riverpod/BLoC state object representing the shop owner initialization status: `loading`, `ready` (business + branches loaded), or `error`.
- **GoRouter**: The Flutter navigation package used for declarative routing with redirect guards.
- **ServiceLocator**: The `get_it` instance used to register and resolve Dio client instances and services.
- **Mutex**: A lock from the `synchronized` package used to prevent concurrent token refresh races when multiple requests fail with 401 simultaneously.

---

## Requirements

### Requirement 1: Project Dependencies for Auth, RBAC, and Shop Init

**User Story:** As a developer, I want all required packages declared in `pubspec.yaml`, so that the authentication, RBAC, and shop initialization flows compile with the correct dependency versions.

#### Acceptance Criteria

1. THE App SHALL declare `dio: ^5.4.0` as a dependency in `pubspec.yaml`.
2. THE App SHALL declare `flutter_secure_storage: ^10.0.0` as a dependency in `pubspec.yaml`.
3. THE App SHALL declare `shared_preferences: ^2.2.2` as a dependency in `pubspec.yaml`.
4. THE App SHALL declare `flutter_riverpod: ^2.5.1` (or `flutter_bloc: ^8.1.5`) as a dependency in `pubspec.yaml`.
5. THE App SHALL declare `go_router: ^14.0.0` as a dependency in `pubspec.yaml`.
6. THE App SHALL declare `get_it: ^8.0.0` as a dependency in `pubspec.yaml`.
7. THE App SHALL declare `synchronized: ^3.1.0` as a dependency in `pubspec.yaml` for the Mutex used in token refresh.
8. THE App SHALL declare `logger: ^2.0.2` as a dependency in `pubspec.yaml`.

---

### Requirement 2: Dio Client Configuration

**User Story:** As a developer, I want two dedicated Dio instances registered in the ServiceLocator, so that Auth Service and Shop Service requests are routed to the correct base URLs with consistent interceptor behavior.

#### Acceptance Criteria

1. THE ServiceLocator SHALL register an `authDio` Dio instance with `baseUrl: http://161.35.222.194:8001`, `connectTimeout: 30 seconds`, and `receiveTimeout: 30 seconds`.
2. THE ServiceLocator SHALL register a `shopDio` Dio instance with `baseUrl: http://161.35.222.194:8012`, `connectTimeout: 30 seconds`, and `receiveTimeout: 30 seconds`.
3. THE `authDio` instance SHALL apply interceptors in this order: `Locale_Interceptor` (request), `Logger_Interceptor` (request/response), `Error_Interceptor` (response), `Auth_Interceptor` (response).
4. THE `shopDio` instance SHALL apply the same interceptor chain as `authDio`.
5. THE `authDio` and `shopDio` instances SHALL set default headers `Content-Type: application/json` and `Accept: application/json`.
6. THE ServiceLocator SHALL register `Secure_Storage` and `Local_Storage` services before registering the Dio instances.
7. WHEN the app starts, THE ServiceLocator SHALL initialize all registered services before `runApp` is called.

---

### Requirement 3: Interceptor Chain

**User Story:** As a developer, I want a composable interceptor pipeline, so that every API request gets consistent locale injection, logging, error normalization, and token refresh behavior.

#### Acceptance Criteria

1. WHEN a request is dispatched, THE Locale_Interceptor SHALL read the active locale from the device locale settings and inject it as the `Accept-Language` header (value: `en` or `ar`).
2. WHEN a request is dispatched in debug mode, THE Logger_Interceptor SHALL log the HTTP method, URL, headers, and request body.
3. WHEN a response is received in debug mode, THE Logger_Interceptor SHALL log the HTTP status code, response body, and elapsed time in milliseconds.
4. WHEN a response has HTTP status 200–299, THE Error_Interceptor SHALL pass the response through unchanged.
5. WHEN a response has HTTP status 400, THE Error_Interceptor SHALL return an `AppError` with `badRequest: true` and the error message extracted from the `detail` or `message` field of the response body.
6. WHEN a response has HTTP status 401, THE Error_Interceptor SHALL return an `AppError` with `unauthorized: true` and pass control to the `Auth_Interceptor`.
7. WHEN a response has HTTP status 403, THE Error_Interceptor SHALL return an `AppError` with `forbidden: true`.
8. WHEN a response has HTTP status 404, THE Error_Interceptor SHALL return an `AppError` with `notFound: true`.
9. WHEN a response has HTTP status 409, THE Error_Interceptor SHALL return an `AppError` with `conflict: true`.
10. WHEN a response has HTTP status 422, THE Error_Interceptor SHALL map each validation error object `{ loc, msg }` to a human-readable string and return an `AppError` with `validationErrors: true` and a populated `errors` map.
11. WHEN a response has HTTP status 500, THE Error_Interceptor SHALL return an `AppError` with `serverError: true`.
12. WHEN a network error occurs (no response, connection refused, DNS failure), THE Error_Interceptor SHALL return an `AppError` with `networkError: true` and `status: 0`.
13. WHEN a request is cancelled, THE Error_Interceptor SHALL return an `AppError` with `cancelled: true`.
14. WHEN a 401 response is received, THE Auth_Interceptor SHALL acquire a `Mutex` lock, call `POST /api/v1/auth/refresh` with the stored `Refresh_Token`, store the new `Access_Token` in `Secure_Storage`, release the lock, and retry the original request exactly once with the new token.
15. IF the token refresh call itself returns a 401 or the `Refresh_Token` is absent, THEN THE Auth_Interceptor SHALL clear all stored tokens, update `Auth_State` to `unauthenticated`, and redirect to the login route.
16. WHILE a token refresh is in progress, THE Auth_Interceptor SHALL queue all other 401 requests and replay them with the new token once the refresh completes, using the shared `Mutex` lock to prevent concurrent refresh races.

---

### Requirement 4: Token Storage

**User Story:** As a developer, I want tokens stored securely and session metadata stored in preferences, so that the app can restore the authenticated session across restarts without exposing sensitive data.

#### Acceptance Criteria

1. WHEN login succeeds, THE Secure_Storage SHALL write the `access_token` under the key `access_token`.
2. WHEN login succeeds, THE Secure_Storage SHALL write the `refresh_token` under the key `refresh_token`.
3. WHEN login succeeds, THE Local_Storage SHALL write `user_id`, `full_name`, `email`, `is_superuser` (as bool), and `default_tenant_id` to `shared_preferences`.
4. THE App SHALL NOT store `access_token` or `refresh_token` in `shared_preferences`.
5. WHEN the user logs out, THE Secure_Storage SHALL delete both `access_token` and `refresh_token`.
6. WHEN the user logs out, THE Local_Storage SHALL clear all session-related keys (`user_id`, `full_name`, `email`, `is_superuser`, `default_tenant_id`).
7. WHEN the app starts, THE Auth_State SHALL be restored by reading `access_token` from `Secure_Storage` — if present, the user is considered authenticated; if absent, the user is considered unauthenticated.

---

### Requirement 5: Authentication API — Login

**User Story:** As a CMS user, I want to log in with my email and password, so that I receive a secure session with tokens and user metadata.

#### Acceptance Criteria

1. WHEN a user submits valid credentials, THE Auth_Service SHALL be called at `POST /api/v1/auth/login` with body `{ email: string, password: string }`.
2. WHEN login succeeds, THE Auth_Service SHALL return `{ access_token, refresh_token, expires_in, user: { id, email, full_name, is_superuser, is_email_verified, roles, default_tenant_id } }`.
3. WHEN login succeeds, THE Auth_Repository SHALL store tokens via `Secure_Storage` and session metadata via `Local_Storage`, then return a `Result.success(AuthSession)`.
4. WHEN login fails with HTTP 401, THE Auth_Repository SHALL return `Result.failure(AppError(unauthorized: true))`.
5. WHEN login fails with HTTP 422, THE Auth_Repository SHALL return `Result.failure(AppError(validationErrors: true, errors: fieldErrors))`.
6. WHILE a login request is in progress, THE Login_State SHALL be `loading`.
7. IF the login form is submitted with an empty email or password, THEN THE Login_Screen SHALL display inline validation errors without making an API call.
8. IF the login form is submitted with an invalid email format, THEN THE Login_Screen SHALL display an inline email format error without making an API call.

---

### Requirement 6: Authentication API — Registration

**User Story:** As a new user, I want to register an account, so that I can access the platform after email verification.

#### Acceptance Criteria

1. WHEN a user submits the registration form, THE Auth_Service SHALL be called at `POST /api/v1/auth/register` with body `{ email, password, full_name, role_id? }`.
2. WHEN registration succeeds, THE Auth_Repository SHALL return `Result.success(RegisterResponse)` and the app SHALL navigate to the email verification screen.
3. WHEN registration fails with HTTP 409 (email already exists), THE Auth_Repository SHALL return `Result.failure(AppError(conflict: true))`.
4. THE Register_Screen SHALL display a role selection field populated by calling `GET /api/v1/roles` (no auth required) to list available roles.
5. WHEN the role list is loading, THE Register_Screen SHALL display a loading indicator in the role selection field.

---

### Requirement 7: Authentication API — Email Verification

**User Story:** As a newly registered user, I want to verify my email address, so that my account is activated and I can log in.

#### Acceptance Criteria

1. WHEN a user submits an OTP code, THE Auth_Service SHALL be called at `POST /api/v1/auth/verify-email` with body `{ email: string, otp: string }`.
2. WHEN email verification succeeds, THE Auth_Repository SHALL return `Result.success(void)` and the app SHALL navigate to the login screen.
3. WHEN a user requests a new verification email, THE Auth_Service SHALL be called at `POST /api/v1/auth/resend-verification` with body `{ email: string }`.
4. IF the OTP is invalid or expired, THEN THE Auth_Repository SHALL return `Result.failure(AppError(badRequest: true))` and THE Verify_Email_Screen SHALL display the error message.

---

### Requirement 8: Authentication API — Password Reset

**User Story:** As a user who has forgotten their password, I want to reset it via email OTP, so that I can regain access to my account.

#### Acceptance Criteria

1. WHEN a user submits their email on the forgot-password screen, THE Auth_Service SHALL be called at `POST /api/v1/auth/forgot-password` with body `{ email: string }`.
2. WHEN a user submits the OTP received by email, THE Auth_Service SHALL be called at `POST /api/v1/auth/verify-otp` with body `{ email: string, otp: string }`.
3. WHEN a user submits a new password, THE Auth_Service SHALL be called at `POST /api/v1/auth/reset-password` with body `{ email: string, otp: string, new_password: string }`.
4. WHEN password reset succeeds, THE Auth_Repository SHALL return `Result.success(void)` and the app SHALL navigate to the login screen.
5. WHILE authenticated, WHEN a user changes their password, THE Auth_Service SHALL be called at `POST /api/v1/auth/change-password` with body `{ current_password: string, new_password: string }` and the `Authorization: Bearer <access_token>` header.

---

### Requirement 9: Token Refresh

**User Story:** As an authenticated user, I want my session to be refreshed automatically, so that I am not unexpectedly logged out while actively using the app.

#### Acceptance Criteria

1. WHEN the app reads the stored `access_token` and its decoded expiry is within 10 minutes of the current time, THE Auth_Repository SHALL proactively call `POST /api/v1/auth/refresh` with body `{ refresh_token: string }` before the next API request.
2. WHEN the refresh call succeeds, THE Secure_Storage SHALL overwrite the `access_token` with the new token returned in the response.
3. WHEN a 401 response is received on any API call, THE Auth_Interceptor SHALL reactively call `POST /api/v1/auth/refresh` and retry the original request once with the new token.
4. IF the refresh call returns HTTP 401 or the stored `Refresh_Token` is absent, THEN THE Auth_Interceptor SHALL clear all tokens, set `Auth_State` to `unauthenticated`, and navigate to the login route.
5. THE Auth_Interceptor SHALL use a `Mutex` lock so that only one refresh call runs at a time across all concurrent requests.

---

### Requirement 10: RBAC — Role Storage and Selection

**User Story:** As a user with multiple roles, I want to select which role I am acting under, so that the app shows me the correct features and navigation for that role.

#### Acceptance Criteria

1. WHEN login succeeds, THE Auth_Repository SHALL parse the `roles` array from the login response and store it in the `Role_Store`.
2. THE `roles` array SHALL contain objects with at minimum `id` (string), `name` (string), and `scope` (string) fields.
3. THE Role_Store SHALL expose `selectedRole`, `selectedRoles`, `setSelectedRole(Role)`, `clearSelectedRole()`, `getSelectedRoleId()`, and `getSelectedRoleName()`.
4. THE Role_Store SHALL persist `selectedRole` and `selectedRoles` to `Local_Storage` under the key `zoovana_role_storage` so the selection survives app restarts.
5. WHEN a user holds exactly one role, THE App SHALL automatically set that role as `selectedRole` without showing a role selection screen.
6. WHEN a user holds more than one role, THE App SHALL navigate to a role selection screen after login where the user picks their active role.
7. THE Role_Selection_Screen SHALL display the name and scope of each available role.

---

### Requirement 11: RBAC — Superuser Gate

**User Story:** As a superuser, I want to access the admin panel, so that I can manage users, roles, and platform-wide settings.

#### Acceptance Criteria

1. WHEN login succeeds and `is_superuser` is `true`, THE Local_Storage SHALL store `is_superuser: true`.
2. WHEN a user navigates to any route under `/admin`, THE GoRouter redirect callback SHALL check `is_superuser` from `Local_Storage` and redirect to `/dashboard` if the value is `false` or absent.
3. THE Admin_Shell route SHALL only be accessible when both `authenticated` is `true` and `is_superuser` is `true`.

---

### Requirement 12: RBAC — Role-Based Navigation Guards

**User Story:** As a developer, I want GoRouter redirect guards that enforce authentication and role requirements, so that users cannot access screens they are not authorized for.

#### Acceptance Criteria

1. THE GoRouter SHALL define a `redirect` callback that runs on every navigation event.
2. WHEN `Auth_State` is `unauthenticated` and the target route is not in the public route list (`/login`, `/signup`, `/register`, `/forgot-password`, `/reset-password`, `/verify-email`, `/pending-approval`), THE GoRouter redirect callback SHALL return `/login`.
3. WHEN `Auth_State` is `authenticated` and the target route is in the public route list, THE GoRouter redirect callback SHALL return `/dashboard`.
4. WHEN `Auth_State` is `pendingApproval`, THE GoRouter redirect callback SHALL return `/pending-approval` regardless of the target route.
5. WHEN `Auth_State` is `loading`, THE GoRouter redirect callback SHALL return `/splash` to show a loading screen while auth state is being restored.
6. THE GoRouter SHALL define the following named routes: `/splash`, `/login`, `/signup`, `/register`, `/forgot-password`, `/reset-password`, `/verify-email`, `/pending-approval`, `/role-select`, `/dashboard`, `/shop-dashboard`, `/admin`.

---

### Requirement 13: Tenant & Approval Flow

**User Story:** As a user whose account is pending admin approval, I want to be redirected to a pending-approval screen, so that I understand my account status and am not shown inaccessible features.

#### Acceptance Criteria

1. WHEN login succeeds, THE Auth_Repository SHALL store `default_tenant_id` in `Local_Storage`.
2. THE `default_tenant_id` SHALL be passed implicitly via the Bearer token to all authenticated API calls — the frontend SHALL NOT manually append it as a query or path parameter unless explicitly required by a specific endpoint.
3. WHEN the Auth_Service returns a response indicating the account is pending approval (HTTP 403 with a `pending_approval` flag or equivalent status field), THE Auth_Repository SHALL return `Result.success(AuthSession(status: pendingApproval))`.
4. WHEN `Auth_State` is `pendingApproval`, THE App SHALL display the `/pending-approval` screen with a message explaining the account status.
5. THE Pending_Approval_Screen SHALL provide a logout button that clears all stored tokens and navigates to `/login`.
6. WHEN a user on the pending-approval screen taps a refresh button, THE App SHALL re-fetch the user profile at `GET /api/v1/users/me/profile` and update `Auth_State` if the account has been approved.

---

### Requirement 14: Shop Owner Initialization Flow

**User Story:** As a shop owner, I want the app to load my business and branch data immediately after login, so that I can access my shop dashboard without additional loading steps.

#### Acceptance Criteria

1. WHEN a user's `selectedRole` has `scope: shop_owner` (or equivalent), THE App SHALL trigger the shop initialization flow after role selection.
2. WHEN the shop initialization flow starts, THE Shop_Repository SHALL call `GET /api/v1/businesses/me` on the Shop_Service to fetch the user's business entity.
3. WHEN the business is fetched successfully, THE Shop_Repository SHALL call `GET /api/v1/businesses/me/with-branches` to fetch the business with its associated branches.
4. WHEN branches are fetched successfully, THE Shop_Repository SHALL store the first branch's `id` as the `activeBranchId` in `Local_Storage` for use in subsequent branch-scoped API calls.
5. WHEN all initialization data is loaded, THE Shop_Init_State SHALL transition to `ready` and THE App SHALL navigate to `/shop-dashboard`.
6. IF the `GET /api/v1/businesses/me` call returns HTTP 404, THEN THE Shop_Init_State SHALL transition to `error` with message indicating no business is registered, and THE App SHALL navigate to a business setup screen.
7. WHILE the shop initialization is in progress, THE App SHALL display a loading screen with a progress indicator.
8. THE Shop_Repository SHALL also call `GET /api/v1/branches` to fetch the full branch list for the branch selector in the shop dashboard.

---

### Requirement 15: Shop Owner — Business and Branch Data Models

**User Story:** As a developer, I want typed Dart models for business and branch API responses, so that shop initialization data is parsed correctly and available throughout the app.

#### Acceptance Criteria

1. THE `BusinessModel` SHALL parse at minimum: `id` (string), `name` (string), `owner_id` (string), `tenant_id` (string), `status` (string), and `created_at` (DateTime) from the `GET /api/v1/businesses/me` response.
2. THE `BranchModel` SHALL parse at minimum: `id` (string), `business_id` (string), `name` (string), `address` (string, nullable), `is_active` (bool), and `created_at` (DateTime) from the branches array.
3. THE `BusinessWithBranchesModel` SHALL parse the business fields plus a `branches` list of `BranchModel` objects from the `GET /api/v1/businesses/me/with-branches` response.
4. THE `BusinessEntity`, `BranchEntity`, and `BusinessWithBranchesEntity` SHALL be domain-layer objects with `toEntity()` methods on their corresponding models.
5. FOR ALL valid `BusinessWithBranchesModel` objects, parsing then converting to entity SHALL preserve the branch count and all branch `id` values (round-trip property).

---

### Requirement 16: Auth Data Models

**User Story:** As a developer, I want typed Dart models for all authentication API responses, so that login, registration, and token refresh data is parsed correctly.

#### Acceptance Criteria

1. THE `LoginRequestModel` SHALL serialize `{ email: string, password: string }` to JSON.
2. THE `LoginResponseModel` SHALL parse `access_token`, `refresh_token`, `expires_in`, and a nested `user` object from the login API response.
3. THE `UserModel` SHALL parse `id`, `email`, `full_name`, `is_superuser` (bool), `is_email_verified` (bool), `roles` (list of `RoleModel`), and `default_tenant_id` from the `user` object.
4. THE `RoleModel` SHALL parse `id`, `name`, and `scope` from each role object in the `roles` array.
5. THE `AuthSessionEntity` SHALL be the domain-layer object containing `accessToken`, `refreshToken`, `expiresIn`, `user` (as `UserEntity`), and `status` (enum: `active`, `pendingApproval`).
6. THE `UserEntity` SHALL contain `id`, `email`, `fullName`, `isSuperuser`, `isEmailVerified`, `roles` (list of `RoleEntity`), and `defaultTenantId`.
7. THE `RoleEntity` SHALL contain `id`, `name`, and `scope`.
8. FOR ALL valid `LoginResponseModel` objects, calling `toEntity()` SHALL produce an `AuthSessionEntity` whose `user.roles` list length equals the number of role objects in the original JSON (round-trip property).
9. FOR ALL valid `UserModel` objects, calling `toEntity()` SHALL produce a `UserEntity` where `isSuperuser` equals the `is_superuser` boolean in the source JSON (round-trip property).

---

### Requirement 17: State Management — Auth State

**User Story:** As a developer, I want a centralized auth state notifier, so that all screens can reactively respond to authentication changes without polling or manual checks.

#### Acceptance Criteria

1. THE `Auth_Notifier` SHALL expose an `Auth_State` with variants: `loading`, `unauthenticated`, `authenticated(AuthSessionEntity)`, and `pendingApproval(AuthSessionEntity)`.
2. WHEN the app starts, THE `Auth_Notifier` SHALL read `Secure_Storage` and transition from `loading` to `authenticated` or `unauthenticated` based on the presence of a stored `access_token`.
3. WHEN `LoginUseCase` succeeds, THE `Auth_Notifier` SHALL transition to `authenticated(session)`.
4. WHEN `LogoutUseCase` is called, THE `Auth_Notifier` SHALL clear all storage and transition to `unauthenticated`.
5. WHEN the `Auth_Interceptor` detects an unrecoverable 401, THE `Auth_Notifier` SHALL transition to `unauthenticated`.
6. THE `Auth_Notifier` SHALL be registered as a global provider accessible from any screen without passing it through the widget tree.

---

### Requirement 18: State Management — Shop Init State

**User Story:** As a developer, I want a shop initialization state notifier, so that the shop dashboard only renders after all required data is loaded.

#### Acceptance Criteria

1. THE `Shop_Init_Notifier` SHALL expose a `Shop_Init_State` with variants: `idle`, `loading`, `ready(BusinessWithBranchesEntity, List<BranchEntity>)`, and `error(AppError)`.
2. WHEN the shop initialization flow is triggered, THE `Shop_Init_Notifier` SHALL transition to `loading` and call `ShopInitUseCase`.
3. WHEN `ShopInitUseCase` succeeds, THE `Shop_Init_Notifier` SHALL transition to `ready` with the fetched business and branches data.
4. WHEN `ShopInitUseCase` fails, THE `Shop_Init_Notifier` SHALL transition to `error` with the `AppError`.
5. THE `Shop_Init_Notifier` SHALL expose the `activeBranchId` (the ID of the first branch) for use by other shop-scoped providers.

---

### Requirement 19: Navigation Flow — Step-by-Step

**User Story:** As a developer, I want a documented step-by-step navigation flow, so that I can implement the GoRouter configuration that correctly routes users through login, role selection, and shop initialization.

#### Acceptance Criteria

1. THE App SHALL implement the following navigation flow after a successful login:
   - Step 1: `POST /api/v1/auth/login` → parse response → store tokens and metadata.
   - Step 2: Check `is_email_verified` — if `false`, navigate to `/verify-email`.
   - Step 3: Check pending approval status — if pending, navigate to `/pending-approval`.
   - Step 4: Check `roles` array length — if more than one role, navigate to `/role-select`; if exactly one role, auto-select it.
   - Step 5: Check `selectedRole.scope` — if `shop_owner`, trigger shop initialization flow; otherwise navigate to `/dashboard`.
   - Step 6 (shop owner only): Call `GET /api/v1/businesses/me/with-branches` and `GET /api/v1/branches` in parallel.
   - Step 7 (shop owner only): On success, navigate to `/shop-dashboard`; on failure, navigate to `/business-setup`.
2. THE GoRouter SHALL implement this flow using a `redirect` callback that reads `Auth_State`, `Role_Store`, and `Shop_Init_State` to determine the correct route at each step.
3. WHEN the user presses the back button on `/shop-dashboard`, THE App SHALL NOT navigate back to the login or initialization screens.
4. WHEN the user presses the back button on `/role-select`, THE App SHALL navigate back to `/login` and clear the partially initialized session.

---

### Requirement 20: Error Handling and User Feedback

**User Story:** As a user, I want clear error messages when authentication or initialization fails, so that I understand what went wrong and what action to take.

#### Acceptance Criteria

1. WHEN an `AppError` has `networkError: true`, THE App SHALL display a "No internet connection. Please check your network." message.
2. WHEN an `AppError` has `unauthorized: true` on the login screen, THE App SHALL display "Invalid email or password."
3. WHEN an `AppError` has `validationErrors: true`, THE App SHALL display each field-level error message inline next to the corresponding form field.
4. WHEN an `AppError` has `serverError: true`, THE App SHALL display "An unexpected server error occurred. Please try again."
5. WHEN an `AppError` has `forbidden: true` on a non-login screen, THE App SHALL display "You do not have permission to perform this action."
6. WHEN an `AppError` has `cancelled: true`, THE App SHALL silently ignore the error without displaying any message to the user.
7. WHILE any auth or shop initialization request is in progress, THE App SHALL disable the submit button or show a loading indicator to prevent duplicate submissions.
8. WHEN the shop initialization fails, THE App SHALL display a retry button that re-triggers the `Shop_Init_Notifier` initialization flow.
