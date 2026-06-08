# Implementation Plan: Zoovana Mobile UI

## Overview

Implement the Zoovana mobile UI — a pixel-faithful Flutter adaptation of the real Zoovana web app (s.zoovana.net). Six screens are required: Home, Donation, Lost & Found, Shop Dashboard, Profile, and Settings. All screens use the Zoovana brand design system: primary blue (#1A73E8), teal (#00BFA5), navy headings (#0D1B3E), light blue-grey background (#EEF2FF), white cards, Inter typography, and SAR currency.

The initial screen implementations already exist. These tasks cover completing, polishing, and wiring everything together so the app is fully navigable and visually matches the web screenshots.

---

## Tasks

- [x] 1. Update design system tokens in `lib/core/config/app_colors.dart`
  - Add `teal: #00BFA5`, `tealDark: #00897B`, `tealLight: #E0F7FA`
  - Add `navy: #0D1B3E` for dark headings
  - Update `background` to `#EEF2FF` (Zoovana light blue-grey)
  - Add `backgroundAlt: #F0F4FF`, `heroBlueDark: #0D47A1`
  - Add `grey200: #E8EAED`, `grey300: #DADCE0` (exact Zoovana card border values)
  - _Requirements: 1.1, 1.2_

- [x] 2. Build shared reusable widgets in `lib/shared/widgets/`
  - [x] 2.1 `zoovana_app_bar.dart` — White AppBar with 🐛 teal logo + "Zoovana" text, language pill, avatar
  - [x] 2.2 `primary_button.dart` — Full-width blue button, 48px height, 8px radius, loading state
  - [x] 2.3 `section_header.dart` — Title + optional "See all" action link
  - [x] 2.4 `chip_selector.dart` — Scrollable/wrap chip group, blue selected state
  - [x] 2.5 `segmented_control.dart` — Two-option animated toggle (used for Lost/Found)
  - [x] 2.6 `metric_card.dart` — KPI card with label, value, delta badge, icon
  - [x] 2.7 `form_input.dart` — Styled text field matching Zoovana design
  - _Requirements: 1.3, 1.4, 1.5, 8.1, 8.6_

- [x] 3. Implement Home Screen (`lib/features/home/presentation/views/home_screen.dart`)
  - [x] 3.1 White top navigation bar: 🐛 teal Zoovana logo, EN language pill, J avatar
  - [x] 3.2 Hero section on `#EEF2FF` background: navy 28sp bold headline, subtitle, "Explore More →" blue button
  - [x] 3.3 Pet image placeholder (cream blob container with 🐕 emoji + yellow "BETTER•HEALTHY•PETS" badge)
  - [x] 3.4 Blue ticker bar (#1A73E8, 48px): white text with pet care categories
  - [x] 3.5 About Us section: pet image with "15 Yr Experience" badge, "KNOW MORE ABOUT US" teal label, navy heading, body text, "Learn More →" link
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8_

- [x] 4. Implement Donation Screen (`lib/features/donation/presentation/views/donation_screen.dart`)
  - [x] 4.1 Blue header banner with "Make a Difference Today" title + 3-step stepper (teal active circles)
  - [x] 4.2 Step 1 — Amount: SAR25/50/100/250/500 chips, custom SAR input, "DONATION PURPOSE" chips, monthly toggle
  - [x] 4.3 Donation Summary card: Amount/Purpose/Frequency rows, SAR total in blue, "Continue to Details" button
  - [x] 4.4 Step 2 — Details: Full Name, Email, Phone fields
  - [x] 4.5 Step 3 — Confirm: summary review + "Confirm Donation" teal button
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.9, 3.10_

- [x] 5. Implement Lost & Found Screen (`lib/features/lost_found/presentation/views/lost_found_screen.dart`)
  - [x] 5.1 Blue gradient hero: pill badge, "Lost & Found" title, stats row (500+/24/7/100%)
  - [x] 5.2 Segmented toggle: "I Lost a Pet" (blue fill) / "I Found a Pet" (outlined)
  - [x] 5.3 2-column form grid: Name+Phone, Email, Animal Name+Species, Breed+Color, Sex dropdown
  - [x] 5.4 Collapsible "What happens next?" card with blue left border and bullet points
  - [x] 5.5 Sticky "Submit Report" blue button at bottom
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9_

- [x] 6. Implement Shop Dashboard Screen (`lib/features/shop_dashboard/presentation/views/shop_dashboard_screen.dart`)
  - [x] 6.1 Top bar: "Shop Owner" title, subtitle, EN pill, settings icon, J avatar with "Shop Owner" label
  - [x] 6.2 Horizontally scrollable TabBar: Overview, Branches, Suppliers, Categories, Products, Inventory, Purchase Orders, Marketplace Orders, Marketplace Invoices
  - [x] 6.3 Overview tab — 2×2 metric cards: Total Revenue (SAR 0), Total Orders (0), Active Shops (0), Low Stock (0)
  - [x] 6.4 Revenue Trend + Sales by Category chart panels with "No data available" empty state
  - [x] 6.5 Recent Orders section: search bar, Compact/Default/Spacious view pills, Reset/Export buttons, empty state
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8_

- [x] 7. Implement Profile Screen (`lib/features/profile/presentation/views/profile_screen.dart`)
  - [x] 7.1 Top bar: back arrow, "My Profile" title, subtitle, EN pill, settings icon, avatar
  - [x] 7.2 3-tab bar: Profile | Business | Security (blue active underline)
  - [x] 7.3 Profile header card: J avatar, name + edit icon, email, "Shop Owner" blue badge + "✓ Verified" green badge
  - [x] 7.4 4-icon stats row: Account Status (red ✗), Secure (lock), Role (circle), Email Address (envelope)
  - [x] 7.5 Account Information card: Full Name row with Edit link, Email row, Role row with blue badge
  - [x] 7.6 Quick Actions 2-column grid: "Back to Home" card + "Dashboard" card
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9_

- [x] 8. Implement Settings Screen (`lib/features/settings/presentation/views/settings_screen.dart`)
  - [x] 8.1 Top bar: back arrow, "Settings" title, "Manage your shop settings" subtitle
  - [x] 8.2 Centered header: blue gear icon in rounded square, "Configure Your Shop" navy title, subtitle
  - [x] 8.3 2-column settings card grid: Marketplace Activation (blue icon, "New" teal badge, "Configure →" link), Shop Verification (grey, "Coming Soon"), Payment Settings (grey, "Coming Soon")
  - [x] 8.4 Second row: Notifications (grey, "Coming Soon"), Team Management (grey, "Coming Soon")
  - [x] 8.5 Blue→teal gradient banner: sparkle icon, "More Features Coming Soon!" title, subtitle
  - [x] 8.6 Snackbar "This feature is coming soon." on tapping any Coming Soon card
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8_

- [x] 9. Wire all screens into GoRouter (`lib/routes/app_router.dart`)
  - Add routes for `/home`, `/donation`, `/lost-found`, `/profile`, `/settings`
  - Ensure `HomeScreen`, `DonationScreen`, `LostFoundScreen`, `ProfileScreen`, `SettingsScreen` are imported and registered
  - Verify `ShopDashboardScreen` is wired to `/shop-dashboard` (replacing the old placeholder)
  - Add navigation calls from Home screen quick action chips to Donation and Lost & Found routes
  - Add navigation from Profile quick actions to Home and Shop Dashboard
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 10. Add bottom navigation bar for customer-facing screens
  - Create `lib/shared/widgets/customer_bottom_nav.dart` with 4 tabs: Home, Services, Adoption, Profile
  - Use `NavigationBar` widget with `AppColors.primary` active indicator
  - Wrap Home, Donation, Lost & Found, and Profile screens with the bottom nav shell
  - Active tab highlights with primary blue; inactive tabs use `AppColors.textSecondary`
  - _Requirements: 8.2, 8.3_

- [x] 11. Fix deprecated `withOpacity` calls across shared widgets
  - Replace `withOpacity(x)` with `withValues(alpha: x)` in:
    - `lib/shared/widgets/metric_card.dart`
    - `lib/shared/widgets/primary_button.dart`
    - `lib/shared/widgets/segmented_control.dart`
  - Run `dart analyze lib/shared/widgets/` to confirm 0 issues
  - _Requirements: 1.1_

- [x] 12. Polish Home Screen ticker bar with auto-scroll animation
  - Replace static `SingleChildScrollView` ticker with an animated `Marquee`-style widget
  - Use a `ScrollController` with `animateTo` in a repeating loop, or use the `marquee` package if available
  - Ensure the ticker scrolls continuously from right to left at a readable speed
  - _Requirements: 2.6_

- [x] 13. Add pull-to-refresh to Home Screen and Shop Dashboard
  - Wrap Home Screen `ListView` in a `RefreshIndicator` with `AppColors.primary` color
  - Wrap Shop Dashboard Overview tab `ListView` in a `RefreshIndicator`
  - On refresh, simulate a 1-second delay then rebuild (no real API call needed in mock mode)
  - _Requirements: 2.9, 5.9_

- [x] 14. Add skeleton loading states
  - Create `lib/shared/widgets/skeleton_card.dart` — animated shimmer placeholder using `AnimatedContainer` or a simple grey pulsing box
  - Show skeleton cards on Home Screen and Shop Dashboard while `isLoading` is true
  - Trigger loading state for 1 second on first build, then show real content
  - _Requirements: 10.1, 10.2, 10.3_

- [x] 15. Final verification — run `dart analyze` and `flutter test`
  - Run `dart analyze lib/` and confirm 0 errors (deprecation infos acceptable)
  - Run `flutter test` and confirm all existing tests still pass
  - Manually verify all 6 screens render correctly on a 375px viewport
  - Confirm SAR currency appears everywhere (no $ symbols)
  - Confirm all navigation between screens works end-to-end

## Notes

- All screens are pure UI — no real API calls. Mock data is hardcoded in each screen.
- Tasks 1–8 are already complete based on the initial implementation.
- Tasks 9–15 are the remaining work to make the app fully navigable and polished.
- The `useMocks = true` flag in `DependencyInjection` bypasses all real API calls for the auth flow.
- Currency is SAR throughout — never use `$`.
- Minimum touch target: 48px height for all interactive elements.
- Use `AppColors`, `AppTextStyles` constants — never hardcode hex values or font sizes.
