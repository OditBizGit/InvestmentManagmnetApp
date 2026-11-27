import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_stat_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_main_screen_layout.dart';

import 'cubit/collection_aging_cubit.dart';
import 'repository/collection_aging_repository.dart';
import 'widgets/collection_aging_content.dart';

class CollectionAgingScreen extends StatefulWidget {
  const CollectionAgingScreen({super.key, this.isActive = false});

  /// True while this tab is visible in the admin IndexedStack.
  final bool isActive;

  @override
  State<CollectionAgingScreen> createState() => _CollectionAgingScreenState();
}

class _CollectionAgingScreenState extends State<CollectionAgingScreen> {
  late final CollectionAgingCubit _cubit;

  /// Bumped on re-activation so the content remounts with default filters.
  int _resetKey = 0;

  @override
  void initState() {
    super.initState();
    _cubit = CollectionAgingCubit(CollectionAgingRepository(getIt<Dio>()));
    _refreshIfActive();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CollectionAgingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      setState(() => _resetKey++);
      _refreshIfActive();
    }
  }

  void _refreshIfActive() {
    if (!widget.isActive) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isActive) return;
      final now = DateTime.now();
      _cubit.load(DateTime(now.year, now.month, now.day));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 24.0;

          return BlocProvider.value(
            value: _cubit,
            child: AdminMainScreenLayout(
              horizontalPadding: horizontalPadding,
              body: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const UserManagementSectionHeader(
                      title: 'Collection Aging',
                      subtitle: 'Overdue installments by age',
                    ),
                    const SizedBox(height: 18),
                    CollectionAgingContent(key: ValueKey(_resetKey)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
