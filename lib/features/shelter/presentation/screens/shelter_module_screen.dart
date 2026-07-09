import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../controllers/shelter_controller.dart';

class ShelterModuleScreen extends StatefulWidget {
  const ShelterModuleScreen({
    super.key,
    required this.module,
    required this.title,
    required this.icon,
  });

  final String module;
  final String title;
  final IconData icon;

  @override
  State<ShelterModuleScreen> createState() => _ShelterModuleScreenState();
}

class _ShelterModuleScreenState extends State<ShelterModuleScreen> {
  late final ShelterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ShelterController>();
    _controller.loadModule(widget.module);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(widget.title, style: AppTextStyles.titleLarge),
      ),
      body: Obx(() {
        if (_controller.moduleStatus.value == ShelterStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_controller.moduleItems.isEmpty) {
          return AppEmptyState(
            message: 'No ${widget.title.toLowerCase()} records yet.',
            icon: widget.icon,
          );
        }
        return RefreshIndicator(
          onRefresh: () => _controller.loadModule(widget.module),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.moduleItems.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = _controller.moduleItems[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, color: AppColors.success),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(item.subtitle),
                          if (item.meta != null) Text(item.meta!),
                        ],
                      ),
                    ),
                    Chip(label: Text(item.status)),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
