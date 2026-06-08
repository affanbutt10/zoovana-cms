/// Central asset path constants for the Zoovana CMS application.
/// All asset paths must be sourced from this class.
class AppAssets {
  AppAssets._();

  // ── Base paths ─────────────────────────────────────────────────────────────
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _animations = 'assets/animations';

  // ── Images ─────────────────────────────────────────────────────────────────
  static const String logo = '$_images/logo.png';
  static const String logoWhite = '$_images/logo_white.png';
  static const String splashBackground = '$_images/splash_background.png';
  static const String placeholder = '$_images/placeholder.png';
  static const String productPlaceholder = '$_images/product_placeholder.png';
  static const String avatarPlaceholder = '$_images/avatar_placeholder.png';
  static const String emptyState = '$_images/empty_state.png';
  static const String errorState = '$_images/error_state.png';

  // ── Icons ──────────────────────────────────────────────────────────────────
  static const String iconDashboard = '$_icons/ic_dashboard.svg';
  static const String iconProducts = '$_icons/ic_products.svg';
  static const String iconVendors = '$_icons/ic_vendors.svg';
  static const String iconVendorSites = '$_icons/ic_vendor_sites.svg';
  static const String iconSettings = '$_icons/ic_settings.svg';
  static const String iconNotification = '$_icons/ic_notification.svg';
  static const String iconSearch = '$_icons/ic_search.svg';
  static const String iconFilter = '$_icons/ic_filter.svg';
  static const String iconUpload = '$_icons/ic_upload.svg';

  // ── Animations (Lottie / Rive) ─────────────────────────────────────────────
  static const String animationLoading = '$_animations/loading.json';
  static const String animationSuccess = '$_animations/success.json';
  static const String animationError = '$_animations/error.json';
  static const String animationEmpty = '$_animations/empty.json';
}
