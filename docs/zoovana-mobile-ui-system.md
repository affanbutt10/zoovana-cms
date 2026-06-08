# Zoovana Mobile UI System

Source note: no screenshot image files were present in the workspace. This spec maps the requested public website, donation flow, lost and found, profile, shop owner dashboard, and settings surfaces into the existing Flutter app conventions.

## 1. UI Domains

### Public / Customer

Screens:
- Home
- Services
- Adoption list
- Adoption details
- Donation flow
- Lost and found
- Profile

Primary UX:
- Bottom navigation: Home, Services, Adoption, Profile
- Scroll-first mobile layouts
- Public content remains readable without login where API policy allows
- Auth-gated actions redirect to login, then resume intent

### Functional Flows

Screens:
- Donation amount
- Donation details
- Donation confirmation
- Lost report form
- Found report form

Primary UX:
- Mobile stepper with compact progress labels
- Sticky bottom summary/action
- Form autosave draft for long reports
- Image upload cards for lost/found pets

### User

Screens:
- Profile overview
- Editable profile form
- My pets
- My adoption/donation/report activity

Primary UX:
- Profile header card
- Role badge
- List sections
- Inline loading and error states

### Shop Owner / Admin

Screens:
- Dashboard
- Orders
- Inventory
- Profile
- Settings

Primary UX:
- Segmented navigation or top tabs inside shop owner shell
- Replace all desktop tables with summary cards and list rows
- Metrics first, actions second, detail lists below

## 2. Design Tokens

### Colors

Use existing `AppColors`.

Core:
- Primary: `AppColors.primary` `#1A73E8`
- Primary dark: `AppColors.primaryDark` `#1558B0`
- Secondary: `AppColors.secondary` `#34A853`
- Accent: `AppColors.accent` `#FBBC04`
- Background: `AppColors.background` `#F8F9FA`
- Surface: `AppColors.surface` `#FFFFFF`
- Surface variant: `AppColors.surfaceVariant` `#F1F3F4`
- Text primary: `AppColors.textPrimary` `#202124`
- Text secondary: `AppColors.textSecondary` `#5F6368`
- Error: `AppColors.error` `#EA4335`

Usage:
- Customer primary actions: blue
- Positive adoption/availability states: green
- Warnings, pending approval, low stock: yellow
- Errors and destructive actions: red
- Cards: white on app background
- Dividers and outlines: `grey200` / `grey300`

### Typography

Use existing `AppTextStyles` with Inter.

Mobile mapping:
- Screen title: `headlineSmall`
- Section title: `titleLarge`
- Card title: `titleMedium`
- Body: `bodyMedium`
- Helper text: `bodySmall`
- Button: `button`
- Badge/chip label: `labelMedium`

Avoid display styles on mobile except a short home hero line.

### Spacing

8pt system:
- `xs`: 4
- `sm`: 8
- `md`: 16
- `lg`: 24
- `xl`: 32
- `xxl`: 40

Screen padding:
- Mobile horizontal: 16
- Dense admin screens: 12-16
- Card internal padding: 16
- Section gap: 24
- Form field gap: 16

### Shape / Elevation

- Card radius: 8
- Button radius: 8
- Chip radius: 20
- Input radius: 8
- Bottom sheet top radius: 20
- Prefer borders and tint over heavy shadows
- Elevation: 0-2 only

### Touch Targets

- Minimum interactive height: 48
- Icon button: 48 x 48
- Bottom nav item: platform default, with clear labels
- Chips: minimum 40 high, 48 preferred for amount chips

## 3. Role-Based Mobile Architecture

### Role Model

Roles:
- `customer`
- `shop_owner`
- `admin` / `superuser`

After login:
1. Restore session.
2. Resolve roles from `AuthSessionEntity.user.roles`.
3. If multiple roles, show role selection.
4. If selected role is `shop_owner`, run shop initialization.
5. Route to the correct shell.

### Shells

Customer shell:
- Bottom nav: Home, Services, Adoption, Profile
- Secondary actions available as cards/chips on screens
- Donation and Lost/Found are pushed as full-screen flows

Shop owner shell:
- Top segmented nav or drawer-lite menu for Dashboard, Orders, Inventory, Settings
- No customer bottom nav
- Dashboard opens first

### Route Guard

Existing `computeRedirect` already supports shop owner routing. Extend route constants and branch by selected role:

```dart
String roleHome(RoleEntity role) {
  switch (role.name.toLowerCase()) {
    case 'shop_owner':
      return AppRoutes.shopDashboard;
    case 'admin':
      return AppRoutes.admin;
    default:
      return AppRoutes.customerHome;
  }
}
```

## 4. Navigation Flow

### GoRouter Structure

```dart
GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: roleAwareRedirect,
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (_, __) => SplashScreen()),
    GoRoute(path: AppRoutes.login, builder: (_, __) => LoginScreen()),
    GoRoute(path: AppRoutes.roleSelect, builder: (_, __) => RoleSelectScreen()),

    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => CustomerShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: AppRoutes.customerHome, builder: (_, __) => HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: AppRoutes.services, builder: (_, __) => ServicesScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: AppRoutes.adoption, builder: (_, __) => AdoptionScreen()),
          GoRoute(path: AppRoutes.adoptionDetail, builder: (_, state) => AdoptionDetailScreen(id: state.pathParameters['id']!)),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: AppRoutes.profile, builder: (_, __) => ProfileScreen()),
        ]),
      ],
    ),

    GoRoute(path: AppRoutes.donate, builder: (_, __) => DonationFlowScreen()),
    GoRoute(path: AppRoutes.lostFound, builder: (_, __) => LostFoundScreen()),

    ShellRoute(
      builder: (_, __, child) => ShopOwnerShell(child: child),
      routes: [
        GoRoute(path: AppRoutes.shopDashboard, builder: (_, __) => ShopDashboardScreen()),
        GoRoute(path: AppRoutes.shopOrders, builder: (_, __) => ShopOrdersScreen()),
        GoRoute(path: AppRoutes.shopInventory, builder: (_, __) => ShopInventoryScreen()),
        GoRoute(path: AppRoutes.settings, builder: (_, __) => SettingsScreen()),
      ],
    ),
  ],
)
```

## 5. Component System

### Role-Aware App Bar

Purpose:
- Shows Zoovana title/logo on customer screens
- Shows business/branch context on shop owner screens
- Optional role badge
- Optional notification/action icon

Widget tree:

```dart
AppBar
 ├─ leading: BackButton | MenuButton | Logo
 ├─ title: Column(title, subtitle/branch)
 └─ actions: [RoleBadge, NotificationButton]
```

### Customer Bottom Navigation

Items:
- Home
- Services
- Adoption
- Profile

Widget tree:

```dart
Scaffold
 ├─ body: SafeArea(child: shell)
 └─ bottomNavigationBar: NavigationBar
    ├─ Home
    ├─ Services
    ├─ Adoption
    └─ Profile
```

### Cards

Types:
- `ZoovanaCard`: basic white card
- `ActionCard`: icon, title, subtitle, tap action
- `MetricCard`: label, value, delta, icon
- `PetCard`: image, pet name, metadata, status
- `OrderCard`: order id, customer, amount, status, date

Rules:
- Radius 8
- Padding 16
- Border `grey200`
- No nested cards

### Form Inputs

Use `AppTextField` as base.

Add:
- `AppDropdownField`
- `AppDateField`
- `AppImagePickerTile`
- `AppPhoneField`
- `AppCurrencyField`
- `AppMultiLineField`

Rules:
- Label above input
- Error below input
- 48px minimum height
- Validation appears after blur or submit

### Selection Chips

Use:
- Donation amounts
- Pet type filters
- Lost/found categories
- Order status filters

States:
- Default: white, grey border
- Selected: primary tint, primary border
- Disabled: grey100, disabled text

### Mobile Stepper

Widget tree:

```dart
Column
 ├─ StepProgressHeader(currentStep, totalSteps)
 ├─ Expanded(child: PageView or IndexedStack)
 └─ StickyBottomSummary
```

Rules:
- Never use desktop horizontal stepper
- Keep progress compact
- Preserve entered data between steps
- Back action does not clear form

### List Tiles

Use for settings, profile actions, dashboard recent items.

Widget tree:

```dart
InkWell
 └─ Row
    ├─ IconContainer
    ├─ Expanded(Column(title, subtitle))
    ├─ Badge?
    └─ ChevronRight
```

## 6. Customer Screens

### 6.1 Home Screen

Purpose:
- Public landing adapted to mobile
- Fast access to services, adoption, donation, lost/found

Widget tree:

```dart
Scaffold
 ├─ appBar: ZoovanaAppBar(role: customer)
 ├─ body: RefreshIndicator
 │  └─ CustomScrollView
 │     ├─ SliverToBoxAdapter: HomeHeroStack
 │     ├─ SliverToBoxAdapter: QuickActionsHorizontalList
 │     ├─ SliverToBoxAdapter: ServicesSectionHeader
 │     ├─ SliverGrid: ServiceGrid(2 columns)
 │     ├─ SliverToBoxAdapter: AdoptionSectionHeader
 │     ├─ SliverToBoxAdapter: AdoptionHorizontalCards
 │     └─ SliverToBoxAdapter: LostFoundDonationBand
 └─ bottomNavigationBar: CustomerBottomNav
```

Layout:
- Hero is stacked: background image/tint, title, CTA row
- Quick actions horizontal scroll: Donate, Lost Pet, Found Pet, Adopt
- Services grid: grooming, vet, boarding, training, shop
- Adoption cards horizontal with image, name, age, city, status

States:
- Loading: hero skeleton, grid skeleton cards
- Empty: "No pets available yet" action to refresh
- Error: inline retry card after hero

### 6.2 Services Screen

Widget tree:

```dart
Scaffold
 ├─ appBar: ZoovanaAppBar(title: Services)
 ├─ body: CustomScrollView
 │  ├─ SearchBar
 │  ├─ ServiceCategoryChips
 │  ├─ SliverGrid: ServiceCards
 │  └─ PopularProvidersList
 └─ bottomNavigationBar: CustomerBottomNav
```

Mobile rules:
- Search pinned at top when useful
- 2-column cards on phones, 3+ on tablets
- Provider details open as pushed route or modal bottom sheet

### 6.3 Adoption Screen

Widget tree:

```dart
Scaffold
 ├─ appBar: ZoovanaAppBar(title: Adoption)
 ├─ body: Column
 │  ├─ FilterChipsRow(type, age, gender, location)
 │  └─ Expanded
 │     └─ ListView.separated
 │        └─ PetAdoptionCard
 └─ bottomNavigationBar: CustomerBottomNav
```

Details widget tree:

```dart
Scaffold
 ├─ body: CustomScrollView
 │  ├─ SliverAppBar(expandedHeight: 280, flexibleSpace: PetImageCarousel)
 │  ├─ PetSummarySection
 │  ├─ TraitsWrap
 │  ├─ HealthInfoList
 │  ├─ ShelterInfoCard
 │  └─ SimilarPetsHorizontalList
 └─ bottomNavigationBar: StickyActionBar("Apply for Adoption")
```

States:
- Loading: list skeleton
- Empty: friendly empty state with filters reset
- Error: retry card with network message

### 6.4 Donation Flow

Step 1: Amount selection

```dart
DonationFlowScreen
 └─ StepScaffold
    ├─ StepProgressHeader(step: 1)
    ├─ Wrap: AmountChoiceChips(500, 1000, 2500, 5000)
    ├─ AppCurrencyField(custom amount)
    ├─ DonationCauseCards
    └─ StickyBottomSummary(amount, Continue)
```

Step 2: Details form

```dart
StepScaffold
 ├─ AppTextField(full name)
 ├─ AppTextField(email)
 ├─ AppPhoneField
 ├─ AppDropdownField(payment method)
 ├─ CheckboxListTile(anonymous donation)
 └─ StickyBottomSummary(amount, Continue)
```

Step 3: Confirmation

```dart
StepScaffold
 ├─ ConfirmationCard(amount, cause, donor, payment)
 ├─ InfoBanner
 ├─ TermsCheckbox
 └─ StickyBottomSummary(total, Confirm Donation)
```

Loading:
- Confirm button shows spinner
- Disable back only while payment is being submitted

Error:
- Payment failure bottom sheet with Retry and Change payment method
- Validation errors inline

### 6.5 Lost & Found

Main layout:

```dart
Scaffold
 ├─ appBar: ZoovanaAppBar(title: Lost & Found)
 ├─ body: Column
 │  ├─ SegmentedButton(Lost, Found)
 │  ├─ SearchBar
 │  ├─ FilterChipsRow
 │  └─ Expanded(ListView of ReportCards)
 └─ floatingActionButton: ReportPetFab
```

Report form:

```dart
LostFoundFormScreen
 └─ StepScaffold
    ├─ Step 1: Pet basics(type, breed, color, name)
    ├─ Step 2: Location/date(map preview, area, date)
    ├─ Step 3: Photos/description(contact consent)
    └─ StickyBottomSummary(Save Report)
```

Mobile UX:
- Lost/found tab persists selected mode
- Location field supports current location and manual entry
- Images appear as square upload tiles
- Form draft survives accidental back

## 7. Shop Owner Screens

### 7.1 Dashboard

Purpose:
- Replace desktop tables with mobile cards and lists

Widget tree:

```dart
Scaffold
 ├─ appBar: ZoovanaAppBar(role: shopOwner, branchSelector: true)
 ├─ body: RefreshIndicator
 │  └─ CustomScrollView
 │     ├─ SliverToBoxAdapter: DashboardHeader
 │     ├─ SliverGrid: MetricCards(revenue, orders, stock, lowStock)
 │     ├─ SliverToBoxAdapter: ChartPlaceholderCard
 │     ├─ SliverToBoxAdapter: QuickAdminActions
 │     ├─ SliverToBoxAdapter: RecentOrdersHeader
 │     └─ SliverList: RecentOrderCards
 └─ bottomNavigationBar: none
```

Metrics:
- Revenue
- Orders
- Stock
- Low stock

Recent order card:
- Order number
- Customer
- Items count
- Total
- Status badge
- Time

States:
- Loading: metric skeletons and list skeleton
- Empty orders: empty state with "Orders will appear here"
- Error: retry card at top of scroll

### 7.2 Shop Owner Profile

Widget tree:

```dart
Scaffold
 ├─ appBar: ZoovanaAppBar(title: Profile, role: shopOwner)
 └─ body: ListView
    ├─ ProfileHeaderCard(avatar, name, email, roleBadge)
    ├─ BusinessInfoCard
    ├─ EditableFieldList
    ├─ BranchSelectorCard
    └─ AccountActionsList
```

Fields:
- Full name
- Email
- Phone
- Business name
- Branch
- Role badge: Shop owner

### 7.3 Settings Screen

Widget tree:

```dart
Scaffold
 ├─ appBar: ZoovanaAppBar(title: Settings, role: shopOwner)
 └─ body: ListView
    ├─ SettingsSection("Business")
    ├─ SettingsTile(branches)
    ├─ SettingsTile(products)
    ├─ SettingsTile(inventory locations)
    ├─ SettingsSection("Operations")
    ├─ SettingsFeatureGrid(notifications, permissions, payments, language)
    ├─ SettingsSection("Account")
    └─ SettingsTile(logout, destructive: true)
```

Settings feature card:
- Icon
- Title
- Short status
- Chevron

States:
- Disabled feature: muted card with "Coming soon"
- Error loading settings: retry tile

## 8. Responsive Behavior

Phone:
- Single column everywhere except 2-column compact grids
- Sticky action bars for primary form submits
- Bottom sheets for filters and sort

Large phone / small tablet:
- Service and metric grids move to 2 columns
- Adoption list can use wider cards
- Dashboard charts get more vertical height

Tablet:
- Customer shell may use NavigationRail
- Shop owner can use side rail
- Dashboard metrics use 4 columns

Implementation:

```dart
final width = MediaQuery.sizeOf(context).width;
final isTablet = width >= 600;
final gridColumns = width >= 900 ? 4 : width >= 600 ? 3 : 2;
```

## 9. Loading, Empty, Error

Use existing:
- `AppLoader`
- `AppEmptyState`
- `AppButton(isLoading: true)`

Add:
- `AppErrorState(message, onRetry)`
- `AppSkeletonCard`
- `InlineRetryCard`
- `NetworkStatusBanner`

Rules:
- Full-screen loader only for initial blocking loads
- Use skeletons for feed/list/dashboard content
- Empty states include one clear recovery action
- Errors show human text and retry
- Keep stale content visible during refresh when possible

## 10. Suggested Flutter File Structure

```text
lib/
  core/
    config/
      app_spacing.dart
      app_radii.dart
  shared/
    widgets/
      zoovana_app_bar.dart
      customer_bottom_nav.dart
      role_badge.dart
      zoovana_card.dart
      metric_card.dart
      selection_chip.dart
      step_scaffold.dart
      sticky_bottom_summary.dart
      app_error_state.dart
      app_skeleton_card.dart
  features/
    customer/
      presentation/
        shells/customer_shell.dart
        screens/home_screen.dart
        screens/services_screen.dart
        screens/adoption_screen.dart
        screens/adoption_detail_screen.dart
    donations/
      presentation/screens/donation_flow_screen.dart
    lost_found/
      presentation/screens/lost_found_screen.dart
      presentation/screens/lost_found_form_screen.dart
    profile/
      presentation/screens/profile_screen.dart
    shop_owner/
      presentation/
        shells/shop_owner_shell.dart
        screens/shop_dashboard_screen.dart
        screens/shop_profile_screen.dart
        screens/shop_settings_screen.dart
```

## 11. Route Constants To Add

```dart
static const String customerHome = '/home';
static const String services = '/services';
static const String adoption = '/adoption';
static const String adoptionDetail = '/adoption/:id';
static const String donate = '/donate';
static const String lostFound = '/lost-found';
static const String profile = '/profile';
static const String shopOrders = '/shop-orders';
static const String shopInventory = '/shop-inventory';
```

## 12. Mobile Interaction Improvements

- Add bottom navigation for customer core screens.
- Use a floating action button for creating lost/found reports.
- Move filters into modal bottom sheets on narrow screens.
- Use sticky bottom bars for donation and adoption application actions.
- Replace dashboard tables with cards grouped by status/date.
- Use pull-to-refresh on home, adoption, lost/found, and dashboard.
- Keep form progress visible with compact step header.
- Persist incomplete donation/lost-found drafts locally.
- Show role badge in profile and role-aware app bars.
- Add branch selector for shop owner dashboard when multiple branches exist.
- Use optimistic UI for simple status changes, with rollback on error.

