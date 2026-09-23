import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/funding_investor_list_model.dart';
import '../model/investor_details_models.dart';
import '../model/investor_payment_model.dart';
import '../model/investor_transaction_history_model.dart';

class InvestorPaymentRepository {
  final Dio dio;

  InvestorPaymentRepository({required this.dio});

  Future<AddInvestorPaymentResponseModel> addInvestorPayment(
    AddInvestorPaymentRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.addInvestorPayment,
        data: request.toJson(),
      );

      return AddInvestorPaymentResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      log('Add Investor Payment Error: ${e.message}');

      log('Add Investor Payment Response: ${e.response?.data}');

      rethrow;
    } catch (e) {
      log('Add Investor Payment Error: $e');

      rethrow;
    }
  }

  /// Fetches investors (with payment summary fields) via GetInvestors.
  Future<FundingInvestorsResponseModel> getFundingInvestors() async {
    try {
      final response = await dio.get(ApiEndpoints.investorsList);

      return FundingInvestorsResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      log('Get Funding Investors Error: ${e.message}');
      log('Get Funding Investors Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      log('Get Funding Investors Error: $e');
      rethrow;
    }
  }

  Future<InvestorTransactionHistoryResponseModel>
  getAllInvestorTransactionHistory() async {
    try {
      final response = await dio.get(ApiEndpoints.transactionHistory);

      return InvestorTransactionHistoryResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      log('Get All Investor Transaction History Error: ${e.message}');

      log('Get All Investor Transaction History Response: ${e.response?.data}');

      rethrow;
    } catch (e) {
      log('Get All Investor Transaction History Error: $e');

      rethrow;
    }
  }

  Future<InvestorDetailsResponseModel> getInvestorDetails({
    required int userId,
  }) async {
    try {
      final response = await dio.get('${ApiEndpoints.investorDetails}$userId');
      final raw = response.data;
      if (raw is! Map) {
        return InvestorDetailsResponseModel(
          status: false,
          message: 'Unexpected response format',
          code: 0,
        );
      }

      return InvestorDetailsResponseModel.fromJson(
        Map<String, dynamic>.from(raw),
      );
    } on DioException catch (e) {
      log('Get Investor Details Error: ${e.message}');
      log('Get Investor Details Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      log('Get Investor Details Error: $e');
      rethrow;
    }
  }
}
