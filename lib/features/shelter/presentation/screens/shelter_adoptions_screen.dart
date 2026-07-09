import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/premium_motion.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../../../shared/widgets/zoovana_app_bar.dart';
import '../../data/models/shelter_adoption_model.dart';
import '../../domain/entities/shelter_adoption_entity.dart';
import '../controllers/shelter_controller.dart';

class ShelterAdoptionsScreen extends StatefulWidget {
  const ShelterAdoptionsScreen({super.key});

  @override
  State<ShelterAdoptionsScreen> createState() => _ShelterAdoptionsScreenState();
}

class _ShelterAdoptionsScreenState extends State<ShelterAdoptionsScreen> {
  late final ShelterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ShelterController>();
    _controller.loadAdoptions();
    if (_controller.animals.isEmpty) _controller.loadAnimals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ZoovanaAppBar(title: 'Adoptions', showBack: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create'),
      ),
      body: Obx(() {
        if (_controller.adoptionsStatus.value == ShelterStatus.loading) {
          return _skeletonList();
        }
        if (_controller.adoptionsStatus.value == ShelterStatus.error) {
          return RoleStatePanel(
            title: 'Adoptions are unavailable',
            message: _controller.errorMessage.value,
            icon: Icons.cloud_off_outlined,
            actionLabel: 'Try again',
            onAction: _controller.loadAdoptions,
          );
        }
        if (_controller.adoptions.isEmpty) {
          return RoleStatePanel(
            title: 'No adoption applications',
            message:
                'Create or receive an application to begin placement review.',
            icon: Icons.favorite_border_rounded,
            actionLabel: 'Create application',
            onAction: () => _showCreateSheet(context),
          );
        }
        return RefreshIndicator(
          onRefresh: _controller.loadAdoptions,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
            itemCount: _controller.adoptions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _AdoptionCard(
              adoption: _controller.adoptions[index],
              controller: _controller,
            ),
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
      builder: (_) => _CreateAdoptionSheet(controller: _controller),
    );
  }

  Widget _skeletonList() => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: 4,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (_, _) =>
        const SkeletonCard(width: double.infinity, height: 142),
  );
}

class _AdoptionCard extends StatelessWidget {
  const _AdoptionCard({required this.adoption, required this.controller});

  final ShelterAdoptionEntity adoption;
  final ShelterController controller;

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
                  adoption.animalName,
                  style: AppTextStyles.titleMedium,
                ),
              ),
              Chip(label: Text(adoption.status)),
            ],
          ),
          Text(adoption.applicantName),
          if (adoption.notes != null) Text(adoption.notes!),
          if (adoption.status == 'pending') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      if (!await requireAccount(
                        context,
                        action: 'reject an adoption',
                      )) {
                        return;
                      }
                      controller.updateAdoptionStatus(adoption, 'rejected');
                    },
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      if (!await requireAccount(
                        context,
                        action: 'approve an adoption',
                      )) {
                        return;
                      }
                      controller.updateAdoptionStatus(adoption, 'approved');
                    },
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CreateAdoptionSheet extends StatefulWidget {
  const _CreateAdoptionSheet({required this.controller});

  final ShelterController controller;

  @override
  State<_CreateAdoptionSheet> createState() => _CreateAdoptionSheetState();
}

class _CreateAdoptionSheetState extends State<_CreateAdoptionSheet> {
  String? _animalId;
  final _applicant = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _applicant.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!await requireAccount(context, action: 'create an adoption')) return;
    if (_animalId == null || _applicant.text.trim().isEmpty) return;
    final ok = await widget.controller.createAdoption(
      CreateAdoptionRequest(
        animalId: _animalId!,
        applicantName: _applicant.text.trim(),
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
          Text('Create Adoption', style: AppTextStyles.titleLarge),
          DropdownButtonFormField<String>(
            initialValue: _animalId,
            decoration: const InputDecoration(labelText: 'Animal'),
            items: widget.controller.animals
                .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                .toList(),
            onChanged: (value) => setState(() => _animalId = value),
          ),
          TextField(
            controller: _applicant,
            decoration: const InputDecoration(labelText: 'Applicant name'),
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
                child: Text(loading ? 'Saving...' : 'Create Application'),
              );
            }),
          ),
        ],
      ),
    );
  }
}
