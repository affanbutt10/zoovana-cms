import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:zoovana_cms/core/error/result.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../core/error/app_error.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/verify_email_usecase.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  late String _email;

  bool _isVerifying = false;
  bool _isResending = false;
  AppError? _error;
  String? _successMessage;

  late AnimationController _mainController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    _email = (extra is Map && extra['email'] is String)
        ? extra['email'] as String
        : '';
  }

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _mainController.forward();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _mainController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      _error = null;
      _successMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isVerifying = true);

    final verifyUseCase = GetIt.instance<VerifyEmailUseCase>();
    final result = await verifyUseCase(
      email: _email,
      otp: _otpController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isVerifying = false);

    result.when(
      success: (_) => context.go('/login'),
      failure: (error) => setState(() => _error = error),
    );
  }

  Future<void> _resend() async {
    setState(() {
      _error = null;
      _successMessage = null;
    });

    setState(() => _isResending = true);

    final repository = GetIt.instance<AuthRepository>();
    final result = await repository.resendVerification(_email);

    if (!mounted) return;
    setState(() => _isResending = false);

    result.when(
      success: (_) {
        setState(() {
          _successMessage = 'Verification code resent successfully.';
        });
      },
      failure: (error) => setState(() => _error = error),
    );
  }

  String _errorMessage(AppError error) {
    if (error.badRequest) {
      return error.message.isNotEmpty
          ? error.message
          : 'Invalid or expired OTP.';
    }
    if (error.networkError) return 'No internet connection.';
    if (error.serverError) return 'An unexpected server error occurred.';
    return error.message;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background Glow Orbs ──────────────────────────────────────────
          _AnimatedGlowOrbs(controller: _glowController, size: size),

          // ── Main Content ──────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),

                        // Animated Email Icon
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.mark_email_unread_rounded,
                                color: AppColors.primary,
                                size: 44,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                        Text(
                          'Verify Email',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 32,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _email.isNotEmpty
                              ? 'Enter the 4-digit code sent to\n$_email'
                              : 'Enter the verification code sent to your email.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Glassmorphism Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppColors.glassBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _PremiumTextField(
                                controller: _otpController,
                                label: 'Verification Code',
                                hint: '••••••',
                                prefixIcon: Icons.pin_outlined,
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                textAlign: TextAlign.center,
                                validator: (value) =>
                                    value == null || value.trim().length != 4
                                    ? 'Enter the 4-digit code.'
                                    : null,
                                onFieldSubmitted: (_) => _verify(),
                              ),
                            ],
                          ),
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: 24),
                          Text(
                            _errorMessage(_error!),
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        if (_successMessage != null) ...[
                          const SizedBox(height: 24),
                          Text(
                            _successMessage!,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.success,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const SizedBox(height: 40),

                        _PremiumButton(
                          onPressed: _isVerifying ? null : _verify,
                          label: 'Verify Account',
                          isLoading: _isVerifying,
                        ),

                        const SizedBox(height: 16),

                        _PremiumButton(
                          onPressed: _isResending ? null : _resend,
                          label: 'Resend Code',
                          isLoading: _isResending,
                          isOutline: true,
                        ),

                        const SizedBox(height: 24),

                        Center(
                          child: TextButton(
                            onPressed: () => context.go('/login'),
                            child: Text(
                              'Back to Sign In',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

// ── Shared Widgets (Consistent) ───────────────────────────────────────────────

class _AnimatedGlowOrbs extends StatelessWidget {
  const _AnimatedGlowOrbs({required this.controller, required this.size});
  final AnimationController controller;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: size.height * 0.2 + (controller.value * 20),
              right: -size.width * 0.2,
              child: Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.1 - (controller.value * 30),
              left: -size.width * 0.3,
              child: Container(
                width: size.width,
                height: size.width,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final int? maxLength;
  final TextAlign textAlign;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          textAlign: textAlign,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          style: textAlign == TextAlign.center
              ? AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 8,
                )
              : AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textAlign == TextAlign.center
                ? AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textDisabled,
                    letterSpacing: 8,
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDisabled,
                  ),
            prefixIcon: Icon(
              prefixIcon,
              color: AppColors.textSecondary,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _PremiumButton extends StatelessWidget {
  const _PremiumButton({
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.isOutline = false,
  });
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final bool isOutline;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isOutline
            ? null
            : LinearGradient(
                colors: onPressed == null
                    ? [AppColors.divider, AppColors.divider]
                    : AppColors.primaryGradient,
              ),
        borderRadius: BorderRadius.circular(16),
        border: isOutline
            ? Border.all(color: AppColors.primary, width: 1.5)
            : null,
        boxShadow: (onPressed == null || isOutline)
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: isOutline ? AppColors.primary : AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isOutline
                      ? AppColors.primary
                      : AppColors.textOnPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
