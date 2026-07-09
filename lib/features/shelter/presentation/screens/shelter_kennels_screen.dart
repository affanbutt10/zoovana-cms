import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/premium_motion.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../../../shared/widgets/zoovana_app_bar.dart';
import '../../data/models/shelter_kennel_model.dart';
import '../../domain/entities/shelter_kennel_entity.dart';
import '../controllers/shelter_controller.dart';

class ShelterKennelsScreen extends StatefulWidget {
  const ShelterKennelsScreen({super.key});

  @override
  State<ShelterKennelsScreen> createState() => _ShelterKennelsScreenState();
}

class _ShelterKennelsScreenState extends State<ShelterKennelsScreen> {
  late final ShelterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ShelterController>();
    _controller.loadKennels();
    if (_controller.shelters.isEmpty) _controller.loadShelters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ZoovanaAppBar(title: 'Kennel Management', showBack: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Kennel'),
      ),
      body: Obx(() {
        if (_controller.kennelsStatus.value == ShelterStatus.loading) {
          return _skeletonList();
        }
        if (_controller.kennelsStatus.value == ShelterStatus.error) {
          return RoleStatePanel(
            title: 'Kennels are unavailable',
            message: _controller.errorMessage.value,
            icon: Icons.cloud_off_outlined,
            actionLabel: 'Try again',
            onAction: _controller.loadKennels,
          );
        }
        if (_controller.kennels.isEmpty) {
          return RoleStatePanel(
            title: 'No kennels configured',
            message: 'Add kennel capacity before assigning animals to housing.',
            icon: Icons.grid_view_rounded,
            actionLabel: 'Add kennel',
            onAction: () => _showCreateSheet(context),
          );
        }
        return RefreshIndicator(
          onRefresh: _controller.loadKennels,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
            itemCount: _controller.kennels.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _KennelCard(_controller.kennels[index]),
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
      builder: (_) => _CreateKennelSheet(controller: _controller),
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

class _KennelCard extends StatelessWidget {
  const _KennelCard(this.kennel);

  final ShelterKennelEntity kennel;

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
          Icon(Icons.grid_view_rounded, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kennel.name, style: AppTextStyles.titleMedium),
                Text('${kennel.occupied}/${kennel.capacity} occupied'),
                if (kennel.shelterName != null) Text(kennel.shelterName!),
              ],
            ),
          ),
          Chip(label: Text(kennel.status)),
        ],
      ),
    );
  }
}

class _CreateKennelSheet extends StatefulWidget {
  const _CreateKennelSheet({required this.controller});

  final ShelterController controller;

  @override
  State<_CreateKennelSheet> createState() => _CreateKennelSheetState();
}

class _CreateKennelSheetState extends State<_CreateKennelSheet> {
  String? _shelterId;
  final _name = TextEditingController();
  final _capacity = TextEditingController(text: '1');

  @override
  void dispose() {
    _name.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!await requireAccount(context, action: 'create a kennel')) return;
    final capacity = int.tryParse(_capacity.text.trim()) ?? 1;
    if (_shelterId == null || _name.text.trim().isEmpty) return;
    final ok = await widget.controller.createKennel(
      CreateKennelRequest(
        name: _name.text.trim(),
        shelterId: _shelterId!,
        capacity: capacity,
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
          Text('Add Kennel', style: AppTextStyles.titleLarge),
          DropdownButtonFormField<String>(
            initialValue: _shelterId,
            decoration: const InputDecoration(labelText: 'Shelter'),
            items: widget.controller.shelters
                .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                .toList(),
            onChanged: (value) => setState(() => _shelterId = value),
          ),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _capacity,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Capacity'),
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
                child: Text(loading ? 'Saving...' : 'Save Kennel'),
              );
            }),
          ),
        ],
      ),
    );
  }
}
