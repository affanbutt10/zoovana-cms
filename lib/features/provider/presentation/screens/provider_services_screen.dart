import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/premium_motion.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../../../shared/widgets/zoovana_app_bar.dart';
import '../../data/models/provider_service_model.dart';
import '../../domain/entities/provider_service_entity.dart';
import '../controllers/provider_controller.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  late final ProviderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProviderController>();
    if (_controller.servicesStatus.value == ProviderStatus.idle &&
        _controller.services.isEmpty) {
      _controller.loadServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ZoovanaAppBar(title: 'My Services', showBack: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showServiceSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Service'),
      ),
      body: Obx(() {
        if (_controller.servicesStatus.value == ProviderStatus.loading) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, _) =>
                const SkeletonCard(width: double.infinity, height: 150),
          );
        }
        if (_controller.servicesStatus.value == ProviderStatus.error) {
          return RoleStatePanel(
            title: 'Services are unavailable',
            message: _controller.errorMessage.value,
            icon: Icons.cloud_off_outlined,
            actionLabel: 'Try again',
            onAction: _controller.loadServices,
          );
        }
        if (_controller.services.isEmpty) {
          return RoleStatePanel(
            title: 'Create your first service',
            message:
                'Describe what you offer so pet owners can discover and book your care.',
            icon: Icons.design_services_outlined,
            actionLabel: 'Add service',
            onAction: () => _showServiceSheet(context),
          );
        }
        return RefreshIndicator(
          onRefresh: _controller.loadServices,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
            itemCount: _controller.services.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _ServiceCard(_controller.services[index]),
          ),
        );
      }),
    );
  }

  void _showServiceSheet(BuildContext context) {
    showPremiumBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ServiceSheet(controller: _controller),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard(this.service);

  final ProviderServiceEntity service;

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
                  service.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _ServiceStatus(isActive: service.isActive),
            ],
          ),
          Text(service.serviceType, style: AppTextStyles.labelMedium),
          if (service.description != null) ...[
            const SizedBox(height: 6),
            Text(service.description!, maxLines: 2),
          ],
          if (service.priceLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              service.priceLabel!,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ServiceSheet extends StatefulWidget {
  const _ServiceSheet({required this.controller});

  final ProviderController controller;

  @override
  State<_ServiceSheet> createState() => _ServiceSheetState();
}

class _ServiceSheetState extends State<_ServiceSheet> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  String _type = 'boarding';

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!await requireAccount(context, action: 'publish a service')) return;
    final price = double.tryParse(_price.text.trim());
    if (_title.text.trim().isEmpty || price == null) return;
    final ok = await widget.controller.createService(
      ProviderServiceRequest(
        title: _title.text.trim(),
        serviceType: _type,
        price: price,
        description: _description.text.trim(),
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
          Text('Create a service', style: AppTextStyles.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Clear details help clients choose the right care.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: ['boarding', 'daycare', 'grooming', 'walking']
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) => setState(() => _type = value ?? _type),
          ),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Price'),
          ),
          TextField(
            controller: _description,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Obx(() {
              final loading =
                  widget.controller.mutationStatus.value ==
                  ProviderMutationStatus.loading;
              return FilledButton.icon(
                onPressed: loading ? null : _submit,
                icon: const Icon(Icons.check_rounded),
                label: Text(loading ? 'Saving service' : 'Publish service'),
              );
            }),
          ),
          Obx(() {
            final error = widget.controller.mutationError.value;
            if (error.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(error, style: AppTextStyles.errorText),
            );
          }),
        ],
      ),
    );
  }
}

class _ServiceStatus extends StatelessWidget {
  const _ServiceStatus({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.successDark : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? 'Active' : 'Offline',
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
