import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/usecases/register_usecase.dart';
import '../controllers/role_controller.dart';

// ═══════════════════════════════════════════════════════════════
//  REGISTER SCREEN  — 2-step flow matching the website
//  Step 1: "Who are you?" role picker card grid
//  Step 2: Registration form (name, email, phone, password)
// ═══════════════════════════════════════════════════════════════

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  // ── Step state ───────────────────────────────────────────────
  int _step = 0; // 0 = role picker, 1 = form
  RoleEntity? _selectedRole;

  Future<void> _fetchRoles() async {
    // Trigger a fresh fetch if the list is empty (e.g. network was down at startup)
    if (Get.find<RoleController>().allRoles.isEmpty) {
      await Get.find<RoleController>().fetchAllRoles();
    }
    if (mounted) setState(() {});
  }

  // ── Form ─────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  AppError? _submitError;

  // ── Animations ───────────────────────────────────────────────
  late final AnimationController _glowCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ── Role metadata ────────────────────────────────────────────
  static const _meta = <String, _RoleMeta>{
    'shop_owner': _RoleMeta('Shop Owner', Icons.storefront_rounded, AppColors.primary),
    'shelter': _RoleMeta('Shelter', Icons.home_rounded, AppColors.success),
    'volunteer': _RoleMeta('Volunteer', Icons.volunteer_activism_rounded, AppColors.secondary),
    'animalowner': _RoleMeta('Animal Owner', Icons.pets_rounded, AppColors.accent),
    'serviceprovider': _RoleMeta('Service Provider', Icons.medical_services_rounded, AppColors.highlight),
    'user': _RoleMeta('User', Icons.person_rounded, AppColors.slateLight),
  };

  _RoleMeta _metaFor(RoleEntity r) {
    final key = r.name.toLowerCase().replaceAll(' ', '_');
    return _meta[key] ?? _RoleMeta(_capitalize(r.name), Icons.badge_rounded, AppColors.primary);
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  void initState() {
    super.initState();
    // Roles are pre-fetched on app start via RoleController.fetchAllRoles().
    // Only trigger a fetch here if the list is still empty (network was down).
    if (Get.find<RoleController>().allRoles.isEmpty) {
      _fetchRoles();
    }

    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _fadeCtrl.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _goToForm() async {
    if (_selectedRole == null) return;
    setState(() => _step = 1);
    _fadeCtrl.forward(from: 0);
  }

  void _goBack() {
    if (_step == 1) {
      setState(() => _step = 0);
      _fadeCtrl.forward(from: 0);
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    setState(() => _submitError = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final useCase = GetIt.instance<RegisterUseCase>();
    final result = await useCase(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      fullName: _fullNameCtrl.text.trim(),
      roleId: _selectedRole?.id,
      phoneNumber: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success():
        context.push('/verify-email', extra: {'email': _emailCtrl.text.trim()});
      case Failure(:final error):
        setState(() => _submitError = error);
    }
  }

  String _errorMsg(AppError e) {
    if (e.networkError) return 'No internet connection.';
    if (e.conflict) return 'An account with this email already exists.';
    if (e.validationErrors) {
      final msgs = e.errors?.values.expand((v) => v).join('\n') ?? '';
      return msgs.isNotEmpty ? msgs : e.message;
    }
    return e.message.isNotEmpty ? e.message : 'An unexpected error occurred.';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.backgroundTint,
      body: Stack(
        children: [
          _GlowOrbs(controller: _glowCtrl, size: size),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _step == 0 ? _buildRolePicker() : _buildForm(),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: _goBack,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceGlass,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Role picker ──────────────────────────────────────

  Widget _buildRolePicker() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogoTile(size: 32, radius: 9, showShadow: false),
                  const SizedBox(width: 8),
                  Text('Zoovana',
                      style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 16),
              Text('Welcome to Zoovana',
                  style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900, fontSize: 22)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🐾', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 6),
                  Text('Who are you?',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary)),
                  const SizedBox(width: 6),
                  const Text('👋', style: TextStyle(fontSize: 15)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Grid
        Expanded(
          child: Obx(() {
            final loading = Get.find<RoleController>().allRolesLoading.value;
            final roles = Get.find<RoleController>().allRoles;
            if (loading && roles.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5));
            }
            if (roles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Failed to load roles.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _fetchRoles,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.05,
              ),
              itemCount: roles.length,
              itemBuilder: (_, i) {
                final role = roles[i];
                final meta = _metaFor(role);
                final selected = _selectedRole?.id == role.id;
                return _RoleCard(
                  label: meta.label,
                  description: role.description,
                  icon: meta.icon,
                  color: meta.color,
                  isSelected: selected,
                  onTap: () => setState(() => _selectedRole = role),
                );
              },
            );
          }),
        ),

        // Footer
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedRole != null ? _goToForm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Continue',
                          style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text('Select one role to continue',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.pop(),
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    children: [
                      TextSpan(text: 'Sign in',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 2: Registration form ────────────────────────────────

  Widget _buildForm() {
    final meta = _metaFor(_selectedRole!);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selected role badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: meta.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: meta.color.withValues(alpha: 0.30)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(meta.icon, color: meta.color, size: 16),
                    const SizedBox(width: 8),
                    Text(meta.label,
                        style: AppTextStyles.labelMedium.copyWith(
                            color: meta.color, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Create Your Account',
                style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900, fontSize: 26),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text('Fill in your details to get started',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 28),

            // Form card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.glassBorder),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 32, offset: const Offset(0, 12)),
                ],
              ),
              child: Column(
                children: [
                  _Field(ctrl: _fullNameCtrl, label: 'Full Name',
                      hint: 'Muhammad Umair', icon: Icons.person_outline_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                  const SizedBox(height: 18),
                  _Field(ctrl: _emailCtrl, label: 'Email Address',
                      hint: 'you@example.com', icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      }),
                  const SizedBox(height: 18),
                  _Field(ctrl: _phoneCtrl, label: 'Phone Number',
                      hint: '05XXXXXXXX', icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 18),
                  _Field(ctrl: _passwordCtrl, label: 'Password',
                      hint: 'Min. 8 characters', icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary, size: 20),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) => (v == null || v.length < 8)
                          ? 'Password must be at least 8 characters' : null),
                ],
              ),
            ),

            if (_submitError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                ),
                child: Text(_errorMsg(_submitError!),
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center),
              ),
            ],

            const SizedBox(height: 28),

            // Submit button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Create Account',
                        style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    children: [
                      TextSpan(text: 'Sign in',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ROLE CARD
// ─────────────────────────────────────────────────────────────

class _RoleCard extends StatefulWidget {
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  const _RoleCard({
    required this.label, required this.description,
    required this.icon, required this.color,
    required this.isSelected, required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 130));
    _s = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sel = widget.isSelected;
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) { _c.reverse(); widget.onTap(); },
      onTapCancel: () => _c.reverse(),
      child: AnimatedBuilder(
        animation: _s,
        builder: (_, child) => Transform.scale(scale: _s.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: sel ? widget.color.withValues(alpha: 0.08) : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: sel ? widget.color : AppColors.divider, width: sel ? 2 : 1),
            boxShadow: sel
                ? [BoxShadow(color: widget.color.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 6))]
                : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Stack(
            children: [
              if (sel)
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 25),
                    ),
                    const SizedBox(height: 10),
                    Text(widget.label,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelLarge.copyWith(
                            color: sel ? widget.color : AppColors.textPrimary,
                            fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 3),
                    Text(widget.description,
                        textAlign: TextAlign.center,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary, fontSize: 10, height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SHARED FORM FIELD
// ─────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.ctrl, required this.label,
    required this.hint, required this.icon,
    this.obscureText = false, this.suffixIcon,
    this.keyboardType, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 7),
        TextFormField(
          controller: ctrl,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            suffixIcon: suffixIcon,
            filled: true, fillColor: AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: AppColors.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: AppColors.primary, width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: AppColors.error)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  GLOW ORBS BACKGROUND
// ─────────────────────────────────────────────────────────────

class _GlowOrbs extends StatelessWidget {
  final AnimationController controller;
  final Size size;
  const _GlowOrbs({required this.controller, required this.size});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Stack(
        children: [
          Positioned(
            top: -size.height * 0.1 + controller.value * 20,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8, height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.primary.withValues(alpha: 0),
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.1 - controller.value * 30,
            left: -size.width * 0.3,
            child: Container(
              width: size.width, height: size.width,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.accent.withValues(alpha: 0.08),
                  AppColors.accent.withValues(alpha: 0),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ROLE METADATA
// ─────────────────────────────────────────────────────────────

class _RoleMeta {
  final String label;
  final IconData icon;
  final Color color;
  const _RoleMeta(this.label, this.icon, this.color);
}
