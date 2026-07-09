import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_colors.dart';
import '../../core/config/app_text_styles.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/controllers/role_controller.dart';
import '../../routes/app_routes.dart';
import 'app_logo.dart';

class RoleDashboardDrawerController {
  RoleDashboardDrawerController._();

  static final ValueNotifier<bool> isOpen = ValueNotifier<bool>(false);

  static void setOpen(bool value) {
    if (isOpen.value == value) return;
    isOpen.value = value;
  }
}

class RoleDashboardDrawer extends StatelessWidget {
  const RoleDashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final roleController = Get.find<RoleController>();

    return Obx(() {
      final user = authController.session.value?.user;
      final role =
          roleController.selectedRole.value ??
          (user?.roles.isNotEmpty == true ? user!.roles.first : null);
      final roleName = role?.name ?? 'Member';
      final sections = _sectionsForRole(roleName);
      final currentPath = GoRouterState.of(context).uri.path;
      var animationIndex = 0;

      return Drawer(
        width: 320,
        backgroundColor: AppColors.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AnimatedDrawerEntry(
                index: animationIndex++,
                child: _DrawerHero(
                  brandName: 'Zoovana',
                  displayName: user?.fullName ?? _displayRoleName(roleName),
                  roleLabel: _displayRoleName(roleName),
                  roleIcon: _iconForRole(roleName),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  children: [
                    for (final section in sections) ...[
                      _AnimatedDrawerEntry(
                        index: animationIndex++,
                        child: _SectionLabel(section.label),
                      ),
                      _DrawerCard(
                        children: [
                          for (var i = 0; i < section.items.length; i++) ...[
                            _AnimatedDrawerEntry(
                              index: animationIndex++,
                              child: _DrawerTile(
                                icon: section.items[i].icon,
                                label: section.items[i].label,
                                route: section.items[i].route,
                                selected: section.items[i].matches(currentPath),
                              ),
                            ),
                            if (i != section.items.length - 1)
                              Divider(
                                height: 1,
                                indent: 58,
                                color: AppColors.divider.withValues(alpha: 0.6),
                              ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.divider.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: _DrawerCard(
                  children: [
                    _AnimatedDrawerEntry(
                      index: animationIndex++,
                      child: _DrawerTile(
                        icon: Icons.logout_rounded,
                        label: 'Sign out',
                        destructive: true,
                        onTap: () {
                          Navigator.of(context).pop();
                          authController.logout();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static IconData _iconForRole(String roleName) {
    switch (_roleKey(roleName)) {
      case 'petowner':
      case 'petcare':
      case 'animalowner':
      case 'marketplaceclient':
        return Icons.pets_rounded;
      case 'provider':
      case 'serviceprovider':
        return Icons.medical_services_rounded;
      case 'volunteer':
        return Icons.volunteer_activism_rounded;
      case 'shelter':
      case 'shelterowner':
        return Icons.home_work_rounded;
      case 'shopowner':
        return Icons.storefront_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  static List<_DrawerSection> _sectionsForRole(String roleName) {
    switch (_roleKey(roleName)) {
      case 'petowner':
      case 'petcare':
      case 'animalowner':
      case 'marketplaceclient':
        return const [
          _DrawerSection(
            label: 'Overview',
            items: [
              _DrawerRouteItem(
                icon: Icons.trending_up_rounded,
                label: 'Overview',
                route: AppRoutes.dashboard,
                matchRoutes: [AppRoutes.dashboard, AppRoutes.petOwnerDashboard],
              ),
            ],
          ),
          _DrawerSection(
            label: 'Pet care',
            items: [
              _DrawerRouteItem(
                icon: Icons.pets_rounded,
                label: 'My Pets',
                route: AppRoutes.petOwnerPets,
              ),
              _DrawerRouteItem(
                icon: Icons.search_rounded,
                label: 'Find Services',
                route: AppRoutes.petOwnerServices,
              ),
              _DrawerRouteItem(
                icon: Icons.calendar_month_rounded,
                label: 'Book Service',
                route: AppRoutes.petOwnerBookings,
              ),
            ],
          ),
          _DrawerSection(
            label: 'Communication',
            items: [
              _DrawerRouteItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Messages',
                route: AppRoutes.chatInbox,
              ),
            ],
          ),
        ];
      case 'provider':
      case 'serviceprovider':
        return const [
          _DrawerSection(
            label: 'Overview',
            items: [
              _DrawerRouteItem(
                icon: Icons.trending_up_rounded,
                label: 'Overview',
                route: AppRoutes.dashboard,
                matchRoutes: [AppRoutes.dashboard, AppRoutes.providerDashboard],
              ),
            ],
          ),
          _DrawerSection(
            label: 'Services',
            items: [
              _DrawerRouteItem(
                icon: Icons.content_cut_rounded,
                label: 'My Services',
                route: AppRoutes.providerServices,
              ),
              _DrawerRouteItem(
                icon: Icons.calendar_month_rounded,
                label: 'Bookings',
                route: AppRoutes.providerBookings,
              ),
            ],
          ),
          _DrawerSection(
            label: 'Communication',
            items: [
              _DrawerRouteItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Messages',
                route: AppRoutes.chatInbox,
              ),
            ],
          ),
        ];
      case 'volunteer':
        return const [
          _DrawerSection(
            label: 'Volunteer',
            items: [
              _DrawerRouteItem(
                icon: Icons.fact_check_rounded,
                label: 'My Shifts',
                route: AppRoutes.dashboard,
                matchRoutes: [
                  AppRoutes.dashboard,
                  AppRoutes.volunteerDashboard,
                ],
              ),
              _DrawerRouteItem(
                icon: Icons.send_rounded,
                label: 'Apply',
                route: AppRoutes.volunteerDashboard,
              ),
            ],
          ),
        ];
      case 'shelter':
      case 'shelterowner':
        return const [
          _DrawerSection(
            label: 'Overview',
            items: [
              _DrawerRouteItem(
                icon: Icons.trending_up_rounded,
                label: 'Overview',
                route: AppRoutes.dashboard,
                matchRoutes: [AppRoutes.dashboard, AppRoutes.shelterOverview],
              ),
            ],
          ),
          _DrawerSection(
            label: 'Care operations',
            items: [
              _DrawerRouteItem(
                icon: Icons.business_rounded,
                label: 'Shelters',
                route: AppRoutes.shelterList,
              ),
              _DrawerRouteItem(
                icon: Icons.pets_rounded,
                label: 'Animals',
                route: AppRoutes.shelterAnimals,
              ),
              _DrawerRouteItem(
                icon: Icons.medical_services_rounded,
                label: 'Medical',
                route: AppRoutes.shelterMedical,
              ),
              _DrawerRouteItem(
                icon: Icons.calendar_month_rounded,
                label: 'Vaccinations',
                route: AppRoutes.shelterVaccinations,
              ),
              _DrawerRouteItem(
                icon: Icons.apartment_rounded,
                label: 'Kennel Management',
                route: AppRoutes.shelterKennels,
              ),
              _DrawerRouteItem(
                icon: Icons.monitor_heart_outlined,
                label: 'Animal Care',
                route: AppRoutes.shelterAnimalCare,
              ),
            ],
          ),
          _DrawerSection(
            label: 'Community',
            items: [
              _DrawerRouteItem(
                icon: Icons.favorite_border_rounded,
                label: 'Adoptions',
                route: AppRoutes.shelterAdoptions,
              ),
              _DrawerRouteItem(
                icon: Icons.groups_rounded,
                label: 'Volunteers',
                route: AppRoutes.shelterVolunteers,
              ),
              _DrawerRouteItem(
                icon: Icons.volunteer_activism_rounded,
                label: 'Donations',
                route: AppRoutes.shelterDonations,
              ),
              _DrawerRouteItem(
                icon: Icons.location_on_outlined,
                label: 'Lost & Found',
                route: AppRoutes.shelterLostFound,
              ),
            ],
          ),
        ];
      case 'shopowner':
        return const [
          _DrawerSection(
            label: 'Overview',
            items: [
              _DrawerRouteItem(
                icon: Icons.trending_up_rounded,
                label: 'Overview',
                route: AppRoutes.dashboard,
              ),
            ],
          ),
          _DrawerSection(
            label: 'Catalog',
            items: [
              _DrawerRouteItem(
                icon: Icons.storefront_rounded,
                label: 'Branches',
                route: AppRoutes.moduleBranches,
              ),
              _DrawerRouteItem(
                icon: Icons.sell_outlined,
                label: 'Categories',
                route: AppRoutes.moduleCategories,
              ),
              _DrawerRouteItem(
                icon: Icons.inventory_2_outlined,
                label: 'Products',
                route: AppRoutes.products,
              ),
              _DrawerRouteItem(
                icon: Icons.inventory_2_rounded,
                label: 'Inventory',
                route: AppRoutes.moduleInventory,
              ),
            ],
          ),
          _DrawerSection(
            label: 'Purchasing',
            items: [
              _DrawerRouteItem(
                icon: Icons.local_shipping_outlined,
                label: 'Suppliers',
                route: AppRoutes.moduleSuppliers,
              ),
              _DrawerRouteItem(
                icon: Icons.description_outlined,
                label: 'Purchase Orders',
                route: AppRoutes.modulePurchaseOrders,
              ),
            ],
          ),
          _DrawerSection(
            label: 'Marketplace',
            items: [
              _DrawerRouteItem(
                icon: Icons.shopping_cart_outlined,
                label: 'Marketplace Orders',
                route: AppRoutes.moduleOrders,
              ),
              _DrawerRouteItem(
                icon: Icons.receipt_long_outlined,
                label: 'Marketplace Invoices',
                route: AppRoutes.moduleInvoices,
              ),
            ],
          ),
          _DrawerSection(
            label: 'Integrations',
            items: [
              _DrawerRouteItem(
                icon: Icons.code_rounded,
                label: 'Developer API',
              ),
            ],
          ),
        ];
      default:
        return const [
          _DrawerSection(
            label: 'Main',
            items: [
              _DrawerRouteItem(
                icon: Icons.home_rounded,
                label: 'Home Page',
                route: AppRoutes.dashboard,
              ),
              _DrawerRouteItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Messages',
                route: AppRoutes.chatInbox,
              ),
            ],
          ),
        ];
    }
  }

  static String _roleKey(String roleName) =>
      roleName.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');

  static String _displayRoleName(String roleName) {
    final clean = roleName.replaceAll('_', ' ').trim();
    if (clean.isEmpty) return 'Member';
    return clean
        .split(RegExp(r'\s+'))
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class _AnimatedDrawerEntry extends StatelessWidget {
  const _AnimatedDrawerEntry({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: 260 + (index * 22).clamp(0, 180));
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(-18 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// Hero header at the top of the drawer: soft tinted background,
/// brand mark, and a role-accented identity block.
class _DrawerHero extends StatelessWidget {
  const _DrawerHero({
    required this.brandName,
    required this.displayName,
    required this.roleLabel,
    required this.roleIcon,
  });

  final String brandName;
  final String displayName;
  final String roleLabel;
  final IconData roleIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.background,
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.divider.withValues(alpha: 0.6)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppLogoTile(size: 34, radius: 11, showShadow: false),
              const SizedBox(width: 10),
              Text(
                brandName,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                child: Icon(roleIcon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      roleLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Rounded, bordered, shadowed card wrapper used to group drawer tiles.
class _DrawerCard extends StatelessWidget {
  const _DrawerCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    this.route,
    this.selected = false,
    this.destructive = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? route;
  final bool selected;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = route != null || onTap != null;
    final color = destructive
        ? AppColors.error
        : selected
        ? AppColors.primary
        : enabled
        ? AppColors.textPrimary
        : AppColors.textTertiary;

    final chipColor = destructive
        ? AppColors.error.withValues(alpha: 0.12)
        : selected
        ? AppColors.primary.withValues(alpha: 0.16)
        : AppColors.textTertiary.withValues(alpha: 0.10);

    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.06)
          : Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? onTap ??
                  () {
                    Navigator.of(context).pop();
                    final target = route;
                    if (target == null) return;
                    if (target == AppRoutes.dashboard ||
                        target == AppRoutes.profile) {
                      context.go(target);
                    } else {
                      context.push(target);
                    }
                  }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              if (enabled && route != null)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textTertiary.withValues(alpha: 0.6),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerRouteItem {
  const _DrawerRouteItem({
    required this.icon,
    required this.label,
    this.route,
    this.matchRoutes = const [],
  });

  final IconData icon;
  final String label;
  final String? route;
  final List<String> matchRoutes;

  bool matches(String currentPath) {
    if (route != null && currentPath == route) return true;
    return matchRoutes.contains(currentPath);
  }
}

class _DrawerSection {
  const _DrawerSection({required this.label, required this.items});

  final String label;
  final List<_DrawerRouteItem> items;
}
