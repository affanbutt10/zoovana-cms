/// Central string constants for the Zoovana CMS application.
/// All user-facing strings must be sourced from this class.
class AppStrings {
  AppStrings._();

  // ── App ────────────────────────────────────────────────────────────────────
  static const String appName = 'Zoovana CMS';
  static const String appTagline = 'Marketplace Management';

  // ── Common Actions ─────────────────────────────────────────────────────────
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String create = 'Create';
  static const String update = 'Update';
  static const String submit = 'Submit';
  static const String retry = 'Retry';
  static const String close = 'Close';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String done = 'Done';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String refresh = 'Refresh';
  static const String logout = 'Logout';

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String login = 'Login';
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to your account';
  static const String email = 'Email';
  static const String emailHint = 'Enter your email';
  static const String password = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String forgotPassword = 'Forgot Password?';
  static const String loginButton = 'Sign In';
  static const String loggingIn = 'Signing in…';
  static const String logoutConfirm = 'Are you sure you want to logout?';

  // ── Navigation / Sections ──────────────────────────────────────────────────
  static const String dashboard = 'Dashboard';
  static const String products = 'Products';
  static const String vendors = 'Vendors';
  static const String vendorSites = 'Vendor Sites';
  static const String settings = 'Settings';

  // ── Products ───────────────────────────────────────────────────────────────
  static const String productList = 'Products';
  static const String productDetail = 'Product Detail';
  static const String createProduct = 'Create Product';
  static const String editProduct = 'Edit Product';
  static const String productName = 'Product Name';
  static const String productNameHint = 'Enter product name';
  static const String productDescription = 'Description';
  static const String productDescriptionHint = 'Enter product description';
  static const String productPrice = 'Price';
  static const String productPriceHint = 'Enter price';
  static const String productStatus = 'Status';
  static const String productCategory = 'Category';
  static const String productVendor = 'Vendor';
  static const String uploadImage = 'Upload Image';
  static const String deleteProductConfirm =
      'Are you sure you want to delete this product?';

  // ── Product Status Labels ──────────────────────────────────────────────────
  static const String statusActive = 'Active';
  static const String statusInactive = 'Inactive';
  static const String statusDraft = 'Draft';

  // ── Validation ─────────────────────────────────────────────────────────────
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String passwordTooShort =
      'Password must be at least 8 characters';

  // ── Feedback / States ──────────────────────────────────────────────────────
  static const String loading = 'Loading…';
  static const String noData = 'No data available';
  static const String noProducts = 'No products found';
  static const String noVendors = 'No vendors found';
  static const String noVendorSites = 'No vendor sites found';
  static const String somethingWentWrong = 'Something went wrong';
  static const String networkError = 'No internet connection';
  static const String serverError = 'Server error. Please try again later.';
  static const String sessionExpired =
      'Your session has expired. Please log in again.';
  static const String successSaved = 'Saved successfully';
  static const String successDeleted = 'Deleted successfully';
  static const String successCreated = 'Created successfully';
  static const String successUpdated = 'Updated successfully';
}
