import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

import '../cubit/add_banner_cubit.dart';
import '../models/banner_model.dart';
import 'banner_common_widgets.dart';

class ViewDeleteBanners extends StatefulWidget {
  const ViewDeleteBanners({super.key});

  @override
  State<ViewDeleteBanners> createState() => _ViewDeleteBannersState();
}

class _ViewDeleteBannersState extends State<ViewDeleteBanners> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AddBannerCubit>().fetchBannersIfNeeded();
    });
  }

  void _viewNetworkBanner(String imageUrl) {
    showBannerPreviewDialog(
      context: context,
      image: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, error, stackTrace) => Container(
          color: AppColors.screenBg,
          padding: const EdgeInsets.all(32),
          child: const Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteBanner(BannerModel banner) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delete Banner',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Delete Banner #${banner.bannerId}? This cannot be undone.',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;
    context.read<AddBannerCubit>().deleteBanner(bannerId: banner.bannerId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddBannerCubit, AddBannerState>(
      listenWhen: (previous, current) =>
          current is GetBannersFailure ||
          current is DeleteBannerSuccess ||
          current is DeleteBannerFailure,
      listener: (context, state) {
        if (state is GetBannersFailure) {
          AppToast.error(state.message, context: context);
        } else if (state is DeleteBannerSuccess) {
          AppToast.success(state.message, context: context);
        } else if (state is DeleteBannerFailure) {
          AppToast.error(state.message, context: context);
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddBannerCubit>();
        final banners =
            state is GetBannersSuccess ? state.banners : cubit.banners;
        final isFetching = state is GetBannersLoading;
        final deletingBannerId =
            state is DeleteBannerLoading ? state.bannerId : null;

        if (isFetching && banners.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accent,
              ),
            ),
          );
        }

        if (banners.isEmpty) {
          return _EmptyBannersState(
            onRefresh: () => context.read<AddBannerCubit>().fetchBanners(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'All Banners',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                BannerCountChip(count: banners.length),
                const Spacer(),
                if (isFetching)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  )
                else
                  InkWell(
                    onTap: () => context.read<AddBannerCubit>().fetchBanners(),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.refresh_rounded,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Refresh',
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            BannerGrid(
              itemCount: banners.length,
              itemBuilder: (context, index, itemWidth) {
                final banner = banners[index];
                final imageUrl = banner.bannerImageUrl;
                return SizedBox(
                  width: itemWidth,
                  child: _UploadedBannerCard(
                    banner: banner,
                    imageUrl: imageUrl,
                    isDeleting: deletingBannerId == banner.bannerId,
                    enabled: deletingBannerId == null,
                    onView: imageUrl == null || imageUrl.isEmpty
                        ? null
                        : () => _viewNetworkBanner(imageUrl),
                    onDelete: () => _confirmDeleteBanner(banner),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _EmptyBannersState extends StatelessWidget {
  const _EmptyBannersState({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.screenBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.image_outlined,
            size: 36,
            color: AppColors.textMuted.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          Text(
            'No banners uploaded yet',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Switch to Add to upload your first banner image',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onRefresh,
            child: Text(
              'Refresh',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadedBannerCard extends StatelessWidget {
  const _UploadedBannerCard({
    required this.banner,
    required this.imageUrl,
    required this.isDeleting,
    required this.enabled,
    this.onView,
    required this.onDelete,
  });

  final BannerModel banner;
  final String? imageUrl;
  final bool isDeleting;
  final bool enabled;
  final VoidCallback? onView;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.screenBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, error, stackTrace) => const ColoredBox(
                      color: Color(0xFFF0EEF3),
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textMuted,
                      ),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const ColoredBox(
                        color: Color(0xFFF0EEF3),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                  const ColoredBox(
                    color: Color(0xFFF0EEF3),
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textMuted,
                    ),
                  ),
                if (onView != null)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(onTap: enabled ? onView : null),
                  ),
                if (onView != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Material(
                      color: AppColors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: enabled ? onView : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.visibility_outlined,
                                size: 14,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'View',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    elevation: 1,
                    child: InkWell(
                      onTap: enabled && !isDeleting ? onDelete : null,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: isDeleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.error,
                                ),
                              )
                            : const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: AppColors.error,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Text(
              'Banner #${banner.bannerId}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
