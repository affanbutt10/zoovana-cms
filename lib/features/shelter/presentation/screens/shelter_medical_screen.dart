import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/premium_motion.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../../../shared/widgets/zoovana_app_bar.dart';
import '../../data/models/shelter_medical_record_model.dart';
import '../../domain/entities/shelter_medical_record_entity.dart';
import '../controllers/shelter_controller.dart';

class ShelterMedicalScreen extends StatefulWidget {
  const ShelterMedicalScreen({super.key});

  @override
  State<ShelterMedicalScreen> createState() => _ShelterMedicalScreenState();
}

class _ShelterMedicalScreenState extends State<ShelterMedicalScreen> {
  late final ShelterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ShelterController>();
    _controller.loadMedicalRecords();
    if (_controller.animals.isEmpty) _controller.loadAnimals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ZoovanaAppBar(title: 'Medical Records', showBack: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Record'),
      ),
      body: Obx(() {
        if (_controller.medicalStatus.value == ShelterStatus.loading) {
          return _skeletonList();
        }
        if (_controller.medicalStatus.value == ShelterStatus.error) {
          return RoleStatePanel(
            title: 'Medical records are unavailable',
            message: _controller.errorMessage.value,
            icon: Icons.cloud_off_outlined,
            actionLabel: 'Try again',
            onAction: _controller.loadMedicalRecords,
          );
        }
        if (_controller.medicalRecords.isEmpty) {
          return RoleStatePanel(
            title: 'No medical records yet',
            message:
                'Add diagnoses and treatment details as animals receive care.',
            icon: Icons.medical_services_outlined,
            actionLabel: 'Add record',
            onAction: () => _showCreateSheet(context),
          );
        }
        return RefreshIndicator(
          onRefresh: _controller.loadMedicalRecords,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
            itemCount: _controller.medicalRecords.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _MedicalCard(_controller.medicalRecords[index]),
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
      builder: (_) => _CreateMedicalSheet(controller: _controller),
    );
  }

  Widget _skeletonList() => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: 5,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (_, _) =>
        const SkeletonCard(width: double.infinity, height: 104),
  );
}

class _MedicalCard extends StatelessWidget {
  const _MedicalCard(this.record);

  final ShelterMedicalRecordEntity record;

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
          Icon(Icons.medical_services_rounded, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.animalName, style: AppTextStyles.titleMedium),
                Text(record.diagnosis),
                if (record.treatment != null) Text(record.treatment!),
                if (record.provider != null) Text(record.provider!),
              ],
            ),
          ),
          Chip(label: Text(record.status)),
        ],
      ),
    );
  }
}

class _CreateMedicalSheet extends StatefulWidget {
  const _CreateMedicalSheet({required this.controller});

  final ShelterController controller;

  @override
  State<_CreateMedicalSheet> createState() => _CreateMedicalSheetState();
}

class _CreateMedicalSheetState extends State<_CreateMedicalSheet> {
  String? _animalId;
  final _diagnosis = TextEditingController();
  final _treatment = TextEditingController();
  final _provider = TextEditingController();

  @override
  void dispose() {
    _diagnosis.dispose();
    _treatment.dispose();
    _provider.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!await requireAccount(context, action: 'add a medical record')) return;
    if (_animalId == null || _diagnosis.text.trim().isEmpty) return;
    final ok = await widget.controller.createMedicalRecord(
      CreateMedicalRecordRequest(
        animalId: _animalId!,
        diagnosis: _diagnosis.text.trim(),
        treatment: _treatment.text.trim(),
        provider: _provider.text.trim(),
        recordedAt: DateTime.now(),
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
          Text('Add Medical Record', style: AppTextStyles.titleLarge),
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
            controller: _diagnosis,
            decoration: const InputDecoration(labelText: 'Diagnosis'),
          ),
          TextField(
            controller: _treatment,
            decoration: const InputDecoration(labelText: 'Treatment'),
          ),
          TextField(
            controller: _provider,
            decoration: const InputDecoration(labelText: 'Provider / Vet'),
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
                child: Text(loading ? 'Saving...' : 'Save Record'),
              );
            }),
          ),
        ],
      ),
    );
  }
}
