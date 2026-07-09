import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/premium_motion.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../../../shared/widgets/zoovana_app_bar.dart';
import '../../data/models/pet_model.dart';
import '../../domain/entities/pet_entity.dart';
import '../controllers/pet_owner_controller.dart';

class PetOwnerPetsScreen extends StatefulWidget {
  const PetOwnerPetsScreen({super.key});

  @override
  State<PetOwnerPetsScreen> createState() => _PetOwnerPetsScreenState();
}

class _PetOwnerPetsScreenState extends State<PetOwnerPetsScreen> {
  late final PetOwnerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PetOwnerController>();
    if (_controller.petsStatus.value == PetOwnerStatus.idle &&
        _controller.pets.isEmpty) {
      _controller.loadPets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: const ZoovanaAppBar(title: 'My Pets', showBack: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPetSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Pet'),
      ),
      body: Obx(() {
        if (_controller.petsStatus.value == PetOwnerStatus.loading) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, _) =>
                const SkeletonCard(width: double.infinity, height: 90),
          );
        }
        if (_controller.petsStatus.value == PetOwnerStatus.error) {
          return _ErrorState(
            message: _controller.errorMessage.value,
            onRetry: _controller.loadPets,
          );
        }
        if (_controller.pets.isEmpty) {
          return _EmptyPetsView(onAdd: () => _showPetSheet(context));
        }
        return RefreshIndicator(
          onRefresh: _controller.loadPets,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
            children: [
              _PetsHero(
                count: _controller.pets.length,
                onAdd: () => _showPetSheet(context),
              ),
              const SizedBox(height: 18),
              Text(
                'Care profiles',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              ..._controller.pets.map(
                (pet) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PetCard(pet),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showPetSheet(BuildContext context) {
    showPremiumBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PetFormSheet(controller: _controller),
    );
  }
}

class _PetsHero extends StatelessWidget {
  const _PetsHero({required this.count, required this.onAdd});

  final int count;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.pets_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count registered ${count == 1 ? 'pet' : 'pets'}',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Health notes, photos, and care details in one place.',
                  style: AppTextStyles.bodySmall.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard(this.pet);

  final PetEntity pet;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      pet.species,
      pet.breed,
      pet.ageLabel,
    ].whereType<String>().where((item) => item.isNotEmpty).join(' - ');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAtElevation(1),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            SizedBox(
              width: 94,
              height: 112,
              child: pet.photoUrl == null || pet.photoUrl!.isEmpty
                  ? Container(
                      color: AppColors.primaryGlow,
                      child: Icon(
                        Icons.pets_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    )
                  : Image.network(
                      pet.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.primaryGlow,
                        child: Icon(
                          Icons.pets_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pet.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PetInfoChip(
                          icon: Icons.favorite_outline_rounded,
                          label: pet.healthStatus ?? 'Care profile',
                          color: pet.healthStatus == null
                              ? AppColors.primary
                              : AppColors.success,
                        ),
                        if (pet.species != null && pet.species!.isNotEmpty)
                          _PetInfoChip(
                            icon: Icons.cruelty_free_rounded,
                            label: pet.species!,
                            color: AppColors.accentDark,
                          ),
                      ],
                    ),
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

class _PetInfoChip extends StatelessWidget {
  const _PetInfoChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
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

class _EmptyPetsView extends StatelessWidget {
  const _EmptyPetsView({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceAtElevation(1),
            borderRadius: BorderRadius.circular(30),
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
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.primaryGradient),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Add your first pet',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a care profile to make bookings faster and keep important details together.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add pet'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PetFormSheet extends StatefulWidget {
  const _PetFormSheet({required this.controller});

  final PetOwnerController controller;

  @override
  State<_PetFormSheet> createState() => _PetFormSheetState();
}

class _PetFormSheetState extends State<_PetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _species = TextEditingController();
  final _breed = TextEditingController();
  final _age = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    _breed.dispose();
    _age.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!await requireAccount(context, action: 'create a pet profile')) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await widget.controller.createNewPet(
      CreatePetRequest(
        name: _name.text.trim(),
        species: _species.text.trim(),
        breed: _breed.text.trim(),
        age: _age.text.trim(),
      ),
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create pet profile', style: AppTextStyles.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Add the basics now and keep care details together.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Pet name',
                prefixIcon: Icon(Icons.pets_outlined),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _species,
              decoration: const InputDecoration(
                labelText: 'Species',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _breed,
              decoration: const InputDecoration(labelText: 'Breed'),
            ),
            TextFormField(
              controller: _age,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                final loading =
                    widget.controller.mutationStatus.value ==
                    PetOwnerMutationStatus.loading;
                return FilledButton.icon(
                  onPressed: loading ? null : _submit,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(loading ? 'Saving profile' : 'Save pet'),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RoleStatePanel(
      title: 'Pet profiles are unavailable',
      message: message.isEmpty ? 'We could not refresh your pets.' : message,
      icon: Icons.cloud_off_outlined,
      actionLabel: 'Try again',
      onAction: onRetry,
    );
  }
}
