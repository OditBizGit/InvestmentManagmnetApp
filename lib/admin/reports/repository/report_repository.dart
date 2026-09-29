import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import '../model/funding_payment_overview_model.dart';
import '../model/investor_type_count_model.dart';

class ReportRepository {
  ReportRepository({
    required this.dio,
  });

  final Dio dio;

  Future<FundingPaymentOverviewModel> getFundingPaymentOverview({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      log('Fetching funding payment overview...');
      log('From Date: $fromDate');
      log('To Date: $toDate');

      final response = await dio.post(
        ApiEndpoints.fundingPaymentOverview,
        data: {
          'fromDate': fromDate,
          'toDate': toDate,
        },
      );

      log('Funding Payment Overview Response: ${response.data}');

      final body = response.data;
      if (response.statusCode != 200 || body is! Map) {
        throw Exception('Failed to load funding & payments overview');
      }

      final map = Map<String, dynamic>.from(body);
      final status = map['status'] ?? map['Status'];
      final isSuccess = status == true ||
          status == 1 ||
          status?.toString().toLowerCase() == 'true' ||
          status?.toString().toLowerCase() == 'success' ||
          response.statusCode == 200;

      final message =
          (map['message'] ?? map['Message'] ?? '').toString().trim();

      if (!isSuccess) {
        throw Exception(
          message.isNotEmpty
              ? message
              : 'Failed to load funding & payments overview',
        );
      }

      // Supports both:
      // 1) { data: [...], summary: [...] }
      // 2) { data: { data: [...], summary: [...] } }
      final rawData = map['data'] ?? map['Data'];
      if (rawData is Map) {
        return FundingPaymentOverviewModel.fromJson(
          Map<String, dynamic>.from(rawData),
        );
      }

      return FundingPaymentOverviewModel.fromJson(map);
    } on DioException catch (e) {
      log('Funding Payment Overview Dio Error: ${e.message}');
      log('Funding Payment Overview Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      log('Funding Payment Overview Error: $e');
      rethrow;
    }
  }

  Future<InvestorTypeCountModel> getInvestorTypeCount() async {
    try {
      log('Fetching investor type count...');

      final response = await dio.get(
        ApiEndpoints.investorTypeCount,
      );

      log('Investor Type Count Response: ${response.data}');

      final body = response.data;
      if (response.statusCode != 200 || body is! Map) {
        throw Exception('Failed to load investor summary');
      }

      final map = Map<String, dynamic>.from(body);
      final status = map['status'] ?? map['Status'];
      final isSuccess = status == true ||
          status == 1 ||
          status?.toString().toLowerCase() == 'true' ||
          status?.toString().toLowerCase() == 'success' ||
          response.statusCode == 200;

      final message =
          (map['m essage'] ?? map['Message'] ?? '').toString().trim();

      if (!isSuccess) {
        throw Exception(
          message.isNotEmpty
              ? message
              : 'Failed to load investor summary',
        );
      }

      final rawData = map['data'] ?? map['Data'];
      if (rawData is Map) {
        return InvestorTypeCountModel.fromJson(
          Map<String, dynamic>.from(rawData),
        );
      }

      // Empty / missing payload — treat as empty success for "No data found"
      if (rawData == null) {
        return InvestorTypeCountModel(
          totalInvestors: 0,
          investorTypes: const [],
        );
      }

      throw Exception(
        message.isNotEmpty
            ? message
            : 'Failed to load investor summary',
      );
    } on DioException catch (e) {
      log('Investor Type Count Dio Error: ${e.message}');
      log(
        'Investor Type Count Response: '
            '${e.response?.data}',
      );
      rethrow;
    } catch (e) {
      log('Investor Type Count Error: $e');
      rethrow;
    }
  }
}
