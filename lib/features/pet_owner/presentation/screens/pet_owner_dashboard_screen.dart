import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/ios_dashboard_chrome.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/role_dashboard_drawer.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/pet_entity.dart';
import '../controllers/pet_owner_controller.dart';

class PetOwnerDashboardScreen extends StatefulWidget {
  const PetOwnerDashboardScreen({super.key});

  @override
  State<PetOwnerDashboardScreen> createState() =>
      _PetOwnerDashboardScreenState();
}

class _PetOwnerDashboardScreenState extends State<PetOwnerDashboardScreen> {
  late final PetOwnerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PetOwnerController>();
    if (_controller.overviewStatus.value == PetOwnerStatus.idle) {
      _controller.loadOverview();
    }
  }

  String get _firstName {
    final name = Get.find<AuthController>().session.value?.user.fullName.trim();
    if (name == null || name.isEmpty) return 'there';
    return name.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      drawer: const RoleDashboardDrawer(),
      onDrawerChanged: RoleDashboardDrawerController.setOpen,
      body: RefreshIndicator(
        onRefresh: _controller.loadOverview,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: buildFrostedAppBarBackground(),
              surfaceTintColor: Colors.transparent,
              leading: Builder(
                builder: (context) => Center(
                  child: IosIconButton(
                    tooltip: 'Open menu',
                    icon: CupertinoIcons.line_horizontal_3,
                    onTap: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
              titleSpacing: 16,
              title: Row(
                children: [
                  const AppLogoTile(size: 32, radius: 8, showShadow: false),
                  const SizedBox(width: 10),
                  Text(
                    'My Zoovana',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              actions: [
                IosIconButton(
                  tooltip: 'Messages',
                  onTap: () => context.push(AppRoutes.chatInbox),
                  icon: CupertinoIcons.chat_bubble_2,
                ),
                const SizedBox(width: 8),
                IosIconButton(
                  tooltip: 'Settings',
                  onTap: () => context.push(AppRoutes.settings),
                  icon: CupertinoIcons.gear,
                ),
                const SizedBox(width: 12),
              ],
            ),
            SliverToBoxAdapter(
              child: Obx(() {
                final status = _controller.overviewStatus.value;
                if (status == PetOwnerStatus.loading) {
                  return const RoleDashboardSkeleton();
                }
                if (status == PetOwnerStatus.error) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 120),
                    child: RoleStatePanel(
                      title: 'Your care hub is unavailable',
                      message: _controller.errorMessage.value.isEmpty
                          ? 'We could not refresh your pet information.'
                          : _controller.errorMessage.value,
                      icon: Icons.cloud_off_outlined,
                      actionLabel: 'Try again',
                      onAction: _controller.loadOverview,
                    ),
                  );
                }

                final overview = _controller.overview.value;
                final pets = overview?.petPreview ?? const <PetEntity>[];
                final petCount = overview?.petCount ?? 0;
                final activeBookings = overview?.activeBookingCount ?? 0;
                final unreadMessages = overview?.unreadMessages ?? 0;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PremiumCareHero(
                        firstName: _firstName,
                        petCount: petCount,
                        activeBookings: activeBookings,
                        unreadMessages: unreadMessages,
                        onFindCare: () =>
                            context.push(AppRoutes.petOwnerServices),
                        onManagePets: () =>
                            context.push(AppRoutes.petOwnerPets),
                      ),
                      const SizedBox(height: 14),
                      SectionHeader(
                        title: 'Quick actions',
                        subtitle: 'Everything your pet care journey needs',
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          SizedBox(
                            height: 88,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _PremiumActionCard(
                                    title: 'Services',
                                    subtitle: 'Browse providers',
                                    icon: Icons.search_rounded,
                                    color: AppColors.primary,
                                    onTap: () => context.push(
                                      AppRoutes.petOwnerServices,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _PremiumActionCard(
                                    title: 'Book Service',
                                    subtitle: 'Schedule visit',
                                    icon: Icons.calendar_month_rounded,
                                    color: AppColors.success,
                                    onTap: () => context.push(
                                      AppRoutes.petOwnerBookings,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const SizedBox(
                            height: 74,
                            child: _PremiumActionCard.dark(
                              title: 'Insurance',
                              subtitle: 'Coming soon',
                              icon: Icons.verified_user_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SectionHeader(
                        title: 'Your companions',
                        subtitle: pets.isEmpty
                            ? 'Create a profile for your first pet'
                            : 'Health and care profiles at a glance',
                        actionLabel: pets.isEmpty ? null : 'View all',
                        onAction: pets.isEmpty
                            ? null
                            : () => context.push(AppRoutes.petOwnerPets),
                      ),
                      const SizedBox(height: 10),
                      if (pets.isEmpty)
                        _EmptyPetsPanel(
                          onCreate: () => context.push(AppRoutes.petOwnerPets),
                        )
                      else
                        ...pets.map((pet) => _PetPreviewCard(pet: pet)),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumCareHero extends StatelessWidget {
  const _PremiumCareHero({
    required this.firstName,
    required this.petCount,
    required this.activeBookings,
    required this.unreadMessages,
    required this.onFindCare,
    required this.onManagePets,
  });

  final String firstName;
  final int petCount;
  final int activeBookings;
  final int unreadMessages;
  final VoidCallback onFindCare;
  final VoidCallback onManagePets;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryLight,
            AppColors.secondary,
            AppColors.secondaryDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -44,
            top: -46,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: -62,
            child: Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.14),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: AppColors.accentLight,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: activeBookings == 0
                                ? AppColors.accentLight
                                : AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          activeBookings == 0
                              ? 'Ready to book'
                              : '$activeBookings active',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'PET CARE DASHBOARD',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.accentLight,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Good to see you, $firstName',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                activeBookings == 0
                    ? 'Your pets, bookings, and trusted services are all gathered in one calm place.'
                    : 'Your active care is easy to track, with pets and providers just a tap away.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.76),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _HeroGlassStat(
                      label: 'Pets',
                      value: '$petCount',
                      icon: CupertinoIcons.heart_fill,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HeroGlassStat(
                      label: 'Bookings',
                      value: '$activeBookings',
                      icon: CupertinoIcons.calendar,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HeroGlassStat(
                      label: 'Messages',
                      value: '$unreadMessages',
                      icon: CupertinoIcons.chat_bubble_2_fill,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onFindCare,
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: const Text('Services'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onManagePets,
                      icon: const Icon(Icons.pets_rounded, size: 18),
                      label: const Text('My pets'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroGlassStat extends StatelessWidget {
  const _HeroGlassStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IosGlass(
      blur: 8,
      borderRadius: BorderRadius.circular(18),
      color: Colors.white.withValues(alpha: 0.09),
      borderColor: Colors.white.withValues(alpha: 0.14),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.86), size: 17),
          const SizedBox(height: 9),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.58),
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumActionCard extends StatelessWidget {
  const _PremiumActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : dark = false;

  const _PremiumActionCard.dark({
    required this.title,
    required this.subtitle,
    required this.icon,
  }) : color = AppColors.secondary,
       onTap = null,
       dark = true;

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : color;
    return Material(
      color: dark ? AppColors.secondaryDark : color.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(22),
      child: IosPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : color.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: foreground, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: dark ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: dark
                            ? Colors.white.withValues(alpha: 0.60)
                            : color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!dark)
                Icon(Icons.arrow_forward_rounded, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPetsPanel extends StatelessWidget {
  const _EmptyPetsPanel({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceAtElevation(1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryGlow,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.pets_rounded, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            'No pets registered yet',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a care profile to make every booking faster.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add pet'),
          ),
        ],
      ),
    );
  }
}

class _PetPreviewCard extends StatelessWidget {
  const _PetPreviewCard({required this.pet});

  final PetEntity pet;

  @override
  Widget build(BuildContext context) {
    final details = [
      pet.species,
      pet.breed,
      pet.ageLabel,
    ].whereType<String>().where((value) => value.isNotEmpty).join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: IosPressable(
          onTap: () => context.push(AppRoutes.petOwnerPets),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.divider.withValues(alpha: .82),
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [...iosCardShadows(AppColors.primary)],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: AppColors.primaryGlow,
                    child: pet.photoUrl == null || pet.photoUrl!.isEmpty
                        ? Icon(
                            Icons.pets_rounded,
                            color: AppColors.primary,
                            size: 26,
                          )
                        : Image.network(
                            pet.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.pets_rounded,
                              color: AppColors.primary,
                              size: 26,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          details,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                      if (pet.healthStatus != null &&
                          pet.healthStatus!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _HealthBadge(status: pet.healthStatus!),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  const _HealthBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = normalized.contains('good') || normalized.contains('healthy')
        ? AppColors.success
        : normalized.contains('due') || normalized.contains('attention')
        ? AppColors.warning
        : AppColors.info;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
