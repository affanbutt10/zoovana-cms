/// All named route constants for the Zoovana CMS app.
///
/// Use these constants everywhere navigation is needed to avoid
/// hardcoded strings and keep route names in a single source of truth.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String pendingApproval = '/pending-approval';
  static const String roleSelect = '/role-select';
  static const String shopInit = '/shop-init';
  static const String dashboard = '/dashboard';
  static const String shopDashboard = '/shop-dashboard';
  static const String admin = '/admin';

  // Additional routes
  static const String products = '/products';
  static const String productDetail = '/products/detail';
  static const String productForm = '/products/form';
  static const String vendors = '/vendors';
  static const String vendorSites = '/vendor-sites';
  static const String settings = '/settings';

  // New feature routes
  static const String home = '/home';
  static const String donation = '/donation';
  static const String lostFound = '/lost-found';
  static const String profile = '/profile';
  static const String chatInbox = '/messages';
  static const String chatConversation = '/messages/conversation';
  static const String petOwnerDashboard = '/dashboard/pet-owner';
  static const String petOwnerPets = '/dashboard/pet-owner/pets';
  static const String petOwnerServices = '/dashboard/pet-owner/services';
  static const String petOwnerBookings = '/dashboard/pet-owner/bookings';
  static const String petOwnerMessages = '/dashboard/pet-owner/messages';
  static const String legacyPetcare = '/dashboard/petcare';
  static const String providerDashboard = '/dashboard/provider';
  static const String providerServices = '/dashboard/provider/services';
  static const String providerBookings = '/dashboard/provider/bookings';
  static const String providerMessages = '/dashboard/provider/messages';
  static const String providerSettings = '/dashboard/provider/settings';
  static const String volunteerDashboard = '/dashboard/volunteer';
  static const String shelterOverview = '/dashboard/shelters';
  static const String shelterList = '/dashboard/shelters/list';
  static const String shelterAnimals = '/dashboard/shelters/animals';
  static const String shelterMedical = '/dashboard/shelters/medical';
  static const String shelterVaccinations = '/dashboard/shelters/vaccinations';
  static const String shelterKennels = '/dashboard/shelters/kennel-managment';
  static const String shelterAdoptions = '/dashboard/shelters/adoptions';
  static const String shelterVolunteers = '/dashboard/shelters/volunteers';
  static const String shelterDonations = '/dashboard/shelters/donations';
  static const String shelterLostFound = '/dashboard/shelters/lost-found';
  static const String shelterAnimalCare = '/dashboard/shelters/animal-care';
  static const String shelterSettings = '/dashboard/shelters/settings';

  // Dashboard module routes
  static const String moduleBranches = '/dashboard/branches';
  static const String moduleSuppliers = '/dashboard/suppliers';
  static const String moduleCategories = '/dashboard/categories';
  static const String moduleInventory = '/dashboard/inventory';
  static const String modulePurchaseOrders = '/dashboard/purchase-orders';
  static const String moduleOrders = '/dashboard/marketplace-orders';
  static const String moduleInvoices = '/dashboard/invoices';
}
