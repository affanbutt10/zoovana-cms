import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';
import '../../core/config/app_text_styles.dart';

/// Horizontally scrollable chip selector.
class ChipSelector extends StatelessWidget {
  const ChipSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.scrollable = true,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final chips = options.map((option) {
      final isSelected = option == selected;
      return GestureDetector(
        onTap: () => onSelected(option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Text(
            option,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected
                  ? AppColors.textOnPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      );
    }).toList();

    if (!scrollable) {
      return Wrap(spacing: 8, runSpacing: 8, children: chips);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.expand((c) => [c, const SizedBox(width: 8)]).toList()
          ..removeLast(),
      ),
    );
  }
}
