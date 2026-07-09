import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/ios_dashboard_chrome.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/role_dashboard_drawer.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../data/models/volunteer_application_model.dart';
import '../../domain/entities/volunteer_shift_entity.dart';
import '../controllers/volunteer_controller.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  State<VolunteerDashboardScreen> createState() =>
      _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  late final VolunteerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<VolunteerController>();
    if (_controller.status.value == VolunteerStatus.idle) {
      _controller.loadDashboard();
      _controller.loadShelters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const RoleDashboardDrawer(),
      onDrawerChanged: RoleDashboardDrawerController.setOpen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: buildFrostedAppBarBackground(),
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.divider,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: Builder(
          builder: (context) => Center(
            child: IosIconButton(
              tooltip: 'Open menu',
              icon: CupertinoIcons.line_horizontal_3,
              onTap: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        titleSpacing: 16,
        title: Row(
          children: [
            const AppLogoTile(size: 32, radius: 8, showShadow: false),
            const SizedBox(width: 10),
            Text(
              'Volunteer Hub',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (_controller.status.value == VolunteerStatus.loading) {
          return const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: RoleDashboardSkeleton(),
          );
        }
        if (_controller.status.value == VolunteerStatus.error) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 120),
            children: [
              RoleStatePanel(
                title: 'Volunteer activity is unavailable',
                message: _controller.errorMessage.value,
                icon: Icons.cloud_off_outlined,
                actionLabel: 'Try again',
                onAction: _controller.loadDashboard,
              ),
            ],
          );
        }
        return _ShiftsTab(controller: _controller);
      }),
    );
  }
}

class _ShiftsTab extends StatelessWidget {
  const _ShiftsTab({required this.controller});

  final VolunteerController controller;

  @override
  Widget build(BuildContext context) {
    final actionable = controller.shifts
        .where((shift) => shift.canSignIn || shift.canSignOut)
        .length;
    return RefreshIndicator(
      onRefresh: controller.loadDashboard,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          RoleDashboardHeader(
            eyebrow: 'Your volunteer impact',
            title: actionable > 0
                ? '$actionable shift ${actionable == 1 ? 'action is' : 'actions are'} ready'
                : 'Ready when your shelter needs you',
            subtitle:
                'Track your time, manage upcoming shifts, and keep your shelter team in sync.',
            icon: Icons.volunteer_activism_rounded,
            accent: AppColors.highlightLight,
            stats: [
              RoleHeroStat(
                label: 'Shifts',
                value: '${controller.shifts.length}',
                icon: CupertinoIcons.calendar_badge_plus,
              ),
              RoleHeroStat(
                label: 'Hours',
                value: '${controller.totalHours}',
                icon: CupertinoIcons.timer,
              ),
              RoleHeroStat(
                label: 'Action',
                value: '$actionable',
                icon: CupertinoIcons.bolt_fill,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: RoleMetricTile(
                  label: 'Total shifts',
                  value: '${controller.shifts.length}',
                  icon: Icons.event_available_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RoleMetricTile(
                  label: 'Hours served',
                  value: '${controller.totalHours}',
                  icon: Icons.timer_outlined,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RoleMetricTile(
                  label: 'Needs action',
                  value: '$actionable',
                  icon: Icons.bolt_rounded,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Your shifts',
            subtitle: controller.shifts.isEmpty
                ? 'Approved shifts will appear here'
                : 'Use attendance actions when your shift begins',
          ),
          const SizedBox(height: 12),
          if (controller.shifts.isEmpty)
            const RoleStatePanel(
              title: 'No shifts scheduled',
              message:
                  'When your shelter assigns a shift, it will appear here with attendance actions.',
              icon: Icons.event_busy_rounded,
            )
          else
            ...controller.shifts.map(
              (shift) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ShiftCard(shift: shift, controller: controller),
              ),
            ),
          const SizedBox(height: 24),
          _ApplyTab(controller: controller),
        ],
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({required this.shift, required this.controller});

  final VolunteerShiftEntity shift;
  final VolunteerController controller;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(shift.status);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surfaceAtElevation(1),
        border: Border.all(color: AppColors.divider.withValues(alpha: .82)),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  color: statusColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (shift.shelterName != null)
                      Text(
                        shift.shelterName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  shift.status,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          if (shift.notes != null) ...[
            const SizedBox(height: 12),
            Text(
              shift.notes!,
              style: AppTextStyles.bodySmall.copyWith(height: 1.4),
            ),
          ],
          if (shift.canSignIn || shift.canSignOut) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  if (!await requireAccount(
                    context,
                    action: shift.canSignIn
                        ? 'start a volunteer shift'
                        : 'end a volunteer shift',
                  )) {
                    return;
                  }
                  if (shift.canSignIn) {
                    controller.signIn(shift);
                  } else {
                    controller.signOut(shift);
                  }
                },
                icon: Icon(
                  shift.canSignIn ? Icons.login_rounded : Icons.logout_rounded,
                ),
                label: Text(shift.canSignIn ? 'Start shift' : 'End shift'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    final key = status.toLowerCase();
    if (key.contains('active') || key.contains('approved')) {
      return AppColors.success;
    }
    if (key.contains('pending') || key.contains('scheduled')) {
      return AppColors.warning;
    }
    if (key.contains('cancel') || key.contains('reject')) {
      return AppColors.error;
    }
    return AppColors.primary;
  }
}

class _ApplyTab extends StatefulWidget {
  const _ApplyTab({required this.controller});

  final VolunteerController controller;

  @override
  State<_ApplyTab> createState() => _ApplyTabState();
}

class _ApplyTabState extends State<_ApplyTab> {
  String? _shelterId;
  final _skills = <String>{'feeding'};
  final _availability = <String>{'weekends'};
  final _contactName = TextEditingController();
  final _contactPhone = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _contactName.dispose();
    _contactPhone.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!await requireAccount(context, action: 'submit an application')) {
      return;
    }
    if (_shelterId == null ||
        _contactName.text.trim().isEmpty ||
        _contactPhone.text.trim().isEmpty) {
      return;
    }
    await widget.controller.apply(
      VolunteerApplicationRequest(
        shelterId: _shelterId!,
        skills: _skills.toList(),
        availability: _availability.toList(),
        emergencyContactName: _contactName.text.trim(),
        emergencyContactPhone: _contactPhone.text.trim(),
        notes: _notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latest = widget.controller.latestApplication;
    if (latest != null && !latest.isRejected) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoleStatePanel(
            title: latest.isApproved
                ? 'You are approved to volunteer'
                : 'Your application is under review',
            message: latest.isApproved
                ? 'Your shelter can now schedule shifts for you. Check My Shifts for assignments.'
                : 'The shelter team is reviewing your application. Your status will update here.',
            icon: latest.isApproved
                ? Icons.verified_rounded
                : Icons.hourglass_top_rounded,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RoleDashboardHeader(
          eyebrow: 'Volunteer application',
          title: latest?.isRejected == true
              ? 'Choose your next opportunity'
              : 'Make a difference nearby',
          subtitle: latest?.isRejected == true
              ? (latest?.rejectionReason ??
                    'Update your availability and apply to a shelter that needs your skills.')
              : 'Share your skills and availability with a shelter accepting volunteer support.',
          icon: Icons.handshake_rounded,
          accent: AppColors.accentLight,
        ),
        const SizedBox(height: 24),
        const SectionHeader(
          title: 'Application details',
          subtitle: 'Select a shelter and tell them how you can help',
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _shelterId,
          decoration: const InputDecoration(labelText: 'Shelter'),
          items: widget.controller.shelters
              .where((shelter) => shelter.acceptingVolunteers)
              .map(
                (shelter) => DropdownMenuItem(
                  value: shelter.id,
                  child: Text(shelter.name),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _shelterId = value),
        ),
        const SizedBox(height: 12),
        _ChipSet(
          title: 'Skills',
          values: const ['feeding', 'cleaning', 'dog_walking', 'events'],
          selected: _skills,
          onChanged: () => setState(() {}),
        ),
        _ChipSet(
          title: 'Availability',
          values: const ['weekdays', 'weekends', 'mornings', 'evenings'],
          selected: _availability,
          onChanged: () => setState(() {}),
        ),
        TextField(
          controller: _contactName,
          decoration: const InputDecoration(
            labelText: 'Emergency contact name',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _contactPhone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Emergency contact phone',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notes,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Notes',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 18),
        Obx(() {
          final loading =
              widget.controller.mutationStatus.value ==
              VolunteerMutationStatus.loading;
          return SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: loading ? null : _submit,
              icon: const Icon(Icons.send_rounded),
              label: Text(
                loading ? 'Submitting application' : 'Submit application',
              ),
            ),
          );
        }),
        Obx(() {
          final error = widget.controller.mutationError.value;
          if (error.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(error, style: AppTextStyles.errorText),
          );
        }),
      ],
    );
  }
}

class _ChipSet extends StatelessWidget {
  const _ChipSet({
    required this.title,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<String> values;
  final Set<String> selected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelLarge),
          Wrap(
            spacing: 8,
            children: values
                .map(
                  (value) => FilterChip(
                    label: Text(value.replaceAll('_', ' ')),
                    selected: selected.contains(value),
                    onSelected: (isSelected) {
                      isSelected ? selected.add(value) : selected.remove(value);
                      onChanged();
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
