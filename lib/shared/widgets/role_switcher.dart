import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/config/app_colors.dart';
import '../../core/config/app_text_styles.dart';
import '../../features/auth/domain/entities/role_entity.dart';
import '../../features/auth/presentation/controllers/role_controller.dart';

/// Role Switcher Widget
/// 
/// Displays a dropdown or bottom sheet allowing users with multiple roles
/// to switch between them. The active role determines which dashboard and
/// features are visible.
class RoleSwitcher extends StatelessWidget {
  const RoleSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoleController>(
      builder: (roleController) {
        final roles = roleController.roles;
        final selectedRole = roleController.selectedRole.value;

        // Don't show switcher if user has only one role
        if (roles.length <= 1) {
          return const SizedBox.shrink();
        }

        return Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showRoleSwitcherSheet(context, roles, selectedRole),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getIconForRole(selectedRole?.name ?? ''),
                      color: _getColorForRole(selectedRole?.name ?? ''),
                      size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _capitalize(selectedRole?.name ?? 'Select Role'),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down_rounded,
                      color: AppColors.textSecondary, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRoleSwitcherSheet(
    BuildContext context,
    List<RoleEntity> roles,
    RoleEntity? selectedRole,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('Switch Role',
                        style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800)),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Role list
              ...roles.map((role) {
                final isSelected = role.id == selectedRole?.id;
                return _RoleOption(
                  role: role,
                  isSelected: isSelected,
                  onTap: () {
                    Get.find<RoleController>().setSelectedRole(role);
                    Navigator.pop(context);
                  },
                );
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForRole(String roleName) {
    final key = roleName.toLowerCase().replaceAll(' ', '_');
    switch (key) {
      case 'shop_owner':
        return Icons.storefront_rounded;
      case 'shelter':
        return Icons.home_rounded;
      case 'volunteer':
        return Icons.volunteer_activism_rounded;
      case 'animalowner':
        return Icons.pets_rounded;
      case 'serviceprovider':
        return Icons.medical_services_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color _getColorForRole(String roleName) {
    final key = roleName.toLowerCase().replaceAll(' ', '_');
    switch (key) {
      case 'shop_owner':
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

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _RoleOption extends StatelessWidget {
  final RoleEntity role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForRole(role.name);
    final icon = _getIconForRole(role.name);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.08)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? color : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_capitalize(role.name),
                        style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700)),
                    if (role.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(role.description,
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForRole(String roleName) {
    final key = roleName.toLowerCase().replaceAll(' ', '_');
    switch (key) {
      case 'shop_owner':
        return Icons.storefront_rounded;
      case 'shelter':
        return Icons.home_rounded;
      case 'volunteer':
        return Icons.volunteer_activism_rounded;
      case 'animalowner':
        return Icons.pets_rounded;
      case 'serviceprovider':
        return Icons.medical_services_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color _getColorForRole(String roleName) {
    final key = roleName.toLowerCase().replaceAll(' ', '_');
    switch (key) {
      case 'shop_owner':
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

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
