import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/premium_motion.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../../../shared/widgets/zoovana_app_bar.dart';
import '../../data/models/shelter_vaccination_model.dart';
import '../../domain/entities/shelter_vaccination_entity.dart';
import '../controllers/shelter_controller.dart';

class ShelterVaccinationsScreen extends StatefulWidget {
  const ShelterVaccinationsScreen({super.key});

  @override
  State<ShelterVaccinationsScreen> createState() =>
      _ShelterVaccinationsScreenState();
}

class _ShelterVaccinationsScreenState extends State<ShelterVaccinationsScreen> {
  late final ShelterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ShelterController>();
    _controller.loadVaccinations();
    if (_controller.animals.isEmpty) _controller.loadAnimals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ZoovanaAppBar(title: 'Vaccinations', showBack: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Vaccine'),
      ),
      body: Obx(() {
        if (_controller.vaccinationsStatus.value == ShelterStatus.loading) {
          return _skeletonList();
        }
        if (_controller.vaccinationsStatus.value == ShelterStatus.error) {
          return RoleStatePanel(
            title: 'Vaccinations are unavailable',
            message: _controller.errorMessage.value,
            icon: Icons.cloud_off_outlined,
            actionLabel: 'Try again',
            onAction: _controller.loadVaccinations,
          );
        }
        if (_controller.vaccinations.isEmpty) {
          return RoleStatePanel(
            title: 'No vaccination records yet',
            message: 'Record administered vaccines and keep due dates visible.',
            icon: Icons.vaccines_outlined,
            actionLabel: 'Add vaccination',
            onAction: () => _showCreateSheet(context),
          );
        }
        return RefreshIndicator(
          onRefresh: _controller.loadVaccinations,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
            itemCount: _controller.vaccinations.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _VaccinationCard(_controller.vaccinations[index]),
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
      builder: (_) => _CreateVaccinationSheet(controller: _controller),
    );
  }

  Widget _skeletonList() => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: 5,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (_, _) =>
        const SkeletonCard(width: double.infinity, height: 94),
  );
}

class _VaccinationCard extends StatelessWidget {
  const _VaccinationCard(this.record);

  final ShelterVaccinationEntity record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.vaccines_rounded, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.animalName, style: AppTextStyles.titleMedium),
                Text(record.vaccineName),
                if (record.notes != null) Text(record.notes!),
              ],
            ),
          ),
          Chip(label: Text(record.status)),
        ],
      ),
    );
  }
}

class _CreateVaccinationSheet extends StatefulWidget {
  const _CreateVaccinationSheet({required this.controller});

  final ShelterController controller;

  @override
  State<_CreateVaccinationSheet> createState() =>
      _CreateVaccinationSheetState();
}

class _CreateVaccinationSheetState extends State<_CreateVaccinationSheet> {
  String? _animalId;
  final _vaccine = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _vaccine.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!await requireAccount(context, action: 'record a vaccination')) return;
    if (_animalId == null || _vaccine.text.trim().isEmpty) return;
    final ok = await widget.controller.createVaccination(
      CreateVaccinationRequest(
        animalId: _animalId!,
        vaccineName: _vaccine.text.trim(),
        givenAt: DateTime.now(),
        notes: _notes.text.trim(),
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
          Text('Add Vaccination', style: AppTextStyles.titleLarge),
          DropdownButtonFormField<String>(
            initialValue: _animalId,
            decoration: const InputDecoration(labelText: 'Animal'),
            items: widget.controller.animals
                .map(
                  (animal) => DropdownMenuItem(
                    value: animal.id,
                    child: Text(animal.name),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _animalId = value),
          ),
          TextField(
            controller: _vaccine,
            decoration: const InputDecoration(labelText: 'Vaccine'),
          ),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Notes'),
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
                child: Text(loading ? 'Saving...' : 'Save Vaccination'),
              );
            }),
          ),
        ],
      ),
    );
  }
}
