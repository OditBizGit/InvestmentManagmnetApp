import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_details_response_model.dart';

class ProfileRepository {
  ProfileRepository({
    required this.dio,
  });

  final Dio dio;

  Future<InvestorDetailsResponseModel> getInvestorDetails(String userId) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.investorDetails}$userId',
      );

      return InvestorDetailsResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      log('Get Investor Details Error: ${e.message}');
      rethrow;
    } catch (e) {
      log('Get Investor Details Error: $e');
      rethrow;
    }
  }
}
