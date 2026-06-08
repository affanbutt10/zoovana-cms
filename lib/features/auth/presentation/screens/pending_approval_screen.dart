import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';

// ═══════════════════════════════════════════════════════════════
//  PENDING APPROVAL SCREEN
//  Matches the website's "Account Setup Pending" design.
// ═══════════════════════════════════════════════════════════════

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  bool _isRefreshing = false;
  String? _refreshError;

  // User info restored from local storage
  String _email = '';
  String _fullName = '';
  String _roleName = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final ls = GetIt.instance<LocalStorageService>();
    final email = await ls.getString(LocalStorageKeys.email) ?? '';
    final fullName = await ls.getString(LocalStorageKeys.fullName) ?? '';
    final roleName = await ls.getString(LocalStorageKeys.zoovanaRoleName) ?? '';
    if (mounted) {
      setState(() {
        _email = email;
        _fullName = fullName;
        _roleName = roleName;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() { _isRefreshing = true; _refreshError = null; });

    final repo = GetIt.instance<AuthRepository>();
    final result = await repo.getRoles();

    if (!mounted) return;
    setState(() => _isRefreshing = false);

    switch (result) {
      case Success():
        // Roles loaded — account may now be active, re-trigger auth check
        Get.find<AuthController>().status.value = AuthStatus.authenticated;
      case Failure(:final error):
        setState(() => _refreshError = error.networkError
            ? 'No internet connection.'
            : 'Your account is still pending approval.');
    }
  }

  Future<void> _logout() async {
    await Get.find<AuthController>().logout();
  }

  Future<void> _launchPhone() async {
    await Clipboard.setData(const ClipboardData(text: '+966500000000'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Phone number copied to clipboard'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _launchEmail() async {
    await Clipboard.setData(const ClipboardData(text: 'admin@zoovana.com'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email address copied to clipboard'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final horizontalPadding = screenWidth < 360 ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F0), // warm cream bg matching screenshot
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isSmallScreen ? 12 : 24,
          ),
          child: Column(
            children: [
              // ── Logo ──────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogoTile(size: 44, radius: 12, showShadow: false),
                  const SizedBox(width: 10),
                  Text(
                    'Zoovana',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 16 : 28),

              // ── Main card ─────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: isSmallScreen ? 20 : 32),

                    // Clock icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.highlight.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.access_time_rounded,
                        size: 32,
                        color: AppColors.highlight,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      'Account Setup Pending',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Text(
                        'Your account has been created but your business setup is not yet complete.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    if (_fullName.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Hello, $_fullName!',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    SizedBox(height: isSmallScreen ? 12 : 20),

                    // ── Account Details card ─────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Details',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_email.isNotEmpty)
                              _DetailRow(
                                icon: Icons.email_outlined,
                                color: AppColors.primary,
                                text: _email,
                              ),
                            if (_roleName.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _DetailRow(
                                icon: Icons.shield_outlined,
                                color: AppColors.secondary,
                                text: 'Role: $_roleName',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 10 : 14),

                    // ── What Happens Next card ───────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.highlight.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What Happens Next',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: const Color(0xFFB45309),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _NextStep(
                              number: '1.',
                              text: 'Admin reviews your registration',
                            ),
                            const SizedBox(height: 6),
                            _NextStep(
                              number: '2.',
                              text: 'Full dashboard access is enabled after approval',
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 10 : 14),

                    // ── Info message ─────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.40),
                          ),
                        ),
                        child: Text(
                          'Your shelter or shop has not been created yet. '
                          'Please complete the registration process or wait for '
                          'your account to be fully set up.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF92400E),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 10 : 14),

                    // ── SuperAdmin Contact card ───────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.highlight.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'SuperAdmin Contact',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: const Color(0xFFB45309),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            screenWidth < 400
                                ? Column(
                                    children: [
                                      _ContactBtn(
                                        icon: Icons.phone_rounded,
                                        label: '+966 50 000 0000',
                                        onTap: _launchPhone,
                                      ),
                                      const SizedBox(height: 8),
                                      _ContactBtn(
                                        icon: Icons.email_rounded,
                                        label: 'admin@zoovana.com',
                                        onTap: _launchEmail,
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: _ContactBtn(
                                          icon: Icons.phone_rounded,
                                          label: '+966 50 000 0000',
                                          onTap: _launchPhone,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _ContactBtn(
                                          icon: Icons.email_rounded,
                                          label: 'admin@zoovana.com',
                                          onTap: _launchEmail,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 14 : 20),

                    // ── Error message ────────────────────────
                    if (_refreshError != null)
                      Padding(
                        padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 12),
                        child: Text(
                          _refreshError!,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // ── Buttons ──────────────────────────────
                    Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 24),
                      child: screenWidth < 380
                          ? Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: _isRefreshing ? null : _refresh,
                                    icon: _isRefreshing
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                color: Colors.white, strokeWidth: 2))
                                        : const Icon(Icons.refresh_rounded, size: 18),
                                    label: Text(
                                      'Refresh Status',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton.icon(
                                    onPressed: _logout,
                                    icon: const Icon(Icons.logout_rounded, size: 18),
                                    label: Text(
                                      'Log Out',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textPrimary,
                                      side: BorderSide(color: AppColors.divider),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isRefreshing ? null : _refresh,
                                    icon: _isRefreshing
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                color: Colors.white, strokeWidth: 2))
                                        : const Icon(Icons.refresh_rounded, size: 18),
                                    label: Text(
                                      'Refresh Status',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _logout,
                                    icon: const Icon(Icons.logout_rounded, size: 18),
                                    label: Text(
                                      'Log Out',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textPrimary,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      side: BorderSide(color: AppColors.divider),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isSmallScreen ? 12 : 20),
              Text(
                'Need help? Contact our support team.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _DetailRow({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _NextStep extends StatelessWidget {
  final String number;
  final String text;
  const _NextStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(number,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFFB45309),
              fontWeight: FontWeight.w700,
            )),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFFB45309),
                height: 1.4,
              )),
        ),
      ],
    );
  }
}

class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ContactBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: const Color(0xFFB45309)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFFB45309),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
