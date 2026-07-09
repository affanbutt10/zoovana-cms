import 'package:flutter_test/flutter_test.dart';
import 'package:zoovana_cms/features/auth/presentation/controllers/auth_controller.dart';
import 'package:zoovana_cms/features/shop/presentation/controllers/shop_init_controller.dart';
import 'package:zoovana_cms/routes/app_routes.dart';
import 'package:zoovana_cms/routes/redirect_logic.dart';

void main() {
  String? redirect(String location) {
    return computeRedirect(
      location: location,
      authStatus: AuthStatus.unauthenticated,
      session: null,
      roles: const [],
      selectedRole: null,
      shopInitStatus: ShopInitStatus.idle,
    );
  }

  const loginRequired = '/login?reason=account_required';

  test('guests can browse only Home', () {
    expect(redirect(AppRoutes.home), isNull);
  });

  test('guests are redirected from all other app routes', () {
    expect(redirect(AppRoutes.donation), loginRequired);
    expect(redirect(AppRoutes.lostFound), loginRequired);
    expect(redirect(AppRoutes.dashboard), loginRequired);
    expect(redirect(AppRoutes.profile), loginRequired);
    expect(redirect(AppRoutes.petOwnerDashboard), loginRequired);
    expect(redirect(AppRoutes.providerDashboard), loginRequired);
    expect(redirect(AppRoutes.shelterOverview), loginRequired);
    expect(redirect(AppRoutes.volunteerDashboard), loginRequired);
    expect(redirect(AppRoutes.chatInbox), loginRequired);
    expect(redirect(AppRoutes.products), loginRequired);
    expect(redirect(AppRoutes.admin), loginRequired);
    expect(redirect(AppRoutes.shopInit), loginRequired);
    expect(redirect(AppRoutes.roleSelect), loginRequired);
  });
}
