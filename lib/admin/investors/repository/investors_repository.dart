import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/investor_response_model.dart';

class InvestorsRepository {
  final Dio dio;

  InvestorsRepository({
    required this.dio,
  });

  Future<InvestorResponseModel> getInvestors() async {
    try {
      final response = await dio.get(
        ApiEndpoints.investorsList,
      );

      return InvestorResponseModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      log(
        'Get Investors Error: ${e.message}',
      );

      rethrow;
    } catch (e) {
      log(
        'Get Investors Error: $e',
      );

      rethrow;
    }
  }
}