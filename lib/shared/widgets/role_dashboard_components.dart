import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/config/app_colors.dart';
import '../../core/config/app_text_styles.dart';
import 'ios_dashboard_chrome.dart';
import 'skeleton_card.dart';

class RoleDashboardHeader extends StatelessWidget {
  const RoleDashboardHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.primaryAction,
    this.stats = const [],
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Widget? primaryAction;
  final List<RoleHeroStat> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryLight,
            AppColors.secondary,
            AppColors.secondaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -46,
            top: -52,
            child: _AmbientCircle(color: accent, size: 146, alpha: 0.16),
          ),
          Positioned(
            right: 38,
            bottom: -74,
            child: _AmbientCircle(
              color: AppColors.primaryLight,
              size: 128,
              alpha: 0.11,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    child: Icon(icon, color: accent, size: 24),
                  ),
                  const Spacer(),
                  ?primaryAction,
                ],
              ),
              const SizedBox(height: 24),
              Text(
                eyebrow.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textOnSecondary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textOnSecondary.withValues(alpha: 0.76),
                  height: 1.42,
                ),
              ),
              if (stats.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (var i = 0; i < stats.length; i++) ...[
                      Expanded(child: _HeroStatGlass(stat: stats[i])),
                      if (i != stats.length - 1) const SizedBox(width: 8),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class RoleHeroStat {
  const RoleHeroStat({
    required this.label,
    required this.value,
    required this.icon,
    this.detail,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? detail;
}

class _HeroStatGlass extends StatelessWidget {
  const _HeroStatGlass({required this.stat});

  final RoleHeroStat stat;

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
          Icon(
            stat.icon,
            color: Colors.white.withValues(alpha: 0.86),
            size: 17,
          ),
          const SizedBox(height: 9),
          Text(
            stat.label,
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
            stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          if (stat.detail != null) ...[
            const SizedBox(height: 2),
            Text(
              stat.detail!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.66),
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AmbientCircle extends StatelessWidget {
  const _AmbientCircle({
    required this.color,
    required this.size,
    required this.alpha,
  });

  final Color color;
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: alpha),
      ),
    );
  }
}

class RoleMetricTile extends StatelessWidget {
  const RoleMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: IosPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(minHeight: 128),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider.withValues(alpha: .82)),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [...iosCardShadows(color)],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 100;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: compact ? 28 : 38,
                        height: compact ? 28 : 38,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.11),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: compact ? 16 : 20,
                        ),
                      ),
                      const Spacer(),
                      if (trend != null && trend!.isNotEmpty)
                        Text(
                          trend!,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: compact ? 0 : 14),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (compact
                                ? AppTextStyles.titleMedium
                                : AppTextStyles.headlineSmall)
                            .copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class RoleQuickAction extends StatelessWidget {
  const RoleQuickAction({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: IosPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider.withValues(alpha: .82)),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [...iosCardShadows(color)],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_forward,
                color: AppColors.textTertiary,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleStatePanel extends StatelessWidget {
  const RoleStatePanel({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceAtElevation(1),
        border: Border.all(color: AppColors.divider.withValues(alpha: .82)),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 36),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(height: 1.45),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(CupertinoIcons.arrow_right, size: 18),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class RoleDashboardSkeleton extends StatelessWidget {
  const RoleDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonCard(width: double.infinity, height: 190),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: SkeletonCard(width: double.infinity, height: 112),
              ),
              SizedBox(width: 8),
              Expanded(
                child: SkeletonCard(width: double.infinity, height: 112),
              ),
              SizedBox(width: 8),
              Expanded(
                child: SkeletonCard(width: double.infinity, height: 112),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SkeletonLine(width: 130, height: 18),
          const SizedBox(height: 12),
          const SkeletonCard(width: double.infinity, height: 72),
          const SizedBox(height: 10),
          const SkeletonCard(width: double.infinity, height: 72),
          const SizedBox(height: 24),
          const SkeletonLine(width: 100, height: 18),
          const SizedBox(height: 12),
          const SkeletonCard(width: double.infinity, height: 88),
        ],
      ),
    );
  }
}
