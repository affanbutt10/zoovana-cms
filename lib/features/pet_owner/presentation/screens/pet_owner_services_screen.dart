import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/premium_motion.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../../../shared/widgets/zoovana_app_bar.dart';
import '../../data/models/pet_booking_model.dart';
import '../../domain/entities/pet_service_entity.dart';
import '../controllers/pet_owner_controller.dart';

class PetOwnerServicesScreen extends StatefulWidget {
  const PetOwnerServicesScreen({super.key});

  @override
  State<PetOwnerServicesScreen> createState() => _PetOwnerServicesScreenState();
}

class _PetOwnerServicesScreenState extends State<PetOwnerServicesScreen> {
  late final PetOwnerController _controller;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PetOwnerController>();
    if (_controller.servicesStatus.value == PetOwnerStatus.idle) {
      _controller.loadServices();
    }
    if (_controller.pets.isEmpty) _controller.loadPets();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: const ZoovanaAppBar(title: 'Services', showBack: true),
      body: Column(
        children: [
          _FindCareHeader(
            search: _search,
            onSubmitted: (value) =>
                _controller.loadServices(query: value.trim()),
          ),
          Expanded(
            child: Obx(() {
              if (_controller.servicesStatus.value == PetOwnerStatus.loading) {
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, _) =>
                      const SkeletonCard(width: double.infinity, height: 150),
                );
              }
              if (_controller.servicesStatus.value == PetOwnerStatus.error) {
                return RoleStatePanel(
                  title: 'Care providers are unavailable',
                  message: _controller.errorMessage.value,
                  icon: Icons.error_outline_rounded,
                  actionLabel: 'Try again',
                  onAction: _controller.loadServices,
                );
              }
              if (_controller.services.isEmpty) {
                return _NoServicesState(
                  onClear: () {
                    _search.clear();
                    _controller.loadServices();
                  },
                );
              }
              return RefreshIndicator(
                onRefresh: () => _controller.loadServices(query: _search.text),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  itemCount: _controller.services.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final service = _controller.services[index];
                    return _ServiceCard(
                      service: service,
                      onBook: () => _showBookingSheet(context, service),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showBookingSheet(BuildContext context, PetServiceEntity service) {
    showPremiumBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _BookingSheet(controller: _controller, service: service),
    );
  }
}

class _FindCareHeader extends StatelessWidget {
  const _FindCareHeader({required this.search, required this.onSubmitted});

  final TextEditingController search;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAtElevation(1),
        borderRadius: BorderRadius.circular(28),
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
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryGlow,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.search_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find Services',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Boarding, grooming, daycare and walking.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundAlt,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
            ),
            child: TextField(
              controller: search,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search boarding, grooming, walking',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.textTertiary,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    search.clear();
                    onSubmitted('');
                  },
                  icon: Icon(Icons.tune_rounded, color: AppColors.primary),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onBook});

  final PetServiceEntity service;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAtElevation(1),
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _ServicePhoto(url: service.photoUrl),
                if (service.rating != null)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: _RatingBadge(rating: service.rating!),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    service.providerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (service.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      service.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ServiceMetaChip(
                        icon: Icons.sell_outlined,
                        label: service.priceLabel ?? 'Price on request',
                        color: AppColors.success,
                      ),
                      if (service.serviceType != null)
                        _ServiceMetaChip(
                          icon: Icons.pets_outlined,
                          label: service.serviceType!,
                          color: AppColors.primary,
                        ),
                      if (service.locationLabel != null)
                        _ServiceMetaChip(
                          icon: Icons.location_on_outlined,
                          label: service.locationLabel!,
                          color: AppColors.accentDark,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onBook,
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('Details'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onBook,
                          icon: const Icon(
                            Icons.event_available_rounded,
                            size: 18,
                          ),
                          label: const Text('Request'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicePhoto extends StatelessWidget {
  const _ServicePhoto({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 156,
      width: double.infinity,
      child: url == null
          ? Container(
              color: AppColors.primaryGlow,
              child: Icon(
                Icons.home_work_outlined,
                color: AppColors.primary,
                size: 42,
              ),
            )
          : Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.primaryGlow,
                child: Icon(
                  Icons.home_work_outlined,
                  color: AppColors.primary,
                  size: 42,
                ),
              ),
            ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 16, color: AppColors.highlightDark),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceMetaChip extends StatelessWidget {
  const _ServiceMetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoServicesState extends StatelessWidget {
  const _NoServicesState({required this.onClear});

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
                Icons.search_off_rounded,
                color: AppColors.textTertiary,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No matching services found',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a broader search or clear filters to browse all providers.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 14),
            TextButton(onPressed: onClear, child: const Text('Clear search')),
          ],
        ),
      ),
    );
  }
}

class _BookingSheet extends StatefulWidget {
  const _BookingSheet({required this.controller, required this.service});

  final PetOwnerController controller;
  final PetServiceEntity service;

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  String? _petId;
  DateTime _requestedAt = DateTime.now().add(const Duration(days: 1));
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!await requireAccount(context, action: 'request a booking')) return;
    if (_petId == null) return;
    final ok = await widget.controller.requestNewBooking(
      BookingRequest(
        serviceId: widget.service.id,
        petId: _petId!,
        requestedAt: _requestedAt,
        notes: _notes.text.trim(),
      ),
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final pets = widget.controller.pets;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Request care', style: AppTextStyles.titleLarge),
          const SizedBox(height: 4),
          Text(
            '${widget.service.title} with ${widget.service.providerName}',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _petId,
            decoration: const InputDecoration(labelText: 'Pet'),
            items: pets
                .map(
                  (pet) =>
                      DropdownMenuItem(value: pet.id, child: Text(pet.name)),
                )
                .toList(),
            onChanged: (value) => setState(() => _petId = value),
          ),
          const SizedBox(height: 10),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Requested date'),
            subtitle: Text(
              '${_requestedAt.year}-${_requestedAt.month}-${_requestedAt.day}',
            ),
            trailing: const Icon(Icons.calendar_month_rounded),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDate: _requestedAt,
              );
              if (picked != null) setState(() => _requestedAt = picked);
            },
          ),
          TextField(
            controller: _notes,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: Obx(() {
              final loading =
                  widget.controller.mutationStatus.value ==
                  PetOwnerMutationStatus.loading;
              return FilledButton.icon(
                onPressed: loading || _petId == null ? null : _submit,
                icon: const Icon(Icons.send_rounded),
                label: Text(
                  loading ? 'Sending request' : 'Send booking request',
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
