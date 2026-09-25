import 'dart:convert';
import 'dart:developer';

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

      log('Add Banner FormData fields: ${formData.fields}');


      final response = await dio.post(
        endpoint,
        data: formData,
      );


      if (response.data == null) {
        log('Add Banner failed: response data is null');
        log('========== ADD BANNER END (NULL DATA) ==========');
        return null;
      }

      final Map<String, dynamic> json;
      if (response.data is Map<String, dynamic>) {
        json = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        json = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        log('Add Banner: response is String, decoding JSON...');
        final decoded = jsonDecode(response.data as String);
        if (decoded is! Map) {
          log('Add Banner failed: decoded string is not a Map');
          log('========== ADD BANNER END (BAD STRING JSON) ==========');
          return null;
        }
        json = Map<String, dynamic>.from(decoded);
      } else {
        log(
          'Add Banner failed: unexpected response type '
          '${response.data.runtimeType}',
        );
        log('========== ADD BANNER END (BAD TYPE) ==========');
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
      log('Fetching banners...');

      final response = await dio.get(
        ApiEndpoints.getBanner,
      );

      log('Get Banners Response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];

        return data
            .map((item) => BannerModel.fromJson(item))
            .toList();
      }

      log('Get Banners failed: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      log('Get Banners Dio Error: ${e.message}');
      log('Get Banners Response: ${e.response?.data}');
      return null;
    } catch (e) {
      log('Get Banners Error: $e');
      return null;
    }
  }


  Future<DeleteBannerModel?> deleteBanner({
    required int bannerId,
  }) async {
    try {
      log('Deleting banner...');
      log('Banner ID: $bannerId');

      final response = await dio.delete(
        ApiEndpoints.deleteBanner,
        data: {
          'bannerId': bannerId,
        },
      );

      log('Delete Banner Response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> json;
        if (response.data is Map<String, dynamic>) {
          json = response.data as Map<String, dynamic>;
        } else if (response.data is Map) {
          json = Map<String, dynamic>.from(response.data as Map);
        } else {
          log('Delete Banner failed: unexpected response type');
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

      log('Delete Banner failed: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      log('Delete Banner Dio Error: ${e.message}');
      log('Delete Banner Response: ${e.response?.data}');
      return null;
    } catch (e) {
      log('Delete Banner Error: $e');
      return null;
    }
  }
}
