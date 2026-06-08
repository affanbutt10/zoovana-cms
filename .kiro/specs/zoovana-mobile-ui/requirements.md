# Requirements Document

## Introduction

This document specifies the UI requirements for the Zoovana Flutter mobile app — a pet-care marketplace serving the Saudi Arabian market. The mobile app faithfully adapts the existing Zoovana web application into a 375 px-first mobile experience, preserving the exact brand identity: teal logo (#00BFA5), primary blue (#1A73E8), navy headings (#0D1B3E), light blue-grey backgrounds (#EEF2FF / #F0F4FF), white cards, Inter typography, and SAR currency throughout.

Six screens are specified: Home, Donation, Lost & Found, Shop Dashboard, Profile, and Settings. Each screen converts the desktop layout into a mobile-optimised single-column flow while retaining every visual component, colour token, and interaction pattern from the web source.

---

## Glossary

- **App**: The Zoovana Flutter mobile application.
- **Design_System**: The shared set of colour tokens, typography scale, spacing constants, shape radii, and component styles defined in this document and implemented in `core/config/`.
- **AppColors**: The Dart class in `core/config/app_colors.dart` that exposes all colour constants.
- **AppTextStyles**: The Dart class in `core/config/app_text_styles.dart` that exposes all text style constants using the Inter font family.
- **AppSpacing**: The Dart class in `core/config/app_spacing.dart` that exposes the 8 pt spacing scale.
- **Primary_Blue**: The colour `#1A73E8` used for primary buttons, hero backgrounds, active states, and interactive elements.
- **Teal**: The colour `#00BFA5` used for the Zoovana logo, toggle active states, and CTA banners.
- **Background**: The colour `#EEF2FF` (alias `#F0F4FF`) used as the app-wide scaffold background.
- **Navy**: The colour `#0D1B3E` used for primary headings and high-emphasis text.
- **SAR**: Saudi Riyal — the currency symbol used throughout all monetary displays.
- **Home_Screen**: The public-facing landing screen accessible without authentication.
- **Donation_Screen**: The three-step donation flow screen.
- **Lost_Found_Screen**: The lost and found report submission screen.
- **Shop_Dashboard_Screen**: The shop owner analytics and order management screen.
- **Profile_Screen**: The authenticated user profile screen.
- **Settings_Screen**: The shop owner configuration screen.
- **Sticky_Bottom_Bar**: A `Container` pinned to the bottom of the `Scaffold` above the system navigation bar, used for primary actions on forms and summaries.
- **Scrollable_Tab_Bar**: A horizontally scrollable `TabBar` used to replace desktop multi-column navigation tabs on mobile.
- **Selection_Chip**: A `ChoiceChip` or `FilterChip` styled with white background and grey border in default state, and Primary_Blue tint with Primary_Blue border in selected state.
- **Metric_Card**: A white `Card` displaying a label, a large numeric value, a percentage delta, and an optional icon.
- **Step_Progress_Header**: A compact horizontal stepper showing step number, step label, and a connecting line, used at the top of multi-step flows.
- **Collapsible_Card**: An `ExpansionTile`-based card that shows a summary header and expands to reveal detail content.
- **Coming_Soon_Badge**: A grey pill badge with the text "Coming Soon" overlaid on disabled feature cards.
- **New_Badge**: A teal pill badge with the text "New" overlaid on newly available feature cards.

---

## Requirements

---

### Requirement 1: Design System Tokens

**User Story:** As a developer, I want all Zoovana brand colours, typography, spacing, and shape values defined as Dart constants, so that every screen uses the exact same visual language without hardcoding values.

#### Acceptance Criteria

1. THE Design_System SHALL define the following colour constants in `AppColors`:
   - `primaryBlue`: `#1A73E8`
   - `primaryBlueDark`: `#1558B0`
   - `teal`: `#00BFA5`
   - `tealDark`: `#00897B`
   - `background`: `#EEF2FF`
   - `backgroundAlt`: `#F0F4FF`
   - `surface`: `#FFFFFF`
   - `navy`: `#0D1B3E`
   - `textPrimary`: `#202124`
   - `textSecondary`: `#5F6368`
   - `grey200`: `#E8EAED`
   - `grey300`: `#DADCE0`
   - `error`: `#EA4335`
   - `success`: `#34A853`
   - `warning`: `#FBBC04`
   - `tickerBlue`: `#1A73E8` (scrolling ticker bar background)
   - `heroBlueDark`: `#0D47A1` (hero gradient dark stop)
2. THE Design_System SHALL define the following text styles in `AppTextStyles` using the Inter font family:
   - `displayLarge`: Inter Bold, 32 sp, Navy
   - `headlineMedium`: Inter Bold, 24 sp, Navy
   - `titleLarge`: Inter SemiBold, 20 sp, Navy
   - `titleMedium`: Inter SemiBold, 16 sp, textPrimary
   - `bodyLarge`: Inter Regular, 16 sp, textPrimary
   - `bodyMedium`: Inter Regular, 14 sp, textPrimary
   - `bodySmall`: Inter Regular, 12 sp, textSecondary
   - `labelLarge`: Inter Medium, 14 sp, textPrimary
   - `labelMedium`: Inter Medium, 12 sp, textSecondary
   - `button`: Inter SemiBold, 14 sp, surface
3. THE Design_System SHALL define the following spacing constants in `AppSpacing`:
   - `xs`: 4.0
   - `sm`: 8.0
   - `md`: 16.0
   - `lg`: 24.0
   - `xl`: 32.0
   - `xxl`: 40.0
   - `screenHorizontal`: 16.0
4. THE Design_System SHALL define the following shape constants:
   - Card border radius: 8.0
   - Button border radius: 8.0
   - Chip border radius: 20.0
   - Input border radius: 8.0
   - Bottom sheet top radius: 20.0
   - Badge border radius: 12.0
5. THE Design_System SHALL define a minimum touch target height of 48.0 for all interactive widgets.
6. WHEN the Inter font is not available, THE App SHALL fall back to the system sans-serif font.

---

### Requirement 2: Home Screen

**User Story:** As a visitor, I want to see the Zoovana home screen with the brand hero, quick navigation, and About Us section, so that I understand the platform and can navigate to key features.

#### Acceptance Criteria

1. THE Home_Screen SHALL render on a `#EEF2FF` scaffold background.
2. THE Home_Screen SHALL display a top navigation bar containing:
   - The Zoovana ladybug/bug icon in Teal followed by the text "Zoovana" in Teal (#00BFA5), Inter SemiBold 18 sp
   - A horizontal row of navigation links: "Shop Now", "Donation", "Lost & Found" in Inter Medium 14 sp, textPrimary
   - A language toggle pill showing "EN | AR" with the active language highlighted in Primary_Blue
   - A circular user avatar (32 px diameter) on the far right
3. WHEN the viewport width is less than 600 px, THE Home_Screen SHALL collapse the navigation links into a hamburger menu icon and retain only the logo and avatar in the top bar.
4. THE Home_Screen SHALL display a hero section with:
   - A dark navy (#0D1B3E) background or a blue gradient from #1A73E8 to #0D47A1
   - Left side: headline text "Trusted Pet Care & Veterinary Center Point" in Inter Bold 28 sp, white
   - Left side: subtitle text in Inter Regular 14 sp, white at 80% opacity
   - Left side: a "Explore More →" button with Primary_Blue fill (#1A73E8), white text, 8 px border radius, 48 px height
   - Right side: a pet image (dog or cat) displayed as a rounded image, stacked below the text on mobile
5. WHEN the screen width is less than 600 px, THE Home_Screen SHALL stack the hero text and pet image vertically with text above and image below.
6. THE Home_Screen SHALL display a horizontally scrolling ticker bar immediately below the hero with:
   - Background colour Primary_Blue (#1A73E8)
   - White text listing pet care categories (e.g., "Veterinary", "Grooming", "Boarding", "Training", "Adoption", "Shop") separated by bullet separators
   - Continuous auto-scroll animation from right to left
7. THE Home_Screen SHALL display an "About Us" section below the ticker bar containing:
   - A blob-shaped or rounded-rectangle image on the left (stacked above on mobile)
   - A "15 Yr Experience" badge overlaid on the image in Teal (#00BFA5) with white text
   - A section heading "About Us" in Inter Bold 22 sp, Navy
   - Body text describing Zoovana's mission in Inter Regular 14 sp, textSecondary
   - A "Learn More" or "Read More" link in Primary_Blue
8. WHEN the screen width is less than 600 px, THE Home_Screen SHALL stack the About Us image above the text content.
9. THE Home_Screen SHALL support pull-to-refresh to reload dynamic content sections.
10. WHILE content is loading, THE Home_Screen SHALL display skeleton placeholder cards for the hero and About Us sections.
11. IF content fails to load, THE Home_Screen SHALL display an inline retry card below the hero section.

---

### Requirement 3: Donation Screen

**User Story:** As a donor, I want to complete a three-step donation flow on mobile, so that I can select an amount, provide my details, and confirm my donation to Zoovana.

#### Acceptance Criteria

1. THE Donation_Screen SHALL render on a white scaffold background.
2. THE Donation_Screen SHALL display a blue header banner at the top with:
   - Background colour Primary_Blue (#1A73E8)
   - Title text "Make a Difference Today" in Inter Bold 22 sp, white
   - A Step_Progress_Header showing three steps: "1 Amount", "2 Details", "3 Confirm"
   - The active step indicator filled in Teal (#00BFA5); completed steps shown with a checkmark; inactive steps shown in white at 50% opacity
3. THE Donation_Screen Step 1 SHALL display a "Select Donation Amount" card containing:
   - A wrap of Selection_Chips for preset amounts: SAR 25, SAR 50, SAR 100, SAR 250, SAR 500
   - A custom amount text input field with "SAR" prefix label, numeric keyboard, 48 px height, 8 px border radius, grey border
   - A section label "DONATION PURPOSE" in Inter SemiBold 12 sp, textSecondary, uppercase
   - A wrap of Selection_Chips for purposes: "General", "Medical Care", "Food & Supplies", "Shelter Operations"
   - A monthly donation toggle row: label "Make this a monthly donation" in Inter Regular 14 sp, textPrimary; toggle switch with Teal (#00BFA5) active colour
4. WHEN a preset amount chip is tapped, THE Donation_Screen SHALL mark that chip as selected (Primary_Blue tint and border) and clear the custom amount field.
5. WHEN a custom amount is entered, THE Donation_Screen SHALL deselect all preset amount chips.
6. THE Donation_Screen SHALL display a "Donation Summary" card below the amount selection card (stacked vertically on mobile) containing:
   - Rows for: Amount (SAR value), Purpose (selected purpose), Frequency ("One-time" or "Monthly"), Total (SAR value)
   - Each row: label in Inter Regular 14 sp, textSecondary; value in Inter SemiBold 14 sp, textPrimary
   - A horizontal divider above the Total row
7. THE Donation_Screen SHALL display a Sticky_Bottom_Bar containing a "Continue to Details" button:
   - Background Primary_Blue (#1A73E8), white text, Inter SemiBold 14 sp, full width, 48 px height, 8 px border radius
8. WHEN the "Continue to Details" button is tapped without a selected amount, THE Donation_Screen SHALL display an inline validation error "Please select or enter a donation amount."
9. THE Donation_Screen Step 2 SHALL display a details form with fields: Full Name, Email Address, Phone Number — each using `AppTextField` with label above, 48 px height, 8 px border radius.
10. THE Donation_Screen Step 3 SHALL display a confirmation card summarising all entered data and a "Confirm Donation" button in the Sticky_Bottom_Bar.
11. WHILE a donation submission is in progress, THE Donation_Screen SHALL disable the Sticky_Bottom_Bar button and show a circular progress indicator inside it.
12. IF a donation submission fails, THE Donation_Screen SHALL display a bottom sheet with the error message and a "Retry" button.
13. THE Step_Progress_Header SHALL allow tapping a completed step to navigate back to it without clearing entered data.

---

### Requirement 4: Lost & Found Screen

**User Story:** As a pet owner or finder, I want to submit a lost or found pet report on mobile, so that I can help reunite pets with their owners.

#### Acceptance Criteria

1. THE Lost_Found_Screen SHALL display a hero section at the top with:
   - A blue gradient background from Primary_Blue (#1A73E8) to #0D47A1
   - A pill badge "Lost & Found Tracking System" in white text on a semi-transparent white background, 20 px border radius
   - A large title "Lost & Found" in Inter Bold 28 sp, white
   - A subtitle in Inter Regular 14 sp, white at 80% opacity
   - Three stat items displayed in a horizontal row: "500+ Reunited", "24/7 Active Support", "100% Free Service" — each with a bold number/label in Inter Bold 16 sp, white and a descriptor in Inter Regular 12 sp, white at 80% opacity
2. WHEN the screen width is less than 600 px, THE Lost_Found_Screen SHALL display the three stats in a single horizontal row with equal spacing, wrapping to a second row if necessary.
3. THE Lost_Found_Screen SHALL display a white card below the hero containing a segmented toggle with two options: "I Lost a Pet" (Primary_Blue filled when active) and "I Found a Pet" (outlined when inactive).
4. WHEN "I Lost a Pet" is selected, THE Lost_Found_Screen SHALL show the lost pet report form; WHEN "I Found a Pet" is selected, THE Lost_Found_Screen SHALL show the found pet report form.
5. THE lost pet report form SHALL contain the following fields in vertical order:
   - Your Name (text input, required)
   - Phone Number (phone input, required)
   - Email Address (email input, required)
   - Animal Name (text input, optional — labelled "Animal Name (Optional)")
   - Species (dropdown, required — options: Dog, Cat, Bird, Rabbit, Other)
   - Breed (text input, required)
   - Color (text input, required)
   - Sex (dropdown, required — options: Male, Female, Unknown)
6. EACH form field SHALL use `AppTextField` or `AppDropdownField` with label above, 48 px height, 8 px border radius, grey border, and inline error message below on validation failure.
7. THE Lost_Found_Screen SHALL display a "What happens next?" Collapsible_Card below the form:
   - Header: "What happens next?" in Inter SemiBold 14 sp, Primary_Blue, with a chevron icon
   - Expanded content: a blue info card (#EEF2FF background, Primary_Blue left border) listing the process steps as bullet points
   - Default state: collapsed
8. WHEN the "What happens next?" card header is tapped, THE Lost_Found_Screen SHALL expand or collapse the card with an animated transition.
9. THE Lost_Found_Screen SHALL display a Sticky_Bottom_Bar containing a "Submit Report" button:
   - Background Primary_Blue (#1A73E8), white text, Inter SemiBold 14 sp, full width, 48 px height, 8 px border radius
10. WHEN the "Submit Report" button is tapped with any required field empty, THE Lost_Found_Screen SHALL display inline validation errors on each empty required field without submitting.
11. WHILE a report submission is in progress, THE Lost_Found_Screen SHALL disable the Sticky_Bottom_Bar button and show a circular progress indicator inside it.
12. WHEN a report is submitted successfully, THE Lost_Found_Screen SHALL display a success bottom sheet with a confirmation message and a "Done" button that dismisses the sheet and resets the form.

---

### Requirement 5: Shop Dashboard Screen

**User Story:** As a shop owner, I want to view my shop's key metrics, revenue trends, and recent orders on mobile, so that I can monitor performance without needing a desktop browser.

#### Acceptance Criteria

1. THE Shop_Dashboard_Screen SHALL render on a white scaffold background.
2. THE Shop_Dashboard_Screen SHALL display a Scrollable_Tab_Bar at the top with the following tabs in order: "Overview", "Branches", "Suppliers", "Categories", "Products", "Inventory", "Purchase Orders", "Marketplace Orders", "Marketplace Invoices".
3. THE Scrollable_Tab_Bar SHALL use Primary_Blue (#1A73E8) for the active tab indicator and active tab label; inactive tab labels SHALL use textSecondary.
4. THE Scrollable_Tab_Bar SHALL allow horizontal scrolling so all tabs are accessible on a 375 px screen without wrapping.
5. THE Shop_Dashboard_Screen Overview tab SHALL display four Metric_Cards in a 2×2 grid:
   - "Total Revenue": value "SAR 0", delta "0.0%", downward arrow icon in error red
   - "Total Orders": value "0", delta "0.0%", downward arrow icon in error red
   - "Active Shops": value "0", delta "+0 new", upward arrow icon in success green
   - "Low Stock": value "0", subtitle "Needs attention", warning icon in warning yellow
6. EACH Metric_Card SHALL have: white background, 8 px border radius, 1 px grey200 border, 16 px internal padding, label in Inter Regular 12 sp textSecondary, value in Inter Bold 24 sp Navy, delta/subtitle in Inter Regular 12 sp with colour matching the trend direction.
7. THE Shop_Dashboard_Screen Overview tab SHALL display two chart panel cards below the metric grid:
   - "Revenue Trend" card: white background, 8 px border radius, title in Inter SemiBold 14 sp Navy, empty state message "No data available" centred in Inter Regular 14 sp textSecondary
   - "Sales by Category" card: same styling as Revenue Trend
   - On mobile (width < 600 px), the two chart cards SHALL be stacked vertically
8. THE Shop_Dashboard_Screen Overview tab SHALL display a "Recent Orders" section below the chart cards containing:
   - Section title "Recent Orders" in Inter SemiBold 16 sp Navy
   - A search input field with placeholder "Search orders…", 48 px height, 8 px border radius, grey border, search icon prefix
   - A row of view toggle buttons: "Compact", "Default", "Spacious" — the active toggle highlighted with Primary_Blue tint
   - A row of action buttons: "Reset" (outlined, grey) and "Export" (outlined, grey), each 40 px height, 8 px border radius
   - An empty state message "No results found" centred in Inter Regular 14 sp textSecondary when no orders exist
9. THE Shop_Dashboard_Screen SHALL support pull-to-refresh to reload all dashboard data.
10. WHILE dashboard data is loading, THE Shop_Dashboard_Screen SHALL display skeleton placeholder cards for the metric grid and chart panels.
11. IF dashboard data fails to load, THE Shop_Dashboard_Screen SHALL display an inline retry card at the top of the Overview tab content.

---

### Requirement 6: Profile Screen

**User Story:** As an authenticated user, I want to view and manage my profile information on mobile, so that I can verify my account details and access key account actions.

#### Acceptance Criteria

1. THE Profile_Screen SHALL render on a white scaffold background.
2. THE Profile_Screen SHALL display a profile header card at the top containing:
   - A circular avatar (64 px diameter) with the user's initial in Inter Bold 24 sp white on a Primary_Blue background
   - The user's full name in Inter Bold 18 sp Navy, with an edit (pencil) icon in textSecondary immediately to the right
   - The user's email address in Inter Regular 14 sp textSecondary below the name
   - A "Shop Owner" badge: Primary_Blue background, white text, Inter Medium 12 sp, 12 px border radius
   - A "Verified" badge: success green (#34A853) background, white text, Inter Medium 12 sp, 12 px border radius
   - The two badges SHALL be displayed in a horizontal row below the email
3. THE Profile_Screen SHALL display a row of four icon stat items below the header card:
   - "Account Status": red X icon, label "Account Status" in Inter Regular 11 sp textSecondary
   - "Secure": lock icon in textSecondary, label "Secure"
   - "Role": circle/person icon in textSecondary, label "Role"
   - "Email Address": envelope icon in textSecondary, label "Email Address"
   - Each stat item SHALL be equally spaced in a horizontal row with icon above label
4. THE Profile_Screen SHALL display an "Account Information" section card containing:
   - Section title "Account Information" in Inter SemiBold 16 sp Navy
   - A "Full Name" row: label in Inter Regular 14 sp textSecondary, value in Inter Regular 14 sp textPrimary, "Edit" link in Primary_Blue on the far right
   - An "Email Address" row: label and value in the same style, no edit link
   - A "Role" row: label in Inter Regular 14 sp textSecondary, a "Shop Owner" badge (Primary_Blue) as the value
   - Horizontal dividers between each row
5. THE Profile_Screen SHALL display a "Quick Actions" section below the Account Information card containing two action cards side by side (2-column grid on mobile):
   - "Back to Home" card: white background, 8 px border radius, grey border, home icon, title in Inter SemiBold 14 sp Navy
   - "Dashboard" card: same styling, dashboard/grid icon, title in Inter SemiBold 14 sp Navy
6. WHEN the edit icon next to the user's name is tapped, THE Profile_Screen SHALL navigate to an editable profile form screen.
7. WHEN the "Edit" link in the Full Name row is tapped, THE Profile_Screen SHALL navigate to an editable profile form screen.
8. WHEN the "Back to Home" quick action card is tapped, THE Profile_Screen SHALL navigate to the Home_Screen.
9. WHEN the "Dashboard" quick action card is tapped, THE Profile_Screen SHALL navigate to the Shop_Dashboard_Screen.

---

### Requirement 7: Settings Screen

**User Story:** As a shop owner, I want to access and configure my shop settings on mobile, so that I can activate marketplace features and manage my shop configuration.

#### Acceptance Criteria

1. THE Settings_Screen SHALL render on the `#EEF2FF` scaffold background.
2. THE Settings_Screen SHALL display a centred layout containing:
   - A settings gear icon in a blue rounded square container (48×48 px, Primary_Blue background, 12 px border radius, white icon)
   - A large title "Configure Your Shop" in Inter Bold 24 sp Navy, centred
   - A subtitle in Inter Regular 14 sp textSecondary, centred, below the title
3. THE Settings_Screen SHALL display a settings card grid below the title section:
   - Row 1: "Marketplace Activation", "Shop Verification", "Payment Settings" — displayed as a 2-column grid on mobile (width < 600 px), wrapping the third card to a second row
   - Row 2: "Notifications", "Team Management" — displayed in the same 2-column grid
4. EACH settings card SHALL contain:
   - An icon in a rounded square container (40×40 px, 8 px border radius)
   - A card title in Inter SemiBold 14 sp Navy
   - A status badge: "New" badge (Teal #00BFA5 background, white text) for Marketplace Activation; "Coming Soon" badge (grey background, textSecondary text) for all other cards
   - A "Configure →" link in Primary_Blue, Inter Medium 12 sp, for Marketplace Activation only
   - White background, 8 px border radius, 1 px grey200 border, 16 px internal padding
5. THE "Marketplace Activation" card SHALL have a Primary_Blue icon container; all other settings cards SHALL have a grey200 icon container to indicate disabled/coming-soon state.
6. WHEN the "Marketplace Activation" card or its "Configure →" link is tapped, THE Settings_Screen SHALL navigate to the marketplace activation configuration flow.
7. WHEN any "Coming Soon" settings card is tapped, THE Settings_Screen SHALL display a brief snackbar message "This feature is coming soon."
8. THE Settings_Screen SHALL display a gradient banner at the bottom of the screen:
   - Background: linear gradient from Primary_Blue (#1A73E8) to Teal (#00BFA5), left to right
   - Title "More Features Coming Soon!" in Inter Bold 18 sp, white, centred
   - Subtitle text in Inter Regular 13 sp, white at 80% opacity, centred
   - 12 px border radius, 16 px internal padding

---

### Requirement 8: Shared Navigation Components

**User Story:** As a user, I want consistent navigation components across all screens, so that I can move between sections of the app predictably.

#### Acceptance Criteria

1. THE App SHALL provide a `ZoovanaAppBar` widget that displays the Zoovana logo (ladybug icon + "Zoovana" text in Teal) as the leading element on customer-facing screens.
2. THE App SHALL provide a `CustomerBottomNav` widget with four items: Home, Services, Adoption, Profile — using `NavigationBar` with Primary_Blue active indicator.
3. THE App SHALL provide a `ShopOwnerShell` widget that wraps shop owner screens with the Scrollable_Tab_Bar navigation pattern instead of a bottom navigation bar.
4. THE `ZoovanaAppBar` SHALL display a role badge ("Shop Owner" in Primary_Blue) in the actions area when the authenticated user has the shop owner role.
5. WHEN the back button is pressed on the Shop_Dashboard_Screen, THE App SHALL NOT navigate back to the login or initialization screens.
6. THE App SHALL provide a `Sticky_Bottom_Bar` widget that renders above the system navigation bar using `SafeArea` bottom padding.

---

### Requirement 9: Responsive Layout Adaptation

**User Story:** As a developer, I want documented responsive breakpoints and layout rules, so that all screens adapt correctly from 375 px phones to 768 px tablets.

#### Acceptance Criteria

1. THE App SHALL define the following breakpoints:
   - Phone: width < 600 px — single column, stacked layouts
   - Large phone / small tablet: 600 px ≤ width < 900 px — 2-column grids where specified
   - Tablet: width ≥ 900 px — 3–4 column grids, NavigationRail option
2. WHEN the screen width is less than 600 px, THE App SHALL convert all side-by-side desktop layouts to stacked vertical layouts (hero text + image, donation form + summary, lost & found form + info card, dashboard charts).
3. WHEN the screen width is less than 600 px, THE App SHALL convert all 3-column desktop card grids to 2-column grids (settings cards, metric cards).
4. THE App SHALL implement responsive column count using `MediaQuery.sizeOf(context).width` and a helper function that returns the appropriate column count.
5. THE Donation_Screen summary sidebar SHALL become a Sticky_Bottom_Bar summary card on screens narrower than 600 px.
6. THE Lost_Found_Screen "What happens next?" sidebar SHALL become a Collapsible_Card below the form on screens narrower than 600 px.
7. THE Shop_Dashboard_Screen navigation tabs SHALL become a Scrollable_Tab_Bar on screens narrower than 900 px.
8. THE Home_Screen navigation links SHALL collapse into a hamburger drawer on screens narrower than 600 px.

---

### Requirement 10: Loading, Empty, and Error States

**User Story:** As a user, I want clear visual feedback during loading, empty, and error conditions on every screen, so that I always understand the current state of the app.

#### Acceptance Criteria

1. THE App SHALL provide an `AppSkeletonCard` widget that renders an animated shimmer placeholder matching the dimensions of the card it replaces.
2. THE App SHALL provide an `AppErrorState` widget that accepts a message string and an `onRetry` callback, displaying a retry button.
3. WHILE any screen is performing its initial data load, THE App SHALL display `AppSkeletonCard` placeholders in place of content cards.
4. WHEN a screen's data load completes with an empty result, THE App SHALL display an `AppEmptyState` widget with a contextually appropriate message and a recovery action.
5. WHEN a screen's data load fails, THE App SHALL display an `AppErrorState` widget with a human-readable error message and a retry button.
6. WHILE a form submission is in progress, THE App SHALL disable the primary submit button and replace its label with a `CircularProgressIndicator` of size 20 px in white.
7. THE App SHALL NOT display a full-screen blocking loader except during the initial app startup and shop owner initialization flow.
8. WHEN stale data is available, THE App SHALL display it during a pull-to-refresh operation rather than replacing it with a skeleton.

---

### Requirement 11: Currency and Localisation

**User Story:** As a user in Saudi Arabia, I want all monetary values displayed in SAR and the app to support both English and Arabic, so that the app feels native to the local market.

#### Acceptance Criteria

1. THE App SHALL display all monetary values with the "SAR" prefix followed by the numeric value (e.g., "SAR 250").
2. THE App SHALL NOT display any monetary values with the "$" symbol.
3. THE App SHALL display a language toggle (EN / AR) in the Home_Screen top navigation bar.
4. WHEN the AR language option is selected, THE App SHALL switch the text direction to right-to-left (RTL) using Flutter's `Directionality` widget.
5. THE App SHALL use `intl` package number formatting for all monetary and numeric displays, respecting the active locale.
6. THE App SHALL store the selected language preference in `LocalStorageService` and restore it on app restart.

