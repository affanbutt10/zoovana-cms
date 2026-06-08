import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../auth/domain/entities/role_entity.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/role_controller.dart';

// ═══════════════════════════════════════════════════════════════
//  ROLE SELECT SCREEN
//  Mirrors the website's "Who are you?" registration step.
//  Shows all available roles as tappable cards in a 2-column grid.
//  Single-select — tapping a card immediately selects it and
//  enables the Continue button.
// ═══════════════════════════════════════════════════════════════

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  RoleEntity? _selected;

  // ── Role metadata — icon, color, description per role name ───────────────

  static const _meta = <String, _RoleMeta>{
    'shop_owner': _RoleMeta(
      label: 'Shop Owner',
      description: 'Shop owner with full access to their shop',
      icon: Icons.storefront_rounded,
      color: AppColors.primary,
    ),
    'shelter': _RoleMeta(
      label: 'Shelter',
      description: 'Premium Pet Shelter',
      icon: Icons.home_rounded,
      color: AppColors.success,
    ),
    'volunteer': _RoleMeta(
      label: 'Volunteer',
      description: 'Apply for the job in Shelter',
      icon: Icons.volunteer_activism_rounded,
      color: AppColors.secondary,
    ),
    'animalowner': _RoleMeta(
      label: 'Animal Owner',
      description: 'Provides daily care for pets',
      icon: Icons.pets_rounded,
      color: AppColors.accent,
    ),
    'serviceprovider': _RoleMeta(
      label: 'Service Provider',
      description: 'A provider offering pet care services',
      icon: Icons.medical_services_rounded,
      color: AppColors.highlight,
    ),
    'user': _RoleMeta(
      label: 'User',
      description: 'Default role for new users',
      icon: Icons.person_rounded,
      color: AppColors.slateLight,
    ),
  };

  _RoleMeta _metaFor(RoleEntity role) {
    final key = role.name.toLowerCase().replaceAll(' ', '_');
    return _meta[key] ??
        _RoleMeta(
          label: _capitalize(role.name),
          description: role.scope,
          icon: Icons.badge_rounded,
          color: AppColors.primary,
        );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Future<void> _onContinue() async {
    if (_selected == null) return;
    await Get.find<RoleController>().setSelectedRole(_selected!);
    // RouterNotifier will fire and redirect to the correct screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundTint,
      body: SafeArea(
        child: GetBuilder<RoleController>(
          builder: (roleController) {
            // Show the user's assigned roles (from login response).
            // If empty, fall back to all platform roles.
            final roles = roleController.roles.isNotEmpty
                ? roleController.roles
                : roleController.allRoles;

            return Column(
              children: [
                // ── Header ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Column(
                    children: [
                      // Logo + brand
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppLogoTile(
                              size: 36, radius: 10, showShadow: false),
                          const SizedBox(width: 10),
                          Text(
                            'Zoovana',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome to Zoovana',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🐾', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            'Who are you?',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('👋', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Role grid ────────────────────────────────
                Expanded(
                  child: roles.isEmpty
                      ? Center(
                          child: Text(
                            'No roles available.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.05,
                          ),
                          itemCount: roles.length,
                          itemBuilder: (context, i) {
                            final role = roles[i];
                            final meta = _metaFor(role);
                            final isSelected = _selected?.id == role.id;
                            return _RoleCard(
                              role: role,
                              meta: meta,
                              isSelected: isSelected,
                              onTap: () => setState(() => _selected = role),
                            );
                          },
                        ),
                ),

                // ── Footer ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    children: [
                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _selected != null ? _onContinue : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.35),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded,
                                  size: 18, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Select one role to continue',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Sign out link
                      TextButton(
                        onPressed: () async {
                          await Get.find<AuthController>().logout();
                        },
                        child: Text(
                          'Sign out',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ROLE CARD
// ─────────────────────────────────────────────────────────────

class _RoleCard extends StatefulWidget {
  final RoleEntity role;
  final _RoleMeta meta;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.meta,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.isSelected;
    final color = widget.meta.color;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.08)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? color : AppColors.divider,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // Selected checkmark badge
              if (selected)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),

              // Card content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon container
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(widget.meta.icon, color: color, size: 26),
                    ),
                    const SizedBox(height: 12),
                    // Role label
                    Text(
                      widget.meta.label,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: selected ? color : AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      widget.meta.description,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ROLE METADATA
// ─────────────────────────────────────────────────────────────

class _RoleMeta {
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const _RoleMeta({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
}
