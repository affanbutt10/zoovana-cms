import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/premium_motion.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../../../shared/widgets/zoovana_app_bar.dart';
import '../../data/models/shelter_animal_model.dart';
import '../../domain/entities/shelter_animal_entity.dart';
import '../controllers/shelter_controller.dart';

class ShelterAnimalsScreen extends StatefulWidget {
  const ShelterAnimalsScreen({super.key});

  @override
  State<ShelterAnimalsScreen> createState() => _ShelterAnimalsScreenState();
}

class _ShelterAnimalsScreenState extends State<ShelterAnimalsScreen> {
  late final ShelterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ShelterController>();
    _controller.loadAnimals();
    if (_controller.shelters.isEmpty) _controller.loadShelters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ZoovanaAppBar(title: 'Shelter Animals', showBack: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Animal'),
      ),
      body: Obx(() {
        if (_controller.animalsStatus.value == ShelterStatus.loading) {
          return _skeletonList();
        }
        if (_controller.animalsStatus.value == ShelterStatus.error) {
          return RoleStatePanel(
            title: 'Animals are unavailable',
            message: _controller.errorMessage.value,
            icon: Icons.cloud_off_outlined,
            actionLabel: 'Try again',
            onAction: _controller.loadAnimals,
          );
        }
        if (_controller.animals.isEmpty) {
          return RoleStatePanel(
            title: 'No animals in care yet',
            message:
                'Create the first animal profile to begin intake and care tracking.',
            icon: Icons.pets_outlined,
            actionLabel: 'Add animal',
            onAction: () => _showCreateSheet(context),
          );
        }
        return RefreshIndicator(
          onRefresh: _controller.loadAnimals,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
            itemCount: _controller.animals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _AnimalCard(_controller.animals[index]),
          ),
        );
      }),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showPremiumBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CreateAnimalSheet(controller: _controller),
    );
  }

  Widget _skeletonList() => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: 5,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (_, _) =>
        const SkeletonCard(width: double.infinity, height: 92),
  );
}

class _AnimalCard extends StatelessWidget {
  const _AnimalCard(this.animal);

  final ShelterAnimalEntity animal;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      animal.code,
      animal.species,
      animal.breed,
      animal.shelterName,
    ].whereType<String>().join(' - ');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.successLight,
            foregroundImage: animal.photoUrl == null
                ? null
                : NetworkImage(animal.photoUrl!),
            child: const Icon(Icons.pets_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle.isNotEmpty) Text(subtitle),
                if (animal.healthStatus != null) Text(animal.healthStatus!),
              ],
            ),
          ),
          Chip(label: Text(animal.status)),
        ],
      ),
    );
  }
}

class _CreateAnimalSheet extends StatefulWidget {
  const _CreateAnimalSheet({required this.controller});

  final ShelterController controller;

  @override
  State<_CreateAnimalSheet> createState() => _CreateAnimalSheetState();
}

class _CreateAnimalSheetState extends State<_CreateAnimalSheet> {
  final _name = TextEditingController();
  final _species = TextEditingController();
  final _breed = TextEditingController();
  String? _shelterId;

  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    _breed.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!await requireAccount(context, action: 'add an animal')) return;
    if (_name.text.trim().isEmpty || _shelterId == null) return;
    final ok = await widget.controller.createAnimal(
      CreateShelterAnimalRequest(
        name: _name.text.trim(),
        shelterId: _shelterId!,
        species: _species.text.trim(),
        breed: _breed.text.trim(),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Add Animal', style: AppTextStyles.titleLarge),
          DropdownButtonFormField<String>(
            initialValue: _shelterId,
            decoration: const InputDecoration(labelText: 'Shelter'),
            items: widget.controller.shelters
                .map(
                  (shelter) => DropdownMenuItem(
                    value: shelter.id,
                    child: Text(shelter.name),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _shelterId = value),
          ),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _species,
            decoration: const InputDecoration(labelText: 'Species'),
          ),
          TextField(
            controller: _breed,
            decoration: const InputDecoration(labelText: 'Breed'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Obx(() {
              final loading =
                  widget.controller.mutationStatus.value ==
                  ShelterStatus.loading;
              return FilledButton(
                onPressed: loading ? null : _submit,
                child: Text(loading ? 'Saving...' : 'Save Animal'),
              );
            }),
          ),
        ],
      ),
    );
  }
}
