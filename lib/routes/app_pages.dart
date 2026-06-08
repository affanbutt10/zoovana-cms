import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/auth/presentation/bindings/auth_binding.dart';
import '../features/auth/presentation/views/login_view.dart';
import '../features/dashboard/presentation/bindings/dashboard_binding.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/products/presentation/bindings/product_binding.dart';
import '../features/products/presentation/screens/product_detail_screen.dart';
import '../features/products/presentation/screens/product_form_screen.dart';
import '../features/products/presentation/screens/product_list_screen.dart';
import '../features/vendor_sites/presentation/bindings/vendor_site_binding.dart';
import '../features/vendor_sites/presentation/screens/vendor_site_list_screen.dart';
import '../features/vendors/presentation/bindings/vendor_binding.dart';
import '../features/vendors/presentation/screens/vendor_list_screen.dart';
import 'app_routes.dart';

// ---------------------------------------------------------------------------
// Placeholder views
// These will be replaced by the real feature views created in tasks 12–18.
// ---------------------------------------------------------------------------

class _SplashView extends StatelessWidget {
  const _SplashView();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Splash')));
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Settings')));
}

// ---------------------------------------------------------------------------
// Placeholder bindings
// These will be replaced by the real feature bindings created in tasks 12–18.
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Route → View + Binding mapping
// ---------------------------------------------------------------------------

/// Maps every named route to its corresponding View widget and Binding.
///
/// GetX automatically invokes the [Binding] when the route is pushed,
/// lazily registering all feature-level dependencies (Requirement 10.3).
class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const _SplashView(),
      // Splash has no dedicated binding — global DI is already initialised.
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.products,
      page: () => const ProductListScreen(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailScreen(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.productForm,
      page: () => const ProductFormScreen(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.vendors,
      page: () => const VendorListScreen(),
      binding: VendorBinding(),
    ),
    GetPage(
      name: AppRoutes.vendorSites,
      page: () => const VendorSiteListScreen(),
      binding: VendorSiteBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const _SettingsView(),
      // Settings has no dedicated binding yet.
    ),
  ];
}
