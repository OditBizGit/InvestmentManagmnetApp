import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';
import 'package:maribel_wellness_centre_application/user/home/model/banner_item_model.dart';
import 'package:maribel_wellness_centre_application/user/home/model/banners_response_model.dart';
import 'package:maribel_wellness_centre_application/user/home/model/home_profile_model.dart';
import 'package:maribel_wellness_centre_application/user/home/model/top_investor_model.dart';
import 'package:maribel_wellness_centre_application/user/home/model/top_investors_response_model.dart';
import 'package:maribel_wellness_centre_application/user/home/model/work_progress_details_response_model.dart';
import 'package:maribel_wellness_centre_application/user/home/model/work_progress_item_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/repository/profile_repository.dart';

class HomeRepository {
  HomeRepository({
    required LocalStorage localStorage,
    required ProfileRepository profileRepository,
    required Dio dio,
  })  : _localStorage = localStorage,
        _profileRepository = profileRepository,
        _dio = dio;

  final LocalStorage _localStorage;
  final ProfileRepository _profileRepository;
  final Dio _dio;

  Future<HomeProfileModel> getHomeProfile() async {
    final localProfile = _profileFromLocalStorage();

    final userId = _localStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      return localProfile;
    }

    final response = await _profileRepository.getInvestorDetails(userId);
    final details = response.data;
    if (details == null) {
      return localProfile;
    }

    final fullName = details.fullName.trim();
    final username = details.username.trim();
    final displayName = fullName.isNotEmpty
        ? fullName
        : (username.isNotEmpty ? username : localProfile.displayName);

    final investorCode = details.investorCode?.trim();

    return HomeProfileModel(
      displayName: displayName,
      investorCode: (investorCode != null && investorCode.isNotEmpty)
          ? investorCode
          : localProfile.investorCode,
      profileImageUrl:
          details.profileImageUrl ?? localProfile.profileImageUrl,
      totalCollection: details.totalPaidAmount,
      totalCommitment: details.investmentAmount,
    );
  }

  Future<List<TopInvestorModel>> getTopInvestors() async {
    try {
      final response = await _dio.get(ApiEndpoints.topInvestors);
      final parsed = TopInvestorsResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      final looksSuccessful = parsed.status ||
          parsed.code == 200 ||
          parsed.message.toLowerCase().contains('success');

      if (!looksSuccessful && parsed.data.isEmpty) {
        throw Exception(
          parsed.message.isNotEmpty
              ? parsed.message
              : 'Failed to load top investors',
        );
      }

      return parsed.data;
    } on DioException catch (e) {
      log('Get Top Investors Error: ${e.message}');
      rethrow;
    } catch (e) {
      log('Get Top Investors Error: $e');
      rethrow;
    }
  }

  Future<List<WorkProgressItemModel>> getWorkProgressDetails() async {
    try {
      final response = await _dio.get(ApiEndpoints.workProgressDetails);
      final parsed = WorkProgressDetailsResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      final looksSuccessful = parsed.status ||
          parsed.code == 200 ||
          parsed.message.toLowerCase().contains('success');

      if (!looksSuccessful && parsed.data.isEmpty) {
        throw Exception(
          parsed.message.isNotEmpty
              ? parsed.message
              : 'Failed to load work progress',
        );
      }

      return parsed.data;
    } on DioException catch (e) {
      log('Get Work Progress Details Error: ${e.message}');
      rethrow;
    } catch (e) {
      log('Get Work Progress Details Error: $e');
      rethrow;
    }
  }

  Future<List<BannerItemModel>> getBanners() async {
    try {
      final response = await _dio.get(ApiEndpoints.getBanners);
      final parsed = BannersResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      final looksSuccessful = parsed.status ||
          parsed.code == 200 ||
          parsed.message.toLowerCase().contains('success');

      if (!looksSuccessful && parsed.data.isEmpty) {
        throw Exception(
          parsed.message.isNotEmpty
              ? parsed.message
              : 'Failed to load banners',
        );
      }

      return parsed.data;
    } on DioException catch (e) {
      log('Get Banners Error: ${e.message}');
      rethrow;
    } catch (e) {
      log('Get Banners Error: $e');
      rethrow;
    }
  }

  HomeProfileModel _profileFromLocalStorage() {
    final fullName = _localStorage.getFullName()?.trim();
    final username = _localStorage.getUsername()?.trim();
    final displayName = (fullName != null && fullName.isNotEmpty)
        ? fullName
        : (username != null && username.isNotEmpty ? username : 'Investor');

    final investorCode = _localStorage.getInvestorCode()?.trim();

    return HomeProfileModel(
      displayName: displayName,
      investorCode:
          (investorCode != null && investorCode.isNotEmpty) ? investorCode : null,
      profileImageUrl: resolveMediaUrl(_localStorage.getProfileImage()),
    );
  }
}
