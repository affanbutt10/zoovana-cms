// Feature: zoovana-mobile-ui
// Requirements: 8.2, 8.3

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_colors.dart';
import '../../core/config/app_text_styles.dart';
import 'ios_dashboard_chrome.dart';
import 'premium_motion.dart';
import 'role_dashboard_drawer.dart';

/// Premium floating bottom navigation bar shell.
///
/// Requirements: 8.2, 8.3
class CustomerBottomNavShell extends StatelessWidget {
  const CustomerBottomNavShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: TweenAnimationBuilder<double>(
        key: ValueKey(navigationShell.currentIndex),
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 350),
        curve: PremiumMotion.curve,
        child: navigationShell,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: FractionalTranslation(
              translation: Offset(0.018 * (1 - value), 0.012 * (1 - value)),
              child: child,
            ),
          );
        },
      ),
      extendBody: true,
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: RoleDashboardDrawerController.isOpen,
        builder: (context, drawerOpen, child) {
          return AnimatedSlide(
            offset: drawerOpen ? const Offset(0, 1.2) : Offset.zero,
            duration: const Duration(milliseconds: 220),
            curve: PremiumMotion.curve,
            child: AnimatedOpacity(
              opacity: drawerOpen ? 0 : 1,
              duration: const Duration(milliseconds: 160),
              curve: PremiumMotion.curve,
              child: IgnorePointer(ignoring: drawerOpen, child: child),
            ),
          );
        },
        child: _PremiumBottomNav(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            HapticFeedback.lightImpact();
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
        ),
      ),
    );
  }
}

class _PremiumBottomNav extends StatefulWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _PremiumBottomNav({required this.currentIndex, required this.onTap});

  @override
  State<_PremiumBottomNav> createState() => _PremiumBottomNavState();
}

class _PremiumBottomNavState extends State<_PremiumBottomNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnims;

  static const _items = [
    _NavItem(
      icon: CupertinoIcons.hand_raised,
      activeIcon: CupertinoIcons.hand_raised_fill,
      label: 'Services',
    ),
    _NavItem(
      icon: CupertinoIcons.heart,
      activeIcon: CupertinoIcons.heart_fill,
      label: 'Adopt',
    ),
    _NavItem(
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      label: 'Home',
    ),
    _NavItem(
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _items.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );
    _scaleAnims = _controllers
        .map(
          (c) => Tween<double>(
            begin: 1.0,
            end: 1.12,
          ).animate(CurvedAnimation(parent: c, curve: PremiumMotion.curve)),
        )
        .toList();
    // Animate initial selected
    _controllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(_PremiumBottomNav old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _controllers[old.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 82,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 18),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.82),
              border: Border(
                top: BorderSide(
                  color: AppColors.divider.withValues(alpha: 0.55),
                ),
              ),
              boxShadow: iosCardShadows(AppColors.primary),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final isSelected = i == widget.currentIndex;
                return IosPressable(
                  onTap: () => widget.onTap(i),
                  scale: 0.90,
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedBuilder(
                    animation: _scaleAnims[i],
                    builder: (context, child) => Transform.scale(
                      scale: isSelected ? _scaleAnims[i].value : 1.0,
                      child: child,
                    ),
                    child: SizedBox(
                      width: 62,
                      height: 56,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            width: isSelected ? 42 : 34,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryGlow.withValues(
                                      alpha: 0.95,
                                    )
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 21,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 10,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
