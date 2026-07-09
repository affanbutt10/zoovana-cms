/// Single source of truth for all API URL path constants.
///
/// All paths are relative to the service base URL and are used by data-source
/// classes to construct full request URLs.
///
/// Rule: No hardcoded URL strings are permitted outside this file.
class ApiEndpoints {
  ApiEndpoints._();

  /// Base URL for all API requests (legacy — prefer [AppConfig.authBaseUrl]).
  /// The actual value is injected at runtime via [AppConfig].
  static const String baseUrl = 'https://api.zoovana.com/api/v1';

  // ---------------------------------------------------------------------------
  // Auth Service endpoints  (base: AppConfig.authBaseUrl)
  // ---------------------------------------------------------------------------

  /// POST — authenticate a user and receive JWT tokens.
  static const String login = '/api/v1/auth/login';

  /// POST — register a new user account.
  static const String register = '/api/v1/auth/register';

  /// POST — verify a user's email address with an OTP.
  static const String verifyEmail = '/api/v1/auth/verify-email';

  /// POST — resend the email verification OTP.
  static const String resendVerification = '/api/v1/auth/resend-verification';

  /// POST — initiate the forgot-password flow.
  static const String forgotPassword = '/api/v1/auth/forgot-password';

  /// POST — verify the OTP sent during password reset.
  static const String verifyOtp = '/api/v1/auth/verify-otp';

  /// POST — set a new password after OTP verification.
  static const String resetPassword = '/api/v1/auth/reset-password';

  /// POST — change password for an authenticated user.
  static const String changePassword = '/api/v1/auth/change-password';

  /// POST — exchange a refresh token for a new access token.
  static const String refresh = '/api/v1/auth/refresh';

  /// GET — list all available roles.
  /// Note: served from the main service, not the auth service.
  static const String roles = '/api/v1/roles';

  /// Base URL for the main/roles service.
  static const String mainBaseUrl = 'https://zoovana.net/api/main';

  /// GET — retrieve the authenticated user's profile.
  static const String userProfile = '/api/v1/users/me/profile';

  // ---------------------------------------------------------------------------
  // Shop Service endpoints  (base: AppConfig.shopBaseUrl)
  // ---------------------------------------------------------------------------

  /// GET — retrieve the authenticated owner's business.
  static const String businessMe = '/api/v1/businesses/me';

  /// GET — retrieve the authenticated owner's business with its branches.
  static const String businessMeWithBranches =
      '/api/v1/businesses/me/with-branches';

  /// GET / POST — list or create branches.
  static const String branches = '/api/v1/branches';

  // ---------------------------------------------------------------------------
  // Legacy auth path (kept for backward compatibility)
  // ---------------------------------------------------------------------------

  /// POST — invalidate the current session token.
  static const String logout = '/auth/logout';

  // ---------------------------------------------------------------------------
  // Products
  // ---------------------------------------------------------------------------

  /// GET (paginated) / POST — list or create products.
  static const String products = '/products';

  /// GET / PUT / DELETE — operate on a single product by [id].
  ///
  /// Usage: `'${ApiEndpoints.productById('abc123')}'`
  static String productById(String id) => '/products/$id';

  /// PATCH — update the status of a single product by [id].
  ///
  /// Usage: `'${ApiEndpoints.productStatus('abc123')}'`
  static String productStatus(String id) => '/products/$id/status';

  /// POST — upload an image for a single product by [id].
  ///
  /// Usage: `'${ApiEndpoints.productImage('abc123')}'`
  static String productImage(String id) => '/products/$id/image';

  // ---------------------------------------------------------------------------
  // Vendors
  // ---------------------------------------------------------------------------

  /// GET (paginated) / POST — list or create vendors.
  static const String vendors = '/vendors';

  // ---------------------------------------------------------------------------
  // Vendor Sites
  // ---------------------------------------------------------------------------

  /// GET (paginated) / POST — list or create vendor sites.
  static const String vendorSites = '/vendor-sites';
}
