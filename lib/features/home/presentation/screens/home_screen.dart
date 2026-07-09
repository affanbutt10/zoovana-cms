import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/app_logo.dart';

// ═══════════════════════════════════════════════════════════════
//  ZOOVANA — HOME SCREEN
//  Design: FLUTTER_HOME_DESIGN_GUIDE.md
//  Sections: Hero · Categories · Featured Pets · Services ·
//            Trust Stats · About · CTA
// ═══════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Hero floating animation
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  // Staggered entrance animation — drives all section reveals
  late final AnimationController _entranceCtrl;

  // Per-section staggered animations (fade + slide-up)
  late final List<Animation<double>> _sectionFade;
  late final List<Animation<Offset>> _sectionSlide;

  // 8 sections: appbar, search, hero, categories, pets, services, stats, about+cta
  static const int _sectionCount = 8;

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  void initState() {
    super.initState();

    // ── Float animation (hero icon) ──────────────────────────
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    // ── Entrance animation ───────────────────────────────────
    // Total duration: 1200ms. Each section gets a 120ms window,
    // staggered by 80ms so they cascade one after another.
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _sectionFade = List.generate(_sectionCount, (i) {
      final start = (i * 0.10).clamp(0.0, 0.85);
      final end = (start + 0.30).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _sectionSlide = List.generate(_sectionCount, (i) {
      final start = (i * 0.10).clamp(0.0, 0.85);
      final end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.18),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    // Small delay so the page transition from splash finishes first,
    // then the content cascades in
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  // Wraps a widget in its staggered fade+slide envelope
  Widget _reveal(int index, Widget child) {
    return FadeTransition(
      opacity: _sectionFade[index],
      child: SlideTransition(position: _sectionSlide[index], child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Silver App Bar ────────────────────────────────
            SliverAppBar(
              pinned: true,
              floating: false,
              snap: false,
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              shadowColor: AppColors.divider,
              elevation: 0,
              scrolledUnderElevation: 1,
              toolbarHeight: 60,
              titleSpacing: 16,
              automaticallyImplyLeading: false,
              title: _reveal(
                0,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLogoTile(size: 34, radius: 10, showShadow: false),
                    const SizedBox(width: 9),
                    Text(
                      'Zoovana',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                _reveal(
                  0,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Notification button
                      Material(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {},
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              size: 19,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Avatar
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.profile),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.primaryGradient,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'J',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textOnPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ],
            ),

            // // ── Search Bar ───────────────────────────────────
            // SliverToBoxAdapter(child: _reveal(1, _SearchBar())),

            // ── Hero ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: _reveal(2, _HeroSection(floatAnim: _floatAnim)),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Categories ───────────────────────────────────
            SliverToBoxAdapter(
              child: _reveal(3, const _SectionHeader(title: 'Categories')),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _reveal(3, _CategoriesRow())),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Featured Pets ────────────────────────────────
            SliverToBoxAdapter(
              child: _reveal(
                4,
                _SectionHeader(
                  title: 'Available Pets',
                  actionText: 'View All',
                  onActionTap: () {},
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverToBoxAdapter(child: _reveal(4, const _FeaturedPets())),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Services 2×2 grid ────────────────────────────
            SliverToBoxAdapter(
              child: _reveal(
                5,
                _SectionHeader(
                  title: 'Our Services',
                  actionText: 'See All',
                  onActionTap: () {},
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverToBoxAdapter(child: _reveal(5, _ServicesGrid())),

            // ── Trust Stats ──────────────────────────────────
            SliverToBoxAdapter(child: _reveal(6, _TrustStats())),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── About ────────────────────────────────────────
            SliverToBoxAdapter(child: _reveal(7, _AboutSection())),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── CTA ──────────────────────────────────────────
            SliverToBoxAdapter(child: _reveal(7, _CTASection())),

            // Bottom nav clearance
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }
}

/* ══════════════════════════════════════════════════════════════ */
/*  APP BAR                                                       */
/* ══════════════════════════════════════════════════════════════ */
/*  HERO SECTION  (300dp, floating icon, single message)         */
/* ══════════════════════════════════════════════════════════════ */

class _HeroSection extends StatelessWidget {
  final Animation<double> floatAnim;
  const _HeroSection({required this.floatAnim});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circle
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            right: -10,
            top: -10,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.08),
              ),
            ),
          ),

          // Floating icon — top right
          Positioned(
            right: 16,
            top: 20,
            child: AnimatedBuilder(
              animation: floatAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, floatAnim.value),
                child: child,
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.pets_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // Text content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'WHERE EVERY PET FINDS LOVE',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Headline
              SizedBox(
                width: 210,
                child: Text(
                  'Welcome to\nZoovana',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 30,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              SizedBox(
                width: 220,
                child: Text(
                  'Find your perfect pet companion. Shop, adopt, and care — all in one place.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.55,
                  ),
                ),
              ),
              const Spacer(),

              // CTA buttons
              Row(
                children: [
                  _PrimaryBtn(label: 'Get Started', onTap: () {}),
                  const SizedBox(width: 10),
                  _OutlineBtn(label: 'Adopt a Pet', onTap: () {}),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ══════════════════════════════════════════════════════════════ */
/*  CATEGORIES ROW                                               */
/* ══════════════════════════════════════════════════════════════ */

class _CategoriesRow extends StatelessWidget {
  static const _cats = [
    _CatData('Adoption', Icons.pets_rounded),
    _CatData('Health', Icons.health_and_safety_rounded),
    _CatData('Shop', Icons.shopping_bag_rounded),
    _CatData('Grooming', Icons.content_cut_rounded),
    _CatData('Donate', Icons.volunteer_activism_rounded),
    _CatData('Lost Pet', Icons.search_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _CategoryChip(data: _cats[i]),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final _CatData data;
  const _CategoryChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.backgroundTint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Icon(data.icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(height: 7),
              Text(
                data.label,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatData {
  final String label;
  final IconData icon;
  const _CatData(this.label, this.icon);
}

/* ══════════════════════════════════════════════════════════════ */
/*  FEATURED PETS  (horizontal swipe, alternating corner radius) */
/* ══════════════════════════════════════════════════════════════ */

class _FeaturedPets extends StatelessWidget {
  const _FeaturedPets();

  static const _pets = [
    _PetData('Emma', 'Unknown Breed', 'Riyadh', Icons.pets_rounded),
    _PetData('Stella', 'Ice Breed', 'Jeddah', Icons.cruelty_free_rounded),
    _PetData('Loki', 'Ragdoll', 'Dammam', Icons.pets_rounded),
    _PetData('Coco', 'Australian Parrot', 'Mecca', Icons.flutter_dash_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _pets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) => _PetCard(data: _pets[i], index: i),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final _PetData data;
  final int index;
  const _PetCard({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    // Alternating corner radius — matches design guide
    final isAlt = index >= 2;
    final br = isAlt
        ? const BorderRadius.only(
            topRight: Radius.circular(72),
            bottomLeft: Radius.circular(72),
            topLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(72),
            bottomRight: Radius.circular(72),
            topRight: Radius.circular(22),
            bottomLeft: Radius.circular(22),
          );

    return Container(
      width: 168,
      decoration: BoxDecoration(
        color: AppColors.surfaceAtElevation(1),
        borderRadius: br,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: isAlt
                  ? const Radius.circular(22)
                  : const Radius.circular(72),
              topRight: isAlt
                  ? const Radius.circular(72)
                  : const Radius.circular(22),
            ),
            child: Container(
              height: 140,
              color: AppColors.backgroundTint,
              child: Center(
                child: Icon(
                  data.icon,
                  size: 56,
                  color: AppColors.primary.withValues(alpha: 0.65),
                ),
              ),
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.breed,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        data.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PetData {
  final String name;
  final String breed;
  final String location;
  final IconData icon;
  const _PetData(this.name, this.breed, this.location, this.icon);
}

/* ══════════════════════════════════════════════════════════════ */
/*  SERVICES  2×2 GRID                                           */
/* ══════════════════════════════════════════════════════════════ */

class _ServicesGrid extends StatelessWidget {
  static const _services = [
    _SvcData(
      'Pet Adoption',
      'Find & adopt your perfect companion',
      Icons.pets_rounded,
    ),
    _SvcData('Pet Care', 'Expert care guidance & tips', Icons.favorite_rounded),
    _SvcData(
      'Pet Shop',
      'Quality supplies & products',
      Icons.shopping_bag_rounded,
    ),
    _SvcData(
      'Pet Health',
      'Medical records & vaccination',
      Icons.health_and_safety_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.0,
        ),
        itemCount: _services.length,
        itemBuilder: (context, i) => _ServiceCard(data: _services[i]),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _SvcData data;
  const _ServiceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceAtElevation(1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.backgroundTint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(data.icon, color: AppColors.primary, size: 26),
              ),
              const SizedBox(height: 14),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SvcData {
  final String title;
  final String subtitle;
  final IconData icon;
  const _SvcData(this.title, this.subtitle, this.icon);
}

/* ══════════════════════════════════════════════════════════════ */
/*  TRUST STATS  (gradient banner)                               */
/* ══════════════════════════════════════════════════════════════ */

class _TrustStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: const [
          Expanded(
            child: _Stat(value: '5K+', label: 'Pets Adopted'),
          ),
          _StatDivider(),
          Expanded(
            child: _Stat(value: '100+', label: 'Active Shelters'),
          ),
          _StatDivider(),
          Expanded(
            child: _Stat(value: '50K+', label: 'Pet Parents'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textOnPrimary.withValues(alpha: 0.80),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.textOnPrimary.withValues(alpha: 0.20),
    );
  }
}

/* ══════════════════════════════════════════════════════════════ */
/*  ABOUT SECTION  (image stacked on top, stats row below)       */
/* ══════════════════════════════════════════════════════════════ */

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image on top — full width
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              width: double.infinity,
              height: 180,
              color: AppColors.backgroundTint,
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    left: 60,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Center(child: Text('🐕🐈', style: TextStyle(fontSize: 72))),
                  // Experience badge
                  Positioned(
                    bottom: 14,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.primaryGradient,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '15 Years of Experience',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Text content below
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KNOW MORE ABOUT US',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Our Passion Is\nSuperior Pet Care',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Zoovana brings pet shopping, veterinary care, grooming, adoption, and donations into one trusted platform — serving pet lovers for over 15 years.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _AboutStat(value: '5K+', label: 'Pets\nAdopted'),
                    _AboutStat(value: '100+', label: 'Active\nShelters'),
                    _AboutStat(value: '50K+', label: 'Pet\nParents'),
                  ],
                ),
                const SizedBox(height: 20),

                // Learn more
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Learn More',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutStat extends StatelessWidget {
  final String value;
  final String label;
  const _AboutStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/* ══════════════════════════════════════════════════════════════ */
/*  CTA SECTION  (gradient card, full-width button)              */
/* ══════════════════════════════════════════════════════════════ */

class _CTASection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.secondaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.group_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Join Our Community',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Connect with pet lovers and expert veterinarians. Get tips, offers, and adoption updates.',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),

          // Full-width white button
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {},
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: Text(
                    'Sign Up Now',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ══════════════════════════════════════════════════════════════ */
/*  SECTION HEADER                                               */
/* ══════════════════════════════════════════════════════════════ */

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Accent bar
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 19,
            ),
          ),
          const Spacer(),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Row(
                children: [
                  Text(
                    actionText!,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/* ══════════════════════════════════════════════════════════════ */
/*  SHARED BUTTONS                                               */
/* ══════════════════════════════════════════════════════════════ */

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.primaryGradient),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
