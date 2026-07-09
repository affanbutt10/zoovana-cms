import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/premium_motion.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../../../shared/widgets/zoovana_app_bar.dart';
import '../../data/models/shelter_profile_model.dart';
import '../../domain/entities/shelter_profile_entity.dart';
import '../controllers/shelter_controller.dart';

class ShelterListScreen extends StatefulWidget {
  const ShelterListScreen({super.key});

  @override
  State<ShelterListScreen> createState() => _ShelterListScreenState();
}

class _ShelterListScreenState extends State<ShelterListScreen> {
  late final ShelterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ShelterController>();
    _controller.loadShelters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ZoovanaAppBar(title: 'Shelter Profiles', showBack: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Shelter'),
      ),
      body: Obx(() {
        if (_controller.sheltersStatus.value == ShelterStatus.loading) {
          return _skeletonList();
        }
        if (_controller.sheltersStatus.value == ShelterStatus.error) {
          return RoleStatePanel(
            title: 'Shelter profiles are unavailable',
            message: _controller.errorMessage.value,
            icon: Icons.cloud_off_outlined,
            actionLabel: 'Try again',
            onAction: _controller.loadShelters,
          );
        }
        if (_controller.shelters.isEmpty) {
          return RoleStatePanel(
            title: 'Create your first shelter',
            message:
                'Add a shelter location and configure the services it provides.',
            icon: Icons.home_work_outlined,
            actionLabel: 'Add shelter',
            onAction: () => _showCreateSheet(context),
          );
        }
        return RefreshIndicator(
          onRefresh: _controller.loadShelters,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
            itemCount: _controller.shelters.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _ShelterCard(_controller.shelters[index]),
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
      builder: (_) => _CreateShelterSheet(controller: _controller),
    );
  }

  Widget _skeletonList() => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: 4,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (_, _) =>
        const SkeletonCard(width: double.infinity, height: 116),
  );
}

class _ShelterCard extends StatelessWidget {
  const _ShelterCard(this.shelter);

  final ShelterProfileEntity shelter;

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
          Icon(Icons.home_work_rounded, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shelter.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  [
                    shelter.location,
                    shelter.contact,
                  ].whereType<String>().join(' - '),
                ),
                Wrap(
                  spacing: 6,
                  children: [
                    if (shelter.acceptingVolunteers)
                      const Chip(label: Text('Volunteers')),
                    if (shelter.donationsEnabled)
                      const Chip(label: Text('Donations')),
                  ],
                ),
              ],
            ),
          ),
          Chip(label: Text(shelter.status)),
        ],
      ),
    );
  }
}

class _CreateShelterSheet extends StatefulWidget {
  const _CreateShelterSheet({required this.controller});

  final ShelterController controller;

  @override
  State<_CreateShelterSheet> createState() => _CreateShelterSheetState();
}

class _CreateShelterSheetState extends State<_CreateShelterSheet> {
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _contact = TextEditingController();
  bool _volunteers = false;
  bool _donations = false;

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!await requireAccount(context, action: 'create a shelter')) return;
    if (_name.text.trim().isEmpty) return;
    final ok = await widget.controller.createShelter(
      CreateShelterRequest(
        name: _name.text.trim(),
        location: _location.text.trim(),
        contact: _contact.text.trim(),
        acceptingVolunteers: _volunteers,
        donationsEnabled: _donations,
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
          Text('Add Shelter', style: AppTextStyles.titleLarge),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _location,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          TextField(
            controller: _contact,
            decoration: const InputDecoration(labelText: 'Contact'),
          ),
          SwitchListTile(
            value: _volunteers,
            onChanged: (value) => setState(() => _volunteers = value),
            title: const Text('Accepting volunteers'),
          ),
          SwitchListTile(
            value: _donations,
            onChanged: (value) => setState(() => _donations = value),
            title: const Text('Donations enabled'),
          ),
          SizedBox(
            width: double.infinity,
            child: Obx(() {
              final loading =
                  widget.controller.mutationStatus.value ==
                  ShelterStatus.loading;
              return FilledButton(
                onPressed: loading ? null : _submit,
                child: Text(loading ? 'Saving...' : 'Save Shelter'),
              );
            }),
          ),
        ],
      ),
    );
  }
}
