import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:sizer/sizer.dart';

import 'cubit/add_banner_cubit.dart';
import 'repository/add_banner_repository.dart';
import 'widgets/add_banner_form.dart';
import 'widgets/view_delete_banners.dart';

enum BannerScreenMode { add, view }

class AddBanner extends StatelessWidget {
  const AddBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddBannerCubit(
        addBannerRepository: AddBannerRepository(dio: getIt<Dio>()),
      ),
      child: const _AddBannerShell(),
    );
  }
}

class _AddBannerShell extends StatefulWidget {
  const _AddBannerShell();

  @override
  State<_AddBannerShell> createState() => _AddBannerShellState();
}

class _AddBannerShellState extends State<_AddBannerShell> {
  BannerScreenMode _mode = BannerScreenMode.add;

  void _setMode(BannerScreenMode mode) {
    setState(() => _mode = mode);
    if (mode == BannerScreenMode.view) {
      context.read<AddBannerCubit>().fetchBannersIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddBannerCubit, AddBannerState>(
      buildWhen: (previous, current) =>
          current is GetBannersSuccess ||
          current is GetBannersLoading ||
          current is DeleteBannerSuccess ||
          current is AddBannerSuccess,
      builder: (context, state) {
        final bannerCount = context.read<AddBannerCubit>().banners.length;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _mode == BannerScreenMode.add
                              ? 'Add Banner'
                              : 'Uploaded Banners',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _mode == BannerScreenMode.add
                              ? 'Upload banner images, preview them, and remove any you no longer need'
                              : 'Review banners already uploaded for the app home screen',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _BannerModeToggle(
                    mode: _mode,
                    bannerCount: bannerCount,
                    onChanged: _setMode,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (_mode == BannerScreenMode.add)
                AddBannerForm(
                  onUploadSuccess: () => _setMode(BannerScreenMode.view),
                )
              else
                const ViewDeleteBanners(),
            ],
          ),
        );
      },
    );
  }
}

class _BannerModeToggle extends StatelessWidget {
  const _BannerModeToggle({
    required this.mode,
    required this.bannerCount,
    required this.onChanged,
  });

  final BannerScreenMode mode;
  final int bannerCount;
  final ValueChanged<BannerScreenMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.screenBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            label: 'Add',
            selected: mode == BannerScreenMode.add,
            onTap: () => onChanged(BannerScreenMode.add),
          ),
          _ToggleChip(
            label: bannerCount > 0 ? 'View ($bannerCount)' : 'View',
            selected: mode == BannerScreenMode.view,
            onTap: () => onChanged(BannerScreenMode.view),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accent : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
