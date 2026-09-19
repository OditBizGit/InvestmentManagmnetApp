import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/investor_transaction_history_response_model.dart';

class InvestmentsRepository {
  InvestmentsRepository({
    required this.dio,
  });

  final Dio dio;

  Future<InvestorTransactionHistoryResponseModel> getInvestorTransactionHistory(
    String userId,
  ) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.investorTransactionHistory}$userId',
      );

      return InvestorTransactionHistoryResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      log('Get Investor Transaction History Error: ${e.message}');
      rethrow;
    } catch (e) {
      log('Get Investor Transaction History Error: $e');
      rethrow;
    }
  }
}
