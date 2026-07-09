import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../../../shared/widgets/zoovana_app_bar.dart';
import '../../domain/entities/pet_booking_entity.dart';
import '../controllers/pet_owner_controller.dart';

class PetOwnerBookingsScreen extends StatefulWidget {
  const PetOwnerBookingsScreen({super.key});

  @override
  State<PetOwnerBookingsScreen> createState() => _PetOwnerBookingsScreenState();
}

class _PetOwnerBookingsScreenState extends State<PetOwnerBookingsScreen> {
  late final PetOwnerController _controller;
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PetOwnerController>();
    if (_controller.bookingsStatus.value == PetOwnerStatus.idle &&
        _controller.bookings.isEmpty) {
      _controller.loadBookings();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<PetBookingEntity> _visibleBookings(
    List<PetBookingEntity> bookings,
    String filter,
  ) {
    final query = _query.trim().toLowerCase();
    final items = filter == 'all'
        ? bookings
        : bookings.where((booking) => booking.status == filter).toList();
    if (query.isEmpty) return items;
    return items.where((booking) {
      return booking.serviceTitle.toLowerCase().contains(query) ||
          booking.providerName.toLowerCase().contains(query) ||
          (booking.petName?.toLowerCase().contains(query) ?? false) ||
          booking.status.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: const ZoovanaAppBar(title: 'My Bookings', showBack: true),
      body: Column(
        children: [
          const _BookingsHero(),
          _FilterBar(controller: _controller),
          _BookingSearchField(
            controller: _search,
            onChanged: (value) => setState(() => _query = value),
          ),
          Expanded(
            child: Obx(() {
              final status = _controller.bookingsStatus.value;
              final filter = _controller.selectedBookingFilter.value;
              final bookings = _controller.bookings.toList();

              if (status == PetOwnerStatus.loading) {
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, _) =>
                      const SkeletonCard(width: double.infinity, height: 120),
                );
              }
              if (status == PetOwnerStatus.error) {
                return RoleStatePanel(
                  title: 'Bookings are unavailable',
                  message: _controller.errorMessage.value,
                  icon: Icons.cloud_off_outlined,
                  actionLabel: 'Try again',
                  onAction: _controller.loadBookings,
                );
              }
              final items = _visibleBookings(bookings, filter);
              if (items.isEmpty) {
                return _PremiumBookingEmptyState(
                  hasQuery: _query.trim().isNotEmpty,
                  onClear: () {
                    _search.clear();
                    setState(() => _query = '');
                  },
                );
              }
              return RefreshIndicator(
                onRefresh: _controller.loadBookings,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _BookingCard(items[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BookingsHero extends StatelessWidget {
  const _BookingsHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceAtElevation(1),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.24),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bookings',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Manage your pet care journey through every stage.',
                  style: AppTextStyles.bodySmall.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller});

  final PetOwnerController controller;

  @override
  Widget build(BuildContext context) {
    const filters = [
      'all',
      'pending',
      'confirmed',
      'rejected',
      'completed',
      'cancelled',
    ];
    return Container(
      height: 62,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider),
      ),
      child: Obx(() {
        final selectedFilter = controller.selectedBookingFilter.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 4),
          itemBuilder: (context, index) {
            final filter = filters[index];
            final selected = selectedFilter == filter;
            return InkWell(
              onTap: () => controller.selectedBookingFilter.value = filter,
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: selected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.10),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  filter.toUpperCase(),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _BookingSearchField extends StatelessWidget {
  const _BookingSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search provider, pet, status...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard(this.booking);

  final PetBookingEntity booking;

  @override
  Widget build(BuildContext context) {
    final dateLabel = booking.scheduledAt == null
        ? 'Schedule pending'
        : '${_monthName(booking.scheduledAt!.month)} ${booking.scheduledAt!.day}, ${booking.scheduledAt!.year}';

    return Material(
      color: AppColors.surfaceAtElevation(1),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(24),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.providerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            booking.serviceTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _BookingStatus(status: booking.status),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _BookingInfoTile(
                        label: 'Schedule',
                        value: dateLabel,
                        icon: Icons.event_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _BookingInfoTile(
                        label: 'Amount',
                        value: booking.totalLabel ?? '—',
                        icon: Icons.payments_outlined,
                        accent: AppColors.success,
                      ),
                    ),
                  ],
                ),
                if (booking.petName != null && booking.petName!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _BookingInfoTile(
                    label: 'Pet',
                    value: booking.petName!,
                    icon: Icons.cruelty_free_rounded,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }
}

class _BookingInfoTile extends StatelessWidget {
  const _BookingInfoTile({
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
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

class _BookingStatus extends StatelessWidget {
  const _BookingStatus({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final key = status.toLowerCase();
    final color = key == 'confirmed' || key == 'completed'
        ? AppColors.successDark
        : key == 'cancelled' || key == 'rejected'
        ? AppColors.error
        : AppColors.warningDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(key), size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            status.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(String key) {
    if (key == 'confirmed' || key == 'completed') {
      return Icons.check_circle_outline_rounded;
    }
    if (key == 'cancelled' || key == 'rejected') {
      return Icons.cancel_outlined;
    }
    return Icons.pending_actions_rounded;
  }
}

class _PremiumBookingEmptyState extends StatelessWidget {
  const _PremiumBookingEmptyState({
    required this.hasQuery,
    required this.onClear,
  });

  final bool hasQuery;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasQuery ? Icons.search_off_rounded : Icons.event_busy_rounded,
                color: AppColors.textTertiary,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasQuery ? 'No results found' : 'Nothing here yet',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasQuery
                  ? 'Try adjusting your search or filters.'
                  : 'Bookings matching this status will appear here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            if (hasQuery) ...[
              const SizedBox(height: 14),
              TextButton(onPressed: onClear, child: const Text('Clear search')),
            ],
          ],
        ),
      ),
    );
  }
}
