# Zoovana Frontend — Complete Architecture Analysis

> **Purpose:** This document is a standalone, human-readable architectural and functional analysis of the Zoovana Next.js frontend. It is intended to guide the replication of this system in a Flutter mobile application.

---

# Requirements Document

## Introduction

This document captures the complete architectural and functional analysis of the **Zoovana** Next.js frontend application. Zoovana is a multi-domain pet services platform that encompasses a pet shop management system, an animal shelter management system, a pet care marketplace (bookings, providers), and a public-facing adoption/lost-found portal.

The purpose of this analysis is to produce a structured, reusable specification that can guide the replication of this system's architecture in a Flutter mobile application. Every section describes *what* the system does and *how* it is structured — not the implementation details of the Next.js framework itself.

The system communicates with four independent backend microservices over HTTP/REST and one WebSocket endpoint. It uses NextAuth.js for session management, TanStack React Query for server-state management, Zustand for client-state, and next-intl for bilingual (English/Arabic) support.

---

## Glossary

- **Auth Service**: The main backend microservice at port 8001. Handles authentication, users, roles, permissions, and tenants.
- **Shop Service**: The backend microservice at port 8012. Handles businesses, branches, products, categories, suppliers, inventory, purchase orders, marketplace submissions, and marketplace orders/invoices.
- **Shelter Service**: The backend microservice at port 8014. Handles shelters, animals, kennels, adoptions, volunteers, donations, lost-and-found, and medical records.
- **PetCare Service**: The backend microservice at port 8015. Handles pet owners, pets, provider profiles, service listings, bookings, payments, reviews, and real-time chat.
- **Access_Token**: A short-lived JWT (default 1800 seconds) issued by the Auth Service on login. Sent as a Bearer token in the Authorization header of every authenticated request.
- **Refresh_Token**: A long-lived token used to obtain a new Access_Token without re-login.
- **Session**: The NextAuth.js server-side session object that stores the Access_Token, Refresh_Token, user metadata, roles, and tenant ID in an encrypted JWT cookie.
- **Tenant**: A top-level organizational unit. Each user belongs to a tenant via `default_tenant_id`.
- **Branch**: A physical or logical sub-unit of a business (shop). All product, category, supplier, and inventory data is scoped to a Branch.
- **Business**: The parent entity of one or more Branches. Managed via the Shop Service.
- **Role**: A named set of permissions assigned to a user. Roles have a scope (e.g., shop_owner, shelter_staff, provider, admin).
- **Permission**: A granular action right (e.g., `products:create`, `animals:read`) grouped into Modules.
- **Module**: A logical grouping of Permissions (e.g., "Products", "Animals").
- **Provider**: A pet care service provider (groomer, vet, trainer, etc.) who has applied and been verified.
- **Shelter**: An animal shelter organization managing animals, kennels, adoptions, and volunteers.
- **Marketplace**: The public product marketplace where shop owners submit categories and products for admin approval and sale.
- **QueryClient**: The TanStack React Query client instance that manages all server-state caching, invalidation, and synchronization.
- **Interceptor**: An Axios middleware function that runs before a request is sent or after a response is received.
- **Locale**: The active language code, either `en` (English) or `ar` (Arabic). Embedded in every URL path as the first segment.
- **RTL**: Right-to-left text direction, applied when locale is `ar`.
- **WebSocket**: A persistent bidirectional connection used for real-time chat messaging.
- **RBAC**: Role-Based Access Control — the system of assigning roles and permissions to users to control what they can do.
- **FormData**: A browser API for encoding file uploads alongside text fields in multipart/form-data HTTP requests.
- **staleTime**: The duration (in milliseconds) after which React Query considers cached data stale and eligible for background refetch.
- **gcTime**: The duration after which React Query removes unused cached data from memory.
- **Superuser**: A user with `is_superuser: true`, granting access to the admin panel.
- **PO**: Purchase Order — a formal document from a branch to a supplier for goods.

---

## Requirements

### Requirement 1: Authentication Flow

**User Story:** As a user, I want to log in with my email and password, so that I can access the platform with a secure, auto-refreshing session.

#### Acceptance Criteria

1. WHEN a user submits valid credentials, THE Auth_Service SHALL return an `access_token`, `refresh_token`, `token_type`, `expires_in`, and a `user` object containing `id`, `email`, `full_name`, `is_superuser`, `is_email_verified`, `roles`, and `default_tenant_id`.
2. WHEN login succeeds, THE Session SHALL store the `access_token`, `refresh_token`, `expires_in`, `is_superuser`, `roles`, `default_tenant_id`, and `full_name` in an encrypted JWT cookie managed by NextAuth.js.
3. WHEN the `access_token` is within 10 minutes of expiry, THE Session SHALL automatically call `POST /api/v1/auth/refresh` with the `refresh_token` and replace the stored `access_token` with the new one.
4. IF the refresh call fails or returns no valid token, THEN THE Session SHALL be invalidated and the user SHALL be redirected to the login page.
5. WHEN a client-side API call receives a 401 response, THE Auth_Interceptor SHALL attempt to fetch a fresh session from `/api/auth/session` and retry the original request once with the new token.
6. IF the retry after token refresh also returns 401, THEN THE Auth_Interceptor SHALL call `signOut` and redirect the user to `/login`.
7. WHILE the user is on an auth page (login, register, signup), THE Auth_Interceptor SHALL skip the logout redirect to prevent redirect loops.
8. THE Auth_Service SHALL expose `POST /api/v1/auth/register` for new user registration.
9. THE Auth_Service SHALL expose `POST /api/v1/auth/verify-email` and `GET /api/v1/auth/verify-email?otp=` for email verification.
10. THE Auth_Service SHALL expose `POST /api/v1/auth/forgot-password`, `POST /api/v1/auth/verify-otp`, and `POST /api/v1/auth/reset-password` for the password reset flow.
11. THE Auth_Service SHALL expose `POST /api/v1/auth/change-password` for authenticated password changes.
12. THE Auth_Service SHALL expose `POST /api/v1/auth/resend-verification` for resending the verification email.


---

### Requirement 2: API Client Architecture

**User Story:** As a developer, I want a structured multi-client HTTP layer, so that requests to different backend microservices are routed correctly with consistent interceptor behavior.

#### Acceptance Criteria

1. THE System SHALL maintain five distinct Axios client instances: `authClient` (Auth Service, port 8001), `shopClient` (Shop Service, port 8012), `shelterClient` (Shelter Service, port 8014), `petCareClient` (PetCare Service, port 8015), and `serverClient` (server-side only, no automatic token handling).
2. THE System SHALL resolve base URLs from environment variables at runtime, with fallback defaults: `NEXT_PUBLIC_API_BASE_URL` → `http://161.35.222.194:8001`, `NEXT_PUBLIC_SHOP_API_BASE_URL` → `http://161.35.222.194:8012`, `NEXT_PUBLIC_SHELTER_API_BASE_URL` → `http://161.35.222.194:8014`, `NEXT_PUBLIC_PETCARE_API_BASE_URL` → `http://161.35.222.194:8015`.
3. WHEN running in a browser, THE System SHALL proxy API requests through Next.js rewrites: `/api/main/*` → Auth Service, `/api/shop/*` → Shop Service, `/api/shelter/*` → Shelter Service, `/api/petcare/*` → PetCare Service.
4. WHEN running server-side, THE System SHALL use direct IP:port base URLs to bypass the browser proxy.
5. THE System SHALL expose a `getClient(clientType)` factory function that returns the correct Axios instance for a given `ClientType` enum value (`AUTH`, `SHOP`, `SHELTER`, `PETCARE`, `SERVER`).
6. THE `serverClient` SHALL support a `createAuthenticatedServerClient(token)` factory that returns a pre-authorized Axios instance for use in server components and API routes.
7. WHEN a request is made in development mode, THE Logger_Interceptor SHALL attach a `requestId` and `startTime` to the request metadata for performance tracking.
8. THE System SHALL set a request timeout of 80,000 milliseconds on all client instances.
9. THE `shopClient` and `petCareClient` and `shelterClient` SHALL use `useForcedRefresh: true` in their auth interceptor, triggering a forced session update call to `/api/auth/session?update=1` when no valid token is found after the initial session fetch.
10. THE System SHALL include `ngrok-skip-browser-warning: 69420` and `Content-Type: application/json` as default headers on all clients to support development tunneling.

---

### Requirement 3: Interceptor Chain

**User Story:** As a developer, I want a composable interceptor pipeline, so that every API client gets consistent locale injection, logging, error normalization, and token refresh behavior.

#### Acceptance Criteria

1. THE System SHALL apply interceptors in this fixed order per client: (Request) Locale → Logger; (Response) Logger → Error → Auth.
2. WHEN a request is dispatched, THE Locale_Interceptor SHALL read the active locale from the URL path first segment (`/en/` or `/ar/`), falling back to the `NEXT_LOCALE` cookie, and inject it as the `Accept-Language` header.
3. WHEN a response is received successfully, THE Error_Interceptor SHALL unwrap `response.data` and return it directly, so service functions receive the payload without accessing `.data`.
4. WHEN a response has HTTP status 400, THE Error_Interceptor SHALL extract the error message from `detail` (string or array) or `message` fields and return a normalized error object with `{ status: 400, message, errors, badRequest: true }`.
5. WHEN a response has HTTP status 401, THE Error_Interceptor SHALL return `{ status: 401, message: "errors.sessionExpired", unauthorized: true }` and pass control to the Auth_Interceptor.
6. WHEN a response has HTTP status 403, THE Error_Interceptor SHALL return `{ status: 403, message: "You don't have permission...", forbidden: true }`.
7. WHEN a response has HTTP status 404, THE Error_Interceptor SHALL return `{ status: 404, message: detail|message, notFound: true }`.
8. WHEN a response has HTTP status 409, THE Error_Interceptor SHALL return `{ status: 409, message, errors, conflict: true }`.
9. WHEN a response has HTTP status 422, THE Error_Interceptor SHALL map each validation error object `{ loc, msg }` to a human-readable string and return `{ status: 422, message, errors, validationErrors: true }`.
10. WHEN a response has HTTP status 500, THE Error_Interceptor SHALL return `{ status: 500, message: detail|message|"errors.unexpectedError", serverError: true }`.
11. WHEN a network error occurs (no response, ERR_NETWORK, ERR_NAME_NOT_RESOLVED), THE Error_Interceptor SHALL return `{ status: 0, message: "errors.serverUnavailable", networkError: true }`.
12. WHEN a request is cancelled (CanceledError, ERR_CANCELED), THE Error_Interceptor SHALL return `{ status: 0, message: "Request cancelled", cancelled: true }`.
13. THE Auth_Interceptor SHALL use a single shared refresh promise per client instance to prevent concurrent token refresh races when multiple requests fail simultaneously.


---

### Requirement 4: Service Layer

**User Story:** As a developer, I want a dedicated service module per domain, so that all API endpoint logic is centralized and reusable across hooks and components.

#### Acceptance Criteria

1. THE System SHALL organize service functions into one file per domain: `auth.js`, `users.js`, `tenants.js`, `shops.js` (branches), `categories.js`, `products.js`, `productVariants.js`, `suppliers.js`, `business.js`, `marketplace.js`, `mpOrders.js`, `mpInvoices.js`, `purchaseOrders.js`, `inventoryStock.js`, `inventoryLocations.js`, `shelters.js`, `animals.js`, `kennels.js`, `kennelAssignments.js`, `cleaningLogs.js`, `adoptions.js`, `requests.js`, `lostFound.js`, `volunteers.js`, `donations.js`, `medicalRecords.js`, `vaccinations.js`, `vaccinationSchedules.js`, `animalCare.js`, `pets.js`, `providers.js`, `bookings.js`, `payments.js`, `reviews.js`, `chats.js`, `health.js`, and admin sub-services `admin/marketplaceApprovals.js` and `admin/providerProfiles.js`.
2. WHEN a service function is called, THE Service SHALL pass the `accessToken` explicitly as a Bearer token in the `Authorization` header of every authenticated request.
3. THE System SHALL use `multipart/form-data` encoding (FormData) for all endpoints that accept file uploads, including category images, product images, animal images, shelter logos, provider ID documents, and pet photos.
4. FOR ALL paginated list endpoints, THE Service SHALL accept `page` and `page_size` parameters and append them as URL query parameters.
5. THE System SHALL use `shopClient` for: branches, categories, products, productVariants, suppliers, business, marketplace, mpOrders, mpInvoices, purchaseOrders, inventoryStock, inventoryLocations, and admin marketplace approvals.
6. THE System SHALL use `authClient` for: auth, users, tenants, roles, permissions, and modules.
7. THE System SHALL use `shelterClient` for: shelters, animals, kennels, kennelAssignments, cleaningLogs, adoptions, requests, lostFound, volunteers, donations, medicalRecords, vaccinations, vaccinationSchedules, and animalCare.
8. THE System SHALL use `petCareClient` for: pets, providers, bookings, payments, reviews, chats, and admin provider profiles.

---

### Requirement 5: State Management — React Query

**User Story:** As a developer, I want a centralized server-state management layer, so that API data is cached, deduplicated, and invalidated consistently across the application.

#### Acceptance Criteria

1. THE System SHALL use TanStack React Query (v5) as the sole server-state management solution, configured with: `staleTime: 2 minutes`, `gcTime: 10 minutes`, `retry: false`, `refetchOnWindowFocus: false`, `refetchOnMount: true`, `refetchOnReconnect: false`, `networkMode: 'always'`.
2. THE System SHALL define all query keys in a centralized `queryKeys` factory object in `src/lib/query/keys.js`, using hierarchical arrays (e.g., `["users", "list", filters]`, `["products", branchId, search, page, pageSize]`).
3. THE System SHALL define an `invalidationMap` object that maps mutation events (onCreate, onUpdate, onDelete) to arrays of query keys that must be invalidated.
4. WHEN a mutation succeeds, THE System SHALL call `queryClient.invalidateQueries` with `refetchType: "active"` for each key in the invalidation map, so only currently visible queries are refetched immediately.
5. THE System SHALL provide four generic hook factories: `useList`, `useCreate`, `useUpdate`, `useDelete` in `src/lib/query/hooks/`, each accepting a `resource` URL, `client` type, `queryKey`, and `invalidates` array.
6. THE `useList` hook SHALL only enable the query when `status === "authenticated"` and `session?.user?.accessToken` is present.
7. THE `useList` hook SHALL never retry on 401, 404, or auth errors, and SHALL allow up to 2 retries for other errors.
8. THE `useUpdate` hook SHALL support `{id}` placeholder substitution in the resource URL string.
9. THE `useDelete` hook SHALL support `{id}` placeholder substitution in the resource URL string.
10. THE System SHALL create a single `QueryClient` instance per `QueryProvider` mount using `useState(() => createQueryClient())` to prevent memory leaks from shared instances.

---

### Requirement 6: State Management — Zustand

**User Story:** As a developer, I want lightweight client-side state for UI-level concerns, so that role selection and section navigation persist across page reloads without server round-trips.

#### Acceptance Criteria

1. THE System SHALL use Zustand with the `persist` middleware for the `roleStore`, persisting `selectedRole` and `selectedRoles` to `localStorage` under the key `zoovana-role-storage`.
2. THE `roleStore` SHALL expose: `setSelectedRole(role)`, `setSelectedRoles(roles)`, `clearSelectedRole()`, `getSelectedRoleId()`, `getSelectedRoleIds()`, and `getSelectedRoleName()`.
3. THE System SHALL use a React Context (`SectionContext`) for tracking the active landing page section index, providing `currentSection` and `setCurrentSection` to child components.


---

### Requirement 7: Routing and Navigation

**User Story:** As a developer, I want a structured route hierarchy with locale prefixes and role-based guards, so that users are directed to the correct experience based on their authentication state and role.

#### Acceptance Criteria

1. THE System SHALL prefix every route with a locale segment, making all URLs of the form `/{locale}/{path}` (e.g., `/en/dashboard`, `/ar/login`). The locale prefix SHALL always be present.
2. THE System SHALL support two locales: `en` (English, LTR) and `ar` (Arabic, RTL). The default locale SHALL be `en`.
3. THE System SHALL organize routes into three route groups: `(auth)` for unauthenticated pages, `(admin)` for superuser-only pages, and the default group for authenticated user pages.
4. THE `(auth)` route group SHALL contain: `/login`, `/signup`, `/register`, `/register/shopOwner`, `/forgot-password`, `/reset-password`, `/pending-approval`.
5. THE `(admin)` route group SHALL contain: `/admin-panel` (dashboard), `/admin-panel/addAnimal`, `/admin-panel/analyticsDashboard`, `/admin-panel/createRole`, `/admin-panel/data-management`, `/admin-panel/marketplace-approvals`, `/admin-panel/provider-verification`, `/admin-panel/registerOwner`, `/admin-panel/user`, `/admin-panel/userAnimalManagement`.
6. THE default route group SHALL contain: `/dashboard`, `/profile`, `/marketplace`, `/adopt`, `/donate`, `/lost-found`, `/provider`.
7. WHEN a request reaches the `(admin)` layout, THE Admin_Layout SHALL call `getServerSession` and redirect to `/{locale}/login` if no session exists, or redirect to `/{locale}` if the user is not a superuser (`is_superuser !== true`).
8. THE System SHALL use next-intl middleware (`createMiddleware`) to handle locale detection and redirection, matching all paths except `/api`, `/_next`, `/_vercel`, and static file paths.
9. THE System SHALL expose locale-aware navigation utilities (`Link`, `redirect`, `usePathname`, `useRouter`) from `next-intl/navigation` so all internal links automatically include the active locale.

---

### Requirement 8: Multi-Tenancy Architecture

**User Story:** As a developer, I want all data operations to be scoped to the user's tenant and branch, so that different organizations cannot access each other's data.

#### Acceptance Criteria

1. WHEN a user logs in, THE Session SHALL store the user's `default_tenant_id` from the login response.
2. THE Auth_Service SHALL expose full CRUD for tenants at `/api/v1/tenants` and `/api/v1/tenants/{tenant_id}`, all requiring Bearer token authentication.
3. THE Shop_Service SHALL scope all branch, product, category, supplier, and inventory data to a `branch_id` path or query parameter.
4. WHEN fetching categories, THE System SHALL pass `branch_id` as a path parameter: `GET /api/v1/products/categories/{branch_id}`.
5. WHEN fetching products, THE System SHALL pass `branch_id` as a path parameter: `GET /api/v1/products/{branch_id}`.
6. WHEN fetching suppliers, THE System SHALL pass `branch_id` as a path parameter: `GET /api/v1/{branch_id}/suppliers`.
7. WHEN fetching inventory stock, THE System SHALL pass `branch_id` as a query parameter: `GET /api/v1/inventory/stock/?branch_id={branch_id}`.
8. WHEN fetching inventory locations, THE System SHALL pass `branch_id` as a path parameter: `GET /api/v1/inventory/branches/{branch_id}/locations`.
9. WHEN fetching purchase orders, THE System SHALL pass `branch_id` as a path parameter: `GET /api/v1/purchase-orders/branches/{branch_id}`.
10. THE System SHALL expose `GET /api/v1/businesses/me` and `GET /api/v1/businesses/me/with-branches` to retrieve the authenticated user's business and its associated branches.
11. THE Shelter_Service SHALL scope animal, kennel, adoption, and volunteer data to a `shelter_id` query parameter where applicable.
12. THE System SHALL expose a `/pending-approval` page for users whose tenant or account is awaiting admin approval.

---

### Requirement 9: RBAC — Roles and Permissions

**User Story:** As an admin, I want to define roles with granular permissions and assign them to users, so that access to features is controlled at a fine-grained level.

#### Acceptance Criteria

1. THE Auth_Service SHALL expose `GET /api/v1/roles` (public, no auth required) to list all available roles for registration flows.
2. THE Auth_Service SHALL expose full CRUD for roles at `/api/v1/roles` and `/api/v1/roles/{id}`, requiring Bearer token authentication for write operations.
3. THE Auth_Service SHALL expose `GET /api/v1/roles/{id}/permissions` to retrieve all permissions attached to a role.
4. THE Auth_Service SHALL expose `POST /api/v1/roles/{id}/permissions` to attach permissions to a role.
5. THE Auth_Service SHALL expose `DELETE /api/v1/roles/{roleId}/permissions/{permissionId}` to remove a permission from a role.
6. THE Auth_Service SHALL expose full CRUD for permissions at `/api/v1/permissions` and `/api/v1/permissions/{id}`.
7. THE Auth_Service SHALL expose full CRUD for modules at `/api/v1/modules` and `/api/v1/modules/{id}`, where each module groups related permissions.
8. THE System SHALL store the user's `roles` array (from the login response) in the NextAuth session token and expose it via `session.user.roles`.
9. THE System SHALL use `is_superuser: true` as the gate for admin panel access, checked server-side in the `(admin)` layout.
10. THE `roleStore` SHALL allow the UI to track which role the user has selected when a user holds multiple roles.
11. THE Auth_Service SHALL expose `GET /api/v1/admin/dashboard/stats` for admin dashboard statistics.
12. THE Auth_Service SHALL expose `GET /api/v1/users/me/profile` for the authenticated user's own profile.


---

### Requirement 10: Shop Module (Branches, Products, Categories, Suppliers)

**User Story:** As a shop owner, I want to manage my branches, product catalog, categories, and suppliers, so that I can operate my pet supply business through the platform.

#### Acceptance Criteria

1. THE Shop_Service SHALL expose full CRUD for branches at `/api/v1/branches` and `/api/v1/branches/{branch_id}`, using POST for create, GET for read, PATCH for update, and DELETE for delete.
2. THE Shop_Service SHALL expose full CRUD for categories scoped to a branch: `POST /api/v1/products/categories/{branch_id}`, `GET /api/v1/products/categories/{branch_id}`, `GET /api/v1/products/category/{category_id}`, `PUT /api/v1/products/category/{category_id}`, `DELETE /api/v1/products/category/{category_id}`.
3. WHEN creating or updating a category, THE System SHALL send a `multipart/form-data` request containing `name_en`, `name_ar`, optional `description_en`, `description_ar`, `parent_id`, `sort_order`, `is_active`, and an optional `image` file.
4. THE Shop_Service SHALL support hierarchical categories via a `parent_id` field. A category with no `parent_id` is a root category.
5. THE `GET /api/v1/products/categories/{branch_id}` endpoint SHALL accept a `roots_only=true` query parameter to return only top-level categories.
6. THE Shop_Service SHALL expose full CRUD for products scoped to a branch: `POST /api/v1/products/{branch_id}`, `GET /api/v1/products/{branch_id}`, `GET /api/v1/products/item/{product_id}`, `PUT /api/v1/products/product/{product_id}`, `DELETE /api/v1/products/product/{product_id}`.
7. WHEN creating or updating a product, THE System SHALL send a `multipart/form-data` request with `product_data` as a JSON string field and `images` as one or more file fields.
8. THE Shop_Service SHALL expose full CRUD for product variants at `/api/v1/product-variants` and `/api/v1/product-variants/{variant_id}`, plus `POST /api/v1/product-variants/bulk` for bulk creation.
9. THE Shop_Service SHALL expose full CRUD for suppliers scoped to a branch: `POST /api/v1/{branch_id}/suppliers`, `GET /api/v1/{branch_id}/suppliers`, `GET /api/v1/suppliers/{supplier_id}`, `PATCH /api/v1/suppliers/{supplier_id}`, `DELETE /api/v1/suppliers/{supplier_id}`.
10. THE Shop_Service SHALL expose `GET /api/v1/dashboard/overview` (with optional `branch_id` query param) for the shop owner dashboard.
11. THE Shop_Service SHALL expose `GET /api/v1/businesses/me`, `PATCH /api/v1/businesses/me`, and `GET /api/v1/businesses/me/with-branches` for business management.

---

### Requirement 11: Inventory Module

**User Story:** As a shop owner, I want to manage inventory stock levels and storage locations, so that I can track product quantities across my branch.

#### Acceptance Criteria

1. THE Shop_Service SHALL expose full CRUD for inventory locations scoped to a branch: `GET /api/v1/inventory/branches/{branch_id}/locations`, `GET /api/v1/inventory/locations/{location_id}`, `POST /api/v1/inventory/locations`, `PATCH /api/v1/inventory/locations/{location_id}`, `DELETE /api/v1/inventory/locations/{location_id}`.
2. THE Shop_Service SHALL expose full CRUD for inventory stock: `GET /api/v1/inventory/stock/` (with `branch_id` and optional `location_id` query params), `GET /api/v1/inventory/stock/{stock_id}`, `POST /api/v1/inventory/stock/`, `PUT /api/v1/inventory/stock/{stock_id}`, `DELETE /api/v1/inventory/stock/{stock_id}`.
3. THE Shop_Service SHALL expose `POST /api/v1/inventory/adjust` for single stock adjustments, accepting `stock_item_id`, `adjustment_type` (received/sold/damaged/returned/adjustment), `quantity_change`, `reason`, and optional `reference_id`, `reference_type`, `metadata_json`.
4. THE Shop_Service SHALL expose `POST /api/v1/inventory/bulk-adjust` for bulk stock adjustments.
5. THE Shop_Service SHALL expose full CRUD for purchase orders: `GET /api/v1/purchase-orders/branches/{branch_id}`, `GET /api/v1/purchase-orders/{po_id}`, `POST /api/v1/purchase-orders`, `PATCH /api/v1/purchase-orders/{po_id}`, `DELETE /api/v1/purchase-orders/{po_id}`.
6. THE Shop_Service SHALL expose purchase order lifecycle transitions: `POST /api/v1/purchase-orders/{po_id}/submit` (DRAFT→PENDING), `POST /api/v1/purchase-orders/{po_id}/confirm` (PENDING→CONFIRMED), `POST /api/v1/purchase-orders/{po_id}/receive` (CONFIRMED→RECEIVED/PARTIALLY_RECEIVED), `POST /api/v1/purchase-orders/{po_id}/cancel`, `POST /api/v1/purchase-orders/{po_id}/close`.

---

### Requirement 12: Marketplace Module

**User Story:** As a shop owner, I want to submit my products and categories to the marketplace and manage my marketplace orders, so that I can sell to customers beyond my direct branch.

#### Acceptance Criteria

1. THE Shop_Service SHALL expose `POST /api/v1/marketplace/submissions/categories/{category_id}/submit` and `POST /api/v1/marketplace/submissions/products/{product_id}/submit` for marketplace submission.
2. THE Shop_Service SHALL expose `GET /api/v1/marketplace/status` to check the shop's marketplace activation status.
3. THE Shop_Service SHALL expose `POST /api/v1/marketplace/generate-api-key`, `POST /api/v1/marketplace/activate`, and `POST /api/v1/marketplace/deactivate` for marketplace lifecycle management.
4. THE Shop_Service SHALL expose `GET /api/v1/mp-orders` (with filters: `status`, `fulfillment_status`, `search`, `from_date`, `to_date`, `page`, `page_size`) for listing marketplace orders.
5. THE Shop_Service SHALL expose `GET /api/v1/mp-orders/stats` for order statistics.
6. THE Shop_Service SHALL expose `GET /api/v1/mp-orders/{sub_order_id}` and `GET /api/v1/mp-orders/number/{sub_order_number}` for order detail retrieval.
7. THE Shop_Service SHALL expose `PATCH /api/v1/mp-orders/{sub_order_id}/fulfillment` for updating fulfillment status with valid transitions: pending→processing, processing→shipped (requires tracking info), processing→cancelled, shipped→delivered.
8. THE Shop_Service SHALL expose `POST /api/v1/mp-orders/{sub_order_id}/cancel` for order cancellation (only when status is `processing`).
9. THE Shop_Service SHALL expose `GET /api/v1/mp-invoices` (with filters), `GET /api/v1/mp-invoices/{invoice_id}`, and `GET /api/v1/mp-invoices/sub-order/{sub_order_id}` for invoice management.
10. THE Shop_Service SHALL expose admin approval endpoints: `POST /api/v1/admin/mp-approvals/categories/{category_id}/approve`, `POST /api/v1/admin/mp-approvals/categories/{category_id}/reject`, `POST /api/v1/admin/mp-approvals/products/{product_id}/approve`, `POST /api/v1/admin/mp-approvals/products/{product_id}/reject`, `GET /api/v1/admin/mp-approvals/products/{product_id}`, and `POST /api/v1/admin/mp-approvals/products/bulk-approve`.


---

### Requirement 13: Shelter Module

**User Story:** As a shelter staff member, I want to manage animals, kennels, adoptions, volunteers, and donations, so that I can operate the shelter efficiently.

#### Acceptance Criteria

1. THE Shelter_Service SHALL expose full CRUD for shelters: `GET /api/v1/shelters`, `POST /api/v1/shelters`, `GET /api/v1/shelters/{id}`, `PUT /api/v1/shelters/{id}`, `DELETE /api/v1/shelters/{id}`, plus `GET /api/v1/shelters/public/list` (no auth required).
2. THE Shelter_Service SHALL expose full CRUD for animals: `GET /api/v1/animals` (with filters: `shelter_code`, `species`, `status`, `intake_type`, `shelter_status`, `is_adopted`, `sort_by`, `order`, `search`, `page`, `page_size`), `POST /api/v1/animals`, `GET /api/v1/animals/{id}`, `PUT /api/v1/animals/{id}`, `DELETE /api/v1/animals/{id}`, `GET /api/v1/animals/{id}/health`.
3. WHEN creating or updating an animal, THE System SHALL send a `multipart/form-data` request. THE System SHALL append both `images` and `image` fields for backend compatibility.
4. THE Shelter_Service SHALL expose full CRUD for kennels: `GET /api/v1/kennels`, `POST /api/v1/kennels`, `GET /api/v1/kennels/{id}`, `PUT /api/v1/kennels/{id}`, `DELETE /api/v1/kennels/{id}`, `GET /api/v1/kennels/capacity/summary`.
5. THE Shelter_Service SHALL expose kennel assignment and cleaning log endpoints for tracking animal housing history.
6. THE Shelter_Service SHALL expose adoption application endpoints: `GET /api/v1/adoptions/applications`, `POST /api/v1/adoptions/applications`, `GET /api/v1/adoptions/applications/{id}`, `PATCH /api/v1/adoptions/applications/{id}/status`.
7. THE Shelter_Service SHALL expose adoption event endpoints: `GET /api/v1/adoptions/events`, `POST /api/v1/adoptions/events`, `GET /api/v1/adoptions/events/{id}`, `PATCH /api/v1/adoptions/events/{id}/outcome`. Event types SHALL be: `meet_greet`, `home_check`, `follow_up`. Outcome values SHALL be: `successful`, `reschedule`, `unsuitable`.
8. THE Shelter_Service SHALL expose volunteer endpoints: `POST /api/v1/volunteers/apply`, `GET /api/v1/volunteers`, `PUT /api/v1/volunteers/{id}/approve`, `PUT /api/v1/volunteers/{id}/reject`, `POST /api/v1/volunteers/shifts`, `GET /api/v1/volunteers/me/shifts`, `POST /api/v1/volunteers/shifts/{id}/sign-in`, `POST /api/v1/volunteers/shifts/{id}/sign-out`.
9. THE Shelter_Service SHALL expose donation endpoints: `GET /api/v1/donations`, `POST /api/v1/donations`, `PUT /api/v1/donations/{id}/confirm`, `POST /api/v1/donations/{id}/send-receipt`.
10. THE Shelter_Service SHALL expose lost-and-found endpoints for both staff and public users, including: CRUD for lost reports (`/api/v1/lost-found/lost`), CRUD for found reports (`/api/v1/lost-found/found`), linking (`POST /api/v1/lost-found/lost/{lost_id}/link/{found_id}`), reuniting (`POST /api/v1/lost-found/lost/{lost_id}/reunite`), transfer to intake (`POST /api/v1/lost-found/found/{found_id}/transfer-to-intake`), and matching (`GET /api/v1/lost-found/matches/lost/{lost_id}`, `GET /api/v1/lost-found/matches/found/{found_id}`).
11. THE Shelter_Service SHALL expose public lost/found report creation at `POST /api/v1/lost-found/public/lost` and `POST /api/v1/lost-found/public/found`, which SHALL work with or without authentication.
12. THE Shelter_Service SHALL expose `GET /api/v1/dashboard/overview` and `GET /api/v1/financials/dashboard` for shelter dashboard data.
13. THE Shelter_Service SHALL expose adoption/foster request management at `/api/v1/requests` with CRUD and status update operations.

---

### Requirement 14: PetCare Module (Pets, Providers, Bookings)

**User Story:** As a pet owner or service provider, I want to manage pets, discover and book pet care services, and communicate with providers, so that I can access quality care for my animals.

#### Acceptance Criteria

1. THE PetCare_Service SHALL expose full CRUD for pets: `POST /api/v1/pets`, `GET /api/v1/pets`, `GET /api/v1/pets/{pet_id}`, `PUT /api/v1/pets/{pet_id}`, `DELETE /api/v1/pets/{pet_id}`. All endpoints require Bearer token authentication.
2. THE PetCare_Service SHALL expose provider profile endpoints: `POST /api/v1/provider-profiles/apply` (FormData for ID uploads), `GET /api/v1/provider-profiles/me`, `PUT /api/v1/provider-profiles/me`.
3. THE PetCare_Service SHALL expose service listing endpoints: `POST /api/v1/provider/services`, `GET /api/v1/provider/services`, `GET /api/v1/provider/services/{listing_id}`, `PUT /api/v1/provider/services/{listing_id}`, `DELETE /api/v1/provider/services/{listing_id}`.
4. THE PetCare_Service SHALL expose availability blocking: `POST /api/v1/provider/services/{listing_id}/availability/block` and `POST /api/v1/provider/services/{listing_id}/availability/recurring`.
5. THE PetCare_Service SHALL expose `GET /api/v1/search/providers` (no auth required) for public provider search.
6. THE PetCare_Service SHALL expose booking endpoints: `POST /api/v1/bookings/request`, `GET /api/v1/bookings/my` (with `filter` enum: created/pending/rejected/confirmed/completed), `GET /api/v1/provider/bookings` (with `filter` enum: pending/confirmed/rejected/completed), `GET /api/v1/bookings/{booking_id}`, `PUT /api/v1/bookings/{booking_id}/accept`, `PUT /api/v1/bookings/{booking_id}/decline`, `PUT /api/v1/bookings/{booking_id}/complete`.
6. THE PetCare_Service SHALL expose `POST /api/v1/payments/create-payment-intent` for Stripe payment intent creation, accepting `booking_id`, `amount`, `payment_method`, and `save_payment_method`.
7. THE PetCare_Service SHALL expose review endpoints: `POST /api/v1/bookings/{booking_id}/reviews`, `GET /api/v1/bookings/{booking_id}/reviews`, `POST /api/v1/reviews/{review_id}/response`, `POST /api/v1/reviews/{review_id}/report`.
8. THE PetCare_Service SHALL expose `GET /api/v1/provider/overview/dashboard` for provider dashboard data.
9. THE PetCare_Service SHALL expose admin provider profile management at `/api/v1/admin/provider-profiles` with list, detail, background check, review, and audit log endpoints.


---

### Requirement 15: Real-Time Chat (WebSocket)

**User Story:** As a pet owner or provider, I want to send and receive messages in real time, so that I can communicate about bookings and services without page refreshes.

#### Acceptance Criteria

1. THE System SHALL establish a WebSocket connection to `{PETCARE_WS_BASE_URL}/api/v1/ws/chats/{thread_id}?token={encoded_access_token}` for each active chat thread.
2. THE System SHALL derive the WebSocket base URL from `PETCARE_WS_BASE_URL`, normalizing `https://` to `wss://` and `http://` to `ws://`.
3. WHEN the WebSocket connection opens, THE System SHALL wait for a `connection.ready` event before considering the connection active.
4. THE System SHALL handle four WebSocket event types: `connection.ready`, `ack`, `message.new`, and `error`.
5. WHEN the WebSocket connection closes unexpectedly, THE System SHALL attempt reconnection with exponential backoff starting at 1 second, doubling each attempt, capped at 10 seconds, for a maximum of 8 attempts.
6. IF the WebSocket closes with codes 1008, 4001, 4003, 4401, or 4403, THEN THE System SHALL NOT attempt reconnection and SHALL display an authorization error.
7. WHEN sending a message, THE System SHALL send a JSON payload `{ type: "message.send", payload: { body: string } }` over the WebSocket.
8. THE System SHALL enforce a maximum message length of 2000 characters and reject empty messages before sending.
9. THE PetCare_Service SHALL expose REST endpoints for chat history: `POST /api/v1/chats/direct/{peer_user_id}` (create or get thread), `GET /api/v1/chats/my` (list threads), `GET /api/v1/chats/{thread_id}/messages` (message history), `GET /api/v1/chats/unread-count`, `GET /api/v1/chats/{thread_id}/unread-count`, `POST /api/v1/chats/{thread_id}/read` (mark as read).
10. THE System SHALL use a single WebSocket connection per thread and prevent duplicate connections by checking the existing socket's `readyState` before creating a new one.

---

### Requirement 16: Localization (i18n)

**User Story:** As a user, I want to use the application in English or Arabic, so that I can interact with the platform in my preferred language.

#### Acceptance Criteria

1. THE System SHALL support two locales: `en` (English, LTR) and `ar` (Arabic, RTL). The default locale SHALL be `en`.
2. THE System SHALL load translation messages from `src/messages/{locale}.json` as the base, merged with `src/messages/{locale}/landingpage.json` and `src/messages/{locale}/petcare.json` as namespaced sub-messages.
3. WHEN the locale is `ar`, THE HTML `dir` attribute SHALL be set to `rtl`. WHEN the locale is `en`, THE HTML `dir` attribute SHALL be set to `ltr`.
4. THE System SHALL use next-intl's `createMiddleware` to automatically redirect users to their preferred locale based on the URL path.
5. WHEN any API request is dispatched, THE Locale_Interceptor SHALL inject the active locale as the `Accept-Language` header, enabling the backend to return locale-appropriate content.
6. THE System SHALL use `next-intl/server` functions (`getTranslations`, `getMessages`) in server components and `useTranslations` in client components.
7. THE System SHALL set the timezone to `UTC` for all server-side date formatting.
8. WHEN a locale is not found in the URL or is invalid, THE System SHALL fall back to the `defaultLocale` (`en`).

---

### Requirement 17: Error Handling and Loading States

**User Story:** As a user, I want clear feedback when operations succeed, fail, or are loading, so that I always know the current state of the application.

#### Acceptance Criteria

1. THE System SHALL expose `isLoading`, `isPending`, `isError`, and `error` states from every `useQuery` and `useMutation` hook for components to render appropriate UI.
2. WHEN an API error has `error.networkError === true`, THE System SHALL display a "server unavailable" message using the `errors.serverUnavailable` translation key.
3. WHEN an API error has `error.sessionExpired === true`, THE System SHALL display a "session expired" message using the `errors.sessionExpired` translation key.
4. WHEN an API error has `error.validationErrors === true`, THE System SHALL display the field-level validation messages from `error.errors`.
5. WHEN an API error has `error.forbidden === true`, THE System SHALL display a permission denied message.
6. WHEN an API error has `error.cancelled === true`, THE System SHALL silently ignore the error (no user-facing message).
7. THE System SHALL use `keepPreviousData: true` on paginated list queries so the previous page's data remains visible while the next page loads.
8. WHEN a mutation is in progress (`isPending`), THE System SHALL disable the submit button or show a loading indicator to prevent duplicate submissions.


---

### Requirement 18: Data Flow Architecture

**User Story:** As a developer, I want a documented end-to-end data flow, so that I can replicate the same pattern in a Flutter mobile application.

#### Acceptance Criteria

1. THE System SHALL follow a strict four-layer data flow: UI Component → Custom Hook → Service Function → Axios Client → Backend API.
2. THE UI_Component SHALL only call custom hooks and SHALL NOT call service functions or Axios clients directly.
3. THE Custom_Hook SHALL use `useSession()` to obtain the `accessToken` and pass it to the service function.
4. THE Service_Function SHALL construct the full request (URL, headers, body) and call the appropriate Axios client.
5. THE Axios_Client SHALL apply the interceptor chain (locale → logger → error → auth) before delivering the response to the service function.
6. THE Service_Function SHALL return the unwrapped response payload (already unwrapped by the error interceptor) to the hook.
7. THE Custom_Hook SHALL expose `{ data, isLoading, isError, error }` for queries and `{ mutate, isPending, isError, error }` for mutations to the UI component.
8. WHEN a mutation succeeds, THE Custom_Hook SHALL call `queryClient.invalidateQueries` to mark related cached data as stale.
9. THE System SHALL use `session?.accessToken` (top-level) OR `session?.user?.accessToken` (nested) interchangeably, as both are set in the NextAuth session callback.

---

### Requirement 19: Folder Structure and Code Organization

**User Story:** As a developer, I want a predictable folder structure, so that I can locate any piece of functionality quickly and understand the system's boundaries.

#### Acceptance Criteria

1. THE System SHALL organize source code under `src/` with the following top-level directories: `api/` (clients, interceptors, services, types), `app/` (Next.js App Router pages and layouts), `components/` (React components), `config/` (environment-based configuration), `constants/` (static values), `context/` (React Context providers), `hooks/` (domain-specific React Query hooks), `i18n/` (locale routing and message loading), `lib/` (shared utilities, generic query hooks, axios wrappers), `messages/` (translation JSON files), `store/` (Zustand stores).
2. THE `src/api/clients/` directory SHALL contain one file per Axios client instance plus an `index.js` barrel export.
3. THE `src/api/interceptors/` directory SHALL contain one file per interceptor factory plus an `index.js` barrel export.
4. THE `src/api/services/` directory SHALL contain one file per domain service, with admin services in a nested `admin/` subdirectory.
5. THE `src/hooks/` directory SHALL contain one subdirectory per domain (e.g., `shop/`, `category/`, `product/`, `supplier/`, `marketplace/`, `shelter/`, `petCare/`, `admin/`, `auth/`, `tenant/`, `user/`, `business/`).
6. THE `src/lib/query/hooks/` directory SHALL contain the four generic CRUD hook factories (`useList`, `useCreate`, `useUpdate`, `useDelete`) plus a `keys.js` query key factory and `config.js` QueryClient configuration.
7. THE `src/app/[locale]/` directory SHALL use Next.js route groups `(admin)`, `(auth)`, and the default group to separate layout concerns.
8. THE `src/messages/` directory SHALL contain `en.json` and `ar.json` base translation files, plus `en/landingpage.json`, `ar/landingpage.json`, `en/petcare.json`, and `ar/petcare.json` namespace files.

---

### Requirement 20: Flutter Mobile Architecture Transformation

**User Story:** As a mobile developer, I want architecture transformation guidance, so that I can replicate the same system design patterns in a Flutter application.

#### Acceptance Criteria

1. THE Flutter_App SHALL replace Axios clients with a `Dio` HTTP client library, creating one `Dio` instance per microservice with equivalent base URL, timeout, and default header configuration.
2. THE Flutter_App SHALL implement Dio interceptors equivalent to: `LocaleInterceptor` (inject `Accept-Language` from device locale), `LoggerInterceptor` (debug logging), `ErrorInterceptor` (normalize error responses), `AuthInterceptor` (401 handling with token refresh and retry).
3. THE Flutter_App SHALL replace NextAuth.js with `flutter_secure_storage` for storing `access_token` and `refresh_token`, and `shared_preferences` for non-sensitive session data.
4. THE Flutter_App SHALL implement a `TokenRefreshInterceptor` that calls the refresh endpoint when a 401 is received, using a lock/mutex pattern to prevent concurrent refresh races (equivalent to the single `_refreshPromise` pattern).
5. THE Flutter_App SHALL replace TanStack React Query with `flutter_query` or a Repository + Provider/Riverpod/BLoC pattern that provides equivalent caching (`staleTime`), background refetch, and cache invalidation on mutation.
6. THE Flutter_App SHALL replace Zustand with `Riverpod` StateNotifier or `Provider` ChangeNotifier for client-side state (role selection, section navigation).
7. THE Flutter_App SHALL replace next-intl with the `flutter_localizations` package and `intl` package, supporting `en` and `ar` locales with RTL layout switching.
8. THE Flutter_App SHALL replace Next.js route groups and server-side layout guards with `GoRouter` route guards that check authentication state and user roles before allowing navigation.
9. THE Flutter_App SHALL replace the WebSocket hook (`useChatSocket`) with a `WebSocketChannel` (from `web_socket_channel` package) wrapped in a service class with equivalent reconnection logic (exponential backoff, max 8 attempts, auth error detection).
10. THE Flutter_App SHALL replace `multipart/form-data` FormData with `dio.FormData` and `MultipartFile.fromFile()` for file upload endpoints.
11. THE Flutter_App SHALL implement a `ServiceLocator` (using `get_it`) to register and resolve the five HTTP client instances, equivalent to the `getClient(ClientType)` factory.
12. THE Flutter_App SHALL scope all data operations to `branch_id`, `shelter_id`, or `tenant_id` parameters, matching the multi-tenancy scoping of the web application.


---

## Architecture Diagrams

### Diagram 1: Microservice Topology

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Next.js Frontend                             │
│                     (Browser / SSR / SSG)                           │
│                                                                     │
│  ┌──────────┐  ┌──────────┐  ┌─────────────┐  ┌────────────────┐  │
│  │authClient│  │shopClient│  │shelterClient│  │petCareClient   │  │
│  │ /api/main│  │ /api/shop│  │/api/shelter │  │ /api/petcare   │  │
│  └────┬─────┘  └────┬─────┘  └──────┬──────┘  └───────┬────────┘  │
│       │              │               │                  │           │
│  Next.js Rewrites (browser) / Direct IP (server)                   │
└───────┼──────────────┼───────────────┼──────────────────┼──────────┘
        │              │               │                  │
        ▼              ▼               ▼                  ▼
  ┌──────────┐  ┌──────────┐  ┌─────────────┐  ┌────────────────┐
  │Auth API  │  │Shop API  │  │Shelter API  │  │PetCare API     │
  │:8001     │  │:8012     │  │:8014        │  │:8015           │
  │          │  │          │  │             │  │                │
  │- auth    │  │- branches│  │- shelters   │  │- pets          │
  │- users   │  │- products│  │- animals    │  │- providers     │
  │- roles   │  │- categs  │  │- kennels    │  │- bookings      │
  │- perms   │  │- suppls  │  │- adoptions  │  │- payments      │
  │- tenants │  │- invntry │  │- volunteers │  │- reviews       │
  │- modules │  │- mktplace│  │- donations  │  │- chats (HTTP)  │
  └──────────┘  │- orders  │  │- lost-found │  │- ws chats      │
                │- invoices│  │- med records│  └────────────────┘
                └──────────┘  └─────────────┘
```

### Diagram 2: Interceptor Chain (per client)

```
REQUEST PIPELINE:
  Component calls hook
       │
       ▼
  Service function builds request
       │
       ▼
  Axios client.request()
       │
       ▼  [Request Interceptors — applied in reverse registration order]
  ① Locale Interceptor (request)
    → Reads locale from URL path or NEXT_LOCALE cookie
    → Injects Accept-Language: en|ar header
       │
       ▼
  ② Logger Interceptor (request)
    → Attaches requestId and startTime to config.metadata
       │
       ▼
  ──── NETWORK ────
       │
       ▼  [Response Interceptors — applied in registration order]
  ③ Logger Interceptor (response)
    → Logs duration in development
       │
       ▼
  ④ Error Interceptor (response)
    → SUCCESS: unwraps response.data → returns payload
    → ERROR: normalizes to { status, message, errors, ...flags }
       │
       ▼
  ⑤ Auth Interceptor (response)
    → SUCCESS: passes through
    → 401: fetches /api/auth/session → retries with new token
    → 401 after retry: calls signOut() → redirects to /login
```

### Diagram 3: Data Flow (UI → Backend)

```
┌─────────────────────────────────────────────────────────────────┐
│  UI Component (e.g., ProductList)                               │
│  const { data, isLoading } = useProducts(branchId)             │
└──────────────────────────┬──────────────────────────────────────┘
                           │ calls
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Custom Hook (useProducts)                                      │
│  - useSession() → accessToken                                   │
│  - useQuery({ queryKey: ["products", branchId, ...] })         │
│  - queryFn: () => getProducts(branchId, search, accessToken)   │
└──────────────────────────┬──────────────────────────────────────┘
                           │ calls
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Service Function (getProducts in products.js)                  │
│  - Builds URL: /api/v1/products/{branchId}?page=1&page_size=20 │
│  - Sets headers: { Authorization: "Bearer {accessToken}" }     │
│  - Calls: shopClient.get(url, { headers })                     │
└──────────────────────────┬──────────────────────────────────────┘
                           │ calls
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Axios Client (shopClient)                                      │
│  - Applies interceptor chain                                    │
│  - Sends HTTP GET to Shop API :8012                            │
│  - Returns unwrapped response.data                             │
└──────────────────────────┬──────────────────────────────────────┘
                           │ returns
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  React Query Cache                                              │
│  - Stores result under key ["products", branchId, ...]         │
│  - staleTime: 5 min, gcTime: 10 min                            │
│  - Serves cached data on subsequent renders                    │
└─────────────────────────────────────────────────────────────────┘
```

### Diagram 4: Authentication & Session Flow

```
User submits login form
        │
        ▼
NextAuth CredentialsProvider.authorize()
        │
        ├─ POST {API_BASE_URL}/api/v1/auth/login
        │
        ▼
Backend returns:
  { success, data: { access_token, refresh_token, expires_in, user } }
        │
        ▼
NextAuth jwt() callback stores in encrypted cookie:
  { accessToken, refreshToken, expiresIn, accessTokenExpires,
    id, email, full_name, is_superuser, roles, default_tenant_id }
        │
        ▼
NextAuth session() callback exposes to client:
  session.user = { id, accessToken, is_superuser, roles,
                   default_tenant_id, full_name, email }
  session.accessToken = accessToken
        │
        ▼
Client hooks call useSession() → session.accessToken
        │
        ▼
Token nearing expiry (within 10 min)?
  YES → jwt() callback calls POST /api/v1/auth/refresh
      → Updates token in cookie
  NO  → Use existing token
        │
        ▼
API call returns 401?
  → Auth Interceptor fetches /api/auth/session (fresh)
  → Retries request with new token
  → Still 401? → signOut() → redirect /login
```

### Diagram 5: Route Structure

```
src/app/
├── [locale]/                    ← Locale prefix (en|ar)
│   ├── layout.js                ← Root layout: Providers (NextIntl + Session + Query)
│   ├── page.js                  ← Landing page
│   │
│   ├── (auth)/                  ← Auth route group (no auth required)
│   │   ├── login/
│   │   ├── signup/
│   │   ├── register/
│   │   │   └── shopOwner/
│   │   ├── forgot-password/
│   │   ├── reset-password/
│   │   └── pending-approval/
│   │
│   ├── (admin)/                 ← Admin route group (superuser only)
│   │   ├── layout.js            ← Guard: getServerSession → is_superuser check
│   │   └── admin-panel/
│   │       ├── layout.js
│   │       ├── page.js          ← Admin dashboard
│   │       ├── addAnimal/
│   │       ├── analyticsDashboard/
│   │       ├── createRole/
│   │       ├── data-management/
│   │       ├── marketplace-approvals/
│   │       ├── provider-verification/
│   │       ├── registerOwner/
│   │       ├── user/
│   │       └── userAnimalManagement/
│   │
│   ├── dashboard/               ← Authenticated user dashboard
│   ├── profile/
│   ├── marketplace/
│   ├── adopt/
│   ├── donate/
│   ├── lost-found/
│   └── provider/
│
└── api/
    ├── auth/[...nextauth]/      ← NextAuth handler (GET + POST)
    └── admin.js
```

### Diagram 6: Module-to-Client Mapping

```
┌─────────────────────────────────────────────────────────────────┐
│  authClient (Auth Service :8001)                                │
│  ─────────────────────────────────────────────────────────────  │
│  auth.js        → /api/v1/auth/*                               │
│  users.js       → /api/v1/users/*                              │
│  tenants.js     → /api/v1/tenants/*                            │
│  (via useList)  → /api/v1/roles, /api/v1/permissions,         │
│                   /api/v1/modules, /api/v1/admin/dashboard/*   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  shopClient (Shop Service :8012)                                │
│  ─────────────────────────────────────────────────────────────  │
│  shops.js           → /api/v1/branches/*                       │
│  business.js        → /api/v1/businesses/*                     │
│  categories.js      → /api/v1/products/categories/*            │
│  products.js        → /api/v1/products/*                       │
│  productVariants.js → /api/v1/product-variants/*               │
│  suppliers.js       → /api/v1/{branch_id}/suppliers/*          │
│  inventoryStock.js  → /api/v1/inventory/stock/*                │
│  inventoryLocations → /api/v1/inventory/branches/*/locations   │
│  purchaseOrders.js  → /api/v1/purchase-orders/*                │
│  marketplace.js     → /api/v1/marketplace/*                    │
│  mpOrders.js        → /api/v1/mp-orders/*                      │
│  mpInvoices.js      → /api/v1/mp-invoices/*                    │
│  admin/mpApprovals  → /api/v1/admin/mp-approvals/*             │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  shelterClient (Shelter Service :8014)                          │
│  ─────────────────────────────────────────────────────────────  │
│  shelters.js        → /api/v1/shelters/*                       │
│  animals.js         → /api/v1/animals/*                        │
│  kennels.js         → /api/v1/kennels/*                        │
│  kennelAssignments  → /api/v1/kennel-assignments/*             │
│  cleaningLogs.js    → /api/v1/cleaning-logs/*                  │
│  adoptions.js       → /api/v1/adoptions/*                      │
│  requests.js        → /api/v1/requests/*                       │
│  lostFound.js       → /api/v1/lost-found/*                     │
│  volunteers.js      → /api/v1/volunteers/*                     │
│  donations.js       → /api/v1/donations/*                      │
│  medicalRecords.js  → /api/v1/medical-records/*                │
│  vaccinations.js    → /api/v1/vaccinations/*                   │
│  animalCare.js      → /api/v1/animal-care/*                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  petCareClient (PetCare Service :8015)                          │
│  ─────────────────────────────────────────────────────────────  │
│  pets.js            → /api/v1/pets/*                           │
│  providers.js       → /api/v1/provider-profiles/*              │
│                       /api/v1/provider/services/*              │
│                       /api/v1/search/providers                 │
│  bookings.js        → /api/v1/bookings/*                       │
│                       /api/v1/provider/bookings                │
│  payments.js        → /api/v1/payments/*                       │
│  reviews.js         → /api/v1/bookings/*/reviews               │
│                       /api/v1/reviews/*                        │
│  chats.js           → /api/v1/chats/* (REST)                   │
│  useChatSocket      → ws://*/api/v1/ws/chats/{thread_id}       │
│  admin/provProfiles → /api/v1/admin/provider-profiles/*        │
└─────────────────────────────────────────────────────────────────┘
```


---

## Extended Architecture Narrative

### 1. Authentication & Authorization — Deep Dive

#### 1.1 Login Flow

The login flow is entirely handled by **NextAuth.js** using the `CredentialsProvider`. When a user submits their email and password:

1. The browser calls NextAuth's internal `POST /api/auth/callback/credentials` endpoint.
2. NextAuth's `authorize()` function calls `POST {AUTH_SERVICE}/api/v1/auth/login` with the credentials.
3. On success, the backend returns `{ access_token, refresh_token, expires_in, user }`.
4. NextAuth's `jwt()` callback stores all fields in an encrypted, server-side JWT cookie (`next-auth.session-token`).
5. NextAuth's `session()` callback shapes the public session object exposed to client components via `useSession()`.

The client **never sees the raw JWT** — it only sees the session object. The `access_token` is stored inside the encrypted cookie and forwarded to API calls by the service layer.

#### 1.2 JWT Structure

```
Encrypted Cookie (next-auth.session-token)
└── accessToken          ← Bearer token for all API calls
└── refreshToken         ← Used to renew accessToken
└── expiresIn            ← Lifetime in seconds (default: 1800)
└── accessTokenExpires   ← Absolute expiry timestamp (ms)
└── id                   ← User UUID
└── email
└── full_name
└── is_superuser         ← Boolean: admin panel gate
└── roles                ← Array of role objects
└── default_tenant_id    ← Tenant scoping key
```

#### 1.3 Token Refresh — Two-Layer Strategy

There are **two independent refresh mechanisms** that work together:

**Layer 1 — Proactive (NextAuth jwt() callback):**
- Every time the session is read, the `jwt()` callback checks if `accessTokenExpires - now < 10 minutes`.
- If true, it calls `POST /api/v1/auth/refresh` with the `refreshToken` and updates the cookie silently.
- This prevents most 401s from ever reaching the client.

**Layer 2 — Reactive (Auth Interceptor):**
- If a 401 still reaches the client (e.g., token expired between the proactive check and the actual request), the `authInterceptor` catches it.
- It fetches a fresh session from `/api/auth/session`, extracts the new token, and retries the original request exactly once.
- If the retry also returns 401, it calls `signOut()` and redirects to `/login`.
- A single shared `_refreshPromise` per client instance prevents concurrent refresh races.

#### 1.4 RBAC Implementation

Roles are **not enforced client-side** in the traditional sense. The system uses a two-tier approach:

| Gate | Where | Mechanism |
|------|-------|-----------|
| Superuser (admin panel) | Server-side layout | `getServerSession()` → `is_superuser` check → redirect |
| Role-based UI | Client-side | `session.user.roles` array → conditional rendering |
| Permission-based API | Backend | Bearer token → backend validates permissions |

The `roleStore` (Zustand) tracks which role the user has **selected** when they hold multiple roles. This is a UI concern only — the backend enforces actual permissions via the Bearer token.

#### 1.5 Tenant & Approval Flow

- `default_tenant_id` is stored in the session and passed implicitly via the Bearer token (the backend reads it from the JWT claims).
- The frontend does **not** manually append `tenant_id` to most requests — the backend resolves it from the token.
- The `/pending-approval` page is shown when a user's account or tenant is awaiting admin activation. This is determined by the backend returning a specific status on login or profile fetch.

---

### 2. API Architecture — Deep Dive

#### 2.1 Client Selection Logic

```
getClient(ClientType) factory
├── AUTH    → authClient    (port 8001, no forced refresh)
├── SHOP    → shopClient    (port 8012, useForcedRefresh: true)
├── SHELTER → shelterClient (port 8014, useForcedRefresh: true)
├── PETCARE → petCareClient (port 8015, useForcedRefresh: true)
└── SERVER  → serverClient  (direct IP, no interceptors)
```

The `useForcedRefresh: true` flag on shop/shelter/petCare clients means: if no valid token is found after the initial session fetch, force a session update via `GET /api/auth/session?update=1` before retrying. This handles edge cases where the session cookie is valid but stale.

#### 2.2 Browser vs. Server Routing

```
Browser environment:
  authClient.baseURL    = /api/main    (proxied by Next.js rewrites)
  shopClient.baseURL    = /api/shop
  shelterClient.baseURL = /api/shelter
  petCareClient.baseURL = /api/petcare

Server environment (SSR/API routes):
  authClient.baseURL    = http://161.35.222.194:8001  (direct)
  shopClient.baseURL    = http://161.35.222.194:8012
  shelterClient.baseURL = http://161.35.222.194:8014
  petCareClient.baseURL = http://161.35.222.194:8015
```

This dual-URL strategy avoids CORS issues in the browser while allowing server components to call backends directly without going through the proxy.

#### 2.3 Error Normalization Contract

Every error returned by the `errorInterceptor` follows this shape:

```
{
  status: number,          // HTTP status code (0 for network errors)
  message: string,         // Human-readable or i18n key
  errors: object|null,     // Field-level errors (validation)
  badRequest: boolean,     // 400
  unauthorized: boolean,   // 401
  forbidden: boolean,      // 403
  notFound: boolean,       // 404
  conflict: boolean,       // 409
  validationErrors: boolean, // 422
  serverError: boolean,    // 500
  networkError: boolean,   // No response
  cancelled: boolean       // Request cancelled
}
```

Components check these boolean flags to render the appropriate error UI without parsing status codes directly.

---

### 3. State Management — Deep Dive

#### 3.1 React Query Configuration

```
QueryClient defaults:
├── staleTime: 120,000 ms (2 minutes)
├── gcTime: 600,000 ms (10 minutes)
├── retry: false (no automatic retries)
├── refetchOnWindowFocus: false
├── refetchOnMount: true
├── refetchOnReconnect: false
└── networkMode: 'always' (works offline with cached data)
```

The `networkMode: 'always'` setting is important — it means queries run even when the browser reports no network connection, relying on the error interceptor to handle actual failures.

#### 3.2 Query Key Hierarchy

Query keys are hierarchical arrays that enable targeted invalidation:

```
["products", branchId]                    ← all products for a branch
["products", branchId, search, page, ps]  ← specific filtered page
["categories", branchId]                  ← all categories for a branch
["users", "list", filters]                ← user list with filters
["animals", shelterId, filters]           ← animals for a shelter
```

When a product is created, the invalidation map triggers `["products", branchId]` invalidation, which refetches all active product queries for that branch.

#### 3.3 Generic Hook Factories

The four generic hooks (`useList`, `useCreate`, `useUpdate`, `useDelete`) accept a configuration object and return a fully-configured React Query hook. Domain-specific hooks are thin wrappers:

```
useProducts(branchId, filters)
  └── useList({
        resource: `/api/v1/products/${branchId}`,
        client: ClientType.SHOP,
        queryKey: queryKeys.products(branchId, ...filters),
        params: filters
      })
```

This pattern means adding a new domain requires only: a service file + a hook file that calls the generic factory. No boilerplate query/mutation logic.

---

### 4. Module Functional Breakdown

#### 4.1 Shop Module

| Sub-module | Key Operations | Scoping |
|------------|---------------|---------|
| Branches | CRUD | Tenant (via token) |
| Business | Read own, Update own | Tenant (via token) |
| Categories | CRUD, hierarchical tree | branch_id (path param) |
| Products | CRUD, multipart upload | branch_id (path param) |
| Product Variants | CRUD, bulk create | product_id |
| Suppliers | CRUD | branch_id (path param) |

**Category hierarchy:** Categories support unlimited nesting via `parent_id`. The `roots_only=true` query param fetches only top-level categories, which are then expanded lazily.

**Product upload pattern:** Products use a two-field multipart form: `product_data` (JSON string of all product fields) + `images` (one or more image files). This avoids JSON/multipart mixing issues.

#### 4.2 Inventory Module

| Sub-module | Key Operations | Notes |
|------------|---------------|-------|
| Locations | CRUD | Physical storage locations within a branch |
| Stock | CRUD | Links products to locations with quantity |
| Adjustments | Single + Bulk | Types: received/sold/damaged/returned/adjustment |
| Purchase Orders | CRUD + lifecycle | DRAFT → PENDING → CONFIRMED → RECEIVED → CLOSED |

**PO Lifecycle state machine:**
```
DRAFT ──submit──► PENDING ──confirm──► CONFIRMED ──receive──► RECEIVED
                                                          └──► PARTIALLY_RECEIVED
  └──cancel──► CANCELLED (from any state)
  └──close──► CLOSED (from RECEIVED)
```

#### 4.3 Marketplace Module

The marketplace is a separate sales channel from direct branch sales. The flow:

```
Shop Owner                Admin                  Marketplace
     │                      │                        │
     ├─ Submit category ──►  │                        │
     │                      ├─ Approve/Reject ──►     │
     ├─ Submit product ───►  │                        │
     │                      ├─ Approve/Reject ──►     │
     ├─ Activate shop ────────────────────────────►   │
     │                                               │
     ├─ Receive orders ◄──────────────────────────── │
     ├─ Update fulfillment ──────────────────────►   │
     └─ View invoices ◄──────────────────────────── │
```

**Fulfillment state machine:**
```
pending ──► processing ──► shipped ──► delivered
                └──► cancelled
```

#### 4.4 Shelter Module

| Sub-module | Key Operations | Public Access |
|------------|---------------|---------------|
| Shelters | CRUD | GET /public/list (no auth) |
| Animals | CRUD + health record | No |
| Kennels | CRUD + capacity summary | No |
| Kennel Assignments | Assign/unassign | No |
| Adoptions | Applications + events | No |
| Volunteers | Apply, approve, shifts | No |
| Donations | Record + confirm + receipt | No |
| Lost & Found | CRUD + match + link + reunite | POST /public/lost, /public/found |
| Medical Records | CRUD | No |
| Vaccinations | CRUD + schedules | No |

**Adoption event flow:**
```
Application submitted
    └──► meet_greet event ──► outcome: successful/reschedule/unsuitable
    └──► home_check event  ──► outcome: successful/reschedule/unsuitable
    └──► follow_up event   ──► outcome: successful/reschedule/unsuitable
    └──► Application status updated (approved/rejected)
```

#### 4.5 PetCare Module

| Sub-module | Key Operations | Notes |
|------------|---------------|-------|
| Pets | CRUD | Owner-scoped |
| Provider Profiles | Apply (FormData), read/update own | Requires admin verification |
| Service Listings | CRUD + availability blocking | Provider-scoped |
| Bookings | Request, accept/decline/complete | Dual view: owner + provider |
| Payments | Create Stripe payment intent | booking_id required |
| Reviews | Post, respond, report | Post-completion only |
| Chat (REST) | Thread CRUD, message history, unread count | |
| Chat (WebSocket) | Real-time messaging | Per-thread connection |

**Booking state machine:**
```
created ──► pending ──► confirmed ──► completed
                └──► rejected
```

---

### 5. Real-Time Chat — Deep Dive

#### 5.1 Connection Lifecycle

```
1. Fetch or create thread via POST /api/v1/chats/direct/{peer_user_id}
2. Encode access_token (URL-safe base64 or percent-encode)
3. Open WebSocket: wss://{host}/api/v1/ws/chats/{thread_id}?token={token}
4. Wait for { type: "connection.ready" } event
5. Connection is now active — begin sending/receiving messages
```

#### 5.2 Reconnection Strategy

```
Attempt 1: wait 1s
Attempt 2: wait 2s
Attempt 3: wait 4s
Attempt 4: wait 8s
Attempt 5: wait 10s (capped)
Attempt 6: wait 10s
Attempt 7: wait 10s
Attempt 8: wait 10s
→ Max 8 attempts, then give up and show error

Auth error codes (NO reconnect): 1008, 4001, 4003, 4401, 4403
```

#### 5.3 Message Protocol

```
Send:    { type: "message.send", payload: { body: string } }
Receive: { type: "message.new", payload: { id, body, sender_id, created_at } }
Ack:     { type: "ack", payload: { message_id } }
Error:   { type: "error", payload: { code, message } }
```

---

### 6. Localization — Deep Dive

#### 6.1 Message File Structure

```
src/messages/
├── en.json              ← Base English translations
├── ar.json              ← Base Arabic translations
├── en/
│   ├── landingpage.json ← Landing page namespace (en)
│   └── petcare.json     ← PetCare namespace (en)
└── ar/
    ├── landingpage.json ← Landing page namespace (ar)
    └── petcare.json     ← PetCare namespace (ar)
```

The `i18n/request.js` file merges base + namespace files at request time using `next-intl/server`.

#### 6.2 RTL Switching

The root layout reads the `locale` param and sets `<html lang={locale} dir={locale === 'ar' ? 'rtl' : 'ltr'}>`. All CSS layout uses logical properties (`margin-inline-start`, `padding-inline-end`) to automatically flip for RTL.

#### 6.3 API Localization

The `localeInterceptor` reads the locale from:
1. The first path segment of `window.location.pathname` (`/en/` or `/ar/`)
2. Fallback: `document.cookie` → `NEXT_LOCALE` cookie

It injects `Accept-Language: en` or `Accept-Language: ar` on every request. The backend uses this header to return locale-appropriate field values (e.g., `name_en` vs `name_ar` in category responses).

---

### 7. Folder Structure Reference

```
src/
├── api/
│   ├── clients/          ← One Axios instance per microservice
│   │   ├── authClient.js
│   │   ├── shopClient.js
│   │   ├── shelterClient.js
│   │   ├── petCareClient.js
│   │   ├── serverClient.js
│   │   └── index.js      ← getClient(ClientType) factory
│   ├── interceptors/     ← Composable interceptor factories
│   │   ├── authInterceptor.js
│   │   ├── errorInterceptor.js
│   │   ├── localeInterceptor.js
│   │   ├── loggerInterceptor.js
│   │   └── index.js      ← applyInterceptors(client, options)
│   ├── services/         ← One file per domain
│   │   ├── auth.js
│   │   ├── shops.js      ← branches
│   │   ├── business.js
│   │   ├── categories.js
│   │   ├── products.js
│   │   ├── productVariants.js
│   │   ├── suppliers.js
│   │   ├── inventoryStock.js
│   │   ├── inventoryLocations.js
│   │   ├── purchaseOrders.js
│   │   ├── marketplace.js
│   │   ├── mpOrders.js
│   │   ├── mpInvoices.js
│   │   ├── shelters.js
│   │   ├── animals.js
│   │   ├── kennels.js
│   │   ├── kennelAssignments.js
│   │   ├── cleaningLogs.js
│   │   ├── adoptions.js
│   │   ├── requests.js
│   │   ├── lostFound.js
│   │   ├── volunteers.js
│   │   ├── donations.js
│   │   ├── medicalRecords.js
│   │   ├── vaccinations.js
│   │   ├── vaccinationSchedules.js
│   │   ├── animalCare.js
│   │   ├── pets.js
│   │   ├── providers.js
│   │   ├── bookings.js
│   │   ├── payments.js
│   │   ├── reviews.js
│   │   ├── chats.js
│   │   ├── users.js
│   │   ├── tenants.js
│   │   ├── health.js
│   │   └── admin/
│   │       ├── marketplaceApprovals.js
│   │       └── providerProfiles.js
│   └── types/            ← JSDoc type definitions
├── app/
│   └── [locale]/
│       ├── layout.js     ← Root: NextIntlProvider + SessionProvider + QueryProvider
│       ├── page.js       ← Landing page
│       ├── (auth)/       ← Public auth pages
│       ├── (admin)/      ← Superuser-only pages (server-side guard)
│       └── */            ← Authenticated user pages
├── components/           ← React UI components
├── config/               ← Environment config (base URLs, feature flags)
├── constants/            ← Static enums and lookup tables
├── context/              ← React Context providers (SectionContext, etc.)
├── hooks/                ← Domain-specific React Query hooks
│   ├── shop/
│   ├── category/
│   ├── product/
│   ├── supplier/
│   ├── marketplace/
│   ├── shelter/
│   ├── petCare/
│   ├── admin/
│   ├── auth/
│   ├── tenant/
│   ├── user/
│   └── business/
├── i18n/                 ← next-intl routing config and message loader
├── lib/
│   └── query/
│       ├── config.js     ← createQueryClient()
│       ├── keys.js       ← queryKeys factory
│       └── hooks/
│           ├── useList.js
│           ├── useCreate.js
│           ├── useUpdate.js
│           └── useDelete.js
├── messages/             ← Translation JSON files
└── store/                ← Zustand stores (roleStore)
```

---

## Flutter Mobile Architecture Transformation Guide

### Technology Stack Mapping

| Web (Next.js) | Flutter Equivalent | Notes |
|---------------|-------------------|-------|
| Axios | `dio` package | One Dio instance per microservice |
| Axios interceptors | `dio` Interceptors | Same chain: Locale → Logger → Error → Auth |
| NextAuth.js | `flutter_secure_storage` + custom auth service | Store tokens securely |
| TanStack React Query | `flutter_query` or Riverpod + Repository pattern | Cache, stale time, invalidation |
| Zustand | `riverpod` StateNotifier or `provider` ChangeNotifier | Persist with `shared_preferences` |
| next-intl | `flutter_localizations` + `intl` package | ARB files instead of JSON |
| Next.js route groups + layouts | `go_router` with redirect guards | Shell routes for layout |
| WebSocket (native) | `web_socket_channel` package | Same reconnection logic |
| FormData (browser) | `dio.FormData` + `MultipartFile.fromFile()` | Same multipart pattern |
| `getClient()` factory | `get_it` ServiceLocator | Register 5 Dio instances |
| `localStorage` (Zustand persist) | `shared_preferences` | Non-sensitive UI state |
| Server-side session guard | GoRouter `redirect` callback | Check auth state before navigation |

---

### Flutter Architecture Blueprint

#### Layer 1: Network (Dio Clients)

Create five Dio instances registered in `get_it`:

```
ServiceLocator
├── authDio       → base: AUTH_BASE_URL, timeout: 80s
├── shopDio       → base: SHOP_BASE_URL, timeout: 80s
├── shelterDio    → base: SHELTER_BASE_URL, timeout: 80s
├── petCareDio    → base: PETCARE_BASE_URL, timeout: 80s
└── serverDio     → base: AUTH_BASE_URL (no auth interceptor)
```

Each Dio instance gets the same interceptor chain:
```
Request:  LocaleInterceptor → LoggerInterceptor
Response: LoggerInterceptor → ErrorInterceptor → AuthInterceptor
```

#### Layer 2: Interceptors

**LocaleInterceptor:** Read device locale from `Localizations.localeOf(context)` or a stored preference. Inject `Accept-Language` header.

**ErrorInterceptor:** Normalize DioException into the same error shape used on web:
```dart
class AppError {
  final int status;
  final String message;
  final Map<String, dynamic>? errors;
  final bool badRequest, unauthorized, forbidden, notFound,
             conflict, validationErrors, serverError,
             networkError, cancelled;
}
```

**AuthInterceptor:** On 401, call the token refresh endpoint, update stored tokens, retry the original request. Use a `Mutex` (from `synchronized` package) to prevent concurrent refresh races.

#### Layer 3: Token Storage

```dart
// Secure storage (flutter_secure_storage)
await storage.write(key: 'access_token', value: token);
await storage.write(key: 'refresh_token', value: refreshToken);

// Non-sensitive (shared_preferences)
await prefs.setString('user_id', userId);
await prefs.setString('full_name', fullName);
await prefs.setBool('is_superuser', isSuperuser);
await prefs.setString('default_tenant_id', tenantId);
```

#### Layer 4: Repository Pattern (replaces service files)

Each domain gets a Repository class:

```
AuthRepository       → authDio
ShopRepository       → shopDio (branches, business)
CategoryRepository   → shopDio
ProductRepository    → shopDio
SupplierRepository   → shopDio
InventoryRepository  → shopDio
MarketplaceRepository → shopDio
ShelterRepository    → shelterDio
AnimalRepository     → shelterDio
AdoptionRepository   → shelterDio
VolunteerRepository  → shelterDio
PetRepository        → petCareDio
ProviderRepository   → petCareDio
BookingRepository    → petCareDio
ChatRepository       → petCareDio (REST)
ChatSocketService    → WebSocketChannel (real-time)
```

#### Layer 5: State Management (replaces React Query + Zustand)

**Server state (replaces React Query):**
```
Riverpod AsyncNotifier per domain
├── Caching: store last fetched data + timestamp
├── Stale check: if (now - lastFetch) > staleTime → refetch
├── Invalidation: call ref.invalidate(provider) after mutations
└── Loading/error states: AsyncValue<T> (loading/data/error)
```

**Client state (replaces Zustand):**
```
RoleNotifier (StateNotifier)
├── selectedRole: Role?
├── selectedRoles: List<Role>
├── Persisted to shared_preferences
└── Methods: setRole, clearRole, getRoleId, getRoleName
```

#### Layer 6: Navigation (replaces Next.js route groups)

```
GoRouter configuration:
├── /login              → LoginScreen (no guard)
├── /signup             → SignupScreen (no guard)
├── /register           → RegisterScreen (no guard)
├── /pending-approval   → PendingApprovalScreen (no guard)
│
├── /dashboard          → DashboardScreen (guard: authenticated)
├── /profile            → ProfileScreen (guard: authenticated)
├── /marketplace        → MarketplaceScreen (guard: authenticated)
├── /adopt              → AdoptScreen (guard: authenticated)
├── /donate             → DonateScreen (guard: authenticated)
├── /lost-found         → LostFoundScreen (guard: authenticated)
├── /provider           → ProviderScreen (guard: authenticated)
│
└── /admin              → AdminShell (guard: authenticated + is_superuser)
    ├── /admin/dashboard
    ├── /admin/users
    ├── /admin/roles
    ├── /admin/marketplace-approvals
    ├── /admin/provider-verification
    └── /admin/animals

GoRouter redirect logic:
  if (!authenticated) → /login
  if (authenticated && route.requiresSuperuser && !isSuperuser) → /dashboard
  if (authenticated && onAuthRoute) → /dashboard
```

#### Layer 7: Localization

```
flutter_localizations setup:
├── Supported locales: [Locale('en'), Locale('ar')]
├── Default locale: Locale('en')
├── ARB files: lib/l10n/app_en.arb, lib/l10n/app_ar.arb
├── RTL: MaterialApp automatically handles dir based on locale
└── API: inject Accept-Language from LocaleNotifier state
```

#### Layer 8: File Uploads (replaces FormData)

```dart
// Category with image
final formData = FormData.fromMap({
  'name_en': nameEn,
  'name_ar': nameAr,
  'is_active': isActive,
  if (imageFile != null)
    'image': await MultipartFile.fromFile(imageFile.path),
});

// Product with multiple images
final formData = FormData.fromMap({
  'product_data': jsonEncode(productData),
  'images': [
    for (final file in imageFiles)
      await MultipartFile.fromFile(file.path),
  ],
});
```

---

### Key Reusable Patterns for Flutter

#### Pattern 1: Multi-Client with Shared Interceptors

Register all Dio instances in `get_it` at app startup. Each instance gets the same interceptor factories applied. The `AuthInterceptor` reads tokens from `flutter_secure_storage` rather than a session cookie.

#### Pattern 2: Normalized Error Handling

The `ErrorInterceptor` converts every `DioException` into an `AppError` with typed boolean flags. UI widgets check `error.networkError`, `error.validationErrors`, etc. — never raw status codes.

#### Pattern 3: Token Refresh with Mutex

Use the `synchronized` package's `Lock` to ensure only one refresh call runs at a time. Queue all other 401 requests until the refresh completes, then replay them with the new token.

#### Pattern 4: Branch/Tenant Scoping

Every repository method that operates on shop data accepts a `branchId` parameter. Every shelter method accepts a `shelterId`. These are passed as path or query parameters — never inferred from global state.

#### Pattern 5: Optimistic Cache Invalidation

After any mutation (create/update/delete), call `ref.invalidate(listProvider)` to mark the list as stale. The next time the list screen is visible, it will refetch automatically.

#### Pattern 6: WebSocket with Exponential Backoff

Wrap `WebSocketChannel` in a `ChatSocketService` class that:
- Maintains a reconnect attempt counter
- Implements `min(1 << attempt, 10)` second backoff
- Checks close codes before attempting reconnect
- Exposes a `Stream<ChatMessage>` for the UI to listen to

---

### Environment Configuration

| Variable | Default | Used By |
|----------|---------|---------|
| `NEXT_PUBLIC_API_BASE_URL` | `http://161.35.222.194:8001` | authClient |
| `NEXT_PUBLIC_SHOP_API_BASE_URL` | `http://161.35.222.194:8012` | shopClient |
| `NEXT_PUBLIC_SHELTER_API_BASE_URL` | `http://161.35.222.194:8014` | shelterClient |
| `NEXT_PUBLIC_PETCARE_API_BASE_URL` | `http://161.35.222.194:8015` | petCareClient |
| `PETCARE_WS_BASE_URL` | Derived from PETCARE URL | WebSocket |
| `NEXTAUTH_SECRET` | — | Session encryption |
| `NEXTAUTH_URL` | — | NextAuth callbacks |

In Flutter, these map to a `AppConfig` class loaded from `--dart-define` or a `.env` file via `flutter_dotenv`.

---

*Document generated from the Zoovana frontend codebase analysis. Last updated: April 2026.*
