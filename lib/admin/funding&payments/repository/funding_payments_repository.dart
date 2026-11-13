import 'package:maribel_wellness_centre_application/core/utils/app_log.dart';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/funding_investor_list_model.dart';
import '../model/investor_details_models.dart';
import '../model/investor_payment_model.dart';
import '../model/investor_transaction_history_model.dart';
import '../model/update_due_dates_model.dart';

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
      appLog(
        'Add Investor Payment Error: ${e.message}; '
        'status=${e.response?.statusCode}; body=${e.response?.data}; '
        'request=${request.toJson()}',
      );
      rethrow;
    } catch (e) {
      appLog('Add Investor Payment Error: $e');
      rethrow;
    }
  }

  /// Fetches investors (with payment summary fields) via GetInvestors.
  Future<FundingInvestorsResponseModel> getFundingInvestors() async {
    try {
      final response = await dio.get(ApiEndpoints.investorsList);

      return FundingInvestorsResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      appLog('Get Funding Investors Error: ${e.message}');
      rethrow;
    } catch (e) {
      appLog('Get Funding Investors Error: $e');
      rethrow;
    }
  }

  Future<InvestorTransactionHistoryResponseModel>
  getAllInvestorTransactionHistory() async {
    try {
      final response = await dio.get(ApiEndpoints.transactionHistory);

      return InvestorTransactionHistoryResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      appLog('Get All Investor Transaction History Error: ${e.message}');


      rethrow;
    } catch (e) {
      appLog('Get All Investor Transaction History Error: $e');

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
      appLog('Get Investor Details Error: ${e.message}');
      rethrow;
    } catch (e) {
      appLog('Get Investor Details Error: $e');
      rethrow;
    }
  }


  Future<UpdateDueDatesResponseModel> updateDueDates({
    required int investorId,
    required int installmentNumber,
    required DateTime dueDate,
  }) async {
    try {
      appLog(
        'UpdateDueDates request: investorId=$investorId, '
            'installmentNumber=$installmentNumber, '
            'dueDate=${UpdateDueDatesRequestModel.toApiIsoString(dueDate)}',
        name: 'UpdateDueDatesAPI',
      );

      final request = UpdateDueDatesRequestModel(
        investorId: investorId,
        installmentNumber: installmentNumber,
        dueDate: dueDate,
      );

      final response = await dio.post(
        ApiEndpoints.updateDueDates,
        data: request.toJson(),
      );

      return UpdateDueDatesResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e, stackTrace) {
      appLog(
        'UpdateDueDates API error: '
            '${e.message}',
        name: 'UpdateDueDatesAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      appLog(
        'Unexpected UpdateDueDates error: $e',
        name: 'UpdateDueDatesAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
