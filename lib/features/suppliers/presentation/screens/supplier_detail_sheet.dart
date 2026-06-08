import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../domain/entities/supplier_entity.dart';

class SupplierDetailSheet extends StatelessWidget {
  final SupplierEntity supplier;
  const SupplierDetailSheet({super.key, required this.supplier});

  static void show(BuildContext context, SupplierEntity supplier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SupplierDetailSheet(supplier: supplier),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 40,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Drag handle ─────────────────────────────
              _DragHandle(),

              // ── Gradient header ──────────────────────────
              _SupplierHeader(supplier: supplier),

              // ── Scrollable body ──────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                  children: [
                    // Contact card
                    _DetailCard(
                      icon: Icons.contacts_rounded,
                      iconColor: AppColors.accent,
                      title: 'Contact Information',
                      children: [
                        if (supplier.contactPerson != null)
                          _DetailRow(
                            icon: Icons.person_rounded,
                            label: 'Contact Person',
                            value: supplier.contactPerson!,
                          ),
                        if (supplier.email != null)
                          _DetailRow(
                            icon: Icons.email_rounded,
                            label: 'Email',
                            value: supplier.email!,
                            copyable: true,
                          ),
                        if (supplier.phone != null)
                          _DetailRow(
                            icon: Icons.phone_rounded,
                            label: 'Phone',
                            value: supplier.phone!,
                            copyable: true,
                          ),
                        if (supplier.address != null)
                          _DetailRow(
                            icon: Icons.location_on_rounded,
                            label: 'Address',
                            value: supplier.address!,
                          ),
                        if (supplier.contactPerson == null &&
                            supplier.email == null &&
                            supplier.phone == null &&
                            supplier.address == null)
                          _EmptyRow(message: 'No contact details provided'),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Notes card
                    if (supplier.notes != null && supplier.notes!.isNotEmpty)
                      _DetailCard(
                        icon: Icons.sticky_note_2_rounded,
                        iconColor: AppColors.highlight,
                        title: 'Notes',
                        children: [_NoteRow(text: supplier.notes!)],
                      ),

                    if (supplier.notes != null && supplier.notes!.isNotEmpty)
                      const SizedBox(height: 14),

                    // Record info card
                    _DetailCard(
                      icon: Icons.info_outline_rounded,
                      iconColor: AppColors.primary,
                      title: 'Record Information',
                      children: [
                        _DetailRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Created',
                          value: DateFormat('dd MMM yyyy · HH:mm')
                              .format(supplier.createdAt.toLocal()),
                        ),
                        _DetailRow(
                          icon: Icons.update_rounded,
                          label: 'Last Updated',
                          value: DateFormat('dd MMM yyyy · HH:mm')
                              .format(supplier.updatedAt.toLocal()),
                        ),
                        _DetailRow(
                          icon: Icons.fingerprint_rounded,
                          label: 'Supplier ID',
                          value: supplier.id,
                          mono: true,
                          copyable: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SupplierHeader extends StatelessWidget {
  final SupplierEntity supplier;
  const _SupplierHeader({required this.supplier});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.12),
            AppColors.primary.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.accentDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.business_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier.name,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _MiniChip(
                      label: 'Supplier',
                      color: AppColors.accent,
                      icon: Icons.local_shipping_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.close_rounded,
                  color: AppColors.textSecondary, size: 18),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Shared premium widgets
// ─────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.dividerStrong,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _DetailCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 15),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),
          // Rows
          ...children.asMap().entries.map((e) => Column(
                children: [
                  e.value,
                  if (e.key < children.length - 1)
                    Divider(
                        height: 1,
                        indent: 52,
                        endIndent: 16,
                        color: AppColors.divider),
                ],
              )),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool mono;
  final bool copyable;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.mono = false,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: AppColors.textTertiary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: mono
                      ? AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontFamily: 'monospace',
                          fontSize: 11,
                          letterSpacing: 0.3,
                        )
                      : AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
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

class _NoteRow extends StatelessWidget {
  final String text;
  const _NoteRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          height: 1.6,
        ),
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final String message;
  const _EmptyRow({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textTertiary,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _MiniChip(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
