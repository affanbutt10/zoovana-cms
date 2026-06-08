import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/dio_factory.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/branch_remote_datasource.dart';
import '../../data/repositories/branch_repository_impl.dart';
import '../../domain/entities/branch_entity.dart';

// ═══════════════════════════════════════════════════════════════
//  BRANCHES SCREEN
//  - Fetches real data from GET /api/v1/branches
//  - Search / filter client-side
//  - FAB opens 2-step bottom sheet to create a branch
//  - POST /api/v1/branches on submit
// ═══════════════════════════════════════════════════════════════

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  late final BranchRepository _repo;

  List<BranchEntity> _all = [];
  List<BranchEntity> _filtered = [];
  bool _loading = true;
  String? _error;
  String _query = '';

  // pagination
  int _page = 1;
  bool _hasNext = false;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    // Use the properly configured shop Dio — includes AuthInterceptor
    // which injects Bearer token and handles 401 refresh automatically.
    final shopDio = DioFactory.createShopDio(
      secureStorage: Get.find<SecureStorageService>(),
      localStorage: Get.find<LocalStorageService>(),
      onForceSignOut: () {
        if (kDebugMode) debugPrint('[Branches] Force sign-out triggered');
      },
    );
    _repo = BranchRepository(BranchRemoteDataSourceImpl(shopDio));
    if (kDebugMode) {
      debugPrint('[Branches] Initialized with shop base URL: '
          '${shopDio.options.baseUrl}');
    }
    _load();
  }

  Future<void> _load({int page = 1}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _repo.getBranches(page: page);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _all = data.branches;
          _total = data.meta.total;
          _hasNext = data.meta.hasNext;
          _page = data.meta.page;
          _loading = false;
          _applyFilter();
        });
      case Failure(:final error):
        setState(() {
          _error = error.message;
          _loading = false;
        });
    }
  }

  void _applyFilter() {
    final q = _query.toLowerCase();
    _filtered = q.isEmpty
        ? List.from(_all)
        : _all
            .where((b) =>
                b.nameEn.toLowerCase().contains(q) ||
                b.nameAr.contains(q) ||
                b.contactEmail.toLowerCase().contains(q) ||
                b.slug.toLowerCase().contains(q))
            .toList();
  }

  void _onSearch(String v) {
    setState(() {
      _query = v;
      _applyFilter();
    });
  }

  Future<void> _openCreateSheet() async {
    final created = await showModalBottomSheet<BranchEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateBranchSheet(repo: _repo),
    );
    if (created != null) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text('Add Branch',
            style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white, fontWeight: FontWeight.w700)),
        elevation: 4,
      ),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ─────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            shadowColor: AppColors.divider,
            elevation: 0,
            scrolledUnderElevation: 1,
            toolbarHeight: 60,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: 20),
              onPressed: () => context.pop(),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(Icons.account_tree_rounded,
                      color: AppColors.secondary, size: 17),
                ),
                const SizedBox(width: 10),
                Text('Branches',
                    style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800)),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$_total ${_total == 1 ? 'branch' : 'branches'}',
                      style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Search bar ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: _SearchField(onChanged: _onSearch),
            ),
          ),

          // ── Body ─────────────────────────────────────────
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: _Loader()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: _ErrorState(
                message: _error!,
                onRetry: () => _load(),
              ),
            )
          else if (_filtered.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(
                hasQuery: _query.isNotEmpty,
                onAdd: _openCreateSheet,
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              sliver: SliverList.separated(
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _BranchCard(branch: _filtered[i]),
              ),
            ),
            // Pagination row
            if (_all.length < _total)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_page > 1)
                        _PageBtn(
                          label: 'Previous',
                          onTap: () => _load(page: _page - 1),
                        ),
                      if (_page > 1 && _hasNext)
                        const SizedBox(width: 12),
                      if (_hasNext)
                        _PageBtn(
                          label: 'Next',
                          onTap: () => _load(page: _page + 1),
                          primary: true,
                        ),
                    ],
                  ),
                ),
              ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  BRANCH CARD
// ─────────────────────────────────────────────────────────────

class _BranchCard extends StatelessWidget {
  final BranchEntity branch;
  const _BranchCard({required this.branch});

  @override
  Widget build(BuildContext context) {
    final isActive = branch.isActive;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(Icons.store_rounded,
                        color: AppColors.secondary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch.nameEn,
                          style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          branch.slug,
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textTertiary, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(active: isActive),
                ],
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),
              // Contact row
              Row(
                children: [
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.email_outlined,
                      label: branch.contactEmail,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.phone_outlined,
                    label: branch.contactPhone,
                  ),
                ],
              ),
              if (branch.address != null &&
                  branch.address!.displayAddress.isNotEmpty) ...[
                const SizedBox(height: 8),
                _InfoChip(
                  icon: Icons.location_on_outlined,
                  label: branch.address!.displayAddress,
                ),
              ],
              const SizedBox(height: 10),
              // Footer
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 13, color: AppColors.textTertiary),
                  const SizedBox(width: 5),
                  Text(
                    'Created ${branch.formattedDate}',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary, fontSize: 11),
                  ),
                  const Spacer(),
                  // Edit
                  _ActionIconBtn(
                    icon: Icons.edit_outlined,
                    color: AppColors.primary,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  // Delete
                  _ActionIconBtn(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.error,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool active;
  const _StatusBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.success : AppColors.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            active ? 'Active' : 'Inactive',
            style: AppTextStyles.labelSmall.copyWith(
                color: color, fontWeight: FontWeight.w700, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionIconBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SEARCH FIELD
// ─────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search branches...',
          hintStyle: AppTextStyles.bodySmall
              .copyWith(color: AppColors.textTertiary),
          prefixIcon: Icon(Icons.search_rounded,
              color: AppColors.textSecondary, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  STATES
// ─────────────────────────────────────────────────────────────

class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
        const SizedBox(height: 16),
        Text('Loading branches...',
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wifi_off_rounded,
                color: AppColors.error, size: 30),
          ),
          const SizedBox(height: 16),
          Text('Something went wrong',
              style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasQuery;
  final VoidCallback onAdd;
  const _EmptyState({required this.hasQuery, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_tree_rounded,
                color: AppColors.secondary, size: 34),
          ),
          const SizedBox(height: 16),
          Text(
            hasQuery ? 'No results found' : 'No branches yet',
            style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            hasQuery
                ? 'Try adjusting your search'
                : 'Add your first branch to get started',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          if (!hasQuery) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Branch'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary;
  const _PageBtn(
      {required this.label, required this.onTap, this.primary = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? AppColors.primary : AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(label,
              style: AppTextStyles.labelMedium.copyWith(
                  color: primary ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CREATE BRANCH BOTTOM SHEET  — 2-step wizard
//  Step 1: Basic Info (name EN/AR, slug, descriptions)
//  Step 2: Contact Info (email, phone, address)
// ═══════════════════════════════════════════════════════════════

class _CreateBranchSheet extends StatefulWidget {
  final BranchRepository repo;
  const _CreateBranchSheet({required this.repo});

  @override
  State<_CreateBranchSheet> createState() => _CreateBranchSheetState();
}

class _CreateBranchSheetState extends State<_CreateBranchSheet> {
  final _pageCtrl = PageController();
  int _step = 0; // 0 = Basic Info, 1 = Contact Info

  // Step 1 controllers
  final _nameEnCtrl = TextEditingController();
  final _nameArCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _descEnCtrl = TextEditingController();
  final _descArCtrl = TextEditingController();

  // Step 2 controllers
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  bool _submitting = false;
  String? _submitError;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameEnCtrl.dispose();
    _nameArCtrl.dispose();
    _slugCtrl.dispose();
    _descEnCtrl.dispose();
    _descArCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  // Auto-generate slug from English name
  void _onNameEnChanged(String v) {
    final slug = v
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
    _slugCtrl.text = slug;
  }

  void _goNext() {
    if (_step1Key.currentState?.validate() ?? false) {
      setState(() => _step = 1);
      _pageCtrl.animateToPage(1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic);
    }
  }

  void _goBack() {
    setState(() => _step = 0);
    _pageCtrl.animateToPage(0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic);
  }

  Future<void> _submit() async {
    if (!(_step2Key.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _submitError = null;
    });

    final payload = {
      'name_en': _nameEnCtrl.text.trim(),
      'name_ar': _nameArCtrl.text.trim(),
      'slug': _slugCtrl.text.trim(),
      'description_en': _descEnCtrl.text.trim(),
      'description_ar': _descArCtrl.text.trim(),
      'contact_email': _emailCtrl.text.trim(),
      'contact_phone': _phoneCtrl.text.trim(),
      'address': {
        'street': _streetCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'country': 'SA',
        'postal_code': '',
      },
    };

    final result = await widget.repo.createBranch(payload);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        Navigator.of(context).pop(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Branch "${data.nameEn}" created successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      case Failure(:final error):
        setState(() {
          _submitting = false;
          _submitError = error.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.account_tree_rounded,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Create Your Branch',
                          style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 18)),
                      Text('Set up your branch to start selling on Zoovana',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Step indicator
          _StepIndicator(currentStep: _step),
          const SizedBox(height: 20),

          // Pages
          SizedBox(
            height: 380,
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step1Form(
                  formKey: _step1Key,
                  nameEnCtrl: _nameEnCtrl,
                  nameArCtrl: _nameArCtrl,
                  slugCtrl: _slugCtrl,
                  descEnCtrl: _descEnCtrl,
                  descArCtrl: _descArCtrl,
                  onNameEnChanged: _onNameEnChanged,
                ),
                _Step2Form(
                  formKey: _step2Key,
                  emailCtrl: _emailCtrl,
                  phoneCtrl: _phoneCtrl,
                  streetCtrl: _streetCtrl,
                  cityCtrl: _cityCtrl,
                  error: _submitError,
                ),
              ],
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: _step == 0
                ? _PrimaryButton(
                    label: 'Next',
                    onTap: _goNext,
                    loading: false,
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _OutlineButton(
                          label: 'Back',
                          onTap: _submitting ? null : _goBack,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _PrimaryButton(
                          label: 'Create Branch',
                          onTap: _submitting ? null : _submit,
                          loading: _submitting,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _StepDot(index: 0, current: currentStep, label: 'Basic Info'),
          Expanded(
            child: Container(
              height: 2,
              color: currentStep >= 1
                  ? AppColors.primary
                  : AppColors.divider,
            ),
          ),
          _StepDot(index: 1, current: currentStep, label: 'Contact Info'),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final int current;
  final String label;
  const _StepDot(
      {required this.index, required this.current, required this.label});

  @override
  Widget build(BuildContext context) {
    final done = current > index;
    final active = current == index;
    final color = (done || active) ? AppColors.primary : AppColors.divider;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 16)
                : Text('${index + 1}',
                    style: AppTextStyles.labelMedium.copyWith(
                        color: (done || active)
                            ? Colors.white
                            : AppColors.textTertiary,
                        fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: AppTextStyles.labelSmall.copyWith(
                color: (done || active)
                    ? AppColors.primary
                    : AppColors.textTertiary,
                fontWeight:
                    active ? FontWeight.w700 : FontWeight.w400,
                fontSize: 11)),
      ],
    );
  }
}

// ── Step 1 form ───────────────────────────────────────────────

class _Step1Form extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameEnCtrl;
  final TextEditingController nameArCtrl;
  final TextEditingController slugCtrl;
  final TextEditingController descEnCtrl;
  final TextEditingController descArCtrl;
  final ValueChanged<String> onNameEnChanged;

  const _Step1Form({
    required this.formKey,
    required this.nameEnCtrl,
    required this.nameArCtrl,
    required this.slugCtrl,
    required this.descEnCtrl,
    required this.descArCtrl,
    required this.onNameEnChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _FormField(
                    label: 'Branch Name (English)',
                    hint: 'Enter branch name in English',
                    controller: nameEnCtrl,
                    required: true,
                    onChanged: onNameEnChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    label: 'Branch Name (Arabic)',
                    hint: 'أدخل اسم الفرع بالعربية',
                    controller: nameArCtrl,
                    required: true,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FormField(
              label: 'Branch URL',
              hint: 'auto-generated',
              controller: slugCtrl,
              required: true,
              prefix: 'zoovana.com/',
              helperText: 'Auto-generated from English branch name',
            ),
            const SizedBox(height: 14),
            _FormField(
              label: 'Description (English)',
              hint: 'Tell customers about your branch in English...',
              controller: descEnCtrl,
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            _FormField(
              label: 'Description (Arabic)',
              hint: 'أخبر العملاء عن فرعك بالعربية...',
              controller: descArCtrl,
              maxLines: 3,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 2 form ───────────────────────────────────────────────

class _Step2Form extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController streetCtrl;
  final TextEditingController cityCtrl;
  final String? error;

  const _Step2Form({
    required this.formKey,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.streetCtrl,
    required this.cityCtrl,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _FormField(
                    label: 'Contact Email',
                    hint: 'branch@example.com',
                    controller: emailCtrl,
                    required: true,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    label: 'Contact Phone',
                    hint: '05XXXXXXXX',
                    controller: phoneCtrl,
                    required: true,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FormField(
              label: 'Street Address',
              hint: 'Enter your branch address',
              controller: streetCtrl,
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 14),
            _FormField(
              label: 'City',
              hint: 'e.g. Riyadh',
              controller: cityCtrl,
              prefixIcon: Icons.location_city_outlined,
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(error!,
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.error)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shared form field ─────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final String? prefix;
  final String? helperText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textDirection,
    this.prefix,
    this.helperText,
    this.prefixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 5),
            ],
            Text(label,
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
            if (required)
              Text(' *',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.error, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textDirection: textDirection,
          onChanged: onChanged,
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.textPrimary, fontSize: 13),
          validator: validator ??
              (required
                  ? (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null
                  : null),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textTertiary, fontSize: 12),
            prefixText: prefix,
            prefixStyle: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary, fontSize: 12),
            helperText: helperText,
            helperStyle: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary, fontSize: 10),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
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
              borderSide:
                  BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Buttons ───────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  const _PrimaryButton(
      {required this.label, required this.onTap, required this.loading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(label,
                style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}
