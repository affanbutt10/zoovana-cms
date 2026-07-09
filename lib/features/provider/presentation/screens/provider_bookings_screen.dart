import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../../../shared/widgets/zoovana_app_bar.dart';
import '../../domain/entities/provider_booking_entity.dart';
import '../controllers/provider_controller.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> {
  late final ProviderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProviderController>();
    if (_controller.bookingsStatus.value == ProviderStatus.idle &&
        _controller.bookings.isEmpty) {
      _controller.loadBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ZoovanaAppBar(title: 'Client Bookings', showBack: true),
      body: Column(
        children: [
          _FilterBar(controller: _controller),
          Expanded(
            child: Obx(() {
              if (_controller.bookingsStatus.value == ProviderStatus.loading) {
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, _) =>
                      const SkeletonCard(width: double.infinity, height: 150),
                );
              }
              if (_controller.bookingsStatus.value == ProviderStatus.error) {
                return RoleStatePanel(
                  title: 'Bookings are unavailable',
                  message: _controller.errorMessage.value,
                  icon: Icons.cloud_off_outlined,
                  actionLabel: 'Try again',
                  onAction: _controller.loadBookings,
                );
              }
              final items = _controller.filteredBookings;
              if (items.isEmpty) {
                return const RoleStatePanel(
                  title: 'No matching bookings',
                  message:
                      'Client requests matching this status will appear here.',
                  icon: Icons.event_busy_rounded,
                );
              }
              return RefreshIndicator(
                onRefresh: _controller.loadBookings,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _BookingCard(
                    booking: items[index],
                    controller: _controller,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller});

  final ProviderController controller;

  @override
  Widget build(BuildContext context) {
    const filters = ['all', 'pending', 'confirmed', 'completed'];
    return SizedBox(
      height: 52,
      child: Obx(
        () => ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = filters[index];
            return ChoiceChip(
              label: Text(filter.capitalizeFirst ?? filter),
              selected: controller.selectedBookingFilter.value == filter,
              onSelected: (_) =>
                  controller.selectedBookingFilter.value = filter,
            );
          },
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.controller});

  final ProviderBookingEntity booking;
  final ProviderController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.serviceTitle,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _BookingStatus(status: booking.status),
            ],
          ),
          Text('${booking.petOwnerName} · ${booking.petName ?? 'Pet'}'),
          if (booking.totalLabel != null) Text(booking.totalLabel!),
          if (booking.status == 'pending') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      if (!await requireAccount(
                        context,
                        action: 'decline a booking',
                      )) {
                        return;
                      }
                      controller.updateBooking(
                        booking: booking,
                        action: 'decline',
                        reason: 'Unavailable',
                      );
                    },
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      if (!await requireAccount(
                        context,
                        action: 'accept a booking',
                      )) {
                        return;
                      }
                      controller.updateBooking(
                        booking: booking,
                        action: 'accept',
                      );
                    },
                    child: const Text('Accept request'),
                  ),
                ),
              ],
            ),
          ] else if (booking.status == 'confirmed') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  if (!await requireAccount(
                    context,
                    action: 'complete a booking',
                  )) {
                    return;
                  }
                  controller.updateBooking(
                    booking: booking,
                    action: 'complete',
                  );
                },
                icon: const Icon(Icons.task_alt_rounded),
                label: const Text('Mark service complete'),
              ),
            ),
          ],
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
        : key == 'rejected' || key == 'cancelled'
        ? AppColors.error
        : AppColors.warningDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
