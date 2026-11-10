import 'package:maribel_wellness_centre_application/core/utils/app_log.dart';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../models/add_banner_model.dart';
import '../models/banner_model.dart';
import '../models/delete_banner_model.dart';

class AddBannerRepository {
  final Dio dio;

  AddBannerRepository({required this.dio});

  Future<AddBannerModel?> addBanner({
    required MultipartFile image,
  }) async {
    try {
      final endpoint = ApiEndpoints.addBanner;

      final formData = FormData.fromMap({
        'Image': image,
      });

      appLog('Add Banner FormData field names: ${formData.fields.map((f) => f.key)}');


      final response = await dio.post(
        endpoint,
        data: formData,
      );


      if (response.data == null) {
        appLog('Add Banner failed: response data is null');
        appLog('========== ADD BANNER END (NULL DATA) ==========');
        return null;
      }

      final Map<String, dynamic> json;
      if (response.data is Map<String, dynamic>) {
        json = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        json = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        appLog('Add Banner: response is String, decoding JSON...');
        final decoded = jsonDecode(response.data as String);
        if (decoded is! Map) {
          appLog('Add Banner failed: decoded string is not a Map');
          appLog('========== ADD BANNER END (BAD STRING JSON) ==========');
          return null;
        }
        json = Map<String, dynamic>.from(decoded);
      } else {
        appLog(
          'Add Banner failed: unexpected response type '
          '${response.data.runtimeType}',
        );
        appLog('========== ADD BANNER END (BAD TYPE) ==========');
        return null;
      }

      final model = AddBannerModel.fromJson(json);


      final statusOk = response.statusCode == 200 || response.statusCode == 201;
      if (!statusOk) {
        return null;
      }

      return model;
    } on DioException {


      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<BannerModel>?> getBanners() async {
    try {
      appLog('Fetching banners...');

      final response = await dio.get(
        ApiEndpoints.getBanner,
      );


      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];

        return data
            .map((item) => BannerModel.fromJson(item))
            .toList();
      }

      appLog('Get Banners failed: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      appLog('Get Banners Dio Error: ${e.message}');
      return null;
    } catch (e) {
      appLog('Get Banners Error: $e');
      return null;
    }
  }


  Future<DeleteBannerModel?> deleteBanner({
    required int bannerId,
  }) async {
    try {
      appLog('Deleting banner...');
      appLog('Banner ID: $bannerId');

      final response = await dio.delete(
        ApiEndpoints.deleteBanner,
        data: {
          'bannerId': bannerId,
        },
      );


      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> json;
        if (response.data is Map<String, dynamic>) {
          json = response.data as Map<String, dynamic>;
        } else if (response.data is Map) {
          json = Map<String, dynamic>.from(response.data as Map);
        } else {
          appLog('Delete Banner failed: unexpected response type');
          return null;
        }

        final model = DeleteBannerModel.fromJson(json);
        // Prefer API bannerId; fall back to requested id when data is empty.
        if (model.bannerId == 0) {
          return DeleteBannerModel(
            bannerId: bannerId,
            status: model.status,
            message: model.message,
          );
        }
        return model;
      }

      appLog('Delete Banner failed: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      appLog('Delete Banner Dio Error: ${e.message}');
      return null;
    } catch (e) {
      appLog('Delete Banner Error: $e');
      return null;
    }
  }
}
