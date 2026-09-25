import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/add_banner_model.dart';
import '../models/banner_model.dart';
import '../repository/add_banner_repository.dart';

part 'add_banner_state.dart';

class AddBannerCubit extends Cubit<AddBannerState> {
  AddBannerCubit({
    required this.addBannerRepository,
  }) : super(const AddBannerInitial());

  final AddBannerRepository addBannerRepository;

  List<BannerModel> _banners = [];
  bool _bannersFetched = false;

  List<BannerModel> get banners => List.unmodifiable(_banners);

  bool get hasFetchedBanners => _bannersFetched;

  Future<void> fetchBannersIfNeeded() async {
    if (_bannersFetched || state is GetBannersLoading) return;
    await fetchBanners();
  }

  Future<void> fetchBanners() async {
    try {
      emit(const GetBannersLoading());
      log('AddBannerCubit: Fetching banners...');

      final result = await addBannerRepository.getBanners();

      if (result != null) {
        _banners = List<BannerModel>.from(result);
        _bannersFetched = true;
        log('AddBannerCubit: Loaded ${_banners.length} banners.');
        emit(GetBannersSuccess(List.unmodifiable(_banners)));
      } else {
        log('AddBannerCubit: Failed to fetch banners.');
        emit(
          const GetBannersFailure(
            'Failed to load banners. Please try again.',
          ),
        );
      }
    } catch (e, stackTrace) {
      log('AddBannerCubit Fetch Banners Error: $e', stackTrace: stackTrace);
      emit(
        GetBannersFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> addBanner({
    required MultipartFile image,
  }) async {
    try {
      emit(const AddBannerLoading());

      log('AddBannerCubit: Uploading banner...');
      final result = await addBannerRepository.addBanner(image: image);

      if (result != null && result.status != false) {
        final message = (result.message?.trim().isNotEmpty ?? false)
            ? result.message!.trim()
            : 'Banner uploaded successfully.';
        log('AddBannerCubit: Banner uploaded. id=${result.bannerId}');
        emit(
          AddBannerSuccess(
            banner: result,
            message: message,
            uploadedCount: 1,
          ),
        );
        await fetchBanners();
      } else {
        final message = (result?.message?.trim().isNotEmpty ?? false)
            ? result!.message!.trim()
            : 'Failed to upload banner. Please try again.';
        log('AddBannerCubit: Banner upload failed.');
        emit(AddBannerFailure(message: message));
      }
    } catch (e, stackTrace) {
      log('AddBannerCubit Add Banner Error: $e', stackTrace: stackTrace);
      emit(
        AddBannerFailure(
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  /// Uploads multiple banner images one-by-one.
  Future<void> addBanners({
    required List<MultipartFile> images,
  }) async {
    if (images.isEmpty) {
      emit(
        const AddBannerFailure(
          message: 'Please select at least one banner image.',
        ),
      );
      return;
    }

    if (images.length == 1) {
      await addBanner(image: images.first);
      return;
    }

    try {
      emit(const AddBannerLoading());

      log('AddBannerCubit: Uploading ${images.length} banners...');
      var successCount = 0;
      AddBannerModel? lastSuccess;
      String? lastError;

      for (var i = 0; i < images.length; i++) {
        final result = await addBannerRepository.addBanner(image: images[i]);
        if (result != null && result.status != false) {
          successCount++;
          lastSuccess = result;
        } else {
          lastError = (result?.message?.trim().isNotEmpty ?? false)
              ? result!.message!.trim()
              : 'Failed to upload banner ${i + 1}.';
          log('AddBannerCubit: Banner ${i + 1} failed: $lastError');
        }
      }

      if (successCount == images.length && lastSuccess != null) {
        emit(
          AddBannerSuccess(
            banner: lastSuccess,
            message: '$successCount banners uploaded successfully.',
            uploadedCount: successCount,
          ),
        );
        await fetchBanners();
      } else if (successCount > 0 && lastSuccess != null) {
        emit(
          AddBannerSuccess(
            banner: lastSuccess,
            message:
                'Uploaded $successCount of ${images.length} banners. ${lastError ?? ''}'
                    .trim(),
            uploadedCount: successCount,
          ),
        );
        await fetchBanners();
      } else {
        emit(
          AddBannerFailure(
            message: lastError ?? 'Failed to upload banners. Please try again.',
          ),
        );
      }
    } catch (e, stackTrace) {
      log('AddBannerCubit Add Banners Error: $e', stackTrace: stackTrace);
      emit(
        AddBannerFailure(
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> deleteBanner({required int bannerId}) async {
    if (bannerId <= 0) {
      emit(
        const DeleteBannerFailure(
          message: 'Invalid banner selected.',
        ),
      );
      return;
    }

    try {
      emit(DeleteBannerLoading(bannerId: bannerId));
      log('AddBannerCubit: Deleting banner id=$bannerId...');

      final result = await addBannerRepository.deleteBanner(
        bannerId: bannerId,
      );

      if (result != null && result.status != false) {
        _banners = _banners
            .where((banner) => banner.bannerId != bannerId)
            .toList(growable: false);
        _bannersFetched = true;

        final message = (result.message?.trim().isNotEmpty ?? false)
            ? result.message!.trim()
            : 'Banner deleted successfully.';

        log('AddBannerCubit: Banner deleted. id=$bannerId');
        emit(
          DeleteBannerSuccess(
            bannerId: bannerId,
            message: message,
          ),
        );
      } else {
        final message = (result?.message?.trim().isNotEmpty ?? false)
            ? result!.message!.trim()
            : 'Failed to delete banner. Please try again.';
        log('AddBannerCubit: Banner delete failed.');
        emit(DeleteBannerFailure(message: message));
      }
    } catch (e, stackTrace) {
      log('AddBannerCubit Delete Banner Error: $e', stackTrace: stackTrace);
      emit(
        DeleteBannerFailure(
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
