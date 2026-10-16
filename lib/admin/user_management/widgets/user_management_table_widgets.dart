import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class UserManagementTableCard extends StatelessWidget {
  const UserManagementTableCard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBg),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class UserManagementHeaderRow extends StatelessWidget {
  const UserManagementHeaderRow({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: children),
    );
  }
}

class UserManagementHeaderCell extends StatelessWidget {
  const UserManagementHeaderCell(
    this.title, {
    super.key,
    required this.flex,
    this.align = TextAlign.left,
  });

  final String title;
  final int flex;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: align,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class UserManagementDataCell extends StatelessWidget {
  const UserManagementDataCell(
    this.text, {
    super.key,
    required this.flex,
  });

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class UserManagementStatusBadge extends StatelessWidget {
  const UserManagementStatusBadge({
    super.key,
    required this.label,
    this.tone = UserManagementBadgeTone.neutral,
  });

  final String label;
  final UserManagementBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      UserManagementBadgeTone.success => (
          AppColors.green.withValues(alpha: 0.12),
          AppColors.green,
        ),
      UserManagementBadgeTone.danger => (
          AppColors.error.withValues(alpha: 0.10),
          AppColors.error,
        ),
      UserManagementBadgeTone.warning => (
          const Color(0xFFFFF3E8),
          const Color(0xFFE89A3C),
        ),
      UserManagementBadgeTone.neutral => (
          AppColors.textMuted.withValues(alpha: 0.14),
          AppColors.textPrimary,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

enum UserManagementBadgeTone { success, danger, warning, neutral }

class UserManagementTableFrame extends StatefulWidget {
  const UserManagementTableFrame({
    super.key,
    required this.minTableWidth,
    required this.header,
    required this.rowCount,
    required this.rowBuilder,
    required this.emptyMessage,
  });

  final double minTableWidth;
  final Widget header;
  final int rowCount;
  final Widget Function(BuildContext context, int index) rowBuilder;
  final String emptyMessage;

  @override
  State<UserManagementTableFrame> createState() =>
      _UserManagementTableFrameState();
}

class _UserManagementTableFrameState extends State<UserManagementTableFrame> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth < widget.minTableWidth
            ? widget.minTableWidth
            : constraints.maxWidth;

        return Scrollbar(
          controller: _horizontalController,
          thumbVisibility: tableWidth > constraints.maxWidth,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  widget.header,
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.screenBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBg),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      height: 540,
                      child: widget.rowCount == 0
                          ? Center(
                              child: Text(
                                widget.emptyMessage,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            )
                          : Scrollbar(
                              controller: _verticalController,
                              thumbVisibility: true,
                              child: ListView.separated(
                                controller: _verticalController,
                                padding: EdgeInsets.zero,
                                itemCount: widget.rowCount,
                                separatorBuilder: (_, _) => const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: AppColors.cardBg,
                                ),
                                itemBuilder: widget.rowBuilder,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
