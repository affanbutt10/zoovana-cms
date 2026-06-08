import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/app_logo.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  String? _selectedAmount;
  String _selectedPurpose = 'General';
  bool _isMonthly = false;
  final _customAmountController = TextEditingController();

  final List<String> _amounts = [
    'SAR 25',
    'SAR 50',
    'SAR 100',
    'SAR 250',
    'SAR 500',
  ];
  final List<String> _purposes = [
    'General',
    'Medical Care',
    'Food & Supplies',
    'Shelter Operations',
  ];

  late AnimationController _animController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    _animController.dispose();
    super.dispose();
  }

  String get _displayAmount {
    if (_selectedAmount != null) return _selectedAmount!;
    final v = _customAmountController.text.trim();
    return v.isEmpty ? 'SAR 0' : 'SAR $v';
  }

  void _nextStep() {
    setState(() => _step++);
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Premium Header Banner ────────────────────────────────────────────
          _DonationHeader(step: _step),

          // ── Content ───────────────────────────────────────────────────────
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _step == 0
                      ? _AmountStep(
                          amounts: _amounts,
                          selectedAmount: _selectedAmount,
                          onAmountSelected: (v) => setState(() {
                            _selectedAmount = v;
                            _customAmountController.clear();
                          }),
                          customController: _customAmountController,
                          onCustomChanged: (_) =>
                              setState(() => _selectedAmount = null),
                          purposes: _purposes,
                          selectedPurpose: _selectedPurpose,
                          onPurposeSelected: (v) =>
                              setState(() => _selectedPurpose = v),
                          isMonthly: _isMonthly,
                          onMonthlyToggle: (v) =>
                              setState(() => _isMonthly = v),
                          displayAmount: _displayAmount,
                          frequency: _isMonthly ? 'Monthly' : 'One-time',
                          onContinue: _nextStep,
                        )
                      : _step == 1
                      ? _DetailsStep(onContinue: _nextStep)
                      : _ConfirmStep(
                          amount: _displayAmount,
                          purpose: _selectedPurpose,
                          frequency: _isMonthly ? 'Monthly' : 'One-time',
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header Banner ─────────────────────────────────────────────────────────────

class _DonationHeader extends StatelessWidget {
  const _DonationHeader({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox.shrink(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Make a Difference',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Support animals in need today',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const AppLogoTile(size: 40, radius: 20, showShadow: false),
            ],
          ),
          const SizedBox(height: 28),
          // Step progress
          Row(
            children: List.generate(3, (i) {
              final labels = ['Amount', 'Details', 'Confirm'];
              final isActive = i == step;
              final isDone = i < step;
              return Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: isActive || isDone
                                ? LinearGradient(
                                    colors: AppColors.primaryGradient,
                                  )
                                : null,
                            color: isActive || isDone
                                ? null
                                : AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive || isDone
                                  ? Colors.transparent
                                  : AppColors.divider,
                            ),
                            boxShadow: isActive || isDone
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: isDone
                                ? Icon(
                                    Icons.check_rounded,
                                    color: AppColors.textOnPrimary,
                                    size: 16,
                                  )
                                : Text(
                                    '${i + 1}',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: isActive
                                          ? AppColors.textOnPrimary
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          labels[i],
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (i < 2)
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 2,
                          margin: const EdgeInsets.only(
                            bottom: 24,
                            left: 8,
                            right: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDone
                                ? AppColors.primary
                                : AppColors.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Amount ────────────────────────────────────────────────────────────

class _AmountStep extends StatelessWidget {
  const _AmountStep({
    required this.amounts,
    required this.selectedAmount,
    required this.onAmountSelected,
    required this.customController,
    required this.onCustomChanged,
    required this.purposes,
    required this.selectedPurpose,
    required this.onPurposeSelected,
    required this.isMonthly,
    required this.onMonthlyToggle,
    required this.displayAmount,
    required this.frequency,
    required this.onContinue,
  });

  final List<String> amounts;
  final String? selectedAmount;
  final ValueChanged<String> onAmountSelected;
  final TextEditingController customController;
  final ValueChanged<String> onCustomChanged;
  final List<String> purposes;
  final String selectedPurpose;
  final ValueChanged<String> onPurposeSelected;
  final bool isMonthly;
  final ValueChanged<bool> onMonthlyToggle;
  final String displayAmount;
  final String frequency;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.volunteer_activism_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select Amount',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: amounts.map((a) {
                  final isSelected = a == selectedAmount;
                  return GestureDetector(
                    onTap: () => onAmountSelected(a),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(colors: AppColors.primaryGradient)
                            : null,
                        color: isSelected ? null : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppColors.divider,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        a,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isSelected
                              ? AppColors.textOnPrimary
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Or enter custom amount',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              _PremiumTextField(
                controller: customController,
                hint: '0',
                prefixText: 'SAR  ',
                keyboardType: TextInputType.number,
                onChanged: onCustomChanged,
              ),
              const SizedBox(height: 28),
              Text(
                'DONATION PURPOSE',
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: purposes.map((p) {
                  final isSelected = p == selectedPurpose;
                  return GestureDetector(
                    onTap: () => onPurposeSelected(p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                      ),
                      child: Text(
                        p,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.autorenew_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Donation',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Help consistently every month',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: isMonthly,
                      onChanged: onMonthlyToggle,
                      activeThumbColor: AppColors.accent,
                      activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SummaryCard(
          displayAmount: displayAmount,
          selectedPurpose: selectedPurpose,
          frequency: frequency,
          onContinue: onContinue,
          buttonLabel: 'Continue to Details',
        ),
      ],
    );
  }
}

// ── Step 2: Details ───────────────────────────────────────────────────────────

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Details',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              const _PremiumTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
              ),
              const SizedBox(height: 16),
              const _PremiumTextField(
                label: 'Email Address',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const _PremiumTextField(
                label: 'Phone Number',
                hint: 'Enter your phone number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),
              _PremiumButton(
                onPressed: onContinue,
                label: 'Continue to Confirm',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Step 3: Confirm ───────────────────────────────────────────────────────────

class _ConfirmStep extends StatelessWidget {
  const _ConfirmStep({
    required this.amount,
    required this.purpose,
    required this.frequency,
  });
  final String amount;
  final String purpose;
  final String frequency;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionCard(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.primaryGradient),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: AppColors.textOnPrimary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Confirm Donation',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 28),
              _SummaryRow('Amount', amount),
              const SizedBox(height: 12),
              _SummaryRow('Purpose', purpose),
              const SizedBox(height: 12),
              _SummaryRow('Frequency', frequency),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: AppColors.divider),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    amount,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _PremiumButton(onPressed: () {}, label: 'Process Payment'),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Shared Premium Widgets ────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.displayAmount,
    required this.selectedPurpose,
    required this.frequency,
    required this.onContinue,
    required this.buttonLabel,
  });

  final String displayAmount;
  final String selectedPurpose;
  final String frequency;
  final VoidCallback onContinue;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _SummaryRow('Amount', displayAmount),
          const SizedBox(height: 12),
          _SummaryRow('Purpose', selectedPurpose),
          const SizedBox(height: 12),
          _SummaryRow('Frequency', frequency),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: AppColors.divider),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                displayAmount,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _PremiumButton(onPressed: onContinue, label: buttonLabel),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  const _PremiumTextField({
    this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.prefixText,
    this.onChanged,
  });
  final String? label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? prefixText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            prefixStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDisabled,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _PremiumButton extends StatelessWidget {
  const _PremiumButton({required this.onPressed, required this.label});
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.primaryGradient),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
