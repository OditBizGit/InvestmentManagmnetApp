import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/investor_payment_model.dart';

class InvestorPaymentRepository {
  final Dio dio;

  InvestorPaymentRepository({
    required this.dio,
  });

  Future<AddInvestorPaymentResponseModel> addInvestorPayment(
      AddInvestorPaymentRequestModel request,
      ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.addInvestorPayment,
        data: request.toJson(),
      );

      return AddInvestorPaymentResponseModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      log(
        'Add Investor Payment Error: ${e.message}',
      );

      log(
        'Add Investor Payment Response: ${e.response?.data}',
      );

      rethrow;
    } catch (e) {
      log(
        'Add Investor Payment Error: $e',
      );

      rethrow;
    }
  }
}