import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/config/app_colors.dart';
import '../../core/config/app_text_styles.dart';
import '../../features/auth/domain/entities/role_entity.dart';
import '../../features/auth/presentation/controllers/role_controller.dart';
import 'ios_dashboard_chrome.dart';
import 'premium_motion.dart';

/// Compact role switcher used in content surfaces such as the profile screen.
class RoleSwitcher extends StatelessWidget {
  const RoleSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoleController>(
      builder: (controller) {
        final roles = controller.roles
            .where(
              (r) =>
                  r.name.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '') !=
                  'marketplaceclient',
            )
            .toList();
        final selectedRole = controller.selectedRole.value;

        if (roles.length <= 1) return const SizedBox.shrink();

        final roleName = selectedRole?.name ?? '';
        return IosPressable(
          onTap: () => _showRoleSheet(context, roles, selectedRole),
          scale: 0.96,
          borderRadius: BorderRadius.circular(14),
          child: IosGlass(
            blur: 16,
            borderRadius: BorderRadius.circular(14),
            color: AppColors.surface.withValues(alpha: 0.72),
            borderColor: AppColors.divider.withValues(alpha: 0.56),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIconForRole(roleName),
                    color: _getColorForRole(roleName),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    selectedRole == null
                        ? 'Select Role'
                        : roleDisplayName(roleName),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    CupertinoIcons.chevron_down,
                    color: AppColors.textSecondary,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRoleSheet(
    BuildContext context,
    List<RoleEntity> roles,
    RoleEntity? selectedRole,
  ) {
    showPremiumBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.26),
              blurRadius: 44,
              offset: const Offset(0, -18),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Switch dashboard'.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              ...roles.map((role) {
                final color = _getColorForRole(role.name);
                final isSelected = role.id == selectedRole?.id;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  child: IosPressable(
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await Get.find<RoleController>().setSelectedRole(role);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIconForRole(role.name),
                              color: color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  roleDisplayName(role.name),
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (role.description.isNotEmpty)
                                  Text(
                                    role.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              CupertinoIcons.check_mark_circled_solid,
                              color: color,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: IosPressable(
                  onTap: () => Navigator.pop(sheetContext),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String roleDisplayName(String roleName) {
    final words = roleName
        .trim()
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match[1]} ${match[2]}',
        )
        .split(RegExp(r'[_\s]+'))
        .where((word) => word.isNotEmpty);
    return words
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  static String _roleKey(String roleName) =>
      roleName.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');

  static IconData _getIconForRole(String roleName) {
    switch (_roleKey(roleName)) {
      case 'shopowner':
        return CupertinoIcons.bag_fill;
      case 'shelter':
        return CupertinoIcons.house_fill;
      case 'volunteer':
        return CupertinoIcons.hand_raised_fill;
      case 'animalowner':
        return CupertinoIcons.heart_fill;
      case 'serviceprovider':
        return CupertinoIcons.briefcase_fill;
      default:
        return CupertinoIcons.person_fill;
    }
  }

  static Color _getColorForRole(String roleName) {
    switch (_roleKey(roleName)) {
      case 'shopowner':
        return AppColors.primary;
      case 'shelter':
        return AppColors.success;
      case 'volunteer':
        return AppColors.secondary;
      case 'animalowner':
        return AppColors.accent;
      case 'serviceprovider':
        return AppColors.highlight;
      default:
        return AppColors.slateLight;
    }
  }
}

/// Premium Collapsible Role Switcher
///
/// A semicircular glass wheel that feels like a physical control surface.
/// Uses layered glassmorphism, orbital physics, and choreographed micro-interactions.
class CollapsibleRoleSwitcher extends StatefulWidget {
  const CollapsibleRoleSwitcher({super.key});

  @override
  State<CollapsibleRoleSwitcher> createState() =>
      _CollapsibleRoleSwitcherState();
}

class _CollapsibleRoleSwitcherState extends State<CollapsibleRoleSwitcher>
    with TickerProviderStateMixin {
  // ─── Geometry ───
  static const double _wheelDiameter = 320; // Slightly larger for presence
  static const double _wheelRadius = _wheelDiameter / 2;
  static const double _itemSpacing = 56; // Tighter for density
  static const double _iconCurveRadius = _wheelRadius - 32;
  static const double _handleWidth = 58;
  static const double _handleGap = 10;

  // ─── Animation Controllers ───
  late final AnimationController _openController;
  late final AnimationController _snapController;
  late final AnimationController _ambientController;
  late final AnimationController _breathController;

  // ─── State ───
  bool _isOpen = false;
  double _arcOffset = 0;
  int _initialIndex = 0;
  int _selectedIndex = 0;
  int _lastHapticIndex = -1;

  // ─── Ambient Particles ───
  final List<_AmbientParticle> _particles = List.generate(
    4,
    (i) => _AmbientParticle(
      angle: (i * math.pi / 2) + (math.Random().nextDouble() * 0.5),
      distance: 60 + math.Random().nextDouble() * 80,
      speed: 0.2 + math.Random().nextDouble() * 0.3,
      size: 2.0 + math.Random().nextDouble() * 2.0,
    ),
  );

  @override
  void initState() {
    super.initState();
    _openController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  void _open(List<RoleEntity> roles, RoleEntity selected) {
    _snapController.stop();
    final selectedIndex = roles.indexWhere((role) => role.id == selected.id);
    setState(() {
      _initialIndex = selectedIndex < 0 ? 0 : selectedIndex;
      _selectedIndex = _initialIndex;
      _arcOffset = 0;
      _isOpen = true;
      _lastHapticIndex = -1;
    });
    _openController.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

  void _close() {
    _openController.reverse().whenComplete(() {
      if (mounted) setState(() => _isOpen = false);
    });
    HapticFeedback.lightImpact();
  }

  void _onVerticalDragUpdate(
    DragUpdateDetails details,
    List<RoleEntity> roles,
  ) {
    final minOffset = -_initialIndex * _itemSpacing;
    final maxOffset = (roles.length - 1 - _initialIndex) * _itemSpacing;
    final nextOffset = (_arcOffset + details.delta.dy).clamp(
      minOffset,
      maxOffset,
    );
    final nextIndex = (_initialIndex + nextOffset / _itemSpacing).round().clamp(
      0,
      roles.length - 1,
    );

    // Rhythmic haptic: tick every item, stronger every 3rd
    if (nextIndex != _lastHapticIndex) {
      if (nextIndex % 3 == 0) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.selectionClick();
      }
      _lastHapticIndex = nextIndex;
    }

    setState(() {
      _arcOffset = nextOffset;
      _selectedIndex = nextIndex;
    });
  }

  void _onVerticalDragEnd(List<RoleEntity> roles) {
    final targetOffset = (_selectedIndex - _initialIndex) * _itemSpacing;
    final animation = Tween<double>(begin: _arcOffset, end: targetOffset)
        .animate(
          CurvedAnimation(parent: _snapController, curve: Curves.elasticOut),
        );

    void tick() {
      if (mounted) setState(() => _arcOffset = animation.value);
    }

    animation.addListener(tick);
    _snapController.forward(from: 0).whenComplete(() async {
      animation.removeListener(tick);
      if (!mounted) return;

      final role = roles[_selectedIndex];
      HapticFeedback.heavyImpact();
      _close();
      await Get.find<RoleController>().setSelectedRole(role);
    });
  }

  @override
  void dispose() {
    _openController.dispose();
    _snapController.dispose();
    _ambientController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoleController>(
      builder: (controller) {
        final roles = controller.roles
            .where(
              (r) =>
                  r.name.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '') !=
                  'marketplaceclient',
            )
            .toList();
        if (roles.length <= 1) return const SizedBox.shrink();

        final selected = controller.selectedRole.value ?? roles.first;
        final selectedRole = roles[_selectedIndex.clamp(0, roles.length - 1)];
        final selectedRoleName = RoleSwitcher.roleDisplayName(
          selectedRole.name,
        );
        final accentColor = RoleSwitcher._getColorForRole(selectedRole.name);
        final wheelTop = MediaQuery.paddingOf(context).top + 88;

        return Stack(
          children: [
            // ─── Backdrop with animated blur ───
            if (_isOpen)
              AnimatedBuilder(
                animation: _openController,
                builder: (context, child) {
                  return Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _close,
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(
                          sigmaX: 18 * _openController.value,
                          sigmaY: 18 * _openController.value,
                        ),
                        child: AnimatedOpacity(
                          opacity: 0.22 * _openController.value,
                          duration: Duration.zero,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Colors.black.withValues(alpha: 0.4),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            // ─── Role Tooltip (Glass Tooltip) ───
            AnimatedBuilder(
              animation: _openController,
              builder: (context, child) {
                final slideProgress = Curves.easeOutCubic.transform(
                  _openController.value,
                );
                return Positioned(
                  left: 16,
                  right: _wheelRadius + _handleWidth + _handleGap + 12,
                  top: wheelTop + _wheelDiameter / 2 - 22,
                  child: Transform.translate(
                    offset: Offset(28 * (1 - slideProgress), 0),
                    child: Opacity(opacity: slideProgress, child: child),
                  ),
                );
              },
              child: IgnorePointer(
                child: _RoleTooltip(
                  roleName: selectedRoleName,
                  accentColor: accentColor,
                ),
              ),
            ),

            // ─── The Wheel Assembly ───
            AnimatedBuilder(
              animation: _openController,
              builder: (context, child) {
                final slideProgress = Curves.easeOutCubic.transform(
                  _openController.value,
                );
                final scaleProgress = 0.94 + (0.06 * slideProgress);

                return Positioned(
                  right: -_wheelRadius + (_wheelRadius * slideProgress),
                  top: wheelTop,
                  width: _wheelRadius + _handleWidth + _handleGap,
                  height: _wheelDiameter,
                  child: Transform.scale(
                    scale: scaleProgress,
                    alignment: Alignment.centerRight,
                    child: child,
                  ),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ─── Toggle Handle (Crystal Tab) ───
                  _ToggleHandle(
                    isOpen: _isOpen,
                    accentColor: accentColor,
                    width: _handleWidth,
                    onTap: () => _isOpen ? _close() : _open(roles, selected),
                  ),
                  const SizedBox(width: _handleGap),

                  // ─── The Glass Wheel ───
                  Expanded(
                    child: ClipRect(
                      child: SizedBox(
                        width: _wheelRadius,
                        height: _wheelDiameter,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragUpdate: (details) =>
                              _onVerticalDragUpdate(details, roles),
                          onVerticalDragEnd: (_) => _onVerticalDragEnd(roles),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Layer 1: Deep glass base
                              _GlassDisc(
                                diameter: _wheelDiameter,
                                accentColor: accentColor,
                              ),

                              // Layer 2: Ambient floating particles
                              ..._particles.map(
                                (p) => _AmbientDot(
                                  particle: p,
                                  controller: _ambientController,
                                  wheelRadius: _wheelRadius,
                                ),
                              ),

                              // Layer 3: Role icons on orbital path
                              ...List.generate(roles.length, (index) {
                                return _OrbitalRoleIcon(
                                  index: index,
                                  initialIndex: _initialIndex,
                                  arcOffset: _arcOffset,
                                  itemSpacing: _itemSpacing,
                                  iconCurveRadius: _iconCurveRadius,
                                  wheelRadius: _wheelRadius,
                                  wheelDiameter: _wheelDiameter,
                                  isSelected: index == _selectedIndex,
                                  role: roles[index],
                                  breathController: _breathController,
                                );
                              }),

                              // Layer 4: Selection glow (crescent wrap)
                              _SelectionGlow(
                                wheelDiameter: _wheelDiameter,
                                wheelRadius: _wheelRadius,
                                accentColor: accentColor,
                                isVisible: _isOpen,
                              ),

                              // Layer 5: Edge specular highlight
                              _EdgeHighlight(wheelDiameter: _wheelDiameter),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SUB-WIDGETS
// ─────────────────────────────────────────────────────────────

/// Deep multi-layer glass disc with liquid glass properties
class _GlassDisc extends StatelessWidget {
  final double diameter;
  final Color accentColor;

  const _GlassDisc({required this.diameter, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      width: diameter,
      height: diameter,
      child: ClipOval(
        child: Stack(
          children: [
            // Deep blur base
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment(-0.3, -0.3),
                    radius: 1.2,
                    colors: [
                      Color.lerp(
                        AppColors.primary,
                        Colors.white,
                        0.05,
                      )!.withValues(alpha: 0.85),
                      Color.lerp(
                        AppColors.primary,
                        Colors.black,
                        0.6,
                      )!.withValues(alpha: 0.95),
                    ],
                  ),
                ),
              ),
            ),
            // Inner shadow for depth
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.25),
                  ],
                ),
              ),
            ),
            // Edge light catcher (specular)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.5,
                ),
                gradient: SweepGradient(
                  center: Alignment.center,
                  startAngle: -math.pi / 3,
                  endAngle: math.pi / 6,
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating ambient particle inside the wheel
class _AmbientParticle {
  double angle;
  final double distance;
  final double speed;
  final double size;

  _AmbientParticle({
    required this.angle,
    required this.distance,
    required this.speed,
    required this.size,
  });
}

class _AmbientDot extends StatelessWidget {
  final _AmbientParticle particle;
  final AnimationController controller;
  final double wheelRadius;

  const _AmbientDot({
    required this.particle,
    required this.controller,
    required this.wheelRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = (controller.value * particle.speed) % 1.0;
        final currentAngle = particle.angle + (progress * math.pi * 2);
        final drift = math.sin(progress * math.pi * 4) * 8;

        final x =
            wheelRadius + math.cos(currentAngle) * (particle.distance + drift);
        final y =
            wheelRadius +
            math.sin(currentAngle) * (particle.distance + drift) * 0.6;

        return Positioned(
          left: x - particle.size / 2,
          top: y - particle.size / 2,
          child: Container(
            width: particle.size,
            height: particle.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(
                alpha: 0.08 + (math.sin(progress * math.pi * 2) * 0.04),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Individual role icon positioned on the orbital curve
class _OrbitalRoleIcon extends StatelessWidget {
  final int index;
  final int initialIndex;
  final double arcOffset;
  final double itemSpacing;
  final double iconCurveRadius;
  final double wheelRadius;
  final double wheelDiameter;
  final bool isSelected;
  final RoleEntity role;
  final AnimationController breathController;

  const _OrbitalRoleIcon({
    required this.index,
    required this.initialIndex,
    required this.arcOffset,
    required this.itemSpacing,
    required this.iconCurveRadius,
    required this.wheelRadius,
    required this.wheelDiameter,
    required this.isSelected,
    required this.role,
    required this.breathController,
  });

  @override
  Widget build(BuildContext context) {
    final distanceFromCenter =
        ((index - initialIndex) * itemSpacing) - arcOffset;

    if (distanceFromCenter.abs() > iconCurveRadius) {
      return const SizedBox.shrink();
    }

    // Circle equation: x = r - sqrt(r² - y²)
    final x =
        wheelRadius -
        math.sqrt(
          iconCurveRadius * iconCurveRadius -
              distanceFromCenter * distanceFromCenter,
        );

    final distanceSteps = distanceFromCenter.abs() / itemSpacing;
    final baseOpacity = isSelected
        ? 1.0
        : (0.45 - distanceSteps * 0.12).clamp(0.15, 0.45);

    final color = RoleSwitcher._getColorForRole(role.name);

    return Positioned(
      left: x - (isSelected ? 28 : 20),
      top: wheelDiameter / 2 + distanceFromCenter - (isSelected ? 28 : 20),
      child: AnimatedBuilder(
        animation: breathController,
        builder: (context, child) {
          final breathScale = isSelected
              ? 1.0 + (breathController.value * 0.03)
              : 1.0;

          return Transform.scale(
            scale: breathScale,
            child: AnimatedOpacity(
              opacity: baseOpacity,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              child: AnimatedScale(
                scale: isSelected ? 1.0 : 0.82,
                duration: const Duration(milliseconds: 220),
                curve: isSelected ? Curves.elasticOut : Curves.easeOutCubic,
                child: Container(
                  width: isSelected ? 56 : 40,
                  height: isSelected ? 56 : 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected
                        ? RadialGradient(
                            center: Alignment(-0.2, -0.2),
                            radius: 1.2,
                            colors: [
                              Color.lerp(color, Colors.white, 0.25)!,
                              color,
                              Color.lerp(color, Colors.black, 0.2)!,
                            ],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : Colors.white.withValues(alpha: 0.06),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: 0.08),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            // Outer glow
                            BoxShadow(
                              color: color.withValues(alpha: 0.45),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                            // Inner inset shadow for depth
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(2, 2),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(1, 2),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Icon(
                      RoleSwitcher._getIconForRole(role.name),
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.65),
                      size: isSelected ? 26 : 18,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Crescent-shaped selection glow that wraps the active icon
class _SelectionGlow extends StatelessWidget {
  final double wheelDiameter;
  final double wheelRadius;
  final Color accentColor;
  final bool isVisible;

  const _SelectionGlow({
    required this.wheelDiameter,
    required this.wheelRadius,
    required this.accentColor,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: -2,
      top: wheelDiameter / 2 - 24,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 4,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                accentColor.withValues(alpha: 0),
                accentColor.withValues(alpha: 0.9),
                accentColor.withValues(alpha: 0.9),
                accentColor.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.25, 0.75, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Specular highlight on the wheel's curved edge
class _EdgeHighlight extends StatelessWidget {
  final double wheelDiameter;

  const _EdgeHighlight({required this.wheelDiameter});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      width: wheelDiameter * 0.35,
      height: wheelDiameter * 0.5,
      child: IgnorePointer(
        child: ClipOval(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Crystal toggle handle with gradient and shadow
class _ToggleHandle extends StatelessWidget {
  final bool isOpen;
  final Color accentColor;
  final double width;
  final VoidCallback onTap;

  const _ToggleHandle({
    required this.isOpen,
    required this.accentColor,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
        child: Container(
          width: width,
          height: 94,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(18),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(accentColor, Colors.white, 0.15)!,
                accentColor,
                Color.lerp(accentColor, Colors.black, 0.15)!,
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(-3, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedRotation(
                turns: isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Icon(
                  isOpen
                      ? Icons.chevron_right_rounded
                      : Icons.chevron_left_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ROLES',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Premium glass tooltip for the current role
class _RoleTooltip extends StatelessWidget {
  final String roleName;
  final Color accentColor;

  const _RoleTooltip({required this.roleName, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Color.lerp(
            AppColors.primary,
            Colors.black,
            0.5,
          )!.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: -4,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'CURRENT ROLE',
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              roleName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
                fontSize: 15,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
